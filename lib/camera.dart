import 'src/native_bridge.dart';
import 'configuration.dart';

import 'dart:async';

class Camera {
    Camera(PreviewConfiguration config) : _config = config {
    }

    Future<void> initialize() async {
    }

    PreviewConfiguration get currentConfiguration {
        return _config;
    }

    Future<void> updateConfiguration(PreviewConfiguration config) async {
        _config = config;
    }

    PreviewConfiguration _config;
}
