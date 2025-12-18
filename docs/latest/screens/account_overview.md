# AccountOverviewPage

## Purpose

- Lets a signed-in user view and update account/profile details.
- Provides access to email/password management and account deletion.

Implementation: `lib/screens/account/account_screen.dart`

## Entry points (routes/deeplinks/navigation)

- GoRouter route: `/account`
- Common navigation entry points:
  - “Account” actions in `SchedulesPage` and `RemindersPage` headers
  - Settings may also navigate here indirectly (depends on UI flow)

## UI Anatomy (major sections; key components; sheets/dialogs)

- Profile header with avatar
- Profile editing actions:
  - Change avatar (image picker + crop flow, then upload)
  - Update full name / student ID (based on available actions in this screen)
- Account actions:
  - Change email (`ChangeEmailSheet`)
  - Change password (`ChangePasswordSheet`)
  - Delete account (`DeleteAccountSheet`)

## States (loading/empty/error/offline) + how each appears

- Loads profile info from Supabase and caches some fields locally (e.g., avatar URL is also stored in SharedPreferences).
- Avatar upload shows progress/loading states; errors surface via snack bars and inline messages.

## Primary actions + validation rules

- Avatar update:
  - user selects image → crop → upload to Supabase Storage bucket `avatars`
  - profile row is updated with a public URL
- Email/password/delete flows are delegated to sheets, which enforce their own validation.

## Data dependencies (services/repos + Supabase tables if confirmable)

- `AuthService`:
  - Reads/writes `profiles`
  - Uploads to Storage bucket `avatars`
- Change email/password/delete:
  - Supabase Auth APIs (see [Backend](../backend.md))
  - Delete account calls Edge Function `delete_account` (`TODO:` function not in repo)

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Avatar upload creates/overwrites a file under `avatars/user_<uid>/...` and updates `profiles.avatar_url`.
- Sign-out flows elsewhere may clear cached data; confirm desired behavior if you add more caching.

## Accessibility notes (only what you can confirm from code)

- Uses standard Material widgets and custom UI kit components; no explicit semantics overrides found.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `AccountOverviewPage`.

## Related links (to other docs/latest pages)

- [Backend](../backend.md)
- [Security](../security.md)
- [Privacy](../privacy.md)
- [Screens index](index.md)

