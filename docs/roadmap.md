# MySched Program Plan

> Updated: December 2024

Context: Core screens, offline cache (`OfflineCacheService`), retryable Supabase access (`ScheduleApi`), state widgets (`ui/kit/states.dart`), design system (`ui/theme/tokens.dart`), and analytics/telemetry scaffolding are in place. This roadmap tracks remaining work items and sequencing.

---

## Completed ✅

### Design System (v2.3–2.4)
- [x] Centralized tokens: spacing, radii, typography, motion in `tokens.dart`
- [x] UI Kit components: `CardX`, `PrimaryButton`, `SecondaryButton`, `StateDisplay`, `Skeleton*`
- [x] 97% AppTokens adoption across screens
- [x] 100% colorScheme usage (no hardcoded colors)
- [x] Typography system with 8 text styles
- [x] Motion system with durations and curves
- [x] Design system documentation (`docs/design_system.md`)

### UX Resilience
- [x] `StateDisplay` for empty/error/success states
- [x] `MessageCard`, `InfoBanner` for inline states
- [x] Skeleton loaders for list views
- [x] Haptic feedback on buttons and interactions
- [x] Semantic labels on scaffolds and navigation

### Core Features
- [x] Dashboard with schedule hero, reminders preview, metrics
- [x] Schedules module with CRUD, filtering, search
- [x] Reminders module with CRUD, snooze, completion
- [x] Settings with theme, notifications, account management
- [x] Auth flows: login, register, email verification, password reset

---

## In Progress 🚧

### Phase 0: Hardening + Test Backbone
- [ ] Schedule logic tests for DST/time-zone edges
- [ ] Reminder API retry/exhaustion tests
- [ ] Widget smoke tests for loading/error/empty states
- [ ] Performance micro-benchmarks for debounce/search

### Design System Cleanup
- [ ] Migrate 6 files with legacy `BorderRadius.circular` → `AppTokens.radius`
- [ ] Migrate 5 files with hardcoded `EdgeInsets` → `AppTokens.spacing`
- [ ] Increase `AppTokens.motion` adoption from 77% → 95%

---

## Upcoming Phases

### Phase 1: Data, Offline, and Sync
- [ ] Wire `OfflineCacheService` in schedule/reminder fetch paths
- [ ] Add TTL + "last refreshed" banner
- [ ] Offline queue with mutation handlers for CRUD
- [ ] Surface pending count in settings with "Sync now"
- [ ] `ConnectionMonitor` banner integration

### Phase 2: Notifications & Permissions
- [ ] Per-reminder lead-time settings
- [ ] Permission explainer sheet before system prompt
- [ ] Background refresh job for resync
- [ ] Alarm DND hints and dismissal flow

### Phase 3: Forms & Validation Polish
- [ ] Centralize validators in `lib/utils/`
- [ ] Inline errors + summary banner on submit
- [ ] Debounce on search inputs
- [ ] Keyset pagination for large datasets

### Phase 4: Config, Security, CI
- [ ] CI preflight for accidental key patterns
- [ ] Coverage gate on scheduling/reminders modules
- [ ] `flutter analyze`, `dart format`, `flutter test` in CI

### Phase 5: i18n & Accessibility
- [ ] Externalize strings to `intl`
- [ ] Locale switcher in settings
- [ ] RTL layout verification
- [ ] Dynamic text scaling tests
- [ ] Contrast verification on light/dark

### Phase 6: Platform Parity
- [ ] Android/iOS permission/background task audit
- [ ] Desktop/Web responsive layouts
- [ ] Feature flags for unsupported features

---

## Milestones

| Phase | Target | Status |
|-------|--------|--------|
| Design System | v2.4 | ✅ Complete |
| UX Resilience | v2.4 | ✅ Complete |
| Test Backbone | v2.5 | 🚧 In Progress |
| Design Cleanup | v2.5 | 🚧 In Progress |
| Offline/Sync | v2.6 | Planned |
| Notifications | v2.6 | Planned |
| Forms/Validation | v2.7 | Planned |
| CI/Security | v2.7 | Planned |
| i18n/a11y | v2.8 | Planned |
| Platform Parity | v2.8 | Planned |

---

## Exit Criteria by Stream

| Stream | Criteria | Status |
|--------|----------|--------|
| Design System | 95%+ token adoption, documented | ✅ |
| UX Resilience | Standardized states, skeletons, haptics | ✅ |
| Reliability | API tests, DST/TZ coverage, no flaky CI | 🚧 |
| Offline/Sync | Instant cache load, auto-sync, pending count | Planned |
| Notifications | Configurable lead times, permission flow | Planned |
| Config/Security | Secrets safe, CI enforced | Planned |
| i18n/a11y | Strings externalized, RTL/scaling verified | Planned |
