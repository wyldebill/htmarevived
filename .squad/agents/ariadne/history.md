# Project Context

- **Owner:** william austin
- **Project:** Buffalo business tracker app for Flutter
- **Stack:** Flutter, Dart, Firebase/Realtime Database, Google Maps
- **Created:** 2026-04-18T17:33:25.644Z

## Learnings

- Starter Flutter app lives in `htma2\`.
- UI currently consists of the stock counter template and needs full restructuring.
- MVP scope is narrowed: no visit tracking, minimal data model (name, category, address, lat/lng only).
- Environment variables control API key access (build-time and runtime).
- Firebase config is platform-specific (JSON/plist files, not env vars).
- List/map view needs graceful fallback when Google Maps API key is absent.

## Completed Work (Session 2026-04-18)

### Task: ariadne-phase1-firebase ✅
- **Date:** 2026-04-18
- **Goal:** Scaffold Firebase foundation and boot flow
- **Output:**
  - Added Flutter dependencies: `firebase_core`, `firebase_database`, `flutter_dotenv`, `google_maps_flutter`
  - Implemented startup boot flow in `htma2/lib/main.dart`:
    - Environment loading + validation
    - Firebase initialization
    - Loading state, error state, retry action
  - Created config utility: `htma2/lib/core/config/app_config.dart`
  - Set up environment templates: `.env.example`, local `.env`
  - Updated `htma2/README.md` with setup steps
- **Decision Recorded:** Decision #5 (Firebase Foundation Scaffolding)
- **Status:** Complete, awaiting user Firebase config files and API keys

### Task: ariadne-scaffold-shell ✅
- **Date:** 2026-04-18
- **Goal:** Build feature-oriented app shell for MVP
- **Output:**
  - Feature-oriented architecture with top-level navigation (list + map tabs)
  - Read-only business detail route (no add/edit)
  - No visit tracking workflow included
  - Explicit startup orchestration in `lib/app/bootstrap/app_bootstrap.dart`
  - Separation of concerns:
    - RTDB access in `features/businesses/data/rtdb_business_repository.dart`
    - Google Maps integration in `features/businesses/integrations/google_maps/business_google_map.dart`
  - Configuration kept secret-free via `AppConfig`
- **Decision Recorded:** Decision #8 (MVP Shell Composition)
- **Status:** Shell scaffolded, ready for Phase 3 integration

### Task: ariadne-list-maps ✅
- **Date:** 2026-04-18
- **Goal:** Implement list view with graceful map fallback and key gating
- **Output:**
  - Completed list view MVP with search + category chips + empty-filter state
  - Data flow read-only: `RtdbBusinessRepository` → `BusinessShellPage` → list/map/detail
  - Updated startup config contract:
    - `FIREBASE_DATABASE_URL` remains required at app startup
    - `GOOGLE_MAPS_API_KEY` is optional at startup, required only for rendering map tab
  - Graceful map fallback state when key is absent (list/detail remain fully usable)
  - Business model parsing accepts both flattened `lat`/`lng` and legacy nested `coordinates.lat`/`coordinates.lng`
- **Decision Recorded:** Decision #9 (List/Map Resiliency & Key Gating)
- **Status:** List view complete, ready for Phase 3 map integration

## Blockers Cleared

- ✅ Env strategy finalized (Saito)
- ✅ Firebase scaffolding complete
- ✅ App shell composition complete
- ✅ List view with graceful fallback complete
- Unblocks: Phase 3 Google Maps integration, Phase 4 testing

## Critical Remaining Inputs

1. Firebase platform configuration files:
   - `htma2/android/app/google-services.json`
   - `htma2/ios/Runner/GoogleService-Info.plist`
2. Runtime/build values:
   - `GOOGLE_MAPS_API_KEY`
   - `FIREBASE_DATABASE_URL`
3. Firebase project with Realtime Database enabled

## Next Steps

- Phase 3: Integrate Google Maps SDK once API key provided
- Build detail screen, complete navigation flows
- Validate compile-safety (no compile errors at all times)
- Target 60% unit test coverage


