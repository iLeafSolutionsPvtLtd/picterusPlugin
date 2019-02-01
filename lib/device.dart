part of 'camera.dart';

class Device {
    Device.front() : _isFront = true;

    Device.back() : _isFront = false;

    Device.fromNative(String s) : _isFront = s == 'front' ? true : false;

    String get toNative {
        return _isFront == true ? 'front' : 'back';
    }

    Future<List<Size>> get sizes async {
        try {
            final List<dynamic> ss = await NativeBridge.instance.invokeMethod('sizes', this.toNative);
            return ss.map((dynamic size) {
                return Size.fromNative(size);
            }).toList();
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    Future<List<FlashlightMode>> get flashlightModes async {
        try {
            final List<dynamic> fs = await NativeBridge.instance.invokeMethod('flashlightModes', this.toNative);
            return fs.map((dynamic mode) {
                return FlashlightMode.fromNative(mode);
            }).toList();
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    static Future<List<Device>> get devices async {
        try {
            final List<dynamic> ds = await NativeBridge.instance.invokeMethod('devices');
            return ds.map((dynamic device) {
                return Device.fromNative(device);
            }).toList();
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    final bool _isFront;
}
