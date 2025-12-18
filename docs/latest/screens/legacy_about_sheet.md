# AboutSheet (Legacy)

## Purpose

- Presents an “About MySched” information sheet.

Implementation: `lib/screens/about_screen.dart`

## Entry points (routes/deeplinks/navigation)

- `TODO:` This sheet is not referenced by the current Settings implementation (Settings shows About content via inline modal content builders instead).
- If you re-enable it, it can be shown via `AboutSheet.show(context)` in `lib/screens/about_screen.dart`.

## UI Anatomy (major sections; key components; sheets/dialogs)

- Uses `AppModal.sheet(...)` for the main about sheet.
- Uses `AppModal.info(...)` for secondary info dialogs.
- Contains static informational copy referencing Supabase-backed storage and privacy posture.

## States (loading/empty/error/offline) + how each appears

- Primarily static content; no confirmed backend loading.

## Primary actions + validation rules

- Informational only.

## Data dependencies (services/repos + Supabase tables if confirmable)

- None directly confirmed for this legacy sheet.

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- None confirmed.

## Accessibility notes (only what you can confirm from code)

- `TODO:` Validate scrollability and text scaling.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct tests found for `AboutSheet`.

## Related links (to other docs/latest pages)

- [Privacy](../privacy.md)
- [Screens index](index.md)

