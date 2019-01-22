import 'src/native_bridge.dart';
import 'device.dart';
import 'geometry.dart';

class PreviewConfiguration {
    Device device;
    Size size;
    bool autofocus;

    PreviewConfiguration(Device device, Size size, bool autofocus)
            : this.device = device
            , this.size = size
            , this.autofocus = autofocus 
    {
    }

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

class CaptureConfiguration {
    Size size;
}
