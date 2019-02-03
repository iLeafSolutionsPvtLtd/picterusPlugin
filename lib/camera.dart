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
    Camera(PreviewConfiguration config) : _config = config, _textureID = -1;

    Future<void> initialize() async {
        /// TODO
        try {
            final Map<dynamic, dynamic> reply = await NativeBridge.instance.invokeMethod('initialize', _config.toNative);
            _textureID = reply['texture'];
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

    Future<void> focus(Point point) async {
        /// TODO
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
    int _textureID;
}
