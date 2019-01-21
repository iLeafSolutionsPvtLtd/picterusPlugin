import 'geometry.dart';

import 'dart:async';

import 'package:flutter/services.dart';

final MethodChannel _channel = const MethodChannel('camera.picterus.com');

class CameraException implements Exception {
    CameraException(this.code, this.description);

    String code;
    String description;

    @override
    String toString() => '$runtimeType($code, $description)';
}

enum CameraPosition {
    front,
    back
}

CameraPosition _fromString(String s) {
    if (s == "front") {
        return CameraPosition.front;
    }
    return CameraPosition.back;
}

String _toString(CameraPosition p) {
    if (p == CameraPosition.front) {
        return "front";
    }
    return "back";
}

enum CameraFlashlight {
    off,
    on,
    auto
}

enum CameraFocusMode {
    continuous,
    manual
}

class CameraConfiguration
{
    CameraPosition position;
    CameraFlashlight flashlight;
    CameraFocusMode focusMode;
    Size previewSize;
    Size captureSize;

    Map<String, dynamic> get toMap {
        return {
            'position': _toString(position),
            'previewSize': previewSize.toMap,
        };
    }
}

class PicterusCamera {
    PicterusCamera() {
    }

    static Future<List<CameraPosition>> get cameras async {
        try {
            final List<dynamic> cs = await _channel.invokeMethod('cameras');
            return cs.map((dynamic camera) {
                return _fromString(camera);
            }).toList();
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    static Future<List<Size>> get previewSizes async {
        try {
            final List<dynamic> ss = await _channel.invokeMethod('sizes');
            return ss.map((dynamic size) {
                return Size.fromMap(size);
            }).toList();
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    Future<void> initialize(CameraConfiguration config) async {
        try {
            await _channel.invokeMethod('initialize', config.toMap);
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }
}
