# NewPasswordSheet

## Purpose

- Allows the user to set a new password after OTP verification.

Implementation: `lib/screens/auth/new_password_sheet.dart`

## Entry points (routes/deeplinks/navigation)

Opened from `ResetPasswordVerifySheet` after successful verification:

- Source: `lib/screens/auth/reset_password_verify_sheet.dart`

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal container: `ModalShell`
- Form fields:
  - New password
  - Confirm new password
- Primary action: set password

## States (loading/empty/error/offline) + how each appears

- Saving: disables inputs and shows loading state.
- Error mapping handles weak passwords and generic failures.

## Primary actions + validation rules

- New password required.
- Confirm password must match.
- Minimum length requirement is communicated in the UI (“at least 8 characters”).

## Data dependencies (services/repos + Supabase tables if confirmable)

- `AuthService.updatePassword(newPassword: ...)` updates the authenticated user’s password via Supabase Auth.

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Password update may revoke old sessions (depends on Supabase behavior).

## Accessibility notes (only what you can confirm from code)

- Uses standard form validation and focus management.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `NewPasswordSheet`.

## Related links (to other docs/latest pages)

- [Security](../security.md)
- [Backend](../backend.md)

