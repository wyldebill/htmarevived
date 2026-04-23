# Environment Setup Guide

This document explains how the Buffalo Business Tracker MVP handles environment variables for build-time and runtime configuration.

## Overview

The app requires two primary configurations:

1. **Google Maps API Key** – Enables map rendering on Android and iOS
2. **Firebase Database URL** – Provides backend data service access

Both can be supplied via:
- `.env` file (local development)
- `--dart-define` command-line flags (build-time)
- Environment variables (CI/CD and release builds)

Firebase platform configuration files (`.json` and `.plist`) are provided separately by the project owner.

---

## Quick Start

### Local Development

1. Copy the env template:
   ```bash
   Copy-Item .env.example .env
   ```

2. Edit `.env` and fill in your keys:
   ```
   GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY_HERE
   FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
   FLUTTER_ENV=dev
   ```

3. Run the app:
   ```bash
   flutter run
   ```

The app will read from `.env` automatically via `flutter_dotenv` and `AppConfig.load()`.

### Alternative: Command-Line Flags

If you don't want a `.env` file, pass variables at runtime:

```bash
flutter run \
  --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY \
  --dart-define=FIREBASE_DATABASE_URL=YOUR_URL
```

---

## Environment Variables Explained

### Required Variables

| Variable | Purpose | Example | Source |
|----------|---------|---------|--------|
| `GOOGLE_MAPS_API_KEY` | Unlocks Google Maps SDK on Android and iOS | `AIzaSyD...` | [Google Cloud Console](https://console.cloud.google.com/) |
| `FIREBASE_DATABASE_URL` | Firebase Realtime Database endpoint | `https://my-project.firebaseio.com` | [Firebase Console](https://console.firebase.google.com/) | Find this in the Firebase Project, Real Time Database, Data tab.  The URL to the database will be above the data as a link.

### Optional Variables

| Variable | Purpose | Default | Example |
|----------|---------|---------|--------|
| `FLUTTER_ENV` | Environment indicator | `dev` | `dev`, `staging`, `prod` |

---

## How Environment Variables Are Resolved

The app resolves variables in this order (first match wins):

1. **`--dart-define` flag** (highest priority)
   ```bash
   flutter run --dart-define=GOOGLE_MAPS_API_KEY=my-key
   ```

2. **`.env` file** (local development)
   ```
   GOOGLE_MAPS_API_KEY=my-key
   ```

3. **System environment variable** (CI/CD)
   ```bash
   export GOOGLE_MAPS_API_KEY=my-key
   flutter run
   ```

This layering allows flexible configuration:
- **Dev:** Use `.env` file
- **CI/CD:** Pass `--dart-define` from GitHub Secrets
- **Production:** Use system env vars or secure vaults

---

## Getting API Keys

### Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable these APIs:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**
4. Go to **Credentials** → **Create API Key**
5. (Recommended) Add key restrictions:
   - **Application restrictions:** Android/iOS apps
   - **API restrictions:** Restrict to Maps SDKs only
6. Copy the key to `.env` or pass via `--dart-define`

### Firebase Database URL

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Realtime Database**
4. View your database URL (e.g., `https://my-project.firebaseio.com`)
5. Copy to `.env` or pass via `--dart-define`

### Firebase Platform Config Files

The project owner (or DevOps) provides:

- **Android:** `google-services.json`
  - Download from Firebase Console → Project Settings → Download Android config
  - Place at: `android/app/google-services.json`

- **iOS:** `GoogleService-Info.plist`
  - Download from Firebase Console → Project Settings → Download iOS config
  - Place at: `ios/Runner/GoogleService-Info.plist`

**Do not commit these files to git** — they contain sensitive credentials.

---

## Using Environment Variables at Build Time

### Android Build

Flutter automatically injects `--dart-define` values into the app. No additional gradle configuration needed.

```bash
flutter build apk \
  --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY \
  --dart-define=FIREBASE_DATABASE_URL=YOUR_URL
```

### iOS Build

Same as Android — Flutter handles injection:

```bash
flutter build ios \
  --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY \
  --dart-define=FIREBASE_DATABASE_URL=YOUR_URL
```

---

## Using Environment Variables at Runtime

The app reads variables in `main.dart` via `AppConfig.load()`:

```dart
Future<AppConfig> _bootstrap() async {
  final config = await AppConfig.load();
  await Firebase.initializeApp();
  return config;
}
```

`AppConfig` validates that both `GOOGLE_MAPS_API_KEY` and `FIREBASE_DATABASE_URL` are present before the app starts. If missing, it shows an error screen with retry.

---

## CI/CD Configuration (GitHub Actions)

### 1. Add Repository Secrets

Go to **Settings > Secrets and variables > Actions** and add:

- `GOOGLE_MAPS_API_KEY` – Your Google Maps API key
- `FIREBASE_DATABASE_URL` – Your Firebase database URL

### 2. Use in Workflow

In `.github/workflows/build.yml`:

```yaml
- name: Build Flutter App
  env:
    GOOGLE_MAPS_API_KEY: ${{ secrets.GOOGLE_MAPS_API_KEY }}
    FIREBASE_DATABASE_URL: ${{ secrets.FIREBASE_DATABASE_URL }}
  run: |
    flutter build apk \
      --dart-define=GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY \
      --dart-define=FIREBASE_DATABASE_URL=$FIREBASE_DATABASE_URL
    flutter build ios \
      --dart-define=GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY \
      --dart-define=FIREBASE_DATABASE_URL=$FIREBASE_DATABASE_URL
```

---

## Providing API Keys Later (During Release)

If API keys are not yet available during initial development:

### Delay Strategy

1. **Immediate setup:** Firebase platform config files must be provided by the project owner before the app can start at all.
2. **API key provision window:** You have until your first build/deployment to obtain `GOOGLE_MAPS_API_KEY` and `FIREBASE_DATABASE_URL`.

### When Ready to Deploy

Once you have the keys:

1. **Local release builds:** Pass `--dart-define` flags or add to `.env`
2. **CI/CD release builds:** Add to GitHub Secrets and reference in workflow
3. **Production:** Use your organization's secret management system (e.g., AWS Secrets Manager, HashiCorp Vault)

### Preventing Accidental Key Commits

- **`.env` is gitignored** — add it to `.gitignore` if not already present
- **Firebase config files are gitignored** — place them in `.gitignore` as well
- **Never commit `--dart-define` values** — pass them at build time only

---

## Error Handling

### Missing Required Variable

**Error message:**
```
Missing required environment variables: GOOGLE_MAPS_API_KEY, FIREBASE_DATABASE_URL.
Provide them via --dart-define or htma2/.env.
```

**Solution:**
1. Check `.env` file for typos or missing values
2. If using `--dart-define`, ensure flags are spelled correctly
3. Retry the app

### Firebase Initialization Fails

**Error message:**
```
Firebase failed to initialize. Add firebase configuration files and values, then retry.
```

**Solution:**
1. Ensure `android/app/google-services.json` exists and is valid JSON
2. Ensure `ios/Runner/GoogleService-Info.plist` exists and is valid plist format
3. Check that `FIREBASE_DATABASE_URL` is correct and matches your Firebase project
4. Retry the app

### Google Maps Not Loading

The app will start normally, but map screens show:
```
Maps are temporarily unavailable. Check your configuration.
```

**Solution:**
1. Verify `GOOGLE_MAPS_API_KEY` is correct
2. Check Google Cloud Console for API quota or billing issues
3. Retry loading the map

---

## Security Best Practices

- **Never commit `.env` files** — they contain real credentials
- **Use `.env.example` as a template** — provide placeholder values for other developers
- **Rotate API keys regularly** — especially if a key is leaked
- **Use key restrictions** in Google Cloud Console to limit API usage
- **Enable billing alerts** in Google Cloud to detect unusual usage
- **Store production keys** in a secure secret management system, not in code or CI/CD env vars

---

## FAQ

**Q: Can I use the same API key for both Android and iOS?**
A: Yes, a single Google Maps API key works for both platforms. Apply the appropriate platform restrictions in Google Cloud Console if desired.

**Q: What if I don't provide `FIREBASE_DATABASE_URL` but do provide `GOOGLE_MAPS_API_KEY`?**
A: The app will fail to start with an error asking for both variables. The MVP requires Firebase.

**Q: Can I pass variables via environment variables instead of `--dart-define`?**
A: Partially — `flutter_dotenv` reads from `.env`, but `String.fromEnvironment()` requires `--dart-define` at build time. For CI/CD, export environment variables and reference them in the `--dart-define` flag.

**Q: How do I know if my API key is working?**
A: The app will start and show "Firebase foundation is initialized." on the home screen. Once the maps feature is added, you'll see a map render without errors.
