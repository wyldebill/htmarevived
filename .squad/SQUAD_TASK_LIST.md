# Buffalo Business Tracker — Squad Task List

**Last Updated:** 2026-04-18  
**Scope:** Minimal MVP — 3-field business model + Google Maps, no visit tracking  
**Status:** Ready for execution

---

## Phase 1: Lock Down Scope & Data

### PRIORITY 1.1 — Lock Buffalo Business Dataset
**Owner:** Saito (Data & Discovery)  
**Depends on:** None  
**Estimate:** 2–3 hours  

**What:**
- Source 20 real Buffalo, MN small businesses with public, verifiable information
- Collect for each: name, category, full street address, accurate latitude, longitude
- Document the source for each business (Google Maps, Yelp, local directory, public records)
- Deliver as JSON or CSV ready for Firebase import

**Acceptance:**
- 20 businesses in a structured format (JSON array preferred)
- All coordinates verified and tested with Google Maps API
- No duplicate entries
- Categories follow a consistent, simple taxonomy (e.g., "Coffee", "Restaurant", "Retail")

**Notes:**
- Use Google Maps, Yelp, or local Buffalo directories as source
- Coordinate with Arthur if Firebase schema validation is needed

---

### PRIORITY 1.2 — Define Environment Variable Strategy
**Owner:** Saito (Data & Discovery)  
**Depends on:** None  
**Estimate:** 1 hour  

**What:**
- Document the exact environment variable names for Google Maps API key (build-time and runtime)
- Define fallback strategy if env var is missing (error message, logged warning)
- Create a `.env.example` template showing required variables
- Document how CI/CD should pass these values (GitHub Secrets, local .env file, etc.)

**Acceptance:**
- Clear documentation in README or `.squad/config.md`
- `.env.example` file in repo root showing all required variables
- Strategy for both Android and iOS (if they differ)

**Notes:**
- User will supply actual API keys later
- This is a blocker for Ariadne's Phase 2 work

---

## Phase 2: Foundation & Firebase Setup

### PRIORITY 2.1 — Firebase & FlutterFire Setup
**Owner:** Ariadne (Flutter) + Arthur (Backend coordination)  
**Depends on:** 1.2 (env var strategy)  
**Estimate:** 3–4 hours  

**What:**
- Add Firebase Core and Firebase Realtime Database to pubspec.yaml
- Initialize FlutterFire with provided Firebase config files (user to supply)
- Set up app-level bootstrapping to load Firebase on app startup
- Handle Firebase initialization errors gracefully (loading state, retry UI)

**Acceptance:**
- `pubspec.yaml` includes firebase_core, firebase_database, and google_maps_flutter
- FirebaseApp.initializeApp() runs on app startup
- No Firebase initialization errors in debug build
- App shell loads (may be blank list, but no crashes)

**Notes:**
- Arthur advises on Firebase rules if needed (read-only for MVP)
- Google Maps SDK should be added here (google_maps_flutter package)

---

### PRIORITY 2.2 — Design & Serialize Business Model
**Owner:** Ariadne (Flutter)  
**Depends on:** 2.1  
**Estimate:** 2 hours  

**What:**
- Create Dart model class `Business` with exactly 5 fields:
  - `id` (Firebase key)
  - `name` (String)
  - `category` (String)
  - `address` (String)
  - `coordinates` (nested object: lat, lng)
  - `source` (String: "seeded")
  - `createdAt` (DateTime)
- Implement `toJson()` and `fromJson()` for Firebase serialization
- Add basic validation (all required fields non-empty)

**Acceptance:**
- `lib/domain/models/business.dart` with complete serialization
- Unit tests for `toJson()` / `fromJson()` round-trip
- No null-coalescing hacks; required fields enforced at model level

**Notes:**
- Keep model minimal; no optional fields
- If we add contact info later, this is the only place to change

---

### PRIORITY 2.3 — Build Repository Layer
**Owner:** Ariadne (Flutter) + Arthur (Backend coordination)  
**Depends on:** 2.2  
**Estimate:** 2–3 hours  

**What:**
- Create `BusinessRepository` abstract interface (domain layer)
- Implement `FirebaseBusinessRepository` (data layer)
- Methods:
  - `getAllBusinesses()` → `Future<List<Business>>` (read from `businesses` node)
  - `getBusinessById(id)` → `Future<Business>` (single fetch)
  - `searchBusinessesByName(query)` → `Future<List<Business>>` (client-side filter for MVP)
- Handle Firebase errors and convert to app-level exceptions

**Acceptance:**
- Repository interface in `lib/domain/repositories/`
- Implementation in `lib/data/repositories/`
- Unit tests mock Firebase and verify error handling
- No hard-coded database paths; use constants

