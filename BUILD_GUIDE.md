# AI Video Studio Pro

Android-only personal video and audio editing app built for Flutter 3.24.5 stable. It has no sign-in, subscription, web app, or Play Store setup.

## Requirements

- Flutter 3.24.5 on the stable channel
- Android SDK platform 34 and Android build tools
- Android NDK 25.1.8937393
- JDK 17

## Build

From the repository root:

```sh
flutter --version
flutter doctor
flutter pub get
flutter build apk --release
```

Install `build/app/outputs/flutter-apk/app-release.apk` on an Android 7.0 (API 24) or newer device. The manually supplied Android project files use Flutter's Gradle plugin loader; when initializing a local checkout, let Flutter create `android/local.properties` for the installed SDK.

## Features

- Video project preview, resolution conversion, audio conversion, and H.264/H.265 export run locally with FFmpeg.
- Export estimates use configured codec bitrates and selected duration; actual sizes vary with source content and encoder behavior. H.265 output is not guaranteed to be 1 MB/minute on every video/device.
- Outputs are retained in app documents and copied to the device's Movies or Music collection.
- Gemini provides optional online text and image analysis only. Add the API key in Settings; do not commit API keys to source control.
- Dress, hairstyle, deblur, and watermark-removal actions are deliberately unavailable in the free tier and show the requested paid-API notice.

## CI

Run the **Build Android APK** workflow manually from the Actions tab. It builds the release APK with Flutter 3.24.5 and uploads it as `AI-Video-Studio-Pro-APK`.