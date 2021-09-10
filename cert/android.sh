#bin/sh

AARCH=target/aarch64-linux-android/release/libverify_mra_cert.so
ARMV7=target/armv7-linux-androideabi/release/libverify_mra_cert.so
X86_64=target/x86_64-linux-android/release/libverify_mra_cert.so
X86=target/i686-linux-android/release/libverify_mra_cert.so

AARCH_DES=../android/src/main/jniLibs/arm64-v8a
ARMV7_DES=../android/src/main/jniLibs/armeabi-v7a
X86_64_DES=../android/src/main/jniLibs/x86_64
X86_DES=../android/src/main/jniLibs/x86

[ ! -d "$AARCH_DES" ] && mkdir -p "$AARCH_DES"
[ ! -d "$ARMV7_DES" ] && mkdir -p "$ARMV7_DES"
[ ! -d "$X86_DES" ] && mkdir -p "$X86_DES"
[ ! -d "$X86_64_DES" ] && mkdir -p "$X86_64_DES"

[ -f "$AARCH" ] && cp "$AARCH" "$AARCH_DES"
[ -f "$ARMV7" ] && cp "$ARMV7" "$ARMV7_DES"
[ -f "$X86" ] && cp "$X86" "$X86_DES"
[ -f "$X86_64" ] && cp "$X86_64" "$X86_64_DES"
