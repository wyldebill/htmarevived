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


