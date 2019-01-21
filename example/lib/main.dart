import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:picterus_camera/picterus_camera.dart';

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
        String text = "";
        try {
            final cameras = await PicterusCamera.cameras;
            final sizes = await PicterusCamera.previewSizes;
            final camera = PicterusCamera();
            CameraConfiguration config = CameraConfiguration();
            config.position = cameras[0];
            config.previewSize = sizes[0];
            camera.initialize(config);
            for (final camera in cameras) {
                if (camera == CameraPosition.front) {
                    text += 'Front ';
                } else {
                    text += 'Back ';
                }
            }
            text += '\n';
            for (final size in sizes) {
                text += size.width.toString();
                text += ' ';
                text += size.height.toString();
                text += ' ';
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
