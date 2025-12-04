# MySched Program Plan

Context: core screens, offline cache (`OfflineCacheService`), retryable Supabase access (`ScheduleApi`), state widgets (`ui/kit/states.dart`), and analytics/telemetry scaffolding exist. The plan below turns the remaining gaps into concrete work items and sequencing so we can execute “all” streams without stepping on each other.

## Phase 0: Hardening + Test Backbone (start here)
- Reliability: Add schedule logic tests for DST/time-zone edges, overlap detection, and retry exhaustion in `test/services/schedule_api_test.dart`; mirror for reminders in `test/services/reminders_api_test.dart` (add file). Add widget smoke tests for `lib/screens/schedules/schedules_screen.dart` and `lib/screens/reminders/reminders_screen.dart` to pin loading/error/empty states.
- Observability: Ensure every GoRouter route has `TelemetryNavigatorObserver` tags (already registered) and add event names for failures/timeouts in `services/*_api.dart` paths. Verify `TelemetryService.ensureRecorder` is invoked once in `main.dart`.
- Performance guardrails: Add micro-benchmarks for debounce/search flows (create `test/utils/pagination_test.dart` for paging/debounce helpers).

## Phase 1: UX Resilience (loading/error/empty)
- Standard states: Replace ad-hoc placeholders with `StateDisplay`/`MessageCard` in reminders, schedules, dashboard list cards, and admin reports (`lib/screens/..._messages.dart`). Provide retry closures tied to data sources (ScheduleApi.fetchClasses, RemindersApi.fetchReminders).
- Loading strategy: Prefer skeletons (`ui/kit/skeletons.dart`) for list views; only use global spinners for blocking modals.
- Accessibility: Confirm semantics/tap targets ≥48px on primary buttons and list items; wire `Semantics` labels for FABs and nav actions.

## Phase 2: Data, Offline, and Sync
- Local cache: Wire `OfflineCacheService` save/read in schedule/reminder fetch paths; persist per-user snapshots and hydrate UI before network. Add TTL + “last refreshed” banner using `DataSync.lastScheduleSync`.
- Offline queue: Register concrete mutation handlers for reminder CRUD and custom class edits in `OfflineQueue` and invoke `enqueue` on network failures. Surface pending count in settings with “Sync now” action.
- Connection awareness: `ConnectionMonitor` should broadcast status to a shared banner component (reuse `InfoBanner`); pause pull-to-refresh when offline.

## Phase 3: Notifications & Permissions
- Local notifications: Audit `NotifScheduler` coverage—add per-reminder lead-time settings, channel IDs, and deduping. Add permission explainer sheet before system prompt and retry path for denied → settings.
- Background refresh: Schedule a periodic job to resync reminders/classes when online; no-op if user disabled notifications.
- Alarms: Ensure alarm screen respects Do Not Disturb hints and has a dismissal/undo flow; add tests for scheduling windows (night vs day).

## Phase 4: Forms, Validation, and UX polish
- Validation kit: Centralize validators (required, max length, time ordering, overlap) in `lib/utils/` and reuse in add/edit class/reminder forms. Inline errors + summary banner on submit failure.
- Search/debounce: Add debounce to instructor/search inputs; cap Supabase page sizes and enable keyset pagination where supported.
- Design system: Finalize tokens in `ui/theme/tokens.dart` (spacing, radii, elevations) and apply to buttons/forms/navigation for consistency. Extract shared form field styles.

## Phase 5: Config, Security, and CI
- Secrets hygiene: Keep `SUPABASE_URL`/`SUPABASE_ANON_KEY` in `.env`/`--dart-define`; add a CI preflight that fails on accidental key patterns in git diff. Document in README.
- Env ergonomics: Add `Env.init` error UI (already present) to all entry points; emit analytics breadcrumbs for config load success/failure.
- CI: Ensure `flutter analyze`, `dart format .`, and `flutter test` run in CI; add coverage target on scheduling/reminders modules. Optional: `flutter test --coverage` gate for release branches.

## Phase 6: Internationalization & Accessibility
- i18n: Externalize user-facing strings to `intl`, add locale switcher in settings, and verify RTL layout for key screens. Cover date/time formatting per locale.
- Accessibility deep-dive: Test dynamic text scaling, contrast on light/dark themes, and focus order for dialog/sheet components. Add semantics for progress/success/error banners.

## Phase 7: Platform Parity
- Android/iOS: Re-check notification/storage permissions and background task policies; document required plist/manifest strings. Ensure photo/camera flows handle denial gracefully.
- Desktop/Web: Validate layouts with `responsive_framework` breakpoints; guard features not supported on web (local notifications, file system) with feature flags and UX messaging.

## Milestones & Ownership
- Week 1: Phase 0 + Phase 1 (tests + state UX), ready for merge behind feature flags where risky.
- Week 2: Phase 2 + Phase 3 (offline/queue + notifications), plus smoke tests.
- Week 3: Phase 4 + Phase 5 (forms/validation + CI/security), start i18n scaffolding.
- Week 4: Phase 6 + Phase 7 (a11y/i18n + platform parity), regression sweep.

## Exit Criteria by Stream
- Reliability: Schedule/reminder APIs covered for retries, DST/time zones, and overlap; no flaky tests in CI.
- UX: All list/detail screens use standardized empty/error/loading patterns with retries.
- Offline/Sync: Cached schedules/reminders load instantly; offline mutations sync automatically when back online; users can see pending count and force sync.
- Notifications: Reminder lead times configurable; prompts are explained; alarms behave across platforms.
- Config/Security: Secrets never committed; `.env` documented; CI enforces lint/test/format.
- i18n/a11y: Strings externalized; RTL verified; text scaling and contrast pass manual checks.
