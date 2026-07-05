# Worktime Flutter Web UI Prototype

MVP-1 frontend prototype for Worktime. This step is intentionally mock-only:
there is no backend client, token storage, DTO generation, or API integration.

## Included

- `ShadApp.router` with a web-first dashboard shell.
- Fake login with demo roles: employee, manager, admin.
- Role-aware navigation with `go_router`.
- Riverpod controllers backed by fake repositories and mock data.
- Screens for Today, Calendar, Team, Employee Details, Profile, and Admin.
- Shared reusable UI components under `lib/shared/ui`.
- Separate Widgetbook app under `widgetbook/`.

## Run

```bash
flutter run -d chrome
```

## Widgetbook

```bash
cd widgetbook
flutter run -d chrome
```

## Checks

```bash
flutter analyze
flutter test
flutter build web
```

For Widgetbook:

```bash
cd widgetbook
flutter analyze
flutter test
flutter build web
```

## Not In Scope

- Real backend API calls.
- Dio clients or auth interceptors.
- Absences, violations, corrections, or full CRUD workflows.
