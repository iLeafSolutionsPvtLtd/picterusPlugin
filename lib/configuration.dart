part of 'camera.dart';

class PreviewConfiguration {
    Device device;
    Size size;
    bool autofocus;

    PreviewConfiguration(this.device, this.size, this.autofocus);

    PreviewConfiguration.device(Device device) : this(device, Size.zero(), true);

    PreviewConfiguration.fromNative(Map<String, dynamic> m)
            : this(Device.fromNative(m['device']), Size.fromNative(m['size']), m['autofocus']);

    Map<String, dynamic> get toNative {
        return <String, dynamic>{
            'device' : device.toNative,
            'size' : size.toNative,
            'autofocus' : autofocus
        };
    }

    PreviewConfiguration copyWith({
        Device device,
        Size size,
        bool autofocus
    }) {
        return PreviewConfiguration(device, size ?? this.size, autofocus ?? this.autofocus);
    }
}

class FlashlightMode {
    FlashlightMode.on() : _value = 'on';

    FlashlightMode.off() : _value = 'off';

    FlashlightMode.auto() : _value = 'auto';

    FlashlightMode.fromNative(String s) : _value = s;

    String get toNative {
        return _value;
    }

    final String _value;
}

class CaptureConfiguration {
    Size size;
    FlashlightMode flashlightMode;
    String path;

    CaptureConfiguration(this.size, this.flashlightMode, this.path);

    CaptureConfiguration.path(String path) : this(Size.zero(), FlashlightMode.auto(), path);

    CaptureConfiguration.fromNative(Map<String, dynamic> m)
            : this(Size.fromNative(m['size']), FlashlightMode.fromNative(m['flashlightMode']), m['path']);

    Map<String, dynamic> get toNative {
        return <String, dynamic>{
            'size': size.toNative,
            'flashlightMode': flashlightMode.toNative,
            'path': path
        };
    }

    CaptureConfiguration copyWith({
        Size size,
        FlashlightMode flashlightMode,
        String path}) {
        return CaptureConfiguration(size ?? this.size, flashlightMode ?? this.flashlightMode, path ?? this.path);
    }
}
