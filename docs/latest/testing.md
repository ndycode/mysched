# Testing

## Commands

From the repo root:

```powershell
flutter test
flutter analyze
dart format .
```

## Test structure

Tests live under `test/` and mirror `lib/` by area (e.g., `test/services/**`, `test/screens/**`).

## Patterns and helpers (confirmed in code)

- `Env.debugInstallMock(...)` in `lib/env.dart` exists to inject a mock `SupabaseClient` for widget/unit tests.
- `BootstrapGate.debugBypassPermissions` in `lib/app/bootstrap_gate.dart` exists to bypass permission prompts (useful in widget tests).
- Several services expose `@visibleForTesting` helpers (e.g., retry logic and caches) to make deterministic tests feasible.

## Adding tests

- Prefer unit tests for parsing/scheduling logic (e.g., schedule overlap, reminder status conversions).
- Prefer widget tests for screen flows where navigation, forms, and sheets are involved.
- When a screen depends on Supabase, inject mocks where possible (or isolate service logic behind a fake client).

`TODO:` Screen-by-screen test coverage is documented in `docs/latest/screens/*.md` under each screen’s “Tests” section.

