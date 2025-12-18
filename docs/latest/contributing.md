# Contributing

This repo contains the **MySched Flutter mobile app**.

## Repo layout (quick)

- `lib/`: Flutter app code (screens, services, models, UI kit)
- `test/`: automated tests
- `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/`: platform scaffolding
- `assets/`: images/fonts
- `schema.sql`, `supabase/`: Supabase schema context + migrations
- `docs/`: documentation (legacy + generated)

## Development workflow

### Commands

```powershell
flutter pub get
flutter analyze
dart format .
flutter test
flutter run
```

### Code style

- Follow Flutter style guide (2-space indentation, trailing commas on multiline literals).
- Prefer `final` locals when values don’t change.
- Avoid `print` in production code; prefer structured logging (`AppLog`/telemetry).

## Updating documentation

- `docs/latest/` is intended to reflect the **current code**.
- If you change routes, services, backend tables, or notification behavior, update the relevant `docs/latest/*.md` pages and any affected screen docs under `docs/latest/screens/`.
- Keep internal links relative and valid within `docs/latest/`.

## Specs and legacy docs

- Older references may exist under:
  - `docs/legacy/reference/` (legacy)
  - `docs/legacy/audit/` (legacy)
- Use them as hints, but treat the current codebase as the source of truth.

## Definition of done (suggested)

- Feature implemented and matches UI/UX expectations
- `flutter analyze` passes
- `flutter test` passes (or new tests added where appropriate)
- Docs updated (`docs/latest/` + any impacted screen docs)
