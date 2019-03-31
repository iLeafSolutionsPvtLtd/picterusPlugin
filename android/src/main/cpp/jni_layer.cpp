#include <jni.h>

#include <android/bitmap.h>

extern "C" JNIEXPORT long JNICALL Java_com_picterus_picteruscamera_CoreEngine_storeBitmap(
        JNIEnv* env,
        jobject thiz,
        jobject bitmap)
{
    auto obj = env->NewGlobalRef(bitmap);
    return reinterpret_cast<long>(obj);
}

extern "C" JNIEXPORT jobject JNICALL Java_com_picterus_picteruscamera_CoreEngine_getBitmap(
        JNIEnv* env,
        jobject thiz,
        long bitmap)
{
    jobject obj = reinterpret_cast<jobject>(bitmap);
    return obj;
}

extern "C" JNIEXPORT void JNICALL Java_com_picterus_picteruscamera_CoreEngine_releaseBitmap(
        JNIEnv* env,
        jobject thiz,
        long bitmap)
{
    env->DeleteGlobalRef(reinterpret_cast<jobject>(bitmap));
}
