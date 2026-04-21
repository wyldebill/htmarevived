# Project Context

- **Owner:** william austin
- **Project:** Buffalo business tracker app for Flutter
- **Stack:** Flutter, Dart, Firebase/Realtime Database, PowerShell scripting
- **Created:** 2026-04-18T17:33:25.644Z

## Learnings

- Starter Flutter app lives in `htma2\`.
- No Firebase packages are installed yet.
- MVP scope is narrowed: no visit tracking, minimal data model (name, category, address, lat/lng only).
- 20 Buffalo, MN small businesses dataset locked (coordinates verified).
- Firebase Realtime Database is the backend choice.
- Seed import must be deterministic and support both dry-run and `-Apply` modes.

## Completed Work (Session 2026-04-18)

### Task: arthur-seed-import (DECISION COMPLETE)
- **Date:** 2026-04-18
- **Goal:** Define contract for RTDB seed import process
- **Decision Made:**
  - Use deterministic PowerShell import builder: `.squad/scripts/build-seed-import.ps1`
  - Reads: `.squad/data/buffalo-small-businesses-seed.json`
  - Validates: Exactly 20 records
  - Output: `.squad/data/buffalo-small-businesses-rtdb-seed.json`
  - Imports to: `/businesses` path (only with `-Apply` flag)
  - Seed schema (MVP): `name`, `category`, `address`, `lat`, `lng` (flattened, no nested fields)
  - Runtime requirements for `-Apply` mode: `FIREBASE_DATABASE_URL`, `FIREBASE_DATABASE_SECRET`
  - Without credentials, script remains dry-run only (keeps local execution unblocked)
- **Decision Recorded:** Decision #4 (Realtime Database Seed Import Contract)
- **Status:** Decision approved, implementation pending user Firebase credentials

## Blockers

- ⏳ Awaiting user Firebase credentials:
  - `FIREBASE_DATABASE_URL`
  - `FIREBASE_DATABASE_SECRET`
- ⏳ Awaiting user Firebase Realtime Database setup (must be enabled in project)

## Next Steps

1. User provides Firebase credentials and environment secrets
2. Implement PowerShell seed import builder (`.squad/scripts/build-seed-import.ps1`)
3. Test dry-run mode (validates 20 records, no `-Apply` flag)
4. Test `-Apply` mode (actual RTDB import once credentials available)
5. Verify import creates `/businesses/{id}` entries with correct schema

## Scope Alignment

- ✅ Seed contract aligned to MVP minimal data model
- ✅ No Firestore-specific behavior; pure Realtime Database
- ✅ Deterministic import; no side effects in dry-run
- ✅ Script keeps local development unblocked without credentials

## Completed Work (Session 2026-04-18, Firebase Setup)

### Task: arthur-firebase-setup (COMPLETE)
- **Date:** 2026-04-18
- **Goal:** Move app to current FlutterFire initialization pattern and close Firebase wiring gaps.
- **Implemented:**
  - Switched app bootstrap to `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
  - Added `lib/firebase_options.dart` placeholder scaffold to be replaced by `flutterfire configure` output.
  - Enabled Android Google Services Gradle plugin in `android/settings.gradle.kts` and `android/app/build.gradle.kts`.
  - Gitignored generated Firebase service files for Android/iOS/macOS.
  - Updated `htma2/README.md` to official `flutterfire configure` flow across supported platforms.
- **Validation:**
  - `flutter pub get`, `flutter analyze`, `flutter test` all pass after changes.
- **Decision Recorded:** Decision #11 (FlutterFire-based Firebase Setup)
- **Status:** Complete; app compiles cleanly with modern FlutterFire patterns. Pending user action: run `flutterfire configure --project=<id> --platforms=android,ios,macos,web,windows,linux` to generate real Firebase options/config.

## Completed Work (Session 2026-04-18, Firebase CLI Auth Recovery)

### Task: arthur-firebase-auth-fix (COMPLETE)
- **Date:** 2026-04-18
- **Goal:** Diagnose repeated Firebase CLI token refresh failures and provide reliable Windows recovery path.
- **Findings:**
  - Environment running `firebase-tools` `15.15.0` and Node via nvm (`C:\nvm4w\nodejs\firebase.ps1`).
  - Firebase configstore token file absent locally, while gcloud ADC files exist:
    - `C:\Users\wylde\AppData\Roaming\gcloud\application_default_credentials.json`
    - `C:\Users\wylde\AppData\Roaming\gcloud\credentials.db`
  - Failure signature (`oauth2 400` + `UNAUTHENTICATED 401` + `ACCESS_TOKEN_TYPE_UNSUPPORTED`) matches stale/unsupported cached credential source.
