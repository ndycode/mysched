# ChangeEmailSheet

## Purpose

- Allows an authenticated user to update their email address.
- Initiates an email change flow and verifies the new email using a 6-digit code.

Implementation: `lib/screens/account/change_email_sheet.dart`

## Entry points (routes/deeplinks/navigation)

- GoRouter route wrapper: `/account/change-email` (`lib/screens/account/change_email_screen.dart`)
- Also opened via `ChangeEmailScreen.show(...)` from:
  - `lib/screens/account/account_screen.dart`

After initiating the email change, this sheet opens `VerifyEmailSheet` with `VerificationIntent.emailChange`.

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal container: `ModalShell`
- New email field (validated)
- Password field (used to authorize the email change)
- Primary action: “Continue” / “Send code”
- Verification step:
  - Opens `VerifyEmailSheet` for email-change OTP entry

## States (loading/empty/error/offline) + how each appears

- Loading: disables inputs and shows spinner on the primary action.
- Errors are mapped (email already in use, invalid email, same email).

## Primary actions + validation rules

- New email:
  - required and must be valid format
  - must not match current email
- Submit:
  - calls `AuthService.instance.updateEmailWithPassword(...)`
  - opens `VerifyEmailSheet(intent: emailChange)`

## Data dependencies (services/repos + Supabase tables if confirmable)

- `AuthService`:
  - Uses Supabase Auth email change flow
  - Updates profile metadata in `profiles` as needed (implementation-specific)

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Triggers an email change OTP being sent by Supabase Auth.

## Accessibility notes (only what you can confirm from code)

- Uses standard form fields and validation messaging.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `ChangeEmailSheet`.

## Related links (to other docs/latest pages)

- [Verify email sheet](verify_email_sheet.md)
- [Security](../security.md)
- [Backend](../backend.md)

