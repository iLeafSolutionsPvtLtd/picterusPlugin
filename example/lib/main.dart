import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:picterus_camera/camera.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
    @override
    _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
    String _text = '';
    Camera _camera;
    double _maxZoomFactor = 1.0;
    double _zoomFactor = 1.0;
    String _imagePath = '';

    @override
    void initState() {
        super.initState();
        initPlatformState();
    }

    double abs(double x) {
        return x < 0.0 ? -x : x;
    }

    Future<void> initPlatformState() async {
        String text = '';
        double z = 1.0;
        try {
            final devices = await Device.devices;
            final d = Device.front();
            if (devices.contains(d)) {
                final ss = (await d.sizes);
                Size sm = ss[0];
                ss.forEach((f) {
                    if (f.width * f.height > sm.width * sm.height) {
                        sm = f;
                    }
                });
                sm.width /= 2;
                sm.height /= 2;
                Size s = ss[0];
                ss.forEach((f) {
                    if (abs(f.width * f.height - sm.width * sm.height) < abs(s.width * s.height - sm.width * sm.height)) {
                        s = f;
                    }
                });
                 z = await d.maxZoomFactor;
                _camera = Camera();
                _camera.initialize(PreviewConfiguration(d, s, FocusMode.auto(), 1.0));
            }
            text = await getInfo(d);
        } on PlatformException {
            text = 'Failed to get platform version.';
        }

        if (!mounted) {
            return;
        }

        setState(() {
            _text = text;
            _maxZoomFactor = min(z, 16.0);
        });
    }

    Future<void> switchButtonClicked() async {
        _camera.switchDevice();
        final text = await getInfo(_camera.configuration.device);
        final z = await _camera.configuration.device.maxZoomFactor;
        setState(() {
            _zoomFactor = 1.0;
            _text = text;
            _maxZoomFactor = min(z, 16.0);
        });
    }

    Future<void> captureButtonClicked() async {
        final path = (await getTemporaryDirectory()).path + "/" + _camera.configuration.device.toNative + "_capture.jpg";
        final size = (await _camera.configuration.device.sizes).last;
        _camera.capture(CaptureConfiguration(size, FlashlightMode.off(), path), (String path) {
            setState(() {
                _imagePath = path;
            });
        });
    }

    void zoomChanged(double value) {
        _zoomFactor = value * value;
        _camera.changeZoomFactor(_zoomFactor);
        setState(() {
            _zoomFactor = value * value;
        });
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
                home: Scaffold(
                        body: ListView(
                                children: <Widget>[
                                    SizedBox(
                                        width: 375,
                                        height: 500,
                                        child: _camera == null ? Center(child: Text('Initializing')) : _camera.cameraView
                                    ),
                                    FlatButton(
                                        child: Text('Switch'),
                                        color: Color(0xFF8F8FFF),
                                        highlightColor: Color(0xFF4F4FFF),
                                        onPressed: switchButtonClicked
                                    ),
                                    FlatButton(
                                        child: Text('Capture'),
                                        color: Color(0xFF0000FF),
                                        highlightColor: Color(0xFF00FFFF),
                                        onPressed: captureButtonClicked
                                    ),
                                    Text('Zoom'),
                                    Slider(onChanged: zoomChanged, min: 1.0, max: sqrt(_maxZoomFactor), value: sqrt(_zoomFactor)),
                                    _imagePath == '' ? Center(child: Text('No image to show')) : Image.file(File(_imagePath)),
                                    Text(_text,
                                    style: TextStyle(
                                            color: Colors.cyan,
                                            fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center),
                                ],
                        ),
                ),
        );
    }

    Future<String> getInfo(Device device) async {
        String text = '\n';
        text += device.toNative;
        text += '\n';
        final sizes = await device.sizes;
        for (final size in sizes) {
            text += size.width.toString();
            text += ' ';
            text += size.height.toString();
            text += '\n';
        }
        text += '\n';
        final modes = await _camera.flashlightModes;
        for (final mode in modes) {
            text += mode.toNative;
            text += '\n';
        }
        text += '\n';
        final focusModes = await device.focusModes;
        for (final mode in focusModes) {
            text += mode.toNative;
            text += '\n';
        }
        text += (await device.maxZoomFactor).toString();
        return text;
    }
}
