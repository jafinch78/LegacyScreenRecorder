# Legacy Screen Recorder v1.0.0

**Full screen · MP4 · Offline · Android 6.0+**

Legacy Screen Recorder is a lightweight, standalone Android application for recording the entire phone screen with optional microphone narration. It is designed for older Android phones that lack a convenient built-in screen recorder, while retaining compatibility with newer Android releases.

The application reimplements the native `MediaProjection` + `MediaRecorder` architecture demonstrated by the Toyota CAN/BLE Sync Recorder, without BLE synchronization, CAN diagnostics or the associated session metadata. Screen video is encoded as H.264 and microphone audio as AAC in a standard MP4 container.

No root, account, Internet connection, Bluetooth, GPS, Wi-Fi or overlay permission is required for recording. The application uses native Java and has no declared third-party runtime libraries.

## 1. Device compatibility

The minimum supported Android API is **23 (Android 6.0)**. The following devices are representative development and acceptance-test targets.

| Feature | Galaxy J3 Luna Pro | Galaxy S8+ | Galaxy A35 5G |
|---|---|---|---|
| Model | SM-S327VL | SM-G955U | SM-A356U |
| Android version / API | 6.0.1 / 23 | 9 / 28 | 15 / 35 |
| Meets minimum SDK | Yes | Yes | Yes |
| Full-screen capture | Designed for | Designed for | Designed for |
| Microphone narration | Designed for | Designed for | Designed for |
| H.264 hardware encoding | Device-dependent | Device-dependent | Device-dependent |
| Background recording / notification stop | Designed for | Designed for | Designed for |
| Direct internal application audio | Not implemented | Not implemented | Not implemented |
| Root or Internet required | No | No | No |
| v1.0.0 validation | Pending | Build and run confirmed by maintainer | Pending |

Android 10 (API 29) introduced the public AudioPlaybackCapture API, subject to source-app capture policies. This initial release uses microphone input only, even on newer phones. On older devices, speaker output can be picked up acoustically by the microphone, but direct digital playback capture is unavailable through the standard public API. Secure or DRM-protected screen content may appear blank.

## 2. Recording presets

Selectable presets reduce encoder workload and storage consumption on older devices.

| Setting | Economy | Standard | High |
|---|---:|---:|---:|
| Target short-side resolution | 480 px | 720 px | Up to 1080 px |
| Requested frame rate | 10 FPS | 20 FPS | 30 FPS |
| Requested video bitrate | 1 Mbps | 2.5 Mbps | 6 Mbps |
| Video codec | H.264 | H.264 | H.264 |
| Audio codec (optional) | AAC | AAC | AAC |
| Estimated storage/hour | 0.49 GB | 1.17 GB | 2.74 GB |

Storage estimates use decimal GB and 96 kbps microphone audio, excluding container overhead; actual results depend on the device and encoder. Microphone audio is mono, 44.1 kHz. The original BLE Sync recorder's documented 30 FPS / 8 Mbps setting is a reference, not a requirement for this application.

Economy is recommended for the J3 Luna Pro; Standard is a reasonable starting point for the S8+. Economy is the default on Android 6/7 and Standard on Android 8+. The app preserves display aspect ratio as closely as practical, does not upscale, caps the long side at 1920 pixels, and aligns dimensions down to multiples of 16. Encoder preparation can fall back to lower presets; if starting the encoder fails, try Economy manually. Actual FPS, bitrate and encoder selection are device-dependent.

## 3. Application interface and operation

The main screen provides a quality selector, microphone checkbox, **START RECORDING**, **STOP & SAVE**, and a recording/status display. A persistent foreground notification provides a recording timer and a stop action when notifications are available.

1. Open Screen Recorder and select a quality preset.
2. Enable microphone narration if desired. Grant microphone, shared-storage (API 23–28), and notification (API 33+) permissions as applicable.
3. Press **START RECORDING** and approve the Android screen-capture dialog. Select the entire screen if a capture-scope choice appears.
4. Once the app reports `RECORDING`, switch to the desired application and use the phone normally.
5. Press **STOP & SAVE** in the recorder or its notification. Wait for `SAVED` before transferring the file.

