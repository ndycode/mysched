# VerifyEmailSheet

## Purpose

- Confirms email ownership using a 6-digit verification code.
- Supports two intents:
  - signup verification
  - email change verification

Implementation: `lib/screens/account/verify_email_sheet.dart`

## Entry points (routes/deeplinks/navigation)

Opened via `AppModal.sheet(...)` from:

- GoRouter `/verify` route wrapper (`lib/screens/account/verify_email_screen.dart`)
- `ChangeEmailSheet` after initiating email update (`lib/screens/account/change_email_sheet.dart`)

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal container: `ModalShell`
- Instructions text (varies by intent)
- Code input field:
  - expects 6-digit code
  - auto-triggers verification when 6 digits are entered
- Primary action: “Verify” (disabled while verifying/resending)
- Resend section:
  - resend button with cooldown timer

## States (loading/empty/error/offline) + how each appears

- Verifying: disables input and shows loading state.
- Resending: disables resend action and shows cooldown (“Resend code in … s”).
- Errors are mapped to user-friendly messages (invalid code, expired code, etc.).

## Primary actions + validation rules

- Verification code:
  - must be 6 digits (client-side expectation)
- Verify:
  - Signup: `AuthService.instance.verifySignupCode(...)`
  - Email change: `AuthService.instance.verifyEmailChangeCode(...)`
- Resend:
  - Signup: `AuthService.instance.resendSignupCode(...)`
  - Email change: `AuthService.instance.resendEmailChangeCode(...)`

## Data dependencies (services/repos + Supabase tables if confirmable)

- Auth flows: `AuthService` (Supabase OTP verification via Supabase Auth)
- Profile updates after verification are handled by auth/account services (`profiles`).

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Successful verification may:
  - complete signup flow
  - complete an email change
  - invoke an optional `onVerified` callback

## Accessibility notes (only what you can confirm from code)

- Uses labeled input field and buttons; no explicit semantics overrides found.

## Tests (existing tests that cover it; if none, TODO)

- `test/screens/account/verify_email_screen_test.dart`

## Related links (to other docs/latest pages)

- [Backend](../backend.md)
- [Security](../security.md)
- [Privacy](../privacy.md)

