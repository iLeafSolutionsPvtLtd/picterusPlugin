part of 'camera.dart';

class Plane {
  Plane.fromNative(Map<dynamic, dynamic> data)
      : bytes = data['bytes']
      , bytesPerRow = data['bytesPerRow']
      , height = data['height']
      , width = data['width'];

  final Uint8List bytes;
  final int bytesPerRow;
  final int width;
  final int height;
}

class ImageFormat {
    ImageFormat.yuv420() : _value = "yuv420";
    ImageFormat.fromNative(String s) : _value = s;

    String _value;
}

class CameraImage {
    CameraImage.fromNative(Map<dynamic, dynamic> data)
            : format = ImageFormat.fromNative(data['format'])
            , height = data['height']
            , width = data['width']
            , planes = List<Plane>.unmodifiable(data['planes'].map((dynamic planeData) => Plane.fromNative(planeData)));

    final ImageFormat format;
    final int width;
    final int height;
    final List<Plane> planes;
}