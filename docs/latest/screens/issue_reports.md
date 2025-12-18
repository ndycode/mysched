# IssueReportsScreen (Admin)

## Purpose

- Allows admins to review and triage user-submitted class issue reports.
- Supports updating report status and adding a resolution note.

Implementation: `lib/screens/admin/issue_reports_screen.dart`

## Entry points (routes/deeplinks/navigation)

- Not routed via GoRouter.
- Opened via Settings (admin section) using a `MaterialPageRoute` push:
  - Source: `lib/screens/settings/settings_screen.dart`

## UI Anatomy (major sections; key components; sheets/dialogs)

- Report list view, showing:
  - class metadata (from `snapshot` fields)
  - reporter identity (loaded from `profiles`)
  - status badge
- Status actions (depending on current status):
  - mark in review
  - resolve
  - ignore
- Resolution note entry (prompt-style modal in the UI)

## States (loading/empty/error/offline) + how each appears

- Loading: report list fetch uses `AdminService`.
- Errors: failures show snack bars (e.g., “Failed to update status”).

## Primary actions + validation rules

- Update report status:
  - Calls `AdminService.updateReportStatus(...)`
  - Writes an `audit_log` row with status transition details

## Data dependencies (services/repos + Supabase tables if confirmable)

- `AdminService`:
  - Checks admin access via `admins`
  - Reads `class_issue_reports`
  - Reads reporter data from `profiles`
  - Writes `audit_log`

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Writes audit log entries for admin actions.
- `TODO:` Confirm whether admin status is cached; `AdminService.refreshRole()` is a live query.

## Accessibility notes (only what you can confirm from code)

- Uses standard list controls and buttons; no explicit semantics overrides found.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `IssueReportsScreen`.

## Related links (to other docs/latest pages)

- [Backend](../backend.md)
- [Security](../security.md)
- [Screens index](index.md)

