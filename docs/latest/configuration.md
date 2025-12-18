# Configuration

This page documents runtime configuration for the **MySched mobile app** as implemented in `lib/env.dart` and `lib/main.dart`.

## Environment and secrets

### Required

| Key | Where used | Notes |
|---|---|---|
| `SUPABASE_URL` | `lib/env.dart` | Required; loaded from `.env` or `--dart-define` |
| `SUPABASE_ANON_KEY` | `lib/env.dart` | Required; loaded from `.env` or `--dart-define` |

### Optional

| Key | Where used | Notes |
|---|---|---|
| `SENTRY_DSN` | `lib/main.dart` | Optional; if empty, Sentry is effectively disabled |

## How configuration is loaded

1) `Env.init()` tries to load `.env` via `package:flutter_dotenv` (file name `.env`).
2) Each required value is resolved as:
   - `.env` value (if available), otherwise
   - `String.fromEnvironment(...)` value from `--dart-define`
3) If `SUPABASE_URL` or `SUPABASE_ANON_KEY` is missing/empty, `Env.init()` throws and the app shows a configuration error UI.

## `.env.example`

The repository includes `.env.example` with the expected keys:

```dotenv
# Copy this file to `.env` and provide your Supabase project credentials.
# Never commit real keys to source control.

SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# Optional flags (defaults shown)
# CALENDAR_SYNC_ENABLED=false
```

`CALENDAR_SYNC_ENABLED` appears in `.env.example` but is **not referenced** in the current Dart codebase (treat it as a placeholder unless you wire it in).

## Secrets handling guidance

- Do not commit real secrets. Supabase anon keys are not “secret” in the traditional sense, but they still identify your project and should be treated carefully.
- Prefer using CI secrets / `--dart-define` for release builds.
- If you keep `.env` in the repo locally, add it to `.gitignore` in your fork and ensure it is not shipped unintentionally.

## Shorebird configuration

The repo includes `shorebird.yaml` and depends on `shorebird_code_push`. This indicates OTA patching may be used in production.

- Config file: `shorebird.yaml`
- In-app integration: see `package:shorebird_code_push` usage where referenced (search the codebase before making assumptions).

