# ChangePasswordSheet

## Purpose

- Allows an authenticated user to change their password.

Implementation: `lib/screens/account/change_password_sheet.dart`

## Entry points (routes/deeplinks/navigation)

- GoRouter route wrapper: `/account/change-password` (`lib/screens/account/change_password_screen.dart`)
- Also opened via `ChangePasswordScreen.show(...)` from:
  - `lib/screens/account/account_screen.dart`

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal container: `ModalShell`
- Form fields:
  - Current password
  - New password
  - Confirm new password
- Explanatory copy about session security
- Primary action: change password

## States (loading/empty/error/offline) + how each appears

- Loading: disables inputs and shows submit loading state.
- Errors are mapped (incorrect current password, weak password, new password same as old).

## Primary actions + validation rules

- Current password required.
- New password must be different from current and match confirm field.
- Submit uses `AuthService` password-change logic.

## Data dependencies (services/repos + Supabase tables if confirmable)

- `AuthService` (Supabase Auth update password flow)

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Password updates may invalidate older sessions (depends on Supabase behavior and app implementation).

## Accessibility notes (only what you can confirm from code)

- Uses standard form validation and autofill hints.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `ChangePasswordSheet`.

## Related links (to other docs/latest pages)

- [Security](../security.md)
- [Backend](../backend.md)

