# CardVault

CardVault is a Flutter banking capstone project for managing debit and credit
cards securely.

## Version 0: Project Setup

This version establishes the Flutter application, baseline linting, core
dependency configuration, and the planned feature-first directory structure.
Business features and navigation begin in Version 1.

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
