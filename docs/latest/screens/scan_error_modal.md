# ScanErrorModal

## Purpose

- Shows scan/OCR failure messages and offers a recovery path (retake) when possible.

Implementation: `lib/screens/scan/scan_error_modal.dart`

## Entry points (routes/deeplinks/navigation)

Opened via `ScanErrorModal.show(context, errorMessage: ...)` from:

- `lib/screens/scan/scan_preview_screen.dart`

Returns a `ScanErrorAction` (e.g., `retake`) to the caller.

## UI Anatomy (major sections; key components; sheets/dialogs)

- Dialog-style modal (`AppModal.alert(...)`)
- Error message body
- Action buttons:
  - Retake (when shown)
  - Close/cancel

## States (loading/empty/error/offline) + how each appears

- This modal is itself an error state; no additional loading expected.

## Primary actions + validation rules

- Retake returns an action for the caller to restart the scan flow.

## Data dependencies (services/repos + Supabase tables if confirmable)

- None directly.

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- None directly.

## Accessibility notes (only what you can confirm from code)

- Uses standard dialog patterns; ensure button labels are clear.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `ScanErrorModal`.

## Related links (to other docs/latest pages)

- [Scan preview sheet](scan_preview_sheet.md)
- [Schedules preview sheet](schedules_preview_sheet.md)

