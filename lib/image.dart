part of 'camera.dart';

class ImageData {
    int buffer;
    int rotation;

    ImageData(this.buffer, this.rotation);
    ImageData.nil() : this(0, 0);
    ImageData.fromNative(Map<dynamic, dynamic> data) : this(data['buffer'], data['rotation']);

    Map<String, int> get toNative {
        return {'buffer': buffer, 'rotation': rotation};
    }
}