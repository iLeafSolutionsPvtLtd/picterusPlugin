part of 'camera.dart';

class PreviewConfiguration {
    Device device;
    Size size;
    FocusMode focusMode;
    double zoomFactor;

    PreviewConfiguration(this.device, this.size, this.focusMode, this.zoomFactor);

    PreviewConfiguration.device(Device device) : this(device, Size.zero(), FocusMode.auto(), 1.0);

    PreviewConfiguration.fromNative(Map<String, dynamic> m)
            : this(Device.fromNative(m['device'])
            , Size.fromNative(m['size'])
            , FocusMode.fromNative(m['focusMode'])
            , m['zoomFactor']);

    Map<String, dynamic> get toNative {
        return <String, dynamic>{
            'device' : device.toNative,
            'size' : size.toNative,
            'focusMode' : focusMode.toNative,
            'zoomFactor' : zoomFactor
        };
    }

    PreviewConfiguration copyWith({
        Device device,
        Size size,
        FocusMode focusMode,
        double zoomFactor
    }) {
        return PreviewConfiguration(
            device ?? this.device,
            size ?? this.size,
            focusMode ?? this.focusMode,
            zoomFactor ?? this.zoomFactor
        );
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
    FlashlightMode flashlightMode;
    String path;

    CaptureConfiguration(this.flashlightMode, this.path);

    CaptureConfiguration.path(String path) : this(FlashlightMode.auto(), path);

    CaptureConfiguration.fromNative(Map<String, dynamic> m)
            : this(FlashlightMode.fromNative(m['flashlightMode']), m['path']);

    Map<String, dynamic> get toNative {
        return <String, dynamic>{
            'flashlightMode': flashlightMode.toNative,
            'path': path
        };
    }

    CaptureConfiguration copyWith({
        Size size,
        FlashlightMode flashlightMode,
        String path}) {
        return CaptureConfiguration(flashlightMode ?? this.flashlightMode, path ?? this.path);
    }
}
