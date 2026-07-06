# 🌱 Plant Life

**Smart plant monitoring, AI disease detection, guided treatment, and an integrated plant-care store — in one Flutter app.**

Plant Life connects to IoT sensors to track a plant's environment in real time, detects diseases from leaf photos, generates multi-day treatment plans with on-device reminders, tracks recovery over time, and lets users buy the products they need from a built-in store. The app is fully bilingual (English / العربية) with complete right-to-left support.

<p>
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter&logoColor=white">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white">
  <img alt="State" src="https://img.shields.io/badge/State-Bloc%2FCubit-13B9FD">
  <img alt="Platforms" src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey">
</p>

---

## Table of Contents

- [Features](#features)
- [Demo & Screenshots](#demo--screenshots)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Build & Release](#build--release)
- [Release Checklist](#release-checklist)
- [Localization](#localization)
- [Testing](#testing)
- [Documentation](#documentation)
- [Contributors](#contributors)
- [License](#license)

---

## Features

| Area | Description |
|------|-------------|
| 🚀 **Onboarding & Auth** | First-launch onboarding, email/password sign-in & registration, JWT access/refresh tokens stored in platform secure storage with automatic refresh on `401`. |
| 🏠 **Home Dashboard** | At-a-glance sensor overview, active alerts, and today's treatment tasks with pull-to-refresh. |
| 📡 **Live Sensors** | Real-time temperature, humidity, soil-moisture, and light readings streamed over Socket.IO, with trend charts, min/max range indicators, and alert history. |
| 🔬 **Disease Scan** | Detects plant diseases from a leaf photo (camera, gallery, or ESP32 device capture), returning per-disease confidence and severity with a treatment prompt. |
| 🩺 **Treatment Plans** | Multi-day, step-by-step heal plans with progress tracking and **on-device local-notification reminders** (works while the app is backgrounded or closed; no push server required). |
| 📈 **Recovery Progress** | Rescan timeline that visualizes severity change over time after treatment begins. |
| 🔔 **Notifications** | In-app notification center grouped by day, with unread tracking and "mark all read". |
| 🛒 **Store** | Product catalog with search, filtering, and pagination; cart, checkout (cash or Stripe), and order history — backed by a separate store service. |
| 👤 **Profile** | Account details and instant language switching (EN ⇄ AR) with live RTL flip. |
| 🌍 **Localization** | Full English + Arabic translations with automatic RTL layout mirroring. |

---

## Demo & Screenshots

> 📸 **Placeholders below — replace with real captures before sharing externally.**
> Recommended: keep media in `docs/media/` and reference it with relative paths so it renders on GitHub.

### 📽️ Demo

A 20–40s screen recording is the fastest way for a reviewer to grasp the app. Add one as a GIF (autoplays inline on GitHub) or link an MP4/YouTube video.

<!-- Once recorded, drop the file in docs/media/ and swap the line below: -->
<!-- ![Plant Life demo](docs/media/demo.gif) -->

<p align="center">
  <em>🎬 Demo GIF coming soon — add <code>docs/media/demo.gif</code></em>
</p>

### 📱 Screenshots

Capture on a device/emulator, then save as `docs/media/<screen>.png` and replace the `_placeholder_` cells.

| Splash | Home | Sensors | Scan |
|:------:|:----:|:-------:|:----:|
| _placeholder_ | _placeholder_ | _placeholder_ | _placeholder_ |

| Treatments | Recovery | Store | Profile |
|:----------:|:--------:|:-----:|:-------:|
| _placeholder_ | _placeholder_ | _placeholder_ | _placeholder_ |

---

## Architecture

The app follows **Clean Architecture** with a strict, one-directional dependency flow. Each feature is a self-contained slice with its own three layers, wired together by a `get_it` service locator:

```
┌──────────────────────────────────────────────────────────────────────┐
│                          FEATURE SLICE                                 │
│                                                                        │
│   PRESENTATION            DOMAIN                 DATA                   │
│  ┌──────────────┐       ┌──────────────┐       ┌────────────────────┐  │
│  │  Widgets     │       │  Entities    │       │  Repository Impl    │  │
│  │      │       │       │  Use Cases   │       │  Data Sources       │  │
│  │      ▼       │  uses │  Repository  │ impl. │  Models (DTOs)      │  │
│  │  Cubit/Bloc  │──────▶│  interfaces  │◀──────│  Dio · Socket · SS  │  │
│  │  + State     │       │ (ApiResult<T>)│      │  (maps → Failure)   │  │
│  └──────────────┘       └──────────────┘       └─────────┬──────────┘  │
│         ▲                                                 │             │
└─────────┼─────────────────────────────────────────────── ┼─────────────┘
          │ observes state                                  ▼
      renders UI                              REST API · Socket.IO · Secure Storage

   Dependency direction:  presentation ──▶ domain ◀── data
   (domain is the stable core; it depends on nothing outside itself)
```

Data flows **outward-in** at runtime (network → data → domain → presentation) but every
compile-time dependency points **toward the domain**, keeping business logic isolated and
framework-free.

**Layer rules**

- **Presentation** — Widgets + `Cubit`/`Bloc` only. Zero business logic; it observes state and renders. Cubits depend solely on use cases.
- **Domain** — Pure Dart, **no Flutter imports**. Entities, use cases, and repository interfaces. Use cases and repositories return a typed `ApiResult<T>`.
- **Data** — Data sources (Dio/Socket/secure storage), DTO models, and repository implementations. Exceptions are caught at this boundary and mapped to typed `Failure`s.

**Cross-cutting conventions**

- **State management:** `flutter_bloc` (Cubit/Bloc). `setState` is reserved for trivial local UI state only.
- **Dependency injection:** `get_it` service locator, registered centrally in [`lib/core/di/`](lib/core/di/).
- **No code generation:** no Freezed / build_runner. State unions use Dart 3 `sealed class` + exhaustive `switch`; lightweight data uses records.
- **Error handling:** `ApiResult<T>` (domain) ↔ `Failure` (data) ↔ user-friendly messages (presentation).
- **Shared code:** anything reused in 2+ places lives under [`lib/core/`](lib/core/).

---

## Project Structure

```
lib/
├── core/                     # Shared, cross-feature building blocks
│   ├── constants/            # App-wide constants
│   ├── di/                   # get_it service locator setup
│   ├── enums/                # Shared enums
│   ├── errors/               # ApiResult, Failure types
│   ├── events/               # App-level event bus
│   ├── extensions/           # Dart/Flutter extensions
│   ├── localization/         # LocaleCubit + l10n helpers
│   ├── networking/           # Dio factory, API endpoints, interceptors
│   ├── notifications/        # Local notification service
│   ├── routing/              # go_router config & routes
│   ├── storage/              # Secure token storage, preferences
│   ├── theme/                # Colors, text styles, ThemeData
│   ├── utils/                # Formatters & helpers
│   └── widgets/              # Reusable widgets (buttons, cards, states…)
├── features/                 # Feature slices (data / domain / presentation)
│   ├── auth/          home/          main_shell/    notifications/
│   ├── onboarding/    profile/       recovery/      scan/
│   ├── sensors/       splash/        store/         treatments/
├── l10n/                     # ARB files (en, ar) + generated localizations
└── main.dart                 # App entry point & MaterialApp

android/ · ios/ · web/ · windows/ · macos/ · linux/   # Platform runners
assets/                       # App assets (launcher-icon sources under assets/icon/)
test/                         # Unit & widget tests
```

Every folder under `lib/features/<name>/` mirrors the same `data/ · domain/ · presentation/` split.

---

## Tech Stack

| Concern | Package |
|---------|---------|
| Framework | Flutter 3.41 · Dart 3.11 |
| State management | `flutter_bloc` |
| Dependency injection | `get_it` |
| Navigation | `go_router` |
| Networking (REST) | `dio` |
| Real-time | `socket_io_client` |
| Secure storage | `flutter_secure_storage` |
| Local preferences | `shared_preferences` |
| Local notifications | `flutter_local_notifications` · `timezone` · `flutter_timezone` |
| Charts | `fl_chart` |
| Progress indicators | `percent_indicator` |
| Media | `image_picker` |
| External links / Stripe | `url_launcher` |
| Typography | `google_fonts` (Poppins) |
| Localization | `flutter_localizations` · `intl` (gen-l10n) |

**Dev:** `flutter_lints`, `mocktail`, `bloc_test`, `flutter_launcher_icons`.

---

## Getting Started

### Prerequisites

- **Flutter SDK** `3.41+` (Dart `3.11+`) — run `flutter doctor` and resolve any issues
- **Android:** Android Studio + an Android SDK / emulator or a physical device
- **iOS** (optional): Xcode + CocoaPods on macOS

### Setup

```bash
# 1. Clone
git clone https://github.com/iYoussefAdly/plant_life.git
cd plant_life

# 2. Install dependencies
flutter pub get

# 3. Run (uses the default production API URLs unless overridden — see Configuration)
flutter run
```

---

## Configuration

Backend base URLs are injected at build time via `--dart-define`, so no secrets or environment-specific values are committed in code. Both default to the hosted production services when not overridden.

| Variable | Purpose | Default |
|----------|---------|---------|
| `API_BASE_URL` | Main Plant Life API (auth, sensors, scans, treatments, notifications) | `https://plant-life-production-8a63.up.railway.app/api` |
| `STORE_API_BASE_URL` | Store service (products, cart, orders) | `https://plantstore-production-6cbf.up.railway.app/api/v1` |

**Run against a local/staging backend:**

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:3000/api \
  --dart-define=STORE_API_BASE_URL=http://10.0.2.2:4000/api/v1
```

> `10.0.2.2` is the Android emulator's alias for the host machine's `localhost`.

---

## Build & Release

```bash
# Debug APK (for QA / internal testing)
flutter build apk --debug

# Release APK (see note below on signing)
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release
```

Output: `build/app/outputs/flutter-apk/`.

**Launcher icon** — the Android launcher icon (legacy + adaptive) is generated from the source images in `assets/icon/`. To regenerate after changing them:

```bash
dart run flutter_launcher_icons
```

> ⚠️ **Release signing is not yet configured** — release builds currently sign with the debug keystore (Flutter's default). Before publishing, add a real release keystore and signing config. See the [Release Checklist](#release-checklist).

---

## Localization

- Translations live in [`lib/l10n/app_en.arb`](lib/l10n/app_en.arb) and [`lib/l10n/app_ar.arb`](lib/l10n/app_ar.arb).
- Localizations are generated by `flutter gen-l10n` (also runs automatically on build) into `lib/l10n/generated/`.
- Arabic activates full **RTL** layout mirroring across the app. Language can be switched live from onboarding or Profile.

To add or change a string: edit both `.arb` files, then run `flutter gen-l10n`.

---

## Testing

```bash
flutter analyze     # static analysis (lints)
flutter test        # unit & widget tests
```

Tests cover domain/data logic (use cases, repositories) and a smoke widget test, using `mocktail` and `bloc_test`.

---

## Release Checklist

The app is production-ready for internal/QA distribution as a debug APK. Before a **public store release**, complete the following:

- [ ] **Configure a release keystore.** Release builds currently sign with Flutter's **debug keystore** (see [`android/app/build.gradle.kts`](android/app/build.gradle.kts)). Create a dedicated keystore, add a `key.properties` (git-ignored), and wire a `release` signing config. **Never commit the keystore** — `*.jks`, `*.keystore`, and `key.properties` are already in `.gitignore`.
- [ ] **Set a production application ID.** Currently `com.example.plant_life` (the Flutter template placeholder). Change it to a unique, reverse-DNS ID you own, e.g. `com.<yourcompany>.plantlife`, in `android/app/build.gradle.kts` (`applicationId`). See the note below on timing.
- [ ] **Add a `LICENSE` file** (see [License](#license)).
- [ ] **Point API URLs at the intended environment** via `--dart-define` (`API_BASE_URL`, `STORE_API_BASE_URL`) — don't hardcode per-environment values in source.
- [ ] **Bump `version`** in `pubspec.yaml` (`versionName+versionCode`) for each release.
- [ ] **Replace README demo/screenshot placeholders** with real media.

> **ℹ️ On the application ID:** it is intentionally left as `com.example.plant_life` for now.
> It only needs to change before a public store submission, and changing it mid-QA would
> install the app as a **separate** package on testers' devices (a fresh install, not an
> update). The correct value is a reverse-DNS identifier tied to a domain the project owner
> controls, so it's an ownership decision rather than an automatic rename. Changing it does
> **not** affect the current backend/testing setup (the backends authenticate via JWT, not
> package name — there are no package-restricted API keys or Firebase config in the project).

---

## Documentation

Backend and API reference material lives in [`docs/`](docs/):

- [`docs/api_endpoints.md`](docs/api_endpoints.md) — main Plant Life API endpoints
- [`docs/BACKEND_API_REQUESTS.md`](docs/BACKEND_API_REQUESTS.md) — outstanding backend work / API gaps
- [`docs/PlantLife_API_Spec_Full.html`](docs/PlantLife_API_Spec_Full.html) — full API spec (open in a browser)

---

## Contributors

- **Youssef Adly** — [@iYoussefAdly](https://github.com/iYoussefAdly)

_Contributions welcome — please open an issue or pull request._

---

## License

No license file is currently included in this repository. Until a `LICENSE` is added, this project is **All Rights Reserved** by default. Add a license file (e.g. MIT, Apache-2.0, or a proprietary notice) to clarify usage terms before distribution.
