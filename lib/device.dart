import 'exception.dart';
import 'geometry.dart';
import 'src/native_bridge.dart';

import 'dart:async';

import 'package:flutter/services.dart';

class Device {
    Device.front() 
            : _isFront = true {
    }

    Device.back() 
            : _isFront = false {
    }

    Device.fromNative(String s) 
            : _isFront = s == 'front' ? true : false {
    }

    String get toNative {
        return _isFront == true ? 'front' : 'back';
    }

    Future<List<Size>> get sizes async {
        try {
            final List<dynamic> ss = await native_bridge.instance.invokeMethod('sizes', this.toNative);
            return ss.map((dynamic size) {
                return Size.fromNative(size);
            }).toList();
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    static Future<List<Device>> get devices async {
        try {
            final List<dynamic> ds = await native_bridge.instance.invokeMethod('devices');
            return ds.map((dynamic device) {
                return Device.fromNative(device);
            }).toList();
        } on PlatformException catch (e) {
            throw CameraException(e.code, e.message);
        }
    }

    final bool _isFront;
}
