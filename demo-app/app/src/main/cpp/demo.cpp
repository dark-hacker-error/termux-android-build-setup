#include <jni.h>
#include <string>
#include <cstdio>
extern "C" JNIEXPORT jstring JNICALL
Java_com_example_demo_MainActivity_nativeInfo(JNIEnv* env, jclass) {
    char buf[512];
    snprintf(buf, sizeof buf,
        "NDK clang: %d.%d.%d\nCMake build OK - arm64-v8a native lib loaded!",
        __clang_major__, __clang_minor__, __clang_patchlevel__);
    return env->NewStringUTF(buf);
}
