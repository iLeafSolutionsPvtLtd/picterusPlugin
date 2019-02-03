part of 'camera.dart';

class CameraView extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Theme.of(context).platform == TargetPlatform.android 
            ? AndroidView(viewType: 'CameraView')
            : UiKitView(viewType: 'CameraView');
    }
}