import 'package:flutter/material.dart';
import 'dart:async';

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

    @override
    void initState() {
        super.initState();
        initPlatformState();
    }

    Future<void> initPlatformState() async {
        String text = '';
        try {
            final devices = await Device.devices;
            final d = Device.back();
            if (devices.contains(d)) {
                final s = (await d.sizes)[0];
                _camera = Camera(PreviewConfiguration(d, s, FocusMode.auto()));
                _camera.initialize();
            }
            text += '\n';
            final device = _camera.currentConfiguration.device;
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
            final modes = await device.flashlightModes;
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
        } on PlatformException {
            text = 'Failed to get platform version.';
        }

        if (!mounted) return;

        setState(() {
            _text = text;
        });
    }

    void buttonClicked() {
        final d = _camera.currentConfiguration;
        _camera.updateConfiguration(_camera.currentConfiguration.copyWith(device: d.device == Device.front() 
                                                                                  ? Device.back()
                                                                                  : Device.front()));
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
                home: Scaffold(
                        appBar: AppBar(
                                title: const Text('Camera sample'),
                        ),
                        body: ListView(
                                children: <Widget>[
                                    SizedBox(
                                        width: 375,
                                        height: 500,
                                        child: _camera == null ? Center(child: Text('Initializing')) : _camera.cameraView
                                    ),
                                    FlatButton(
                                        child: Text('Switch'),
                                        color: Color(0x8F8F8FFF),
                                        highlightColor: Color(0x4F4F4FFF),
                                        onPressed: buttonClicked
                                    ),
                                    Text(_text,
                                    style: TextStyle(
                                            color: Colors.red.withOpacity(0.8),
                                            fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center)
                                ],
                        ),
                ),
        );
    }
}