- **Implemented:**
  - Documented minimal, ordered recovery sequence:
    1. `firebase logout` + `firebase login --reauth`
    2. Clear `%APPDATA%\configstore\firebase-tools.json` only if needed
    3. Clear stale ADC (`%APPDATA%\gcloud\application_default_credentials.json`) if still failing
    4. Verify with `firebase projects:list`
  - Added CI-safe fallback with service account via `GOOGLE_APPLICATION_CREDENTIALS`.
  - Added checks for nvm/global binary mismatch and credential source overrides (`GOOGLE_APPLICATION_CREDENTIALS`, `FIREBASE_TOKEN`).
- **Decision Recorded:** `\.squad\decisions\inbox\arthur-firebase-auth-fix.md`
- **Status:** Complete; runbook ready for operator use.

## Completed Work (Session 2026-04-18, Package Rename Fallout Fix)

### Task: arthur-package-rename-fix (COMPLETE)
- **Date:** 2026-04-18
- **Goal:** Repair test/build breakage after package rename from `htma2` to `htmarevived`.
- **Findings:**
  - Tests and app imports were already updated to `package:htmarevived/...`.
  - Project package name remained stale in `htma2/pubspec.yaml` (`name: htma2`), so Dart package resolution for `htmarevived` failed.
  - Android `applicationId` still referenced old package stem (`com.example.htma2`) while namespace was already `com.example.htmarevived`.
- **Implemented:**
  - Confirmed package name is `htmarevived` in `htma2/pubspec.yaml`.
  - Updated Android `applicationId` to `com.example.htmarevived` in `htma2/android/app/build.gradle.kts`.
  - Ran `flutter test` to validate resolution and runtime behavior.
- **Decision Recorded:** Decision #13 (Package Rename Alignment)
- **Status:** Complete; test suite passing.

## Completed Work (Session 2026-04-18, Package Rename Validation)

### Task: arthur-validate-rename-fix (COMPLETE)
- **Date:** 2026-04-18
- **Goal:** Confirm package rename to `htmarevived` is complete and test suite passes
- **Implementation:**
  - Verified `htma2/pubspec.yaml` updated to `name: htmarevived`
  - Verified `android/app/build.gradle.kts` updated to `applicationId = "com.example.htmarevived"`
  - Ran `flutter pub get` to refresh package resolution
  - Ran `flutter analyze` to check for lint issues
  - Ran `flutter test` to validate test suite
- **Validation Results:**
  - ✅ Package resolution restored across all imports
  - ✅ All tests passing (no import errors)
  - ✅ No lint violations introduced
- **Decision Reference:** Decision #13 (Package Rename Alignment)
- **Status:** Complete; rename fallout fully resolved, test baseline established

## Completed Work (Session 2026-04-19, Firebase Init Robustness Fix)

### Task: arthur-firebase-init-fix (COMPLETE)
- **Date:** 2026-04-19
- **Goal:** Diagnose why Firebase initialization/connectivity fails and harden startup with actionable errors.
- **Findings:**
  - `lib/firebase_options.dart` was still placeholder-based (`REPLACE_WITH_FLUTTERFIRE_CONFIGURE`) for most platforms, causing Firebase init failure.
  - `FIREBASE_DATABASE_URL` accepted unchecked input; console URLs could be supplied and fail later without clear guidance.
  - Startup error text was generic and did not clearly separate FlutterFire config failure from URL misconfiguration.
- **Implemented:**
  - Added strict `FIREBASE_DATABASE_URL` validation (HTTPS + RTDB endpoint host + console URL rejection) in `AppConfig`.
  - Added pre-init Firebase options placeholder detection with explicit setup error in bootstrap.
  - Improved Firebase initialization failure message to include Firebase error code and next action.
  - Populated Android `DefaultFirebaseOptions.android` from `android/app/google-services.json` to unblock current Android init path.
  - Updated docs/templates to emphasize endpoint URL format and disallow console URLs.
  - Added tests for database URL validation.
- **Validation:**
  - `flutter pub get` ✅
  - `flutter analyze` ✅
  - `flutter test` ✅
  - `flutter run -d windows --no-resident ...` build/startup smoke ✅
- **Decision Recorded:** `\.squad\decisions\inbox\arthur-firebase-init-fix.md`
- **Status:** Complete; initialization path now fails fast with actionable diagnostics and correct URL handling.

