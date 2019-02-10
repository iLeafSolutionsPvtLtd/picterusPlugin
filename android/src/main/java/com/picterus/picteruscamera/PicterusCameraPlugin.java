package com.picterus.picteruscamera;

import static android.view.OrientationEventListener.ORIENTATION_UNKNOWN;

import android.Manifest;
import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.graphics.Camera;
import android.graphics.ImageFormat;
import android.graphics.Point;
import android.graphics.Rect;
import android.graphics.SurfaceTexture;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.media.ImageReader;
import android.os.Build;
import android.os.Bundle;
import android.util.Size;
import android.view.OrientationEventListener;
import android.view.Surface;
import android.view.TextureView;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class PicterusCameraPlugin implements MethodCallHandler {
    private static final int CAMERA_REQUEST_ID = 19870908;
    private class CameraRequestPermissionsListener implements PluginRegistry.RequestPermissionsResultListener {
        @Override
        public boolean onRequestPermissionsResult(int id, String[] permissions, int[] grantResults) {
            if (id == CAMERA_REQUEST_ID) {
                cameraPermissionContinuation_.run();
                return true;
            }
            return false;
        }
    }

    static PicterusCameraPlugin sharedInstance;

    private PicterusCameraPlugin(Registrar registrar) {
        registrar_ = registrar;
        activity_ = registrar_.activity();
        context_ = registrar.activeContext().getApplicationContext();
        cameraManager_ = (CameraManager) activity_.getSystemService(Context.CAMERA_SERVICE);
        orientationEventListener_ = new OrientationEventListener(context_) {
            @Override
            public void onOrientationChanged(int i) {
                if (i == ORIENTATION_UNKNOWN) {
                    return;
                }
                currentOrientation_ = (int) Math.round(i / 90.0) * 90;
            }
        };
        registrar.addRequestPermissionsResultListener(new CameraRequestPermissionsListener());
        this.activityLifecycleCallbacks_ =
                new Application.ActivityLifecycleCallbacks() {
                    @Override
                    public void onActivityCreated(Activity activity, Bundle savedInstanceState) {}

                    @Override
                    public void onActivityStarted(Activity activity) {}

                    @Override
                    public void onActivityResumed(Activity activity) {
                        if (requestingPermission_) {
                            requestingPermission_ = false;
                            return;
                        }
                        if (activity == PicterusCameraPlugin.this.activity_) {
                            orientationEventListener_.enable();
                            if (!cameraName.isEmpty()) {
                                openCamera(null);
                            }
                        }
                    }

                    @Override
                    public void onActivityPaused(Activity activity) {
                        if (activity == PicterusCameraPlugin.this.activity_) {
                            orientationEventListener_.disable();
                            if (!cameraName.isEmpty()) {
                                closeCamera();
                            }
                        }
                    }

                    @Override
                    public void onActivityStopped(Activity activity) {
                        if (activity == PicterusCameraPlugin.this.activity_) {
                            if (!cameraName.isEmpty()) {
                                closeCamera();
                            }
                        }
                    }

                    @Override
                    public void onActivitySaveInstanceState(Activity activity, Bundle outState) {}

                    @Override
                    public void onActivityDestroyed(Activity activity) {}
                };
    }

    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        sharedInstance = new PicterusCameraPlugin(registrar);
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "camera.picterus.com");
        channel.setMethodCallHandler(sharedInstance);
        registrar.platformViewRegistry().registerViewFactory("CameraView", new PicterusCameraViewFactory());
    }

    public void registerPreviewView(PicterusCameraView view) {
        preview_ = view;
        ((TextureView)view.getView()).setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {
            @Override
            public void onSurfaceTextureAvailable(SurfaceTexture surfaceTexture, int i, int i1) {
                if (cameraDevice != null) {
                    try {
                        startPreview();
                    } catch (CameraAccessException e) {
                    }
                }
            }

            @Override
            public void onSurfaceTextureSizeChanged(SurfaceTexture surfaceTexture, int i, int i1) {
                if (cameraDevice != null) {
                    try {
                        startPreview();
                    } catch (CameraAccessException e) {
                    }
                }
            }

            @Override
            public boolean onSurfaceTextureDestroyed(SurfaceTexture surfaceTexture) {
                return false;
            }

            @Override
            public void onSurfaceTextureUpdated(SurfaceTexture surfaceTexture) {

            }
        });
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("devices")) {
            try {
                ArrayList<String> r = new ArrayList<>();
                String[] ids = cameraManager_.getCameraIdList();
                for (String id : ids) {
                    CameraCharacteristics cs = cameraManager_.getCameraCharacteristics(id);
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
            try {
                ArrayList<Map<String, Double>> r = new ArrayList<>();
                CameraCharacteristics cs = cameraManager_.getCameraCharacteristics(id);
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
            try {
                ArrayList<String> r = new ArrayList<>();
                CameraCharacteristics cs = cameraManager_.getCameraCharacteristics(id);
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
            try {
                ArrayList<String> r = new ArrayList<>();
                CameraCharacteristics cs = cameraManager_.getCameraCharacteristics(id);
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
        } else if (call.method.equals("maxZoomFactor")) {
            String s = call.arguments();
            String id = deviceFromString(s);
            try {
                CameraCharacteristics cs = cameraManager_.getCameraCharacteristics(id);
                double modes = cs.get(CameraCharacteristics.SCALER_AVAILABLE_MAX_DIGITAL_ZOOM);
                result.success(modes);
            } catch (CameraAccessException e) {
                result.error(e.getLocalizedMessage(), null, null);
            }
        } else if (call.method.equals("initialize")) {
            Map<String, Object> m = (Map)call.arguments;
            if (cameraDevice != null) {
                closeCamera();
            }
            initializeCamera(m, result);
            this.activity_.getApplication().registerActivityLifecycleCallbacks(this.activityLifecycleCallbacks_);
            orientationEventListener_.enable();
        } else if (call.method.equals("switchDevice")) {
            final Map<String, Object> m = configuration;
            String d = (String)m.get("device");
            m.put("device", d == "back" ? "front" : "back");
            initializeCamera(m, result);
        } else if (call.method.equals("changeZoomFactor")) {
            double z = (double)call.arguments;
            try {
                captureRequestBuilder.set(
                        CaptureRequest.CONTROL_MODE, CameraMetadata.CONTROL_MODE_AUTO);
                CameraCharacteristics characteristics = cameraManager_.getCameraCharacteristics(cameraName);
                Rect m = characteristics.get(CameraCharacteristics.SENSOR_INFO_ACTIVE_ARRAY_SIZE);

                int w = (int)(m.width() / z);
                int h = (int)(m.height() / z);
                w -= w & 3;
                h -= h & 3;
                Point c = new Point(m.centerX(), m.centerY());

                Rect zoom = new Rect(c.x - w / 2, c.y - h / 2, c.x + w / 2, c.y + h / 2);
                captureRequestBuilder.set(CaptureRequest.SCALER_CROP_REGION, zoom);
                cameraCaptureSession.setRepeatingRequest(captureRequestBuilder.build(), null, null);
            } catch (CameraAccessException e) {
            }
        } else if (call.method.equals("capture")) {
        } else {
            result.notImplemented();
        }
    }

    private String deviceFromString(String s) {
        try {
            String[] ids = cameraManager_.getCameraIdList();
            for (String id : ids) {
                CameraCharacteristics cs = cameraManager_.getCameraCharacteristics(id);
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

    private void initializeCamera(final Map<String, Object> arguments, @NonNull final Result result) {
        if (cameraDevice != null) {
            closeCamera();
        }
        cameraName = deviceFromString((String)arguments.get("device"));
        Map<String, Object> s = (Map<String, Object>)arguments.get("size");
        double w = (double)s.get("width");
        double h = (double)s.get("height");
        previewSize = new Size((int)w, (int)h);
        String focus = (String)arguments.get("focus");
        double zoom = (double)arguments.get("zoomFactor");
        configuration = arguments;

        try {
            CameraCharacteristics characteristics = cameraManager_.getCameraCharacteristics(cameraName);
            StreamConfigurationMap streamConfigurationMap =
                    characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
            sensorOrientation = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION);
            if (cameraPermissionContinuation_ != null) {
                result.error("cameraPermission", "Camera permission request ongoing", null);
            }
            cameraPermissionContinuation_ =
                    new Runnable() {
                        @Override
                        public void run() {
                            cameraPermissionContinuation_ = null;
                            if (!hasCameraPermission()) {
                                result.error(
                                        "cameraPermission", "MediaRecorderCamera permission not granted", null);
                                return;
                            }
                            if (!hasAudioPermission()) {
                                result.error(
                                        "cameraPermission", "MediaRecorderAudio permission not granted", null);
                                return;
                            }
                            openCamera(result);
                        }
                    };
            requestingPermission_ = false;
            if (hasCameraPermission() && hasAudioPermission()) {
                cameraPermissionContinuation_.run();
            } else {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    requestingPermission_ = true;
                    activity_.requestPermissions(
                                    new String[] {Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO},
                                    CAMERA_REQUEST_ID);
                }
            }
        } catch (CameraAccessException e) {
            result.error("CameraAccess", e.getMessage(), null);
        } catch (IllegalArgumentException e) {
            result.error("IllegalArgumentException", e.getMessage(), null);
        }
    }

    private void openCamera(@Nullable final Result result) {
        if (!hasCameraPermission()) {
            if (result != null) {
                result.error("cameraPermission", "Camera permission not granted", null);
            }
        } else {
            try {
                imageStreamReader = ImageReader.newInstance(
                                previewSize.getWidth(), previewSize.getHeight(), ImageFormat.YUV_420_888, 2);
                cameraManager_.openCamera(
                        cameraName,
                        new CameraDevice.StateCallback() {
                            @Override
                            public void onOpened(@NonNull CameraDevice cameraDevice) {
                                PicterusCameraPlugin.this.cameraDevice = cameraDevice;
                                if (preview_ != null) {
                                    try {
                                        startPreview();
                                    } catch (CameraAccessException e) {
                                        if (result != null)
                                            result.error("CameraAccess", e.getMessage(), null);
                                        cameraDevice.close();
                                        PicterusCameraPlugin.this.cameraDevice = null;
                                        return;
                                    }
                                }

                                if (result != null) {
                                    Map<String, Object> reply = new HashMap<>();
                                    reply.put("previewWidth", previewSize.getWidth());
                                    reply.put("previewHeight", previewSize.getHeight());
                                    result.success(reply);
                                }
                            }

                            @Override
                            public void onClosed(@NonNull CameraDevice camera) {
                                super.onClosed(camera);
                            }

                            @Override
                            public void onDisconnected(@NonNull CameraDevice cameraDevice) {
                                cameraDevice.close();
                                PicterusCameraPlugin.this.cameraDevice = null;
                            }

                            @Override
                            public void onError(@NonNull CameraDevice cameraDevice, int errorCode) {
                                cameraDevice.close();
                                PicterusCameraPlugin.this.cameraDevice = null;
                                String errorDescription;
                                switch (errorCode) {
                                    case ERROR_CAMERA_IN_USE:
                                        errorDescription = "The camera device is in use already.";
                                        break;
                                    case ERROR_MAX_CAMERAS_IN_USE:
                                        errorDescription = "Max cameras in use";
                                        break;
                                    case ERROR_CAMERA_DISABLED:
                                        errorDescription =
                                                "The camera device could not be opened due to a device policy.";
                                        break;
                                    case ERROR_CAMERA_DEVICE:
                                        errorDescription = "The camera device has encountered a fatal error";
                                        break;
                                    case ERROR_CAMERA_SERVICE:
                                        errorDescription = "The camera service has encountered a fatal error.";
                                        break;
                                    default:
                                        errorDescription = "Unknown camera error";
                                }
                            }
                        },
                        null);
            } catch (CameraAccessException e) {
                if (result != null) {
                    result.error("cameraAccess", e.getMessage(), null);
                }
            }
        }
    }

    private void closeCamera() {
        closeCaptureSession();
        if (cameraDevice != null) {
            cameraDevice.close();
            cameraDevice = null;
        }
        if (imageStreamReader != null) {
            imageStreamReader.close();
            imageStreamReader = null;
        }
    }

    private void startPreview() throws CameraAccessException {
        closeCaptureSession();

        final PicterusCameraView.PicterusTextureView view =
                (PicterusCameraView.PicterusTextureView)preview_.getView();
        SurfaceTexture surfaceTexture = view.getSurfaceTexture();
        surfaceTexture.setDefaultBufferSize(previewSize.getWidth(), previewSize.getHeight());
        captureRequestBuilder = cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);

        List<Surface> surfaces = new ArrayList<>();

        Surface previewSurface = new Surface(surfaceTexture);
        surfaces.add(previewSurface);
        captureRequestBuilder.addTarget(previewSurface);

        surfaces.add(imageStreamReader.getSurface());

        cameraDevice.createCaptureSession(
                surfaces,
                new CameraCaptureSession.StateCallback() {

                    @Override
                    public void onConfigured(@NonNull CameraCaptureSession session) {
                        if (cameraDevice == null) {
                            return;
                        }
                        try {
                            int orientation = activity_.getResources().getConfiguration().orientation;
                            if (orientation == Configuration.ORIENTATION_LANDSCAPE) {
                                view.setAspectRatio(previewSize.getWidth(), previewSize.getHeight());
                            } else {
                                view.setAspectRatio(previewSize.getHeight(), previewSize.getWidth());
                            }
                            cameraCaptureSession = session;
                            captureRequestBuilder.set(CaptureRequest.CONTROL_MODE, CameraMetadata.CONTROL_MODE_AUTO);
                            cameraCaptureSession.setRepeatingRequest(captureRequestBuilder.build(), null, null);
                        } catch (CameraAccessException e) {
                        }
                    }

                    @Override
                    public void onConfigureFailed(@NonNull CameraCaptureSession cameraCaptureSession) {
                    }
                },
                null);
    }

    private void closeCaptureSession() {
        if (cameraCaptureSession != null) {
            cameraCaptureSession.close();
            cameraCaptureSession = null;
        }
    }

    private boolean hasCameraPermission() {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M
                || activity_.checkSelfPermission(Manifest.permission.CAMERA)
                == PackageManager.PERMISSION_GRANTED;
    }

    private boolean hasAudioPermission() {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M
                || activity_.checkSelfPermission(Manifest.permission.RECORD_AUDIO)
                == PackageManager.PERMISSION_GRANTED;
    }

    private Context context_;
    private Registrar registrar_;
    private Activity activity_;
    private CameraManager cameraManager_;
    private final OrientationEventListener orientationEventListener_;
    private int currentOrientation_ = ORIENTATION_UNKNOWN;
    private Runnable cameraPermissionContinuation_;
    private boolean requestingPermission_;
    private Application.ActivityLifecycleCallbacks activityLifecycleCallbacks_;

    private PicterusCameraView preview_;

    private CameraDevice cameraDevice;
    private CameraCaptureSession cameraCaptureSession;
    private CaptureRequest.Builder captureRequestBuilder;
    private ImageReader imageStreamReader;
    private int sensorOrientation;
    private String cameraName;
    private Size previewSize;
    private Map<String, Object> configuration;
}
