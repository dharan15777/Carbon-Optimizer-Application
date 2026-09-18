# Building the CarbonWise Android APK

The app is a standard **Flutter** project. The Dart source lives under `lib/`
and the dependencies are declared in `pubspec.yaml`.

> The native `android/` folder is **not** committed to git (it is generated
> from your installed Flutter version). Generate it once, then build.

## 1. Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.24.x** (stable)
- Android Studio **or** the Android command-line tools (provides the Android SDK)
- JDK 17 (bundled with recent Android Studio / Flutter)

Check your setup:

```bash
flutter doctor
```

## 2. One-time setup (generates the Android project)

Run from the `carbonwise-mobile` directory:

```bash
cd carbonwise-mobile
flutter create --platforms=android --org com.carbonwise --project-name carbonwise .
flutter pub get
```

## 3. Build the release APK

```bash
flutter build apk --release
```

The APK is written to:

```
build/app/outputs/flutter-apk/app-release.apk
```

Install it on a connected device/emulator:

```bash
flutter install
# or
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 4. (Optional) Google Maps API key

The Maps screen uses `google_maps_flutter`. To see a real map, add your
Android API key inside the generated
`android/app/src/main/AndroidManifest.xml`, inside the `<application>` tag:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_ANDROID_API_KEY"/>
```

Get a key from the [Google Cloud Console](https://console.cloud.google.com/google/maps-apis)
(Maps SDK for Android must be enabled).

## 5. (Optional) Sign the APK for the Play Store

The default release build is signed with the debug keystore, which is fine for
testing / a final demo submission. For Play Store upload, configure a real
keystore following the official
[Build and release an Android app](https://docs.flutter.dev/deployment/android)
guide.

---

## Continuous Integration

The CI workflow definition is provided as a template at
`carbonwise-mobile/ci/build-apk.yml`. The Arena agent's GitHub token cannot
create files under `.github/workflows/`, so activate it once (as the repo
owner):

```bash
mkdir -p .github/workflows
cp carbonwise-mobile/ci/build-apk.yml .github/workflows/build-apk.yml
git add .github/workflows/build-apk.yml
git commit -m "ci: add APK build workflow"
git push
```

After that, every push builds the APK automatically. Download it from the
workflow run's **Artifacts** section (`carbonwise-release-apk`).
