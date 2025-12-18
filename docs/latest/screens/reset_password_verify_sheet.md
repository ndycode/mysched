# ResetPasswordVerifySheet

## Purpose

- Verifies the 6-digit recovery code sent during password reset.
- On success, opens `NewPasswordSheet` to set a new password.

Implementation: `lib/screens/auth/reset_password_verify_sheet.dart`

## Entry points (routes/deeplinks/navigation)

Opened from `ForgotPasswordSheet`:

- Source: `lib/screens/auth/forgot_password_sheet.dart`

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal container: `ModalShell`
- Code input (6-digit)
- Primary action: verify code
- On success: opens `NewPasswordSheet`

## States (loading/empty/error/offline) + how each appears

- Verifying: disables input and shows loading state.
- Errors: invalid/expired code mapped to user messaging.

## Primary actions + validation rules

- Code must be 6 digits (client-side expectation).
- Verify:
  - calls `AuthService.instance.verifyPasswordResetCode(email, code)`

## Data dependencies (services/repos + Supabase tables if confirmable)

- `AuthService.verifyPasswordResetCode(...)` uses Supabase Auth recovery OTP verification.

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- On success, transitions into password update UI.

## Accessibility notes (only what you can confirm from code)

- Uses standard input + button surfaces.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `ResetPasswordVerifySheet`.

## Related links (to other docs/latest pages)

- [New password sheet](new_password_sheet.md)
- [Backend](../backend.md)

