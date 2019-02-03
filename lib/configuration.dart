part of 'camera.dart';

class PreviewConfiguration {
    Device device;
    Size size;
    FocusMode focusMode;

    PreviewConfiguration(this.device, this.size, this.focusMode);

    PreviewConfiguration.device(Device device) : this(device, Size.zero(), FocusMode.auto());

    PreviewConfiguration.fromNative(Map<String, dynamic> m)
            : this(Device.fromNative(m['device']), Size.fromNative(m['size']), FocusMode.fromNative(m['focusMode']));

    Map<String, dynamic> get toNative {
        return <String, dynamic>{
            'device' : device.toNative,
            'size' : size.toNative,
            'focusMode' : focusMode.toNative
        };
    }

    PreviewConfiguration copyWith({
        Device device,
        Size size,
        FocusMode focusMode
    }) {
        return PreviewConfiguration(device, size ?? this.size, focusMode ?? this.focusMode);
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

class FocusMode {
    FocusMode.off() : _value = 'off';
    FocusMode.auto() : _value = 'auto';
    FocusMode.manual() : _value = 'manual';
    FocusMode.fromNative(String s) : _value = s;

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
