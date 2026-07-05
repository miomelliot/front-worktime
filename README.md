# Worktime — Flutter frontend

Flutter/Dart client for the `worktime` Go backend (MVP time-tracking service,
a trimmed-down Zoho People). The app includes auth, dashboard, time tracker,
calendar, organization status, profile, and admin screens for users,
departments, schedules, absences, and manual corrections.

## Requirements

- Flutter (latest stable) with Dart (latest stable)
- Material 3, adaptive for mobile + web/desktop

## Docker Compose

The repository can run together with the Go backend placed in `./worktime`.
The root `compose.yaml` builds:

- `frontend` — Flutter web build served by nginx on `http://localhost:8081`;
- `app` — Go backend from `./worktime` on `http://localhost:8080`;
- `postgres`, `kafka`, `kafka-init` — backend dependencies.

Run the full stack:

```bash
docker compose up --build
```

Open the app:

```text
http://localhost:8081
```

The Flutter image is built with `API_BASE_URL=/api/v1`; nginx proxies `/api/v1`
and `/swagger` to the backend container, so browser requests stay same-origin.

## Local Flutter Run

The app uses code generation (`freezed` + `json_serializable`). The
generated `*.freezed.dart` / `*.g.dart` files are **not** committed, so
generate them after fetching dependencies:

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Generate freezed / json_serializable sources
dart run build_runner build --delete-conflicting-outputs

# 3. Run (point at your backend; base URL must include the /api/v1 prefix)
flutter run --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

> Until step 3 runs, the analyzer will report missing `part` files — that is
> expected for a codegen-based skeleton.

## Architecture

Feature-first layout with a shared `core/`:

```
lib/
  main.dart               # ProviderScope + runApp
  app/                    # app widget, router, theme
  core/                   # config, dio, storage, errors, widgets, utils
  features/
    auth/                 # data / domain / presentation
    shared_models/        # enums + shared DTOs
```

- **State management:** Riverpod. The API/repository/controller are each
  exposed as providers; UI reads them and never touches Dio directly.
- **HTTP:** a single `Dio` instance (`dioProvider`) with an `AuthInterceptor`
  that adds `Authorization: Bearer <access_token>` and clears the session on
  `401`.
- **Navigation:** `go_router` with an auth-driven `redirect` that listens to
  the auth state.
- **Models:** `freezed` + `json_serializable`, with field names matching the
  backend contract exactly.

## Backend contract notes / limitations

The client is built strictly against the documented API. Notable constraints:

- **No refresh token and no logout endpoint.** Logout is local-only (delete
  the stored token). The backend returns only `access_token`, `expires_at`,
  and `user`.
- **Session restore** uses `GET /users/me`.
- **Web token storage** uses `flutter_secure_storage` (WebCrypto over
  `localStorage`); browser storage is inherently exposed to XSS — there is no
  fully secure client-side secret store on web.
- **Duration encodings differ:** `*_seconds` fields are integer seconds, while
  Go `time.Duration` fields (`start_time`, `end_time`, `time_from`,
  `time_to`) are integer **nanoseconds**. See `core/utils/duration_formats.dart`.
- **Logical dates** in responses arrive as `YYYY-MM-DDT00:00:00Z`. See
  `core/utils/date_formats.dart`.
- No tenant/organization endpoint, no permissions-matrix endpoint, no
  pagination for most lists, no active-timer websocket. These are not modeled.