**Notes:**
- Firebase read-only for MVP (no write operations)
- Search is client-side (all businesses loaded, filtered in memory)

---

### PRIORITY 2.4 — Scaffold App Architecture
**Owner:** Ariadne (Flutter)  
**Depends on:** 2.1  
**Estimate:** 2 hours  

**What:**
- Replace starter app structure with feature-oriented folders:
  - `lib/core/` – app-level utilities, constants, theme
  - `lib/domain/` – models, repositories, use cases
  - `lib/data/` – Firebase implementations, serialization
  - `lib/presentation/` – screens, widgets, state management
- Create `lib/main.dart` entry point that initializes Firebase and sets up app shell
- Add shared theme (Material 3 or similar; keep it simple)
- Add app-level constants file for Firebase node names and env var keys

**Acceptance:**
- Directory structure matches above layout
- `main.dart` boots Firebase and renders app shell
- Theme applied consistently (no visual bugs)
- App runs without errors (may show loading or placeholder screens)

**Notes:**
- This is the foundation for all Phase 3 screens
- Keep theme minimal (colors, fonts; no complex animations yet)

---

### PRIORITY 2.5 — Seed Firebase Database with 20 Businesses
**Owner:** Arthur (Backend) + Saito (Data)  
**Depends on:** 1.1 (dataset locked), 2.1 (Firebase setup)  
**Estimate:** 1–2 hours  

**What:**
- Take the 20-business JSON from 1.1 and import into Firebase Realtime Database
- Structure: `/businesses/{businessId}/` with name, category, address, coordinates, source, timestamps
- Verify all 20 records in Firebase console
- Document the import process (script, manual upload, or Firebase CLI command)
- Create a seed-data file (JSON) in the repo for future reference

**Acceptance:**
- 20 businesses visible in Firebase console under `/businesses/`
- All fields present and correct
- Coordinates verified against Google Maps (spot-check 3–5 entries)
- Seed script or documented process in `.squad/scripts/seed-firebase.sh` (or similar)

**Notes:**
- Arthur sets up Firebase rules to allow read-only access for now
- Saito prepares the seed file format

---

## Phase 3: Core Screens & Maps Integration

### PRIORITY 3.1 — Build Business List Screen
**Owner:** Ariadne (Flutter)  
**Depends on:** 2.3, 2.4  
**Estimate:** 3–4 hours  

**What:**
- Create `lib/presentation/screens/business_list_screen.dart`
- Display all businesses in a scrollable ListView
- Show: name, category, address for each business
- Add search TextField at the top (client-side filter by name)
- Add category filter dropdown (or chips for quick filter)
- Show loading spinner while fetching from Firebase
- Show "No businesses" message if list is empty
- Tappable list items that navigate to detail screen

**Acceptance:**
- All 20 businesses display in the list
- Search/filter works and updates list in real-time
- Loading state visible during fetch
- Taps navigate to detail screen (may be blank for now)
- No crashes on empty state

