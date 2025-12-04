**Copilot Design-System Audit & Migration Codex**

This document is an actionable, developer-facing audit and changelog that records the design-system remediation work performed by the Copilot agent during the current session. It consolidates the conversation history, the code changes applied, verification steps, and recommended follow-ups.

**Scope**: library code under `lib/` (screens, sheets, kit components, theme tokens).

---

**Summary (High Level)**:
- **Goal:** Replace private, duplicated UI elements across screens with shared kit components; remove hard-coded tokens (colors, durations, spacing) and align components to `AppTokens` design system.
- **Primary outcome:** Created reusable kit components and replaced many private components in `lib/screens/**` to reduce duplication and ensure design-token usage. Ran `flutter analyze` to validate no analyzer errors.

---

**What I changed (detailed)**

- New kit components added (files in `lib/ui/kit/`):
  - `section_header.dart` — `SectionHeader` (title + optional subtitle; replaces private `_SectionHeader`).
  - `info_chip.dart` — `InfoChip` (compact icon + label chip; replaces `_ScopeChip`, `_SummaryChip`, and similar chips).
  - `info_tile.dart` — `InfoTile` (icon, title, optional subtitle; supports `iconInContainer`, `compactContainer`, `showChevron`, `tint`, `onTap`). Used to replace `_PrivacyTile`, `_FeatureTile`, `_BulletTile`, `_SettingsTile`.
  - `refresh_chip.dart` — `RefreshChip` (small refresh chip used on dashboards; replaces `_RefreshChip`).
  - `simple_bullet.dart` — `SimpleBullet` (small bullet list row; replaces `_SimpleBullet`).

- Kit export updated:
  - `lib/ui/kit/kit.dart` — exported the new components so they are available across the app.

- Screens & sheets updated (examples, not exhaustive):
  - `lib/screens/add_class_page.dart`
    - Replaced `_SectionHeader` → `SectionHeader`.
    - Replaced `_ScopeChip` → `InfoChip`.
    - Removed the private `_SectionHeader` and `_ScopeChip` class definitions.

  - `lib/screens/add_reminder_page.dart`
    - Replaced `_SectionHeader` → `SectionHeader`.
    - Replaced `_SummaryChip` → `InfoChip`.
    - Removed the private `_SectionHeader` and `_SummaryChip` class definitions.

  - `lib/screens/privacy_sheet.dart`
    - Replaced `_PrivacyTile` → `InfoTile` (passed `subtitle` in place of `description`).
    - Replaced `_SimpleBullet` → `SimpleBullet`.
    - Removed private `_PrivacyTile` and `_SimpleBullet` definitions.

  - `lib/screens/about_sheet.dart`
    - Replaced `_FeatureTile` and `_BulletTile` → `InfoTile` (used `iconInContainer: true` and `compactContainer: true` for feature tiles).
    - Replaced `_SimpleBullet` → `SimpleBullet`.
    - Removed their private definitions.

  - `lib/screens/account_overview_page.dart`
    - Replaced `_SettingsTile` → `InfoTile(iconInContainer: true, showChevron: true, tint: ...)`.
    - Removed `_SettingsTile` private definition.

  - `lib/screens/dashboard/dashboard_cards.dart`
    - Replaced `_CompactMetricChip` usages earlier with `MetricChip(displayStyle: true)`.
    - Replaced `_RefreshChip` → `RefreshChip` and removed private `_RefreshChip`.

- Theme & style fixes performed earlier in the session (kept as context):
  - Replaced hard-coded `Color(0xFF...)` usages in screens with appropriate `AppTokens` color tokens where found during the initial audit (notably in `settings_screen.dart`).
  - Replaced raw `Duration(milliseconds: ...)` uses with `AppTokens.motion` variants where applicable (example in `bootstrap_gate.dart`).

---

**Files created**
- `lib/ui/kit/section_header.dart`
- `lib/ui/kit/info_chip.dart`
- `lib/ui/kit/info_tile.dart`
- `lib/ui/kit/refresh_chip.dart`
- `lib/ui/kit/simple_bullet.dart`
- `docs/codex/copilot_audit.md` (this file)

**Files modified** (high-level list)
- `lib/ui/kit/kit.dart` — exports
- `lib/screens/add_class_page.dart`
- `lib/screens/add_reminder_page.dart`
- `lib/screens/privacy_sheet.dart`
- `lib/screens/about_sheet.dart`
- `lib/screens/account_overview_page.dart`
- `lib/screens/dashboard/dashboard_cards.dart`

Note: many other files were read and some minor edits applied earlier during the session (color/duration/spacing fixes). The above list records the most significant component consolidation changes.

---

