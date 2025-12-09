# Changelog

## 2.0.1 - 2024-12-09

### ✨ New Features
- **Custom Accent Color**: Pick from 7 preset colors in Settings → Appearance
- **Smooth Theme Transitions**: Screenshot-based crossfade animation when changing themes or accent colors

### 🎨 UI Consistency Fixes
- **Verify Email Screen**: Changed from route navigation to overlay approach (matches change email flow)
- **Report Issue Dialog**: Buttons now in 1 row (Primary + Cancel) instead of stacked
- **Settings Card Shadow**: Changed from modal shadow to lighter card shadow (matches other screens)
- **Navbar Refinements**: Typography and indicator shadow now use global `AppTokens` factories

### 🛠️ Token Compliance
- `glass_navigation_bar.dart`: "Quick actions" label uses `AppTokens.typography.caption`
- `glass_navigation_bar.dart`: Indicator shadow uses `AppTokens.shadow.elevation1()`
- `class_details_sheet.dart`: Report dialog helper text uses `AppTokens.typography.caption`
- Removed hardcoded `theme.textTheme` references in report dialog

### 🐛 Bug Fixes
- **Verify Email Barrier**: Fixed black background on register verify email (now shows translucent barrier over registration form)
- **Supabase Email Template**: Documented fix for magic link vs 6-digit code issue (dashboard config)

---

## 2.0.0 - 2024-12-09

### ✨ Major Features
- **Semester System**: Schedule auto-switches when admin changes active semester
- **Semester Badge**: Shows section code (e.g., "BSCS 4-1") + semester on schedules screen
- **Shorebird OTA Updates**: Push app updates instantly without Play Store review
- **Onboarding Flow**: New onboarding screen for first-time users

### 🎨 Design System Overhaul
- **Global Design Tokens**: Replaced ~50% hardcoded values with `AppTokens` system
- **Full UI Redesign**: All screens, modals, dialogs redesigned with consistent styling
- Organized tokens into `lib/ui/theme/tokens/` folder structure

### 🆕 New UI Components (8 new files in kit/)
- `segmented_pills.dart` - Pill-style filter buttons
- `date_picker.dart` - Custom date picker
- `time_picker.dart` - Custom time picker
- `option_picker.dart` - Generic option selector
- `empty_hero_placeholder.dart` - Empty state illustrations
- `error_banner.dart` - Error display banner
- `back_button.dart` - Consistent back navigation
- `switch.dart` - Custom toggle switch
- `rows.dart` - Common row layouts
- `time_field_tile.dart` - Time input tile

### 📁 Project Reorganization
- **Screens folder restructured**: Split into subfolders
  - `auth/` - Login, Register, Verify Email screens
  - `account/` - Account overview, Change email/password, Delete account
  - `admin/` - Issue reports screen
  - `scan/` - Scan options and preview
  - `onboarding/` - New onboarding flow
- **File renames for clarity**:
  - `schedule_api.dart` → `schedule_repository.dart`
  - `reminders_api.dart` → `reminders_repository.dart`
  - `notif_scheduler.dart` → `notification_scheduler.dart`

### 🆕 New Services & Models
- `lib/services/semester_service.dart` - Semester caching (5-min cache)
- `lib/services/user_settings_service.dart` - User preferences service
- `lib/models/semester.dart` - Semester model
- `lib/models/schedule_filter.dart` - Schedule filter enum
- `lib/ui/semester_badge.dart` - Semester display widget
- `lib/ui/tokens.dart` - Consolidated token exports

### 🛠️ Changed
- `getCurrentSectionId()` filters by active semester and matches section code
- `modals.dart` expanded from 11KB to 23KB (more modal types)
- `skeletons.dart` expanded from 13KB to 75KB (more loading states)
- `buttons.dart` expanded from 12KB to 18KB (more button variants)
- Database schema: `sections.code` now unique per semester (not globally)

### 🐛 Bug Fixes
- Register screen: "Email already used" error now displays properly
- Error messages now display correctly in modals
- Various backend error handling improvements

### 📦 Configuration
- `shorebird.yaml` - OTA update configuration added

---

## 1.6.0

- Added: offline schedule cache w/ banner fallback; CSV export alongside PDF.
- Changed: unified share guard; deps bumped (shared_preferences ^2.5.3, image_picker ^1.2.0, supabase_flutter ^2.10.3).
- Fixed: schedule screen surfaces saved data when offline.
