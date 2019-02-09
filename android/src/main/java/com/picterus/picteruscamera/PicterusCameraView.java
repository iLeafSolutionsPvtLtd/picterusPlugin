package com.picterus.picteruscamera;

import android.content.Context;
import android.view.TextureView;
import android.view.View;
import android.util.AttributeSet;

import io.flutter.plugin.platform.PlatformView;

public class PicterusCameraView implements PlatformView {
    class PicterusTextureView extends TextureView {
        private int mRatioWidth = 0;
        private int mRatioHeight = 0;

        public PicterusTextureView(Context context) {
            this(context, null);
        }

        public PicterusTextureView(Context context, AttributeSet attrs) {
            this(context, attrs, 0);
        }

        public PicterusTextureView(Context context, AttributeSet attrs, int defStyle) {
            super(context, attrs, defStyle);
        }

        public void setAspectRatio(int width, int height) {
            if (width < 0 || height < 0) {
                throw new IllegalArgumentException("Size cannot be negative.");
            }
            mRatioWidth = width;
            mRatioHeight = height;
            requestLayout();
        }

        @Override
        protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
            super.onMeasure(widthMeasureSpec, heightMeasureSpec);
            int width = MeasureSpec.getSize(widthMeasureSpec);
            int height = MeasureSpec.getSize(heightMeasureSpec);
            if (0 == mRatioWidth || 0 == mRatioHeight) {
                setMeasuredDimension(width, height);
            } else {
                if (width > height * mRatioWidth / mRatioHeight) {
                    setMeasuredDimension(width, width * mRatioHeight / mRatioWidth);
                } else {
                    setMeasuredDimension(height * mRatioWidth / mRatioHeight, height);
                }
            }
        }
    }

    PicterusCameraView(Context context, int id) {
        mCameraView = new PicterusTextureView(context);
    }

    @Override
    public View getView() {
        return mCameraView;
    }

    @Override
    public void dispose() {

    }

    private PicterusTextureView mCameraView;
}
