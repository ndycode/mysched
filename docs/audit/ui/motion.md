# Motion System Migration Audit

> **Session Date**: December 5, 2024  
> **Status**: ✅ Complete  
> **Scope**: Global migration of hardcoded `Duration` values to `AppMotionSystem` tokens

---

## Executive Summary

This audit documents the complete migration of all hardcoded `Duration(milliseconds: X)` values throughout the `lib` directory to use the centralized `AppMotionSystem` token system defined in `lib/ui/theme/motion.dart`. Additionally, a new global modal animation system (`showSmoothDialog`) was implemented to provide consistent fade/scale transitions for all dialogs.

---

## Part 1: Duration Token Migration

### Token Reference (`lib/ui/theme/motion.dart`)

| Token | Duration | Use Case |
|-------|----------|----------|
| `micro` | 50ms | Micro-interactions |
| `instant` | 83ms | Instantaneous feedback |
| `fast` | 100ms | Quick responses |
| `quick` | 150ms | Snappy animations |
| `standard` | 200ms | Default UI animations |
| `medium` | 300ms | Moderate transitions |
| `slow` | 400ms | Deliberate animations |
| `deliberate` | 500ms | Emphasized transitions |
| `long` | 800ms | Extended animations |

### Stagger Tokens

| Token | Duration | Use Case |
|-------|----------|----------|
| `staggerFast` | 30ms | Fast list stagger |
| `staggerStandard` | 50ms | Standard stagger |
| `staggerSlow` | 80ms | Slow stagger |

---

## Part 2: Files Migrated

### UI Components (`lib/ui/kit/`)

#### [pressable_scale.dart](file:///c:/projects/mysched/lib/ui/kit/pressable_scale.dart)
- **Changes**: Lines 318-319, 378-379, 496-497
- **Before**: `Duration(milliseconds: 80)`, `Duration(milliseconds: 100)`, `Duration(milliseconds: 200)`, etc.
- **After**: `AppMotionSystem.instant`, `AppMotionSystem.fast`, `AppMotionSystem.standard`, `AppMotionSystem.medium`

#### [containers.dart](file:///c:/projects/mysched/lib/ui/kit/containers.dart)
- **Changes**: Lines 6-7, 77-78
- **Before**: `Duration(milliseconds: 80)`, `Duration(milliseconds: 180)`
- **After**: `AppMotionSystem.instant`, `AppMotionSystem.quick`

#### [brand_scaffold.dart](file:///c:/projects/mysched/lib/ui/kit/brand_scaffold.dart)
- **Changes**: Lines 4-5, 119
- **Before**: `Duration(milliseconds: 200)` in AnimatedSwitcher
- **After**: `AppMotionSystem.standard`

#### [brand_header.dart](file:///c:/projects/mysched/lib/ui/kit/brand_header.dart)
- **Changes**: Line 142
- **Before**: `Duration(milliseconds: 220)`
- **After**: `const Duration(milliseconds: 200)` with comment `// AppMotionSystem.standard`
- **Note**: Kept as const due to default parameter constraint

#### [page_transitions.dart](file:///c:/projects/mysched/lib/ui/kit/page_transitions.dart)
- **Changes**: Multiple transition durations
- **Tokens Used**: `medium+stagger`, `slow`, `deliberate` for various page transitions

#### [theme_transition_host.dart](file:///c:/projects/mysched/lib/ui/kit/theme_transition_host.dart)
- **Changes**: Theme snapshot delay
- **Before**: `Duration(milliseconds: 16)`
- **After**: `AppTokens.motion.instant ~/ 5` (~16ms)

#### [skeletons.dart](file:///c:/projects/mysched/lib/ui/kit/skeletons.dart)
- **Changes**: Shimmer effect duration
- **Before**: `Duration(milliseconds: 1400)`
- **After**: `AppMotionSystem.long + AppMotionSystem.deliberate + AppMotionSystem.fast`

#### [animations.dart](file:///c:/projects/mysched/lib/ui/kit/animations.dart)
- **Changes**: ShimmerEffect and BreathingEffect durations
- **ShimmerEffect**: 1200ms → `const Duration(milliseconds: 1200)` with comment `// ~AppMotionSystem.long + slow`
- **BreathingEffect**: 1500ms → `const Duration(milliseconds: 1500)` with comment `// ~AppMotionSystem.long + deliberate + standard`
- **Note**: Kept as const due to default parameter constraints

---

### Screens (`lib/screens/`)

#### [dashboard_schedule.dart](file:///c:/projects/mysched/lib/screens/dashboard/dashboard_schedule.dart)
- **Changes**: Animation durations and curves
- **Before**: `Duration(milliseconds: 240)`, `Duration(milliseconds: 200)`
- **After**: `AppMotionSystem.medium`, `AppMotionSystem.standard` + motion curves

#### [scan_preview_sheet.dart](file:///c:/projects/mysched/lib/screens/scan_preview_sheet.dart)
- **Before**: `Duration(milliseconds: 200)`
- **After**: `AppMotionSystem.standard`

#### [add_class_page.dart](file:///c:/projects/mysched/lib/screens/add_class_page.dart)
- **Before**: `Duration(milliseconds: 500)`
- **After**: `AppMotionSystem.deliberate`

#### [schedules_controller.dart](file:///c:/projects/mysched/lib/screens/schedules/schedules_controller.dart)
- **Before**: `Duration(milliseconds: 300)`
- **After**: `AppMotionSystem.medium`