**Why these changes**
- Avoid duplicated private components with slightly different styling that cause visual inconsistency (example: `_CompactMetricChip` vs `MetricChip`).
- Enforce design tokens (`AppTokens`) for spacing, radii, colors, typography, and motion durations so behavior and theming are consistent across light/dark modes.
- Centralize common UI patterns (tile, chip, header) into `lib/ui/kit/` so future design updates affect all screens.

---

**Remaining findings / suggestions (things to review next)**
- During a repository-wide scan we discovered other private/private-like classes that may be intentionally private (internal to a widget) or duplicates that could also be promoted to the kit. Please review and decide which should be promoted:
  - `lib/ui/kit/reminder_details_sheet.dart` — `class _InfoChip` (internal to sheet)
  - `lib/ui/kit/class_details_sheet.dart` — `class _InfoChip`
  - `lib/ui/kit/glass_navigation_bar.dart` — `_FloatingQuickActionButton`, `_InlineQuickActionButton` (context-specific quick-action buttons)
  - `lib/screens/schedules_preview_sheet.dart` — `_ImportHeader`, `_SectionCard`, `_DayToggleCard`, `_ImportClassTile` (import sheet internals)
  - `lib/screens/schedules/schedules_cards.dart` — `_ScheduleHeroChip`
  - `lib/screens/dashboard/dashboard_cards.dart` — `_DashboardSummaryCard`, `_UpcomingHeroTile`, `_UpcomingListTile` (dashboard internals — review if generic)
  - `lib/screens/dashboard/dashboard_messages.dart` — `_DashboardMessageCard`
  - `lib/screens/dashboard/dashboard_reminders.dart` — `_DashboardReminderCard`, `_DashboardReminderTile`
  - `lib/app/root_nav.dart` — `_QuickActionButton`

Recommendation: review each item and promote the ones that are reused across screens into `lib/ui/kit/`. Keep intentionally local widgets that are truly single-use and tightly coupled to surrounding layout.

---

**Testing & Verification**
1. Local static analysis (already run):
   - `flutter analyze --no-fatal-infos` — returned `No issues found` after the changes.
2. Unit & widget tests (optional but recommended):
   - `flutter test` — run to ensure no regressions in widget tests.
3. Manual visual verification (recommended):
   - Run on an emulator/device and visually confirm screens that were changed: `Add class`, `Add reminder`, `Privacy`, `About`, `Account overview`, and dashboard cards.

Commands to run locally:
```powershell
cd c:\projects\mysched
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter run
```

---

**Developer notes: code review checklist**
- Ensure all `InfoTile` and `InfoChip` usages supply the correct parameters (`subtitle` vs `description`, `tint`, `iconInContainer`, `compactContainer`).
- Confirm `const` usage where applicable for improved performance (many items are `const` already).
- When promoting a private widget to kit, keep the API minimal and use `AppTokens` for spacing/radii/fonts.
- When removing a private class, ensure there are no remaining references (IDE will highlight unresolved symbols). Run `flutter analyze` to catch misses.

---

**Changelog: session timeline (detailed)**
- Performed an initial design-system audit across `lib/screens/**` and found violations (hard-coded colors, raw Durations, private duplicated components).
- Fixed immediate token violations in `settings_screen.dart` and `bootstrap_gate.dart` (colors → `AppTokens`, durations → `AppTokens.motion`, spacing tokens).
- Investigated alignment discrepancy in dashboard cards; found `_CompactMetricChip` was different from `MetricChip` used elsewhere.
- Created `MetricChip(displayStyle: true)` replacements and deleted unused private classes in dashboard.
- The user requested conversion of all private duplicates into global kit components.
- Implemented new kit components: `SectionHeader`, `InfoChip`, `InfoTile`, `RefreshChip`, `SimpleBullet` and exported them.
- Replaced usages across multiple screens (see 'Files modified' above) and deleted the replaced private classes.
- Ran `flutter analyze` to confirm no analyzer issues; fixed missed `SimpleBullet` references by creating `simple_bullet.dart` and exporting from `kit.dart`.
- Re-ran `flutter analyze` → success: `No issues found`.

---

**Next Steps & Recommended PR instructions**
1. Review this codex and check the remaining private classes listed in the "Remaining findings" section.
2. Create a PR with the changes (branch from `main`). Suggested PR title: `chore(ui): promote private UI components to kit + design-token alignment`.
3. In PR description, reference this codex and list the files changed and verification steps.
4. Request one reviewer and ensure CI runs `flutter analyze` and `flutter test`.

---

If you'd like, I can:
- Open PR and commit these changes (I can stage and create a commit message). 
- Continue promoting the remaining private widgets to kit components.
- Generate a shorter developer focused README for the kit usage.

End of copilot audit codex.
