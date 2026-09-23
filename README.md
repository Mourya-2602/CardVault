# CardVault

CardVault is a Flutter banking capstone project for managing debit and credit
cards securely.

## Current Version: Version 2

Version 0 established the Flutter application, baseline linting, core
dependency configuration, and the feature-first directory structure.

Version 1 adds the app foundation: Material 3 theming, Riverpod's provider
scope, `go_router`, protected route definitions, placeholder screens, and a
session-driven route guard.

Version 2 adds environment-driven API configuration, Dio interceptors, mapped
`BankError` values, secure session storage, session restoration, and a real
login form. Until Version 4's mock backend is available, the repository uses
an explicit local preview credential: `demo@cardvault.local` / `cardvault`.

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