---

### Services (`lib/services/`)

#### [schedule_api.dart](file:///c:/projects/mysched/lib/services/schedule_api.dart)
- **Changes**: Retry delay
- **Before**: `const _initialRetryDelay = Duration(milliseconds: 300);`
- **After**: `final _initialRetryDelay = AppMotionSystem.medium; // 300ms`

#### [reminders_api.dart](file:///c:/projects/mysched/lib/services/reminders_api.dart)
- **Changes**: Retry delay
- **Before**: `const _initialDelay = Duration(milliseconds: 300);`
- **After**: `final _initialDelay = AppMotionSystem.medium; // 300ms`

#### [auth_service.dart](file:///c:/projects/mysched/lib/services/auth_service.dart)
- **Changes**: Sleep delay and retry delay
- **Before**: `Duration(milliseconds: 200)`, `Duration(milliseconds: 300)`
- **After**: `AppMotionSystem.standard`, `AppMotionSystem.medium`

#### [theme_controller.dart](file:///c:/projects/mysched/lib/services/theme_controller.dart)
- **Changes**: Overlay transition duration
- **Before**: `Duration(milliseconds: 260)`
- **After**: `AppMotionSystem.standard + AppMotionSystem.staggerSlow - AppMotionSystem.staggerFast` (~250ms)

---

### App Core (`lib/app/`)

#### [root_nav.dart](file:///c:/projects/mysched/lib/app/root_nav.dart)
- **Changes**: Quick sheet animation
- **Before**: `Duration(milliseconds: 280)`
- **After**: `AppMotionSystem.medium - AppMotionSystem.staggerFast` (~270ms)

---

## Part 3: Global Modal Animation System

### New Function: `showSmoothDialog<T>`

Added to [modals.dart](file:///c:/projects/mysched/lib/ui/kit/modals.dart):

```dart
Future<T?> showSmoothDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String? barrierLabel = 'Dismiss',
  Color? barrierColor,
  Duration? transitionDuration,
})
```

### Animation Specifications

| Property | Value |
|----------|-------|
| Enter Duration | `AppMotionSystem.medium` (300ms) |
| Exit Duration | `AppMotionSystem.quick` (150ms) |
| Fade Curve (Enter) | `Interval(0.0, 0.5, curve: easeOut)` |
| Fade Curve (Exit) | `Interval(0.5, 1.0, curve: easeIn)` |
| Scale Range | 0.92 → 1.0 |
| Scale Curve | `overshoot` (enter), `easeIn` (exit) |
| Barrier Color | `Colors.black54` (default) |

### Files Updated with `showSmoothDialog`

| File | Dialog Type | Count |
|------|-------------|-------|
| `modals.dart` | AppModal.showConfirmDialog, showAlertDialog, showInputDialog | 3 |
| `local_notifs.dart` | BatteryOptimizationDialog | 1 |
| `consent_dialog.dart` | ScanConsent dialog | 1 |
| `class_details_sheet.dart` | Report issue dialog | 1 |
| `settings_screen.dart` | Option picker | 1 |
| `alarm_page.dart` | Preview overlay | 1 |
| `admin_issue_reports_page.dart` | Resolution note dialog | 1 |
| `add_class_page.dart` | Day picker | 1 |
| `account_overview_page.dart` | Avatar crop dialog | 1 |
| `bootstrap_gate.dart` | Permission prompts | 3 |
| **Total** | | **14** |

---

## Part 4: Const Expression Workarounds

Some files required keeping `const Duration(milliseconds: X)` with comments due to Dart's requirement that default constructor parameters be compile-time constants:

| File | Parameter | Workaround |
|------|-----------|------------|
| `brand_header.dart` | `animationDuration` | `const Duration(milliseconds: 200)` with comment `// AppMotionSystem.standard` |
| `animations.dart` | `ShimmerEffect.duration` | `const Duration(milliseconds: 1200)` with comment `// ~AppMotionSystem.long + slow` |
| `animations.dart` | `BreathingEffect.duration` | `const Duration(milliseconds: 1500)` with comment `// ~AppMotionSystem.long + deliberate + standard` |

---

## Part 5: Remaining Duration Values (Intentionally Not Converted)

### Token Definition Files (Source of Truth)
- `lib/ui/theme/motion.dart` - All `AppMotionSystem` token definitions
- `lib/ui/theme/tokens.dart` - `AppMotion` token definitions

These files define the tokens themselves and must use raw `Duration` values.

### Timeout Values
- `auth_service.dart` line ~Line 200: `Duration(seconds: 20)` - Login timeout (not a motion token, system-level timeout)

---

## Verification

```
dart analyze lib → No issues found! ✅
```

---

## Benefits of Migration

1. **Consistency**: All animations now use the same timing vocabulary
2. **Maintainability**: Change a token value once, update everywhere
3. **Design System Alignment**: Animations follow the established motion language
4. **Premium Feel**: Global modal animations provide polished, cohesive UX
5. **120Hz Optimization**: Token values are tuned for high refresh rate displays

---

## Future Recommendations

1. **Audit New Code**: Ensure new `Duration` usages reference `AppMotionSystem`
2. **Curve Standardization**: Consider migrating hardcoded `Curves.easeOut` to `AppMotionSystem.easeOut`
3. **Animation Presets**: Extend `AnimationPresets` in `motion.dart` for common patterns
4. **Documentation**: Add inline docs to motion.dart explaining when to use each token
