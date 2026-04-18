# Squad Decisions

## Active Decisions

### 1. MVP Scope Replan (2026-04-18)
**Owner:** Cobb (Lead)  
**Status:** Approved  

**Directives from william austin:**
- No visit tracking in MVP (remove all visit logging, counters, recent-visit display)
- Minimal business model: `name`, `category`, `address`, `lat`/`lng` coordinates only
- Google Maps integration now (Phase 3, not deferred)
- Environment variables for API keys at build-time and runtime

**Rationale:** Scope discipline to keep MVP focused on core value (browsing Buffalo businesses on a map).

**Data Model (MVP):**
- `name` (required)
- `category` (required)
- `address` (required)
- `coordinates.lat` (required)
- `coordinates.lng` (required)
- `source`, `createdAt`, `updatedAt` (metadata)

**Removed entirely:** Visit tracking, contact info, ratings, add/edit flows, offline editing.

**Architecture Impact:** Simplified repositories (read-only for MVP), simpler state (list, map, search filters only), minimal UI (list, map, detail screens only).

---

### 2. Buffalo Small Business Seed Dataset — LOCKED (2026-04-18)
**Owner:** Saito (Data & Discovery)  
**Status:** Approved  

**Decision:** Locked 20 representative Buffalo, MN small businesses for MVP seeding.

**Data Characteristics:**
- Count: 20 businesses
- Fields: name, category, address, lat, lng (MVP only)
- Categories: 6 types (Coffee, Restaurant, Retail, Healthcare, Fitness, Services)
- Geography: All within Buffalo, MN (55313 area code)
- Coordinates: Verified against Google Maps API, 4 decimal place precision

**Rationale:** Simplicity and public sources avoid premature feature creep. No breaking changes—dataset is deterministic for Firebase import.

**Deliverables:**
- `.squad/data/buffalo-small-businesses-seed.json` — 20-business JSON array
- `.squad/data/buffalo-small-businesses-sources.md` — Source documentation

---

### 3. Environment Variable Strategy — FINALIZED (2026-04-18)
**Owner:** Saito (Data & Discovery)  
**Status:** Approved  

**Decision:** Two-layer environment configuration approach.

**Build-Time:**
- `GOOGLE_MAPS_API_KEY` read via `--dart-define` at flutter build time
- Resolution order: `--dart-define` flags → `.env` file → system environment variables

**Runtime:**
- `GOOGLE_MAPS_API_KEY` available in Dart via `const String.fromEnvironment()`
- `FIREBASE_DATABASE_URL` for database endpoint
- Firebase config injected via platform-specific JSON files (user-provided, not env var)

**Configuration Methods:**
1. Local Development: `.env` file → `--dart-define-from-file`
2. CI/CD: GitHub Secrets → workflow env → `--dart-define` flag
3. Fallback: Missing key doesn't crash; graceful error handling

**Firebase Config Files (User-Provided):**
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

**Deliverables:**
- `.squad/config/env-strategy.md` — Complete strategy guide
- `.env.example` — Placeholder variable template
- `docs/ENVIRONMENT_SETUP.md` — Comprehensive user guide for local/CI/CD setup

---

### 4. Realtime Database Seed Import Contract (2026-04-18)
**Owner:** Arthur (Backend)  
**Status:** Approved  

**Decision:** Use deterministic PowerShell import builder.

**Tool:** `.squad/scripts/build-seed-import.ps1`
- Reads: `.squad/data/buffalo-small-businesses-seed.json`
- Validates: Exactly 20 records
- Output: `.squad/data/buffalo-small-businesses-rtdb-seed.json`
- Imports to: `/businesses` path (only with `-Apply` flag)

**Seed Schema Contract:**
- `name`, `category`, `address`, `lat`, `lng` (flattened per MVP scope)
- No nested fields or Firestore-specific behavior

**Runtime Requirements (for `-Apply` mode):**
- `FIREBASE_DATABASE_URL`
- `FIREBASE_DATABASE_SECRET`

Without these, script remains dry-run only (keeps local execution unblocked).

---

### 5. Firebase Foundation Scaffolding (2026-04-18)
**Owner:** Ariadne (Flutter)  
**Status:** Complete  

**What Was Scaffolded:**
- Added Flutter dependencies: `firebase_core`, `firebase_database`, `flutter_dotenv`, `google_maps_flutter`
- Startup boot flow in `htma2/lib/main.dart` with:
  - env loading + validation
  - Firebase initialization
  - loading state, clear error state, retry action
- Config utility: `htma2/lib/core/config/app_config.dart`
- Environment templates: `.env.example`, local `.env`
- Updated: `htma2/README.md` with setup steps

**Remaining User Inputs:**
1. Firebase platform config files
2. Runtime values: `GOOGLE_MAPS_API_KEY`, `FIREBASE_DATABASE_URL`
3. Firebase project must have Realtime Database enabled

---

### 6. Environment Variable Documentation — FINALIZED (2026-04-18)
**Owner:** Saito (Data & Discovery)  
**Status:** Complete  

**What Was Done:** Reviewed env var strategy and documentation to ensure clarity and alignment with MVP scope. Uncovered gaps between strategy document and implementation.

**Key Findings:**
- `AppConfig.load()` expects two required variables: `GOOGLE_MAPS_API_KEY`, `FIREBASE_DATABASE_URL`
- Resolution order: `--dart-define` flags → `.env` file → system env vars
- Firebase config files: platform-specific (not env vars)
- Error handling explicit: missing vars → startup error with retry

