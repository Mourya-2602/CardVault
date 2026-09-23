# CardVault

CardVault is a Flutter banking capstone project for managing debit and credit
cards securely.

## Current Version: Version 4

Version 0 established the Flutter application, baseline linting, core
dependency configuration, and the feature-first directory structure.

Version 1 adds the app foundation: Material 3 theming, Riverpod's provider
scope, `go_router`, protected route definitions, placeholder screens, and a
session-driven route guard.

Version 2 adds environment-driven API configuration, Dio interceptors, mapped
`BankError` values, secure session storage, session restoration, and a real
login form.

Version 3 adds immutable CardVault domain models, UTC-to-local date conversion,
Indian currency formatting, integer-paise parsing, and validation utilities.

Version 4 connects repositories to a local mock Node API. Login now issues a
real token. Repositories convert Dio failures into `BankError` and never expose
raw HTTP exceptions to the UI.

Start the mock API, then the app:

```text
node mock_api/server.mjs
flutter run --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

Demo login: `demo@cardvault.local` / `cardvault`

Simulate failures with header `X-CardVault-Simulate`:
`401`, `403`, `404`, `409`, `422`, `500`, or `timeout`.

Run with an environment override when needed:

```text
flutter run --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://localhost:3000
```

## Requirements

- Flutter 3.47.4 (stable)
- Dart 3.13.3
- Git

## Run locally

```text
flutter pub get
flutter analyze
flutter test
flutter run
```

For Windows plugin builds, enable Windows Developer Mode if Flutter reports
that symbolic links are unavailable.

## Core dependencies

- `flutter_riverpod`: state management
- `go_router`: declarative navigation
- `dio`: HTTP client
- `flutter_secure_storage`: secure session storage
- `local_auth`: biometric authentication

## Planned structure

```text
lib/
  app/
  core/
    errors/
    network/
    security/
    motion/
    utils/
    widgets/
  features/
    auth/
    cards/
    controls/
    limits/
    credit/
    statements/
    payments/
    block/
test/
  unit/
  widget/
  helpers/
integration_test/
```

## Version policy

The project is implemented one version at a time. Each version is validated
before the next version starts.
