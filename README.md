# Termux Android Build Setup (Java 21 / SDK 35 / NDK r29 / Clang 21 / CMake / Ninja / Gradle Wrapper / AGP 8.13.2)

Tested on Termux (aarch64, Android). One-shot setup for building native+Java Android apps
directly on phone — no PC needed.

## Quick start

```bash
git clone https://github.com/<your-user>/termux-android-build-setup
cd termux-android-build-setup
bash setup.sh
cd ~/demo-app && ./gradlew assembleDebug
```

APK output: `~/demo-app/app/build/outputs/apk/debug/app-debug.apk`

## What gets installed

| Tool | Version |
|------|---------|
| OpenJDK | 21 |
| Android SDK | platforms;android-35, build-tools 35.0.1, cmdline-tools 19.0 |
| ADB | latest (platform-tools + android-tools) |
| NDK | r29 (29.0.14206865), clang 21.0.0 |
| CMake | 4.2.1 (SDK) / Termux cmake |
| Ninja | 1.13.2 |
| Gradle | 8.13 via wrapper |
| AGP | 8.13.2 (stable) |

## Notes
- Build-tools `35.0.2` does not exist upstream; `35.0.1` is the latest 35.x
  (`35.0.2` was a platform-tools version).
- Native aarch64 `aapt2`/`zipalign`/`split-select`/`dexdump` are placed into
  `build-tools/35.0.1`, and `android.aapt2FromMavenOverride` is set in
  `gradle.properties` so AGP does not download x86_64 binaries.
- `gradlew` wrapper `distributionUrl` points to the official URL; first run
  downloads Gradle 8.13.

## New projects

Copy `demo-app/` as a template; it already pins `ndkVersion`,
`sdk.dir`/`ndk.dir`/`cmake.dir` in `local.properties`, and the aapt2 override.
