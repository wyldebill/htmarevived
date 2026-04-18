# Project Context

- **Owner:** william austin
- **Project:** Buffalo business tracker app for Flutter
- **Stack:** Flutter, Dart, Firebase/Firestore
- **Created:** 2026-04-18T17:33:25.644Z

## Learnings

- Starter Flutter app lives in `htma2\`.
- Core product domain is local businesses in Buffalo, MN.
- MVP scope is narrowed: no visit tracking, minimal data model (name, category, address, lat/lng only).
- Environment variables control API key access (build-time and runtime).
- Firebase config is platform-specific (JSON/plist files, not env vars).

## Completed Work (Session 2026-04-18)

### Task: saito-document-env ✅
- **Date:** 2026-04-18
- **Goal:** Review env strategy and documentation; align with implementation
- **Output:**
  - Updated `README.md` (quick-start guide)
  - Created `docs/ENVIRONMENT_SETUP.md` (comprehensive 80+ line guide)
  - Updated `.env.example` with `FIREBASE_DATABASE_URL` and Firebase config notes
  - Verified `AppConfig.load()` implementation (two required vars: `GOOGLE_MAPS_API_KEY`, `FIREBASE_DATABASE_URL`)
  - Confirmed resolution order: `--dart-define` → `.env` → system env vars
- **Decision Recorded:** Decision #6 (Environment Variable Documentation — FINALIZED)

### Task: saito-phase1-data-env ✅
- **Date:** 2026-04-18
- **Goal:** Lock dataset and finalize environment strategy
- **Output:**
  - Locked 20 Buffalo, MN small businesses (name, category, address, lat, lng)
  - Created `.squad/data/buffalo-small-businesses-seed.json`
  - Created `.squad/data/buffalo-small-businesses-sources.md` (verification notes)
  - Defined two-layer env config (build-time: `GOOGLE_MAPS_API_KEY` via `--dart-define`; runtime: via `String.fromEnvironment()`)
  - Created `.squad/config/env-strategy.md`
  - Updated `.env.example`
- **Decisions Recorded:** Decision #2 (Seed Dataset — LOCKED), Decision #3 (Environment Strategy — FINALIZED)

## Blockers Cleared
- ✅ 1.1 (lock-buffalo-dataset) — DONE
- ✅ 1.2 (env-var strategy) — DONE
- Unblocks: 2.1 (Ariadne Firebase), 2.5 (Arthur RTDB seed import)

## Next Steps for Team
- Arthur: Implement RTDB seed import using `.squad/scripts/build-seed-import.ps1`
- Ariadne: Complete Firebase integration (waiting for user config files and API keys)
- Eames: Prepare integration tests once Phase 2-3 tasks complete

