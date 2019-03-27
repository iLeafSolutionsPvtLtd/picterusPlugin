package com.picterus.picteruscamera;

import android.graphics.Bitmap;

public class CoreEngine {
    native public static long storeBitmap(Bitmap b);
    native public static Bitmap getBitmap(long v);
}
