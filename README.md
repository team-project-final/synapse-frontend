# Synapse Frontend

Synapse frontend is a Flutter web/mobile client for the Synapse learning and
knowledge graph platform. The app combines note-based PKM, spaced repetition
cards, AI-assisted search/card generation, study communities, gamification, and
platform account/billing workflows.

## Architecture

The frontend follows the same four-service boundary model defined in the
project architecture wiki. Feature modules live under `lib/services/<boundary>`
when they map to one backend service, while cross-service surfaces stay in
`lib/shared`.

```text
lib/
├── app.dart
├── main.dart
├── core/
│   ├── constants/       # AppRoutes and shared constants
│   ├── network/         # Dio client and environment selection
│   ├── router/          # GoRouter route table
│   ├── services/        # ServiceBoundary registry
│   └── theme/           # Design tokens and ThemeData
├── services/
│   ├── platform/        # auth, billing, notifications, settings, admin
│   ├── engagement/      # community, gamification
│   ├── knowledge/       # notes, graph, search
│   └── learning/        # cards, SRS, AI card generation
└── shared/
    ├── features/        # cross-service features such as dashboard
    └── widgets/         # reusable UI components
```

### Service Boundaries

| Frontend boundary | Backend service | Domains |
|---|---|---|
| `platform` | `synapse-platform-svc` | auth, billing, notifications, settings, admin |
| `engagement` | `synapse-engagement-svc` | community, gamification |
| `knowledge` | `synapse-knowledge-svc` | notes, graph, search |
| `learning` | `synapse-learning-svc` | cards, SRS, AI card generation |
| `shared` | multiple services | dashboard and shared widgets |

Each feature keeps the same internal shape:

```text
feature/
├── data/
├── domain/
├── presentation/
│   └── screens/
└── providers/
```

## Technology

| Area | Technology |
|---|---|
| Framework | Flutter 3.x |
| Language | Dart 3.x |
| State management | Riverpod 3 manual providers |
| Routing | GoRouter |
| HTTP client | Dio |
| Local storage | Hive Flutter |
| Typography | google_fonts |
| Tests | flutter_test, integration_test, mockito |
| Linting | flutter_lints + repository `analysis_options.yaml` |

The project currently targets Dart `>=3.11.0 <4.0.0`.

## Getting Started

### Prerequisites

- Flutter stable SDK
- Dart SDK bundled with Flutter
- Chrome or another Flutter-supported web target

Check the installed toolchain:

```bash
flutter --version
flutter doctor
```

### Install Dependencies

```bash
flutter pub get
```

### Run Locally

Run on a generated web server:

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8088
```

Then open:

```text
http://127.0.0.1:8088
```

Run on Chrome:

```bash
flutter run -d chrome
```

### Environment

The Dio client reads `APP_ENV` from Dart defines.

| APP_ENV | Base URL |
|---|---|
| `dev` | `http://localhost:8080` |
| `staging` | `https://api-staging.synapse.app` |
| `prod` | `https://api.synapse.app` |

Example:

```bash
flutter run -d chrome --dart-define=APP_ENV=dev
```

## Validation

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Build web release:

```bash
flutter build web --release
```

Check dependency freshness:

```bash
flutter pub outdated
```

## Current Status

The current implementation provides the domain/service-boundary architecture,
GoRouter route registration, and placeholder screens for the wiki-defined
domains. API integration and production UI details are expected to be added
inside each service feature boundary.