**Notes:**
- Use FutureBuilder or BLoC for state management (Ariadne's call)
- Keep UI simple; focus on functionality over polish

---

### PRIORITY 3.2 — Integrate Google Maps Screen
**Owner:** Ariadne (Flutter)  
**Depends on:** 2.3, 2.4  
**Estimate:** 4–5 hours  

**What:**
- Add `google_maps_flutter` package (already in pubspec from 2.1)
- Create `lib/presentation/screens/business_map_screen.dart`
- Read `GOOGLE_MAPS_API_KEY` from environment at runtime
- Display all 20 businesses as map pins (Markers)
- Each pin labeled with business name and address
- Center map on Buffalo, MN (rough center of dataset)
- Tappable pins that navigate to detail screen
- Show loading spinner while fetching business list from Firebase

**Acceptance:**
- Map displays correctly with all 20 pins
- Pins are clickable and navigate to detail screen
- Pin labels show name and address (or name only, user's call)
- Map centers on Buffalo area
- API key read from environment variable (no hardcoding)
- No API key errors if variable is missing (graceful error message)

**Notes:**
- Coordinate with Saito on API key setup
- iOS and Android both need API key configuration
- Consider info window on tap vs. direct navigation

---

### PRIORITY 3.3 — Build Business Detail Screen
**Owner:** Ariadne (Flutter)  
**Depends on:** 2.3, 3.1  
**Estimate:** 2–3 hours  

**What:**
- Create `lib/presentation/screens/business_detail_screen.dart`
- Display selected business: name, category, address
- Show a map snippet (small embedded map) with the business pin
- Show a "View on Google Maps" button (deep link to Google Maps or web URL)
- Back button to return to list or map
- Basic layout (column, card style; keep it simple)

**Acceptance:**
- All business info displays correctly
- Map snippet shows correct location
- "View on Google Maps" link works (opens Maps app or web)
- Navigation back to previous screen works
- No crashes or missing data

**Notes:**
- Can reuse a small GoogleMapsWidget (20–30% of screen)
- Arthur can advise on deep linking to Maps if needed

---

## Phase 4: Hardening & Testing

### PRIORITY 4.1 — Add Domain & Repository Tests
**Owner:** Eames (Tester) + Ariadne (Flutter)  
**Depends on:** 2.2, 2.3  
**Estimate:** 2–3 hours  

**What:**
- Replace `test/widget_test.dart` (starter template)
- Add unit tests for `Business` model (serialization, validation)
- Add unit tests for `BusinessRepository` (mock Firebase, error cases)
- Add basic widget tests for list and detail screens
- Aim for >70% code coverage on domain and repository layers

**Acceptance:**
- No starter template tests remaining
- Business model serialization tested (toJson/fromJson round-trip)
- Repository tested with mocked Firebase responses
- Error handling tested (missing fields, network errors)
- All tests pass in CI/CD

**Notes:**
- Use `mockito` or `mocktail` for Firebase mocks
- Keep test expectations clear and simple

---

### PRIORITY 4.2 — Add Loading, Empty, and Error States
**Owner:** Ariadne (Flutter)  
**Depends on:** 3.1, 3.2  
**Estimate:** 1–2 hours  

**What:**
- List screen: show loading spinner, "No businesses found" message, error snackbar
- Map screen: show loading spinner, error snackbar if Firebase fails
- Detail screen: show loading state while fetching single business
- All error messages are user-friendly (no Firebase error codes)

**Acceptance:**
- Loading UI appears and disappears smoothly
- Empty state message is clear
- Error messages don't leak Firebase internals
- No stuck spinners or invisible errors

**Notes:**
- Reuse widgets across screens to keep code DRY

---

### PRIORITY 4.3 — Document Setup & Local Development
**Owner:** Saito (Data) + Ariadne (Flutter)  
**Depends on:** All phases  
**Estimate:** 2 hours  

**What:**
- Create or update `README.md` with:
  - Local development setup (Flutter SDK, dependencies)
  - Firebase setup instructions (create Firebase project, get config files)
  - Environment variable setup (`.env.example`, how to pass vars to `flutter run`)
  - Seed data instructions (how to populate Firebase initially)
  - Map integration instructions (Google Maps API key setup for Android/iOS)
  - How to run tests locally
- Create `.squad/DEVELOPMENT.md` with team-specific notes

**Acceptance:**
- A new developer can clone, follow README, and run the app locally
- All environment variables documented
- Firebase and Google Maps setup clearly explained
- Test commands work

**Notes:**
- Saito writes the data/Firebase sections
- Ariadne writes the Flutter/local setup sections
- Eames reviews from a tester's perspective

---

## Summary: Task Sequencing

| Phase | Task | Owner | Blockers | Est. Hours |
|-------|------|-------|----------|-----------|
| 1 | Lock Buffalo dataset | Saito | None | 2–3 |
| 1 | Env var strategy | Saito | None | 1 |
| 2 | Firebase setup | Ariadne + Arthur | 1.2 | 3–4 |
| 2 | Business model | Ariadne | 2.1 | 2 |
| 2 | Repository layer | Ariadne + Arthur | 2.2 | 2–3 |
| 2 | App architecture | Ariadne | 2.1 | 2 |
| 2 | Seed database | Arthur + Saito | 1.1, 2.1 | 1–2 |
| 3 | List screen | Ariadne | 2.3, 2.4 | 3–4 |
| 3 | Map screen | Ariadne | 2.3, 2.4 | 4–5 |
| 3 | Detail screen | Ariadne | 2.3, 3.1 | 2–3 |
| 4 | Domain tests | Eames + Ariadne | 2.2, 2.3 | 2–3 |
| 4 | UI states | Ariadne | 3.1, 3.2 | 1–2 |
| 4 | Documentation | Saito + Ariadne | All | 2 |

**Total estimate:** 25–35 hours (team effort, parallelized)

---

## Team Assignments Summary

- **Cobb (Lead):** Scope gates, architecture review, unblock decision points
- **Ariadne (Flutter):** Core implementation — screens, state, models, Firebase integration
- **Arthur (Backend):** Firebase rules, seed-data validation, repository guidance
- **Saito (Data):** Buffalo dataset, env var strategy, seed-data preparation, documentation
- **Eames (Tester):** Test coverage, QA validation, error-state verification
- **Scribe / Ralph:** Merge decisions into `.squad/decisions.md` after Cobb approves

---

**Next step:** All team members review this list and confirm availability. Cobb will kick off Phase 1 when team is ready.
