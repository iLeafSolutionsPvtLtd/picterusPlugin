package com.picterus.picteruscamera;

import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.ImageFormat;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.util.Size;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import io.fotoapparat.Fotoapparat;
import io.fotoapparat.parameter.Flash;
import io.fotoapparat.parameter.FocusMode;
import io.fotoapparat.parameter.Resolution;
import io.fotoapparat.result.BitmapPhoto;
import io.fotoapparat.selector.FlashSelectorsKt;
import io.fotoapparat.selector.FocusModeSelectorsKt;
import io.fotoapparat.selector.LensPositionSelectorsKt;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** PicterusCameraPlugin */
public class PicterusCameraPlugin implements MethodCallHandler {
    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "camera.picterus.com");
        channel.setMethodCallHandler(new PicterusCameraPlugin());
        context_ = registrar.activeContext().getApplicationContext();
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
        } else if (call.method.equals("initialize")) {
        } else if (call.method.equals("updateConfiguration")) {
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
}
