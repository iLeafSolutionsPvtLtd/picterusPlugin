library picterus_camera;

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'dart:async';

part 'src/native_bridge.dart';
part 'camera_view.dart';
part 'configuration.dart';
part 'device.dart';
part 'exception.dart';
part 'geometry.dart';
part 'image.dart';

class Camera {
    Camera() {
        cameraView = CameraView(this);
    }

    Future<void> initialize(PreviewConfiguration config) async {
        try {
            NativeBridge.instance.setMethodCallHandler(_nativeHandler);
            NativeBridge.instance.invokeMethod('initialize', config.toNative);
            configuration = config;
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    Future<List<FlashlightMode>> get flashlightModes async {
        try {
            final List<dynamic> fs = await NativeBridge.instance.invokeMethod('flashlightModes');
            return fs.map((dynamic mode) {
                return FlashlightMode.fromNative(mode);
            }).toList();
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    Future<Size> get sensorSize async {
        try {
            final Map<dynamic, dynamic> s = await NativeBridge.instance.invokeMethod('sensorSize');
            return Size.fromNative(s);
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    Future<void> switchDevice() async {
        try {
            NativeBridge.instance.invokeMethod('switchDevice');
            configuration.device = configuration.device == Device.back() ? Device.front() : Device.back();
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    Future<void> changeZoomFactor(double zoom) async {
        try {
            NativeBridge.instance.invokeMethod('changeZoomFactor', zoom);
            configuration.zoomFactor = zoom;
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    Future<void> capture(CaptureConfiguration config, Function(String) completion) async {
        try {
            _captureCompletion = completion;
            NativeBridge.instance.invokeMethod('capture', config.toNative);
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    Future<void> startStreaming(Function(ImageData) streamCompletion) async {
        try {
            _streamCompletion = streamCompletion;
            NativeBridge.instance.invokeMethod('startStreaming');
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    Future<void> stopStreaming() async {
        try {
            _streamCompletion = null;
            NativeBridge.instance.invokeMethod('stopStreaming');
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    Future<dynamic> _nativeHandler(MethodCall call) async {
        switch (call.method) {
            case 'captureFinished':
                _captureCompletion(call.arguments);
                break;
            case 'frameStreamed':
                final d = ImageData.fromNative(call.arguments);
                if (_streamCompletion != null) {
                    _streamCompletion(d);
                }
                NativeBridge.instance.invokeMethod('releaseFrame', d.buffer);
                break;
            default:
                break;
        }
        return true;
    }

    CameraView cameraView;
    PreviewConfiguration configuration;
    Function(String) _captureCompletion;
    Function(ImageData) _streamCompletion;
}
