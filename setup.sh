#!/data/data/com.termux/files/usr/bin/bash
# Termux Android Build Setup - Java 21, SDK 35, NDK r29, CMake, Ninja, Gradle Wrapper, AGP
set -e

echo "[1/8] Installing Termux packages..."
pkg update -y
pkg install -y openjdk-21 gradle cmake ninja aapt2 apksigner d8 aidl wget unzip zip git

echo "[2/8] Downloading NDK r29 (aarch64) and android-sdk (aarch64)..."
mkdir -p ~/opt && cd ~/opt
[ -f ndk.tar.xz ] || wget -q https://github.com/lzhiyong/termux-ndk/releases/download/android-ndk/android-ndk-r29-aarch64.tar.xz -O ndk.tar.xz
[ -f sdk.tar.xz ] || wget -q https://github.com/lzhiyong/termux-ndk/releases/download/android-sdk/android-sdk-aarch64.tar.xz -O sdk.tar.xz
[ -d android-ndk-r29 ] || tar -xf ndk.tar.xz
[ -d android-sdk ] || tar -xf sdk.tar.xz

echo "[3/8] Fixing cmdline-tools layout..."
cd ~/opt/android-sdk/cmdline-tools
if [ ! -d latest ]; then
  mkdir latest
  mv apkanalyzer avdmanager d8 lint profgen r8 resourceshrinker retrace screenshot2 sdkmanager bin lib source.properties latest/ 2>/dev/null || true
fi

echo "[4/8] Setting environment..."
cat > ~/.android-env <<'ENV'
export JAVA_HOME=/data/data/com.termux/files/usr/lib/jvm/java-21-openjdk
export ANDROID_HOME=$HOME/opt/android-sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME
export ANDROID_NDK_HOME=$HOME/opt/android-ndk-r29
export ANDROID_NDK_ROOT=$ANDROID_NDK_HOME
export PATH=$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/35.0.1:$ANDROID_NDK_HOME:$PATH
ENV
grep -q '.android-env' ~/.bashrc 2>/dev/null || printf '\n[ -f ~/.android-env ] && . ~/.android-env\n' >> ~/.bashrc
touch ~/.profile ~/.bash_profile
grep -q '.android-env' ~/.profile || printf '\n[ -f ~/.android-env ] && . ~/.android-env\n' >> ~/.profile
grep -q '.android-env' ~/.bash_profile || printf '\n[ -f ~/.android-env ] && . ~/.android-env\n' >> ~/.bash_profile
source ~/.android-env

echo "[5/8] Accepting licenses and installing SDK packages..."
yes | sdkmanager --licenses >/dev/null 2>&1 || true
sdkmanager "build-tools;35.0.1" "platforms;android-35"

echo "[6/8] Installing native aarch64 binaries into build-tools 35.0.1..."
cp ~/opt/android-sdk/build-tools/37.0.0/aapt ~/opt/android-sdk/build-tools/37.0.0/aapt2 \
   ~/opt/android-sdk/build-tools/37.0.0/zipalign ~/opt/android-sdk/build-tools/37.0.0/split-select \
   ~/opt/android-sdk/build-tools/37.0.0/dexdump ~/opt/android-sdk/build-tools/35.0.1/

echo "[7/8] Setting up Gradle 8.13 wrapper for demo app..."
mkdir -p ~/demo-app
[ -f $PREFIX/tmp/opencode/gradle-8.13-bin.zip ] || wget -q https://services.gradle.org/distributions/gradle-8.13-bin.zip -O /data/data/com.termux/files/usr/tmp/opencode/gradle-8.13-bin.zip
cp -r ~/android-build-setup/demo-app/* ~/demo-app/ 2>/dev/null || true

echo "[8/8] Done! Try: cd ~/demo-app && ./gradlew assembleDebug"

# local.properties generated per-install
cat > ~/demo-app/local.properties <<'LP'
sdk.dir=/data/data/com.termux/files/home/opt/android-sdk
ndk.dir=/data/data/com.termux/files/home/opt/android-ndk-r29
cmake.dir=/data/data/com.termux/files/home/opt/android-sdk/cmake
LP
