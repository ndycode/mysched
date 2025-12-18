# Backend (Supabase)

MySched uses Supabase for:

- Authentication (email/password, OTP flows, Google Sign-In)
- PostgREST database access (`.from('table')`)
- Storage (avatar uploads)
- Edge Functions (account deletion)

Supabase is initialized in `lib/env.dart` (`Supabase.initialize(url, anonKey)`).

## Source of truth

Backend objects referenced here are derived from:

- `schema.sql` (explicitly labeled as “context only” in-file)
- `supabase/migrations/*.sql`
- Direct table/view/function names referenced in Dart code

If a table/view/RPC is referenced by the app but no definition exists in this repo, it is labeled `TODO:`.

## Confirmed tables (from `schema.sql`)

| Table | Used by | Notes |
|---|---|---|
| `profiles` | `AuthService`, `AdminService` | user profile row; created by trigger migration |
| `sections` | schedule flows | user links to section; semester scoping |
| `classes` | schedule flows | class rows per section |
| `user_sections` | schedule scan/import | links a user to a section |
| `user_custom_classes` | schedule | custom/manual classes |
| `user_class_overrides` | schedule | per-user enabled/disabled overrides |
| `reminders` | reminders | task/assignment reminders |
| `user_settings` | settings sync | synced user preferences |
| `instructors` | instructor mode | instructor identity; may link to auth user via `user_id` |
| `admins` | admin mode | admin allowlist |
| `class_issue_reports` | admin tools | user-submitted reports about class data |
| `audit_log` | admin tools | write-audit on admin actions |
| `study_sessions` | study timer/stats | persisted study session history |
| `semesters` | schedule | active semester selection |

## Confirmed migrations (`supabase/migrations/`)

### `create_profile_on_signup.sql`

- Creates trigger/function to upsert a `profiles` row on auth user creation.

### `add_instructor_user_id.sql`

- Adds `instructors.user_id` and a view `instructor_schedule` (used by `InstructorService`).

## Objects referenced in code but not defined in repo (TODO)

### Views / tables

- `user_classes_v` (used heavily by `ScheduleApi`)
- `user_schedule_view` (used by `ScheduleShareService`)
- `schedule_shares` (used by `ScheduleShareService`)

### RPCs

- `is_student_id_available` (used by `AuthService.register` validation)
- `rescan_section` (used by schedule scan/import and `ScanService`)
- `set_class_deleted` (referenced by `ScheduleService`, which appears unused in current UI)

### Edge Functions

- `delete_account` (invoked by `AuthService.deleteAccount`)

## Data model notes (as used by the app)

### Auth + profiles

- Primary auth is Supabase Auth.
- Profile rows live in `profiles` keyed by auth `user.id`.
- `AuthService` upserts profile metadata and stores:
  - `full_name`
  - `student_id`
  - `email`
  - `avatar_url`

Avatar upload:

- Bucket: `avatars` (Supabase Storage)
- Path pattern: `user_<uid>/avatar.<ext>`
- App stores the public URL back into `profiles.avatar_url`.

### Schedule

Schedule composition (current implementation in `ScheduleApi`):

- Base schedule from `user_classes_v` filtered by “current section id”:
  - Section is derived via `user_sections` and `sections` and is re-mapped to the active `semesters` row when possible.
- Overrides from `user_class_overrides` (per-class enabled/disabled).
- Custom classes from `user_custom_classes` (per-user rows).

### Reminders

- `reminders` rows are per-user (`user_id`).
- Status values are treated as strings in Dart:
  - `pending`
  - `completed`
- Snoozing updates `due_at` and `snooze_until`.

### Instructor mode

- `InstructorService` checks `instructors.user_id == auth.user.id`.
- If matched, it reads the `instructor_schedule` view filtered by:
  - `instructor_id`
  - `semester_active = true`

### Admin mode

- `AdminService` treats a user as admin if a row exists in `admins` for their `user_id`.
- Admin tools read `class_issue_reports` and write `audit_log` entries for status updates.

## RLS / authorization model

`TODO:` This repo does not include a complete set of policies/migrations for RLS. If you rely on RLS, document it from:

- Supabase dashboard policy export, or
- SQL migrations in-repo

## Related

- Runtime config: [Configuration](configuration.md)
- Alarm/notification system: [Notifications](notifications.md)

