#include <jni.h>

#include <iostream>

extern "C" JNIEXPORT jlong JNICALL Java_com_picterus_picteruscamera_CoreEngine_storeBitmap(
        JNIEnv* env,
        jobject thiz,
        jobject bitmap)
{
    std::cout << "AAAAA" << std::endl;
    return 10;
}
