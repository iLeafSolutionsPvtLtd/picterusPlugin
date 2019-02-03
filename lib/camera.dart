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
    Camera(PreviewConfiguration config) : _config = config {
        cameraView = CameraView(this);
    }

    Future<void> initialize() async {
        try {
            await NativeBridge.instance.invokeMethod('initialize', _config.toNative);
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    PreviewConfiguration get currentConfiguration {
        return _config;
    }

    Future<void> updateConfiguration(PreviewConfiguration config) async {
        /// TODO
        try {
            await NativeBridge.instance.invokeMethod('updateConfiguration', _config.toNative);
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
        _config = config;
    }

    Future<void> capture(CaptureConfiguration config) async {
        /// TODO
        try {
            await NativeBridge.instance.invokeMethod('capture', config.toNative);
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    PreviewConfiguration _config;
    CameraView cameraView;
}