Recordings are saved in shared storage:

```text
Internal Storage/
  Movies/
    LegacyScreenRecorder/
      SCREEN_20261123_233200_000.mp4
```

The timestamp is illustrative. Finished videos are available through Gallery, My Files or USB transfer; no ZIP compression or conversion is required.

### Recording limitations and safeguards

- Keep the screen awake and unlocked during recording. Screen-lock behavior depends on Android and the device.
- Keep orientation fixed; stop and restart after rotation because the encoder retains its original geometry.
- The service registers a projection-revocation callback, uses a foreground notification and releases recording resources at stop.
- API 23–28 uses an unpublished partial MP4; API 29+ uses a pending MediaStore entry. The app checks positive video duration and dimensions before publishing. This is a container sanity check, not a complete audio/video decode test.
- Legacy API 23–28 recordings have a 3500 MiB file-size cap. Startup reserves approximately 128 MiB of free space; other applications can still exhaust storage. No automatic continuation is implemented.
- Very short clips, forced termination, abrupt power loss or storage exhaustion can prevent MP4 finalization. Record at least several seconds and stop normally.

## 4. Source package

The release source archive is named `LegacyScreenRecorder_v1.0.0_Source.zip`. Obtain the archive from the repository when available, extract it, and open the project directory containing `settings.gradle` (not the `app` subdirectory).

| File | Purpose |
|---|---|
| `app/src/main/java/com/legacy/screenrecorder/MainActivity.java` | User interface, permission requests and capture consent |
| `app/src/main/java/com/legacy/screenrecorder/CaptureService.java` | Foreground service, screen/audio capture, storage and MP4 finalization |
| `app/src/main/java/com/legacy/screenrecorder/Preset.java` | Geometry, frame rate and bitrate presets |
| `app/src/main/AndroidManifest.xml` | Android permissions and service declarations |
| `app/build.gradle` | Application ID, version and SDK configuration |
| `BUILD_APK.bat` | Windows environment checks, APK assembly, lint and build log |
| `README.md` | Original package build, installation and operating instructions |
| `TEST_REPORT.md` | Original source validation results |
| `tests/PresetTest.java` | Pure Java recording-preset tests |

A separate corrected `BUILD_APK_JDK17.bat` is available from the maintainer if supplied alongside the source. It is not part of the original ZIP.

## 5. Build and installation

| Build parameter | Configuration |
|---|---|
| Application ID | `com.legacy.screenrecorder` |
| Version name / code | 1.0.0 / 1 |
| Minimum SDK | 23 (Android 6.0) |
| Compile SDK | 35 |
| Target SDK | 35 |
| Android Gradle Plugin | 8.7.3 |
| Gradle | 8.9 |
| Build JDK | 17 |
| Java source / target compatibility | Java 8 |
| Third-party app libraries | None declared |

### Android Studio

1. Reuse an existing Android SDK Platform 35, JDK 17 and Gradle 8.9 installation where available.
2. Open the extracted project folder in Android Studio.
3. Under **File → Settings → Build, Execution, Deployment → Build Tools → Gradle**, select the local Gradle 8.9 distribution and JDK 17. The original archive does not bundle a Gradle wrapper. Do not allow the IDE to silently select a newer Gradle or JDK.
4. Sync the project, then select **Build → Generate App Bundles or APKs → Generate APKs**, or use **Run** with a USB-debugging-enabled phone connected.

The first online sync may download Android Gradle Plugin build dependencies. These are computer-side development tools, not runtime libraries installed on the phone. Once cached, existing dependencies can be reused for subsequent offline builds.

### Windows command-line build

Set `JAVA_HOME` to an installed **JDK 17** and use the local Gradle 8.9 installation. If the corrected JDK-17 script is available, run it instead of the original script. Otherwise, after selecting the correct JDK, run `BUILD_APK.bat` from the project folder. It assembles the APK, runs lint, writes `BUILD_LAST.log`, and reports a final ERRORLEVEL.

