# WelcomeScreen

## Purpose

- First screen for unauthenticated users.
- Offers sign-in entry points (email login and Google Sign-In).
- Provides in-app access to Terms & Conditions and Privacy Policy content.

Implementation: `lib/screens/auth/welcome_screen.dart`

## Entry points (routes/deeplinks/navigation)

- GoRouter route: `/welcome`
- Typically reached from `BootstrapGate` when there is no valid session.

## UI Anatomy (major sections; key components; sheets/dialogs)

- Brand header + illustration
- Headline/subtitle (from `AppConstants`)
- Primary action: “Log in with email” → navigates to `/login`
- Secondary action: “Continue with Google” → triggers Google Sign-In
- Legal footer:
  - Opens Terms and Privacy via `AppModal.legal(...)` using strings in `lib/app/constants.dart`

## States (loading/empty/error/offline) + how each appears

- Loading: Google button shows an inline spinner while sign-in is in progress.
- Error: sign-in failures show a snack bar message.

## Primary actions + validation rules

- Email login: navigates to `/login` (no validation on this screen).
- Google sign-in: calls `AuthService.signInWithGoogle()`.

## Data dependencies (services/repos + Supabase tables if confirmable)

- Auth: `AuthService.signInWithGoogle()` (Supabase Auth + profile upsert in `profiles`)
- Legal content: `AppConstants.termsAndConditionsContent`, `AppConstants.privacyPolicyContent`

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Performs authentication; successful sign-in navigates to `/app`.
- `TODO:` No explicit analytics events are logged directly by this screen.

## Accessibility notes (only what you can confirm from code)

- Uses standard Flutter buttons and text; no explicit semantics overrides found.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `WelcomeScreen`.

## Related links (to other docs/latest pages)

- [Privacy](../privacy.md)
- [Security](../security.md)
- [Screens index](index.md)

