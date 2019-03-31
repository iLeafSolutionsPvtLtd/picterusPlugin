#include <jni.h>

//#include <android/log.h>
//#include <android/bitmap.h>

#include <string>
#include <unordered_map>

namespace {
    std::unordered_map<long, jobject> bitmap_map_;
    long counter_ = 0;
}

extern "C" JNIEXPORT long JNICALL Java_com_picterus_picteruscamera_CoreEngine_storeBitmap(
        JNIEnv* env,
        jobject thiz,
        jobject bitmap)
{
    auto obj = env->NewGlobalRef(bitmap);
    bitmap_map_[++counter_] = obj;
    return counter_;
    //return reinterpret_cast<long>(obj);
}

extern "C" JNIEXPORT jobject JNICALL Java_com_picterus_picteruscamera_CoreEngine_getBitmap(
        JNIEnv* env,
        jobject thiz,
        long bitmap)
{
    /*
    AndroidBitmapInfo  info;
    AndroidBitmap_getInfo(env, bitmap, &info);
    void* pixels = 0;
    AndroidBitmap_lockPixels(env, bitmap, &pixels);
     */

    /*
    jobject obj = bitmap_map_[bitmap];
    jclass cls = env->GetObjectClass(obj);

    jmethodID mid = env->GetMethodID(cls, "getClass", "()Ljava/lang/Class;");
    jobject clsObj = env->CallObjectMethod(obj, mid);

    cls = env->GetObjectClass(clsObj);

    mid = env->GetMethodID(cls, "getName", "()Ljava/lang/String;");

    jstring strObj = (jstring)env->CallObjectMethod(clsObj, mid);

    const char* str = env->GetStringUTFChars(strObj, NULL);
    __android_log_print(ANDROID_LOG_ERROR, "AAAAAAAA", "%s", str);

    env->ReleaseStringUTFChars(strObj, str);
    */
    return bitmap_map_[bitmap];
    //return reinterpret_cast<jobject>(bitmap);
}

extern "C" JNIEXPORT void JNICALL Java_com_picterus_picteruscamera_CoreEngine_releaseBitmap(
        JNIEnv* env,
        jobject thiz,
        long bitmap)
{
    //env->DeleteGlobalRef(reinterpret_cast<jobject>(bitmap));
    env->DeleteGlobalRef(bitmap_map_[bitmap]);
    bitmap_map_.erase(bitmap_map_.find(bitmap));
}