The expected output path is:

```text
app\build\outputs\apk\debug\app-debug.apk
```

Install with Android Studio or transfer the locally debug-signed APK to the phone and authorize installation from the selected file source. With ADB and one authorized USB device, run the following from the project root:

```bat
adb install -r app\build\outputs\apk\debug\app-debug.apk
```

No production signing key is provided. Keep the same signing key when updating an installed build.

### Known build-environment issues

| Symptom | Corrective action |
|---|---|
| `Unsupported class file major version 69` | Java 25 was selected with Gradle 8.9. Select JDK 17 for both Gradle and the launcher. |
| Gradle 9.3.0 native `gradle-fileevents.dll` fails on a legacy Windows host | Return to the pinned local Gradle 8.9 distribution. If necessary, disable optional file-system watching with `org.gradle.vfs.watch=false` in `gradle.properties`. |
| First-time Maven/Google downloads | Expected when the selected build tools are not cached. Reuse existing caches; do not unnecessarily change toolchain versions. |

The legacy Windows native DLL failure was observed; its exact OS/DLL root cause was not independently established. No application source change was required to address the reported build failures.

## 6. Verification status

Status as of **2026-11-24**. Source checks below are recorded in the original `TEST_REPORT.md` and package verification record; the later S8+ result is maintainer-reported.

| Check | Status |
|---|---|
| Java source parser validation (Java 8 syntax) | PASS — syntax only |
| Pure Java preset tests (29 cases) | PASS |
| Manifest and XML parsing | PASS |
| Static recording lifecycle checks | PASS |
| Source ZIP integrity | PASS |
| Android APK build and installation | PASS — maintainer-reported S8+ build/run |
| Independent Android lint result | Pending — final lint log not supplied |
| Galaxy S8+ hardware smoke test | PASS — maintainer-reported build/run and favorable initial observation |
| J3 Luna Pro hardware acceptance | Pending |
| Galaxy A35 5G hardware acceptance | Pending |
| LG G4 compatibility | Pending — actual installed Android version to verify |
| Video/audio playback, long-duration and failure-mode testing | Pending |

The related Toyota CAN/BLE Sync Recorder has been field-tested across the J3 Luna Pro, S8+ and A35 5G. Those results support the choice of native recording architecture, but do not certify this standalone application on those devices. Full device acceptance remains separate from an APK build or initial launch.

### Recommended acceptance tests

- [ ] On each target phone, confirm installation, permission handling and denial of screen-capture consent without recording.
- [ ] Record 30 seconds in Economy while scrolling text, switching apps and speaking continuously. Stop from the notification and verify MP4 playback, duration, orientation, narration and seekability.
- [ ] Repeat with microphone disabled and verify there is no audio track. Stop from the main application as well.
- [ ] Repeat at least five start/stop cycles; check distinct filenames, no stale service state and no false `SAVED` indication.
- [ ] Qualify Standard and High presets individually. Run a ten-minute capture and monitor thermal behavior, lag, audio dropouts, free storage and file integrity.
- [ ] Test projection revocation, rotation, denied notifications and low-storage handling on a suitable test device.

Preserve the verified API-23 floor, the existing build configuration and source baseline before adding features. Use device-specific test results, recorded metrics and regression checks to guide changes rather than assuming compatibility from the minimum SDK alone.

## 7. Technical references

- [Android MediaProjection](https://developer.android.com/media/grow/media-projection)
- [Android audio playback capture](https://developer.android.com/media/platform/av-capture)
- [Android Gradle Plugin 8.7 release notes](https://developer.android.com/build/releases/agp-8-7-0-release-notes)
- Related project: Toyota CAN/BLE Sync Recorder architecture, documented in `Toyota_CAN_IPO_TOE_Charts.pdf` (separate project reference; not included in the screen recorder ZIP).
