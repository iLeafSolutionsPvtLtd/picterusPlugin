part of 'camera.dart';

class CameraException implements Exception {
    CameraException(this.code, this.description);

    String code;
    String description;

    @override
    String toString() => '$runtimeType($code, $description)';
}

