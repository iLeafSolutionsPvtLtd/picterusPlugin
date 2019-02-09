package com.picterus.picteruscamera;

import android.content.Context;
import android.view.TextureView;
import android.view.View;

import io.flutter.plugin.platform.PlatformView;

public class PicterusCameraView implements PlatformView {
    PicterusCameraView(Context context, int id) {
        mCameraView = new TextureView(context);
    }

    @Override
    public View getView() {
        return mCameraView;
    }

    @Override
    public void dispose() {

    }

    private TextureView mCameraView;
}
