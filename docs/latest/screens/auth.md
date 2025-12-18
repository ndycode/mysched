# AuthScreen (Login / Register)

## Purpose

- Provides a unified authentication surface for:
  - Email/password login
  - Email/password registration (with full name + student ID)
  - Google Sign-In
- Provides entry into password reset flow.

Implementation: `lib/screens/auth/login_screen.dart`

## Entry points (routes/deeplinks/navigation)

- GoRouter routes:
  - `/login` → `AuthScreen(initialMode: AuthMode.login)`
  - `/register` → `AuthScreen(initialMode: AuthMode.register)`
- “Forgot password?” button opens `/forgot-password` (sheet route).

`TODO:` The router’s `/forgot-password` and `/verify` pages expect typed args (`ForgotPasswordScreenArgs` / `VerifyEmailScreenArgs`) or query parameters, but `AuthScreen` currently passes a `Map` via `state.extra`. If you rely on prefilled emails, align argument passing.

## UI Anatomy (major sections; key components; sheets/dialogs)

- Mode switch via `TabBar` (“Log In” / “Sign Up”)
- Login form fields:
  - Email
  - Password
- Register form fields:
  - Full name
  - Student ID
  - Email
  - Password
  - Confirm password
- “Forgot password?” link (login mode)
- Google Sign-In button

## States (loading/empty/error/offline) + how each appears

- Loading: submit button shows loading state while auth is in progress; Google button shows its own loading state.
- Errors: failures are surfaced via snack bars with mapped messages (invalid credentials, email already registered, student ID already in use).

## Primary actions + validation rules

- Email validation: must contain `@` (simple client-side check).
- Password validation: at least 6 characters (client-side check).
- Register-only validation:
  - full name required
  - student ID required (uppercased before submission)
  - confirm password must match
- Login:
  - calls `AuthService.login(email, password)`
  - navigates to `/app` on success
- Register:
  - calls `AuthService.register(fullName, studentId, email, password)`
  - navigates to `/verify` to confirm email

## Data dependencies (services/repos + Supabase tables if confirmable)

- Auth: `AuthService` (Supabase Auth)
- Profile metadata storage:
  - `profiles` (full name, student_id, email)
- Registration validation:
  - RPC `is_student_id_available` is used by `AuthService` (`TODO:` definition not in repo)

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Writes a local SharedPreferences flag `auth.has_logged_in_before` after successful login.
- Google Sign-In flow checks profile completeness and may route into profile completion prompts later.

## Accessibility notes (only what you can confirm from code)

- Uses standard `TextFormField` validation messages; no explicit semantics overrides found.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `AuthScreen`.

## Related links (to other docs/latest pages)

- [Backend](../backend.md)
- [Configuration](../configuration.md)
- [Screens index](index.md)
