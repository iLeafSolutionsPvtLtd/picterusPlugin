import 'src/native_bridge.dart';
import 'configuration.dart';
import 'exception.dart';

import 'dart:async';

import 'package:flutter/services.dart';

class Camera {
    Camera(PreviewConfiguration config) : _config = config, _textureID = -1 {
    }

    Future<void> initialize() async {
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
        try {
            await NativeBridge.instance.invokeMethod('updateConfiguration', _config.toNative);
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
        _config = config;
    }

    Future<void> capture(CaptureConfiguration config) async {
        try {
            await NativeBridge.instance.invokeMethod('capture', config.toNative);
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    PreviewConfiguration _config;
    int _textureID;
}
