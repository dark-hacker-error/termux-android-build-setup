# Termux Android Build Setup

Phone pe hi Android app build karo — Java 21, SDK 35, NDK r29, Clang 21, CMake,
Ninja, Gradle wrapper aur AGP 8.13.2. Koi PC/laptop ki zaroorat nahi.

**Repo:** https://github.com/dark-hacker-error/termux-android-build-setup

---

## Quick Start (ek hi baar)

```bash
git clone https://github.com/dark-hacker-error/termux-android-build-setup
cd termux-android-build-setup
bash setup.sh
```

Uske baad demo build karo:

```bash
cd ~/demo-app
./gradlew assembleDebug
```

APK milega: `~/demo-app/app/build/outputs/apk/debug/app-debug.apk`

---

## Kya install hota hai

| Tool | Version | Kahaan |
|------|---------|--------|
| OpenJDK | 21.0.12 | Termux pkg (`$JAVA_HOME`) |
| Android SDK | cmdline-tools 19.0, platforms;android-35 | `~/opt/android-sdk` |
| Build Tools | 35.0.1 | `~/opt/android-sdk/build-tools/35.0.1` |
| AAPT2 (ARM64) | native aarch64 (build-tools override) | `~/opt/android-sdk/build-tools/35.0.1/aapt2` |
| Platform-Tools / ADB | latest | `~/opt/android-sdk/platform-tools/adb` + global `$PREFIX/bin/adb` |
| NDK | r29 (29.0.14206865) | `~/opt/android-ndk-r29` |
| Clang | 21.0.0 (NDK), 21.1.8 (Termux) | — |
| CMake | 4.2.1 (SDK), 4.4.3 (Termux) | `~/opt/android-sdk/cmake` |
| Ninja | 1.13.2 | — |
| Gradle | 8.13 (wrapper) | `~/demo-app/gradlew` |
| AGP | 8.13.2 (stable, max API 36) | — |

> **Note:** Build-tools `35.0.2` upstream pe exist nahi karta — 35.x series ka
> latest `35.0.1` hai (`35.0.2` ek platform-tools version tha).

---

## Setup ka full process (manual samajhna ho to)

Ye sab `setup.sh` automatically karta hai:

1. **Termux packages** install hote hain:
   `pkg install openjdk-21 gradle cmake ninja aapt2 apksigner d8 aidl wget unzip zip git`
2. **NDK r29 aarch64** download hota hai (lzhiyong/termux-ndk release se,
   officially nahi — kyunki Google sirf x86_64 NDK deta hai jo phone pe nahi
   chalega) aur `~/opt/android-ndk-r29` me extract hota hai. Clang 21.0.0
   iske saath aata hai.
3. **android-sdk aarch64** download hota hai aur `~/opt/android-sdk` me
   extract hota hai. Isme native binaries hoti hain.
4. **cmdline-tools layout fix**: sdkmanager ko `cmdline-tools/latest/`
   structure chahiye, isliye files usi folder me move hoti hain.
5. **Environment variables** `~/.android-env` me likhe jaate hain aur
   `~/.bashrc`, `~/.profile`, `~/.bash_profile` me source ho jaate hain —
   har nayi session me automatic.
6. **SDK licenses** accept hoti hain aur `build-tools;35.0.1` +
   `platforms;android-35` install hote hain (sdkmanager Java hai, Termux ke
   Java 21 pe chalta hai).
7. **Native binary fix (sabse important):** download hue build-tools ke
   andar Google ke x86_64 `aapt2`/`zipalign`/`split-select`/`dexdump`
   binaries hoti hain jo aarch64 pe nahi chalti. Inhe lzhiyong ke native
   aarch64 binaries se replace kiya jaata hai. Saath hi
   `gradle.properties` me:
   ```
   android.aapt2FromMavenOverride=$HOME/opt/android-sdk/build-tools/35.0.1/aapt2
   ```
   set hota hai, warna AGP uska apna x86_64 aapt2 download karke fail ho
   jata.
8. **Gradle 8.13** download hota hai aur demo-app ke `gradlew` wrapper ko
   local zip se link kiya jata hai (Java se https download kabhi-kabhi
   proxy pe fail hota hai; `wget` se downloaded zip local file URL ke
   dwara use hota hai).

---

## Naya project banana

`demo-app/` ko template ki tarah copy karo:

```bash
cp -r ~/demo-app ~/my-app
cd ~/my-app
```

`demo-app/` me ye sab already configured hai:
- `app/build.gradle`: `compileSdk 35`, `targetSdk 35`, `minSdk 24`, Java 21,
  CMake externalNativeBuild, `abiFilters 'arm64-v8a'`, `ndkVersion '29.0.14206865'`
- `local.properties`: `sdk.dir`, `ndk.dir`, `cmake.dir` (setup.sh banata hai)
- `gradle.properties`: `android.aapt2FromMavenOverride`

---

## Common errors aur fix

| Error | Fix |
|-------|-----|
| `aapt2 ... ELF 64-bit ... x86-64 ... not executable` / `cannot run program ".../aapt2"` | Native aapt2 se override karo (setup.sh step 7). `android.aapt2FromMavenOverride` set hai? |
| `NDK from ndk.dir ... had version [29.x] which disagrees with android.ndkVersion [27.x]` | `app/build.gradle` me `defaultConfig { ndkVersion '29.0.14206865' }` likho |
| `SDK location not found` | `local.properties` me `sdk.dir` daalo |
| `Failed to find package 'build-tools;35.0.2'` | 35.0.2 exist nahi karta; `build-tools;35.0.1` use karo |
| `gradle: error ... foojay` / plugin resolve fail | `settings.gradle` me `pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }` hona chahiye |
| Wrapper downloads fail (`SocketTimeoutException`) | setup.sh ka local zip use hota hai; agar official URL wapas chahiye to `gradle/wrapper/gradle-wrapper.properties` me `distributionUrl=https\://services.gradle.org/distributions/gradle-8.13-bin.zip` karo aur zip delete karke wrapper ko dobara download hone do |
| AGP 8.x vs Gradle 9.x mismatch (`InternalProblems` removed in Gradle 9.6) | AGP 8.13.2 ke saath Gradle 8.13 use karo (wrapper default yahi hai) |

---

## Demo app kya karti hai

- `MainActivity.java` — screen me Java version + native info dikhata hai
- `src/main/cpp/demo.cpp` — CMake se bani `libdemo.so` (arm64-v8a) JNI se clang version return karti hai
- Iska matlab poora chain test hota hai: AGP → javac → D8 → Gradle → NDK r29 clang → CMake → Ninja → native lib → APK

## Credits

- NDK/SDK aarch64: [lzhiyong/termux-ndk](https://github.com/lzhiyong/termux-ndk)

---

## termux-studio (Android Studio jaisa menu)

Terminal me `termux-studio` likho — interactive menu milega:

Project directory me CD karke `termux-studio` chalane par **Project mode** khulta hai:

```
 1) Build Debug APK        2) Build Release APK
 3) Rebuild                4) Clean
 5) APK output paths       6) adb install
 7) App open karo          8) SD card me copy
 9) Project info/versions 10) Bahar jao
```

Home directory me **Home mode**: naya project banao ya project list dekho.
Naya project banne ke baad `cd project-naam && termux-studio` karke project
mode me aa jaao — fir sirf project se related options milenge, jaise Android Studio me.

APK jahan milta hai: `<project>/app/build/outputs/apk/debug/app-debug.apk`
