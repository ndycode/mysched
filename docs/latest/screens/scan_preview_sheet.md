# ScanPreviewSheet

## Purpose

- Runs OCR on a captured image to extract:
  - section identification
  - class list details
- Lets the user retake the image if detection fails.

Implementation: `lib/screens/scan/scan_preview_screen.dart`

## Entry points (routes/deeplinks/navigation)

Opened via `AppModal.sheet(...)` after `ScanOptionsSheet` returns an image path:

- `lib/app/root_nav.dart`
- `lib/screens/schedules/schedules_screen.dart`

Returns a `ScanPreviewOutcome` (success or retake) to the caller.

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal container: `ModalShell`
- Image preview (enhanced preview may be generated for OCR quality)
- Processing state UI while OCR runs
- Results preview:
  - section match summary
  - parsed class list (from OCR)
- Actions:
  - retake (returns `ScanPreviewOutcome.retake()`)
  - continue (returns success outcome)
- Error modal:
  - `ScanErrorModal.show(...)` for failure cases

## States (loading/empty/error/offline) + how each appears

- Processing:
  - `_processing` true while OCR and matching run
- Error:
  - Missing image file → error modal
  - Section not found / parsing failures → error modal (may offer retake)
- Cleanup:
  - Enhanced image output is deleted on dispose via `ImagePreprocessor.cleanup(...)`

## Primary actions + validation rules

- OCR uses Google ML Kit text recognition.
- Section matching logic uses `SectionMatcher` (`lib/utils/section_matching.dart`).
- For schedule extraction to proceed, a section must be identified (`section != null`) and a valid image path must exist.

## Data dependencies (services/repos + Supabase tables if confirmable)

- OCR:
  - `google_mlkit_text_recognition`
  - `lib/utils/image_preprocessing.dart`
- Section matching + data fetch:
  - Reads `sections` (active semester context)
  - Reads `classes` for the matched section
  - Reads `semesters` via `SemesterService` to identify the active semester

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Uses camera/gallery-supplied local file path; does not upload images in this screen.
- Logs via `AppLog` in some error paths.

## Accessibility notes (only what you can confirm from code)

- Uses standard modal structure and buttons; `TODO:` confirm the OCR preview is readable with large text.

## Tests (existing tests that cover it; if none, TODO)

- `test/utils/section_matching_test.dart` covers part of the matching logic.
- `TODO:` No direct widget test references found for `ScanPreviewSheet`.

## Related links (to other docs/latest pages)

- [Schedules preview sheet](schedules_preview_sheet.md)
- [Backend](../backend.md)
- [Privacy](../privacy.md)

