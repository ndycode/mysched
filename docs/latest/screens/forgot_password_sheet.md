# ForgotPasswordSheet

## Purpose

- Starts the password reset flow by sending a recovery code to an email address.
- Transitions into code verification and new password creation.

Implementation: `lib/screens/auth/forgot_password_sheet.dart`

## Entry points (routes/deeplinks/navigation)

Opened via `AppModal.sheet(...)` from:

- GoRouter `/forgot-password` route wrapper (`lib/screens/auth/forgot_password_screen.dart`)
- “Forgot password?” link in `AuthScreen` (`lib/screens/auth/login_screen.dart`)

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal container: `ModalShell`
- Email input field (may be prefilled via `initialEmail`)
- Primary action: send code
- Next step sheets:
  - `ResetPasswordVerifySheet` (code entry)
  - `NewPasswordSheet` (set new password)

## States (loading/empty/error/offline) + how each appears

- Sending: disables input and shows loading state.
- Errors:
  - Mapped to user-friendly messages (rate-limited, etc.)
  - For security, the UI avoids confirming whether an email exists.

## Primary actions + validation rules

- Email:
  - required
  - validated via `ValidationUtils.isValidEmail(...)`
- Submit:
  - calls `AuthService.resetPassword(email: ...)`
  - opens `ResetPasswordVerifySheet(email: ...)`

## Data dependencies (services/repos + Supabase tables if confirmable)

- `AuthService.resetPassword(...)` uses Supabase Auth recovery flows.

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Triggers an email-based recovery code being sent by Supabase Auth.

## Accessibility notes (only what you can confirm from code)

- Uses standard form field validation and buttons.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `ForgotPasswordSheet`.

## Related links (to other docs/latest pages)

- [Reset password verify sheet](reset_password_verify_sheet.md)
- [New password sheet](new_password_sheet.md)
- [Backend](../backend.md)

