# htmarevived

Flutter app foundation for the Buffalo Business Tracker MVP.

## Current MVP App Shell

- Startup flow: `main.dart` -> `AppBootstrap` (loads environment + initializes Firebase)
- Shell flow: bottom navigation with two top-level views:
  - **List**: searchable business list
  - **Map**: Google Maps pins for all businesses
- Detail flow: read-only business detail screen from list/map selections

Integration boundaries:

- Realtime Database reads are isolated in `lib/features/businesses/data/rtdb_business_repository.dart`
- Google Maps widget integration is isolated in `lib/features/businesses/integrations/google_maps/`
- Presentation pages only compose UI and navigation

## Setup & Running Locally

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Configure environment variables

Copy the template file and fill in your Google Maps API key:

```bash
Copy-Item .env.example .env
```

Edit `.env` and add:

- `FIREBASE_DATABASE_URL` *(required)* – Use the **Realtime Database endpoint URL** from Firebase Console > Realtime Database > Data.
  - Valid examples:
    - `https://my-project-id-default-rtdb.firebaseio.com/`
    - `https://my-project-id-default-rtdb.firebasedatabase.app/`
  - Do **not** use a console URL like `https://console.firebase.google.com/...`
- `GOOGLE_MAPS_API_KEY` *(required for map tab only)* – Get this from [Google Cloud Console](https://console.cloud.google.com/)
  - Enable **Maps SDK for Android** and **Maps SDK for iOS**
  - Create an API key with appropriate restrictions

Alternatively, pass these values at runtime using `--dart-define`:

```bash
flutter run --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY --dart-define=FIREBASE_DATABASE_URL=YOUR_URL
```

> For Google Maps tiles to render on-device, the native platform also needs `GOOGLE_MAPS_API_KEY`.
> On Android this project reads the key from (in order): environment variable, `android/local.properties`, then `.env`.

> If `GOOGLE_MAPS_API_KEY` is missing, the app still starts and list/detail screens work. The map tab shows a friendly configuration message instead of crashing.
>
> If `FIREBASE_DATABASE_URL` is malformed (for example, a Firebase Console URL instead of an endpoint), startup fails with a specific, actionable message.

### 3. Configure Firebase with FlutterFire CLI

Use the official FlutterFire flow to generate `lib/firebase_options.dart` and platform config files:

```bash
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID --platforms=android,ios,macos,web,windows,linux
```

This command will:

- Generate `lib/firebase_options.dart`
- Write platform service files where needed (`google-services.json`, `GoogleService-Info.plist`)
- Keep initialization aligned with `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`

> Notes:
> - `lib/firebase_options.dart` is currently a placeholder and must be replaced by the generated output.
> - `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, and `macos/Runner/GoogleService-Info.plist` are gitignored.

### 4. Run the app

```bash
flutter run
```

If `FIREBASE_DATABASE_URL` is missing or Firebase is not configured via FlutterFire, the app shows a startup error screen with retry options.

### 5. Seed Realtime Database data

This repo includes starter data at `database/seed/businesses.json`.

Use Firebase CLI to write it to `/businesses`:

```bash
firebase database:set /businesses database/seed/businesses.json --project=YOUR_FIREBASE_PROJECT_ID
```

If your database is in a non-default region, include `--instance`:

```bash
firebase database:set /businesses database/seed/businesses.json --project=YOUR_FIREBASE_PROJECT_ID --instance=YOUR_DATABASE_INSTANCE_NAME
```

## Building for Release

### Android

```bash
flutter build apk --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY --dart-define=FIREBASE_DATABASE_URL=YOUR_URL
```

### iOS

```bash
export GOOGLE_MAPS_API_KEY=YOUR_KEY
export FIREBASE_DATABASE_URL=YOUR_URL
flutter build ios --dart-define=GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY --dart-define=FIREBASE_DATABASE_URL=$FIREBASE_DATABASE_URL
```

## Providing API Keys Later (Deployment)

For CI/CD or production builds:

1. **GitHub Actions (CI/CD):**
   - Add `GOOGLE_MAPS_API_KEY` and `FIREBASE_DATABASE_URL` as repository secrets
   - Reference them in workflows: `${{ secrets.GOOGLE_MAPS_API_KEY }}`

2. **Local CI builds:**
   - Use `--dart-define` flags or a secure `.env` file (not committed)

3. **Firebase configuration:**
   - Run `flutterfire configure` in CI or release prep to generate `firebase_options.dart` and service files

## Further Reading

For detailed environment configuration, troubleshooting, and security best practices, see [`docs/ENVIRONMENT_SETUP.md`](../docs/ENVIRONMENT_SETUP.md).
