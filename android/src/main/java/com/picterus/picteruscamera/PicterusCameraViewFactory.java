package com.picterus.picteruscamera;

import android.content.Context;

import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class PicterusCameraViewFactory extends PlatformViewFactory {
    public PicterusCameraViewFactory() {
        super(StandardMessageCodec.INSTANCE);
    }

    @Override
    public PlatformView create(Context context, int i, Object o) {
        PicterusCameraView r = new PicterusCameraView(context, i);
        PicterusCameraPlugin.sharedInstance().registerPreviewView(r);
        return r;
    }
}
