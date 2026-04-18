# Buffalo Business Tracker - Implementation Plan

## Problem

Turn the starter Flutter app in `C:\src\github-copilot-cli-stuff\htma2\htma2` into a Firebase Realtime Database-backed app for displaying local businesses in Buffalo, MN with Google Maps integration, without authentication or visit tracking in the first release. Seed the first version with 20 Buffalo-area small businesses stored in Firebase.

## Current State

- The actual Flutter app lives in `htma2\`, not the repo root.
- `pubspec.yaml` is still the default starter configuration with no Firebase or state-management packages.
- `lib\main.dart` and `test\widget_test.dart` are starter-template code.
- The project currently has no business-domain models, no data layer, no feature folders, and no Firebase configuration.
- The project currently has no seeded Buffalo business dataset.
- Baseline analysis passes, which makes this a good point to refactor intentionally instead of preserving starter structure.

## Proposed Approach

Build a clean MVP around browsing seeded Buffalo small businesses and viewing them on Google Maps. Use Firebase Realtime Database as the backend, keep the data model minimal (3 fields + coordinates), and structure the app so later features and authentication can be added without rewriting the core layers.

Recommended architecture:

- Flutter feature-oriented structure with dedicated presentation, domain/model, and data/repository boundaries
- Firebase Core + Firebase Realtime Database for persistence
- Google Maps SDK integration for business location visualization
- Environment variable–based API configuration (Google Maps API key, Firebase config)
- A focused state-management layer for list/map/search flows
- Business records with minimal metadata (name, category, address + lat/lng)
- An initial import path for 20 Buffalo small businesses with publicly verifiable location data

## Proposed MVP Scope

1. App shell and theme refresh from the starter template
2. Seed 20 Buffalo, MN small businesses into Firebase Realtime Database with location coordinates
3. Business list screen with search/filter by name and category
4. Google Maps screen showing all businesses as pins with business name and address labels
5. Business detail screen (name, category, address, clickable map pin)
6. Firebase setup and Realtime Database-backed read operations
7. Environment variable configuration for Google Maps API key (build-time and runtime)
8. Basic loading, empty, and error states
9. Replace starter test coverage with business-domain tests

## Suggested Data Model

### businesses

- `name` (required) – Business name
- `category` (required) – Business category (e.g., "Coffee", "Restaurant", "Retail")
- `address` (required) – Full street address
- `coordinates.lat` (required) – Latitude
- `coordinates.lng` (required) – Longitude
- `source` (`seeded` or `user`)
- `createdAt`
- `updatedAt`

**Note:** Minimal model intentionally avoids contact info, visit tracking, ratings, and notes. These can be added in later phases if needed.

## Implementation Phases

### Phase 1 - Define the MVP contract

- Lock down the exact 20 Buffalo small businesses (name, category, address, verified lat/lng)
- Confirm target platforms for the first release
- Confirm Google Maps integration approach (web embed vs. native SDK)
- Confirm environment variable strategy for API keys (build-time, runtime, CI/CD)

### Phase 2 - Foundation, seed data, and Firebase

- Add Firebase dependencies and initialize the FlutterFire configuration
- Add Firebase Realtime Database configuration using the user-provided Flutter config files
- Create the initial 20-business Buffalo seed dataset with verified coordinates
- Create app-level folder structure
- Add models/entities for businesses (minimal model: name, category, address, coordinates)
- Build Realtime Database repositories and serialization
- Set up app bootstrapping, environment variable configuration for Google Maps API key
- Add shared theme and app shell

### Phase 3 - Core screens and Maps integration

- Build business list screen with search/filter
- Integrate Google Maps SDK and display all businesses as pins
- Build business detail screen
- Add loading, empty, and error states

### Phase 4 - Hardening and testing

- Replace the starter widget test with domain-relevant widget and repository tests
- Add integration tests for Firebase read operations
- Document Firebase setup, environment configuration, and local development steps

## Risks and Notes

- No-auth Firebase is acceptable for a prototype, but it should be treated as a temporary MVP constraint
- Seed data should use publicly verifiable business location information only
- Google Maps API key must be read from environment variables at both build time and runtime
- The minimal data model intentionally defers visit tracking, contact info, ratings, and notes to post-MVP
- Offline editing is out of scope for MVP
- Mapping, geolocation, advanced analytics, and auth should be explicitly deferred unless the MVP definition expands

## Todos

- `lock-buffalo-dataset` - Source and verify 20 Buffalo small businesses with names, categories, addresses, and accurate lat/lng coordinates
- `setup-firebase-foundation` - Add Firebase packages, initialize FlutterFire, and configure Realtime Database
- `configure-env-vars` - Set up environment variable handling for Google Maps API key (build-time and runtime)
- `design-minimal-model` - Define business entity with exactly 3 fields + lat/lng and Realtime Database serialization
- `scaffold-app-architecture` - Replace starter structure with feature-oriented app folders, shared app shell, and theme
- `seed-firebase-data` - Create and deploy initial 20-business dataset to Firebase Realtime Database
- `build-list-screen` - Implement business list with search/filter by name and category
- `integrate-google-maps` - Add Google Maps SDK, display all businesses as pins with labels
- `build-detail-screen` - Implement business detail screen with map integration
- `replace-starter-tests` - Remove template tests and add app-relevant coverage for models and repositories
- `document-local-setup` - Add Firebase setup, environment configuration, seed-data, and project run instructions

## Notes

- Cobb's updated analysis is recorded in `.squad\decisions\inbox\cobb-scope-replan.md`.
- The user plans to provide the Flutter Firebase config files later.
- Google Maps API key must be supplied by the user; environment variable names will be defined in the decision document.
- Current squad cast: Cobb (Lead), Ariadne (Flutter), Arthur (Backend), Saito (Data & Discovery), Eames (Tester), plus Scribe and Ralph.
