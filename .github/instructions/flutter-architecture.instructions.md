---
description: "Use when editing Flutter/Dart code in this repo. Enforces feature-first clean architecture, Cubit state management, GetIt DI usage, route naming, and localization/testing expectations."
name: "Flutter Architecture Conventions"
applyTo:
  - "lib/**/*.dart"
  - "test/**/*.dart"
---
# Flutter Architecture Conventions

- Follow the existing feature-first structure under lib/features/<feature> with data/domain/presentation layers.
- Keep domain logic in use cases/repositories, not in widgets.
- Use flutter_bloc Cubit for presentation state updates; emit explicit loading/success/error states.
- Prefer resolving app dependencies through the service locator (sl) configured in lib/core/di/injection_container.dart.
- Prefer not to instantiate repositories/data sources directly inside UI pages unless there is a clear reason.
- Add new named routes through lib/core/routes/route_names.dart and wire them in lib/core/routes/app_router.dart.
- Prefer app theme values and shared widgets over duplicating styles inline.
- Prefer localizations from lib/l10n for user-facing text, and keep en/am translations in sync when adding new keys.
- When adding or changing business logic, add or update focused tests in test/ for cubits, repositories, or use cases.
- Keep changes scoped and consistent with the existing folder/module naming style.
