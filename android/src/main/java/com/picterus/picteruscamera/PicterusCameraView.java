package com.picterus.picteruscamera;

import android.content.Context;
import android.view.View;

import io.flutter.plugin.platform.PlatformView;
import io.fotoapparat.Fotoapparat;
import io.fotoapparat.FotoapparatBuilder;
import io.fotoapparat.selector.LensPositionSelectorsKt;
import io.fotoapparat.view.CameraView;

public class PicterusCameraView implements PlatformView {
    PicterusCameraView(Context context, int id) {
        mCameraView = new CameraView(context);
        mFotoapparat = new FotoapparatBuilder(context).
                lensPosition(LensPositionSelectorsKt.back()).
                into(mCameraView).build();
        mFotoapparat.start();
    }

    @Override
    public View getView() {
        return mCameraView;
    }

    @Override
    public void dispose() {

    }

    private CameraView mCameraView;
    private Fotoapparat mFotoapparat;
}
