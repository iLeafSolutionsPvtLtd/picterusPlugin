library picterus_camera;

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:typed_data';

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
            NativeBridge.instance.invokeMethod('initialize', config.toNative);
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    Future<void> switchDevice() async {
        try {
            NativeBridge.instance.invokeMethod('switchDevice');
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    Future<void> changeZoomFactor(double zoom) async {
        try {
            NativeBridge.instance.invokeMethod('changeZoomFactor', zoom);
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    Future<void> capture(CaptureConfiguration config) async {
        try {
            await NativeBridge.instance.invokeMethod('capture', config.toNative);
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    CameraView cameraView;
}
