# Scan consent dialog

## Purpose

- Collects explicit user consent before enabling OCR scanning.
- Stores a local “consented” flag to avoid repeated prompts.

Implementation: `lib/ui/kit/consent_dialog.dart`

## Entry points (routes/deeplinks/navigation)

Called from `ScanOptionsSheet` before picking an image:

- Source: `lib/screens/scan/scan_options_screen.dart` (`ensureScanConsent(context)`)

## UI Anatomy (major sections; key components; sheets/dialogs)

- `AlertDialog` shown via `AppModal.alert(...)`
- Consent explanation text
- Actions:
  - “Agree & Continue” (saves consent and returns true)
  - “Cancel” (returns false)

## States (loading/empty/error/offline) + how each appears

- No network loading expected.

## Primary actions + validation rules

- If consent is saved, subsequent calls return true without prompting.

## Data dependencies (services/repos + Supabase tables if confirmable)

- Local storage: SharedPreferences key `scan_consent_agreed`

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Writes local consent flag (`scan_consent_agreed`).

## Accessibility notes (only what you can confirm from code)

- Uses standard dialog semantics and labeled buttons.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for scan consent dialog.

## Related links (to other docs/latest pages)

- [Scan options sheet](scan_options_sheet.md)
- [Privacy](../privacy.md)

