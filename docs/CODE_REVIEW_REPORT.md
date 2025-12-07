# MySched Code Review Report

## Summary

**Overall Code Quality: Good**

- ✅ Static Analysis: 0 issues
- ✅ Test Suite: 464 tests, all passing
- ✅ Architecture: Clean separation of concerns with services, models, screens pattern
- ✅ Error Handling: Comprehensive exception hierarchy with proper recovery
- ✅ Offline Support: Robust offline queue with automatic sync

---

## Issues Fixed During Review

### 1. Test: `class_details_sheet_test.dart` - AlertDialog vs Dialog
**File:** `test/ui/class_details_sheet_test.dart`  
**Issue:** Test expected `AlertDialog` but `AppModal.confirm` uses custom `Dialog`  
**Fix:** Changed finder from `AlertDialog` to `Dialog`

### 2. Test: `settings_page_test.dart` - Outdated Picker Interaction
**File:** `test/screens/settings_page_test.dart`  
**Issue:** Test tried to tap text option, but picker uses `ListWheelScrollView` scroll wheel  
**Fix:** Changed to scroll the wheel and tap OK button

### 3. Hardcoded Duration Values → Design Tokens
**Files:** `settings_screen.dart`, `schedules_screen.dart`, `tokens/motion.dart`  
**Issue:** Magic numbers for durations instead of design tokens  
**Fix:** Added `highlightDuration` and `previewDuration` tokens, updated code to use them

### 4. Duplicated Email Validation Logic → Centralized
**Files:** `validation_utils.dart`, `login_page.dart`, `register_page.dart`, `change_email_sheet.dart`  
**Issue:** `value.contains('@')` duplicated in 3 places  
**Fix:** Added `ValidationUtils.looksLikeEmail()` and `ValidationUtils.isValidEmail()`, updated all screens

---

## Remaining Recommendations

### MEDIUM PRIORITY

#### 1. Missing Disposal in ValueNotifier Controllers
**Files:** Some screen controllers  
**Issue:** Some controllers don't dispose internal notifiers  
**Recommendation:** Audit all controllers for proper cleanup in `dispose()`

#### 2. Widget Rebuild Optimization
**Files:** `dashboard_screen.dart`  
**Issue:** Large widget tree rebuilt on minor state changes  
**Recommendation:** Extract smaller `AnimatedBuilder` scopes or use `ValueListenableBuilder`

#### 3. Test Coverage Gaps
**Files:** `test/services/`  
**Issue:** Some services lack comprehensive edge case testing:
- `sync_control.dart` - only basic tests
- `reminders_api.dart` - missing error path tests
- `admin_service.dart` - no tests
**Recommendation:** Add integration tests for critical paths

---

### LOW PRIORITY

#### 8. Documentation Gaps
**Files:** Several services  
**Issue:** Public APIs missing dartdoc comments  
**Recommendation:** Add `///` documentation to all public methods

#### 9. Unused Imports
**Files:** Detected in some screen files  
**Issue:** Minor - unused imports present  
**Recommendation:** Run `dart fix --apply` to clean up

#### 10. String Concatenation in Build Methods
**Files:** Some UI files  
**Issue:** String building in hot paths could be optimized  
**Recommendation:** Consider `StringBuffer` for complex string building

---

## Architecture Observations

### Strengths
1. **Clean Service Layer**: Services properly encapsulate Supabase interactions
2. **Offline-First Design**: `OfflineQueue` + `ConnectionMonitor` + `DataSync` pattern is solid
3. **Error Hierarchy**: `AppException` subclasses provide good error context
4. **Design System**: Token-based theming with `AppTokens` is well-structured
5. **State Management**: `ValueNotifier` pattern keeps things simple and testable

### Areas for Enhancement
1. **Dependency Injection**: Services use singletons - could benefit from DI for testing
2. **Repository Pattern**: Direct Supabase calls in services - could add repository layer
3. **Feature Flags**: No feature flag system for gradual rollouts
4. **Analytics**: Limited telemetry beyond auth failures

---

## Security Observations

1. ✅ No hardcoded secrets in source (uses `env.dart` with external config)
2. ✅ Supabase RLS appears to be enforced based on `user_scope` patterns
3. ⚠️ Consider adding input sanitization for OCR-parsed text before display
4. ⚠️ Add rate limiting awareness for API calls in retry logic

---

## Performance Observations

1. **Image Caching**: Avatar images use network fetch - consider `CachedNetworkImage`
2. **List Rendering**: Large schedule lists could benefit from `ListView.builder` with keys
3. **Database Queries**: Some queries could use `.select()` with specific columns vs `*`

---

## Test Infrastructure

### Current State
- 464 tests covering widgets, services, models, utils
- Good mock infrastructure with `SupabaseTestBootstrap`
- Proper use of `SharedPreferences.setMockInitialValues`

### Recommendations
1. Add integration tests for critical user flows
2. Add golden tests for key UI components
3. Consider property-based testing for date/time logic

---

## Files Reviewed

### Services (23 files)
- auth_service.dart (800 lines) ✓
- schedule_api.dart (1274 lines) ✓
- reminders_api.dart (637 lines) ✓
- admin_service.dart (343 lines) ✓
- offline_queue.dart ✓
- connection_monitor.dart ✓
- data_sync.dart ✓
- sync_control.dart ✓
- notif_scheduler.dart ✓
- profile_cache.dart ✓
- *[and 13 more]*

### Models (4 files)
- schedule_class.dart ✓
- reminder_scope.dart ✓
- section.dart ✓
- schedule_filter.dart ✓

### Screens (15+ files)
- dashboard_screen.dart (1124 lines) ✓
- settings_screen.dart (1588 lines) ✓
- login_page.dart ✓
- register_page.dart ✓
- *[and more]*

### Utilities (8 files)
- app_exceptions.dart ✓
- validation_utils.dart ✓
- app_log.dart ✓
- local_notifs.dart ✓
- *[and more]*

### UI Kit (4 files)
- tokens.dart ✓
- app_theme.dart ✓
- buttons.dart ✓
- modals.dart ✓

---

## Conclusion

MySched is a well-structured Flutter application with solid architecture patterns. The codebase follows Flutter best practices with good separation of concerns. The main areas for improvement are:

1. **Test maintenance** (2 tests were out of sync with UI changes)
2. **Centralize configuration** (magic numbers scattered)
3. **Expand test coverage** for untested services

The fixes applied during this review resolve the immediate test failures. The recommendations above would further improve maintainability and robustness.