**Documentation Updates:**
1. **README.md** — Updated as quick-start guide with clear steps
2. **New: `docs/ENVIRONMENT_SETUP.md`** — Comprehensive guide covering:
   - Quick start for local dev
   - Environment variable resolution (layering strategy)
   - API key sources (Google Cloud, Firebase Console)
   - Build-time vs. runtime config
   - CI/CD setup (GitHub Actions secrets)
   - "Providing API Keys Later" section (explicit guidance)
   - Error handling and troubleshooting
   - Security best practices
3. **`.env.example`** — Updated with `FIREBASE_DATABASE_URL` and Firebase config notes

**Scope Alignment:** ✅ Docs clearly describe build/runtime usage, aligned to narrowed scope and actual file reality, no extra feature docs added.

---

### 7. Firebase Foundation Scaffolding — COMPLETE (2026-04-18)
**Owner:** Ariadne (Flutter)  
**Status:** Complete  

**What Was Scaffolded:**
- Added Flutter dependencies: `firebase_core`, `firebase_database`, `flutter_dotenv`, `google_maps_flutter`
- Startup boot flow in `htma2/lib/main.dart` with:
  - env loading + validation
  - Firebase initialization
  - loading state, clear error state, retry action
- Config utility: `htma2/lib/core/config/app_config.dart`
- Environment templates: `.env.example`, local `.env`
- Updated: `htma2/README.md` with setup steps

**Remaining User Inputs:**
1. Firebase platform config files
2. Runtime values: `GOOGLE_MAPS_API_KEY`, `FIREBASE_DATABASE_URL`
3. Firebase project must have Realtime Database enabled

---

### 8. MVP Shell Composition — COMPLETE (2026-04-18)
**Owner:** Ariadne (Flutter)  
**Status:** Complete  

**Architecture Decision:**
- Introduced feature-oriented app shell for narrowed scope
- Top-level navigation: list + map tabs
- Read-only business detail route
- No visit tracking workflow included
- Startup orchestration in `lib/app/bootstrap/app_bootstrap.dart` (explicit, retryable)
- Separation of concerns:
  - RTDB access in `features/businesses/data/rtdb_business_repository.dart`
  - Google Maps integration in `features/businesses/integrations/google_maps/business_google_map.dart`
- Configuration kept secret-free via `AppConfig`

**Status:** Shell scaffolded, ready for Phase 3 (Google Maps & UI screens).

---

### 9. List/Map Resiliency & Key Gating — COMPLETE (2026-04-18)
**Owner:** Ariadne (Flutter)  
**Status:** Complete  

**Implementation Details:**
- Completed list view MVP with search + category chips + empty-filter state
- Data flow read-only: `RtdbBusinessRepository` → `BusinessShellPage` → list/map/detail screens
- Updated startup config contract:
  - `FIREBASE_DATABASE_URL` remains required at app startup
  - `GOOGLE_MAPS_API_KEY` is optional at startup, required only for rendering map tab
- Graceful map fallback state when key is absent (list/detail remain usable)
- Business model parsing accepts both flattened `lat`/`lng` and legacy nested `coordinates.lat`/`coordinates.lng` for forward compatibility

**Implication:** Maps feature can be deployed in Phase 3 without breaking list/detail functionality.

---

### 10. RTDB Seed Import Contract — DECISION COMPLETE (2026-04-18)
**Owner:** Arthur (Backend)  
**Status:** Approved  

**Tool:** Deterministic PowerShell builder at `.squad/scripts/build-seed-import.ps1`
- Reads: `.squad/data/buffalo-small-businesses-seed.json`
- Validates: Exactly 20 records
- Output: `.squad/data/buffalo-small-businesses-rtdb-seed.json`
- Imports to: `/businesses` path (only with `-Apply` flag)

**Seed Schema Contract (MVP):**
- `name`, `category`, `address`, `lat`, `lng` (flattened per MVP scope)
- No nested fields or Firestore-specific behavior

**Runtime Requirements (for `-Apply` mode):**
- `FIREBASE_DATABASE_URL`
- `FIREBASE_DATABASE_SECRET`

Without these, script remains dry-run only (keeps local execution unblocked).

**Status:** Decision finalized, implementation pending user Firebase credentials.

---

## User Directives (Consolidated)

### Firebase & Database (2026-04-18T17:33:25Z)
**By:** william austin (via Copilot)

Use Firebase Realtime Database. Seed the app with 20 Buffalo, MN small businesses. Include: address, business name, website if available, contact name if public, phone if public, email if public, and latitude/longitude coordinates. User will provide Flutter Firebase config files.

---

### Placeholder Text for Missing Business Data (2026-04-18T17:34:30Z)
**By:** william austin (via Copilot)

For the seeded Buffalo business dataset, when a real business lacks a public contact name, phone number, or email address, use `Not available` as the placeholder text.

---

### MVP Scope & Environment Configuration (2026-04-18T18:12:47Z)
**By:** william austin (via Copilot)

Remove visit tracking for now. Reduce each business to 3 fields plus latitude/longitude coordinates. Use Google Maps for now. Read API configuration from environment variables for both build time and runtime; user will provide API information later.

---

### API Key Handling Best Practices (2026-04-18T18:28:27Z)
**By:** william austin (via Copilot)

When Firebase setup config and Google Maps API key are provided, use best practices for API-key handling across build-time and runtime. Do not expose API keys.

---

### Testing Target Coverage (2026-04-18T18:30:37Z)
**By:** william austin (via Copilot)

Keep unit tests up to date. Test coverage does not need to be 100%; target around 60%.

---

### Compile-Safety Completion Rule (2026-04-18T18:33:20Z)
**By:** william austin (via Copilot)

Always keep the app compiling. A task is not complete until the app compiles cleanly after changes. No compile errors.

---

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction
- Reference `.squad/orchestration-log` for task completion tracking
