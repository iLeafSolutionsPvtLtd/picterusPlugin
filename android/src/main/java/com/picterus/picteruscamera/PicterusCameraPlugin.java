package com.picterus.picteruscamera;

import android.content.Context;
import android.graphics.ImageFormat;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.util.Size;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import io.fotoapparat.Fotoapparat;
import io.fotoapparat.FotoapparatBuilder;
import io.fotoapparat.configuration.CameraConfiguration;
import io.fotoapparat.selector.LensPositionSelectorsKt;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.fotoapparat.view.CameraView;

public class PicterusCameraPlugin implements MethodCallHandler {
    public static enum Device {
        front,
        back
    }

    public static enum FocusMode {
        off,
        auto,
        manual
    }

    public class PreviewConfiguration {
        Device device;
        FocusMode focusMode;
        Size size;
    }

    final static PicterusCameraPlugin sharedInstance = new PicterusCameraPlugin();

    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "camera.picterus.com");
        channel.setMethodCallHandler(sharedInstance);
        context_ = registrar.activeContext().getApplicationContext();
        registrar.platformViewRegistry().registerViewFactory("CameraView", new PicterusCameraViewFactory());
    }

    public void registerPreviewView(PicterusCameraView view) {
        preview_ = view;
        if (builder_ != null) {
            builder_.into((CameraView)preview_.getView());
            fotoapparat_ = builder_.build();
            fotoapparat_.start();
            builder_ = null;
        }
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("devices")) {
            CameraManager m = (CameraManager)context_.getSystemService(Context.CAMERA_SERVICE);
            try {
                ArrayList<String> r = new ArrayList<>();
                String[] ids = m.getCameraIdList();
                for (String id : ids) {
                    CameraCharacteristics cs = m.getCameraCharacteristics(id);
                    switch (cs.get(CameraCharacteristics.LENS_FACING)) {
                        case CameraMetadata.LENS_FACING_BACK:
                            r.add("back");
                            break;
                        case CameraMetadata.LENS_FACING_FRONT:
                            r.add("front");
                            break;
                    }
                }
                result.success(r);
            } catch (CameraAccessException e) {
                result.error(e.getLocalizedMessage(), null, null);
            }
        } else if (call.method.equals("sizes")) {
            String s = call.arguments();
            String id = deviceFromString(s);
            CameraManager m = (CameraManager)context_.getSystemService(Context.CAMERA_SERVICE);
            try {
                ArrayList<Map<String, Double>> r = new ArrayList<>();
                CameraCharacteristics cs = m.getCameraCharacteristics(id);
                StreamConfigurationMap map = cs.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
                if (map != null) {
                    Size[] sizes = map.getOutputSizes(ImageFormat.JPEG);
                    for (Size ss : sizes) {
                        HashMap<String, Double> h = new HashMap<>();
                        h.put("width", (double)ss.getWidth());
                        h.put("height", (double)ss.getHeight());
                        r.add(h);
                    }
                }
                result.success(r);
            } catch (CameraAccessException e) {
                result.error(e.getLocalizedMessage(), null, null);
            }
        } else if (call.method.equals("flashlightModes")) {
            String s = call.arguments();
            String id = deviceFromString(s);
            CameraManager m = (CameraManager)context_.getSystemService(Context.CAMERA_SERVICE);
            try {
                ArrayList<String> r = new ArrayList<>();
                CameraCharacteristics cs = m.getCameraCharacteristics(id);
                if (cs.get(CameraCharacteristics.FLASH_INFO_AVAILABLE)) {
                    r.add("off");
                    r.add("on");
                    r.add("auto");
                } else {
                    r.add("off");
                }
                result.success(r);
            } catch (CameraAccessException e) {
                result.error(e.getLocalizedMessage(), null, null);
            }
        } else if (call.method.equals("focusModes")) {
            String s = call.arguments();
            String id = deviceFromString(s);
            CameraManager m = (CameraManager)context_.getSystemService(Context.CAMERA_SERVICE);
            try {
                ArrayList<String> r = new ArrayList<>();
                CameraCharacteristics cs = m.getCameraCharacteristics(id);
                int[] modes = cs.get(CameraCharacteristics.CONTROL_AF_AVAILABLE_MODES);
                for (int mode : modes) {
                    switch (mode) {
                        case CameraCharacteristics.CONTROL_AF_MODE_OFF:
                            r.add("off");
                            break;
                        case CameraCharacteristics.CONTROL_AF_MODE_AUTO:
                            r.add("auto");
                            break;
                        case CameraCharacteristics.CONTROL_AF_MODE_CONTINUOUS_PICTURE:
                            r.add("manual");
                            break;
                        default:
                            break;
                    }
                }
                result.success(r);
            } catch (CameraAccessException e) {
                result.error(e.getLocalizedMessage(), null, null);
            }
        } else if (call.method.equals("initialize")) {
            Map<String, Object> m = (Map)call.arguments;
            String d = (String)m.get("device");
            builder_ = new FotoapparatBuilder(context_).
                    lensPosition(d.equals("back") ? LensPositionSelectorsKt.back()
                            : LensPositionSelectorsKt.front());
            if (preview_ != null) {
                builder_.into((CameraView)preview_.getView());
                fotoapparat_ = builder_.build();
                fotoapparat_.start();
                builder_ = null;
            }
        } else if (call.method.equals("updateConfiguration")) {
            Map<String, Object> m = (Map)call.arguments;
            String d = (String)m.get("device");
            fotoapparat_.switchTo(d.equals("back") ? LensPositionSelectorsKt.back()
                    : LensPositionSelectorsKt.front(), new CameraConfiguration());
        } else if (call.method.equals("capture")) {
        } else {
            result.notImplemented();
        }
    }

    private String deviceFromString(String s) {
        CameraManager m = (CameraManager)context_.getSystemService(Context.CAMERA_SERVICE);
        try {
            String[] ids = m.getCameraIdList();
            for (String id : ids) {
                CameraCharacteristics cs = m.getCameraCharacteristics(id);
                switch (cs.get(CameraCharacteristics.LENS_FACING)) {
                    case CameraMetadata.LENS_FACING_BACK:
                        if (s.equals("back")) {
                            return id;
                        }
                        break;
                    case CameraMetadata.LENS_FACING_FRONT:
                        if (s.equals("front")) {
                            return id;
                        }
                }
            }
        } catch (CameraAccessException e) {
        }
        return "";
    }

    private static Context context_;
    private Fotoapparat fotoapparat_;
    private FotoapparatBuilder builder_;
    private PicterusCameraView preview_;
}
