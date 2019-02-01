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

    @override
    void initState() {
        super.initState();
        initPlatformState();
    }

    Future<void> initPlatformState() async {
        String text = '';
        try {
            final devices = await Device.devices;
            for (final device in devices) {
                text += device.toNative;
                text += '\n';
                final sizes = await device.sizes;
                for (final size in sizes) {
                    text += size.width.toString();
                    text += ' ';
                    text += size.height.toString();
                    text += '\n';
                }
                final modes = await device.flashlightModes;
                for (final mode in modes) {
                    text += mode.toNative;
                    text += '\n';
                }
            }
        } on PlatformException {
            text = 'Failed to get platform version.';
        }

        if (!mounted) return;

        setState(() {
            _text = text;
        });
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
                home: Scaffold(
                        appBar: AppBar(
                                title: const Text('Camera sample'),
                        ),
                        body: Center(
                                child: Text(_text,
                                        style: TextStyle(
                                                color: Colors.red.withOpacity(0.8),
                                                fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center),
                        ),
                ),
        );
    }
}
