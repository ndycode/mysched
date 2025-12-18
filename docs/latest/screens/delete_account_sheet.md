# DeleteAccountSheet

## Purpose

- Allows an authenticated user to delete their account.
- Requires confirmation and password entry.

Implementation: `lib/screens/account/delete_account_sheet.dart`

## Entry points (routes/deeplinks/navigation)

- GoRouter route wrapper: `/account/delete` (`lib/screens/account/delete_account_screen.dart`)
- Also opened via `DeleteAccountScreen.show(...)` from:
  - `lib/screens/account/account_screen.dart`

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal container: `ModalShell`
- Warning copy about permanent deletion
- Password input
- Confirmation dialog (`AppModal.confirm`) before deletion
- Primary action: delete account

## States (loading/empty/error/offline) + how each appears

- Deleting: disables inputs and shows loading state.
- Errors: surfaced via inline messages and/or snack bars.

## Primary actions + validation rules

- Requires the user to confirm via a danger confirmation prompt.
- Requires password (trimmed) for deletion request.
- Calls `AuthService.instance.deleteAccount(password: ...)`.

## Data dependencies (services/repos + Supabase tables if confirmable)

- `AuthService.deleteAccount(...)` invokes Supabase Edge Function `delete_account`.
  - `TODO:` Edge Function code is not present in this repo.

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Account deletion should revoke access and remove server-side data (depends on Edge Function implementation).

## Accessibility notes (only what you can confirm from code)

- Uses standard form + confirmation dialog.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `DeleteAccountSheet`.

## Related links (to other docs/latest pages)

- [Privacy](../privacy.md)
- [Security](../security.md)
- [Backend](../backend.md)

