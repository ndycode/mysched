# ScanOptionsSheet

## Purpose

- Lets the user choose how to capture an image for schedule OCR:
  - take a photo (camera)
  - upload from gallery
- Enforces scan consent before capture.

Implementation: `lib/screens/scan/scan_options_screen.dart`

## Entry points (routes/deeplinks/navigation)

Opened via `AppModal.sheet(...)` as part of the scan flow from:

- `lib/app/root_nav.dart` (Quick actions)
- `lib/screens/schedules/schedules_screen.dart`

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal container: `ModalShell`
- Header: “Scan student card”
- Preview mock (guidance UI)
- Actions:
  - “Take photo” (camera) → `ImagePicker.pickImage(ImageSource.camera)`
  - “Upload” (gallery) → `ImagePicker.pickImage(ImageSource.gallery)`
- Consent dialog:
  - `ensureScanConsent(context)` (see `Scan consent dialog` doc)

## States (loading/empty/error/offline) + how each appears

- Busy state while launching camera/gallery picker (`_busy`).

## Primary actions + validation rules

- Consent is required before picking an image.
- On success, pops the sheet with the selected image file path.

## Data dependencies (services/repos + Supabase tables if confirmable)

- `image_picker`
- Scan consent stored in SharedPreferences (`scan_consent_agreed`)

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Requires camera permission for the “Take photo” flow.
- Writes scan consent flag to local prefs if user agrees.

## Accessibility notes (only what you can confirm from code)

- Uses labeled buttons and standard controls.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `ScanOptionsSheet`.

## Related links (to other docs/latest pages)

- [Scan preview sheet](scan_preview_sheet.md)
- [Scan consent dialog](scan_consent_dialog.md)
- [Screens index](index.md)

