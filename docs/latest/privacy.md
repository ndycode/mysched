# Privacy

This document describes privacy-related behavior that can be confirmed from the current codebase, plus any user-visible policy text shipped in-app.

## On-device vs server processing

### OCR scanning

- Schedule scanning uses Google ML Kit Text Recognition (`google_mlkit_text_recognition`) in `lib/screens/scan/scan_preview_screen.dart`.
- Based on current code, OCR runs **on-device** and produces extracted schedule data (section + classes).
- The extracted schedule data is then written to Supabase when importing (e.g., linking a section in `user_sections` and applying overrides/custom classes).

`TODO:` Confirm whether any raw images are ever uploaded; current scan UI code does not reference Supabase storage uploads for scan images.

### Backend storage (Supabase)

The app stores (confirmed by code + `schema.sql`):

- User profile data in `profiles` (name, email, student ID, avatar URL)
- Reminders in `reminders`
- Schedule-related links and overrides (`user_sections`, `user_class_overrides`, `user_custom_classes`, and `user_classes_v` view)
- User settings in `user_settings`
- Study sessions in `study_sessions`
- Admin audit/report data in `class_issue_reports` and `audit_log` (admin-only surfaces)

### Crash reporting

- The app can forward exceptions to Sentry (`lib/services/telemetry_service.dart`) when `SENTRY_DSN` is configured.
- The app sets `sendDefaultPii = false`, but crash reports may still include device/runtime information.

## In-app privacy policy text

The app ships a user-visible privacy policy string in `lib/app/constants.dart` (`AppConstants.privacyPolicyContent`) and displays it via `AppModal.legal(...)`.

This documentation does not restate the full policy text; instead it documents observed behavior from code. If the policy text diverges from implementation, update one or both so they match.

## Data retention and deletion

- Account deletion calls Supabase Edge Function `delete_account` (`AuthService.deleteAccount`), but the function implementation is not present in this repo.

`TODO:` Document retention/deletion behavior once the Edge Function and any DB policies are available in-repo.

## Related

- Backend objects: [Backend](backend.md)
- Security notes: [Security](security.md)

