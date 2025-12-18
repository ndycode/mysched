# StudentIdPromptSheet

## Purpose

- Prompts users to complete their profile by adding a student ID (and optionally updating full name).
- Commonly used for Google Sign-In users who don’t provide a student ID during auth.

Implementation: `lib/ui/sheets/student_id_prompt_sheet.dart`

## Entry points (routes/deeplinks/navigation)

Opened via `StudentIdPromptSheet.show(...)` from:

- `lib/app/root_nav.dart` during initial app shell setup (`_checkProfileCompletion`)

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal sheet with:
  - Full name field (may be prefilled)
  - Student ID field (uppercased before submit)
- Primary action: save profile details
- Secondary actions:
  - optional sign-out path (confirmation prompt)

## States (loading/empty/error/offline) + how each appears

- Saving: disables inputs and shows loading state.
- Errors:
  - student ID already in use
  - invalid student ID format
  - generic failures

## Primary actions + validation rules

- Student ID is required and validated client-side.
- Submit:
  - calls `AuthService.instance.updateProfileDetails(...)`
- Optional sign-out:
  - calls `AuthService.instance.logout()` after confirmation

## Data dependencies (services/repos + Supabase tables if confirmable)

- `AuthService.updateProfileDetails(...)` updates `profiles` (student_id, full_name).
- Registration uniqueness is enforced by:
  - `profiles.student_id` unique constraint (from `schema.sql`)
  - RPC `is_student_id_available` used elsewhere in auth (`TODO:` function not in repo)

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Updates the user’s profile row in Supabase.
- May sign the user out (explicit user action).

## Accessibility notes (only what you can confirm from code)

- Uses standard form controls; `TODO:` validate keyboard focus and error messaging with a screen reader.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `StudentIdPromptSheet`.

## Related links (to other docs/latest pages)

- [Account overview](account_overview.md)
- [Backend](../backend.md)
- [Privacy](../privacy.md)

