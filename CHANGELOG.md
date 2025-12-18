# Changelog

## [2.0.5] - 2024-12-17

> 📦 **Deployed to Play Store**

### ✨ Features & Improvements

- **Legal modal dialogs**: Added `AppModal.legal()` and `AppModal.legalWidget()` for beautifully formatted Terms & Conditions and Privacy Policy display
- **About & Privacy refactor**: Settings About and Privacy Policy now use legal-style modal dialogs with matching dimensions and dark barrier
- **Google Auth profile preservation**: Sign-in with Google no longer overwrites existing profile pictures
- **Version badge format**: Dashboard now shows patch number in parentheses e.g., `2.0.5+15 (1)`
- **Study Timer & Stats relocation**: Moved buttons from top of dashboard to between schedule cards and reminders section
- **Fix permissions button**: Settings shows blue "Fix permissions" button when any Android permission is missing
- **Code quality**: Replaced hardcoded dialog width with `AppLayout.dialogMaxWidth` token

### 🛠️ Bug Fixes

- **Dashboard spacing**: Fixed excessive spacing around Study Timer & Stats buttons
- **Unused imports**: Removed deprecated AboutSheet and PrivacySheet imports

---

## [2.0.4] - 2024-12-13

> 📦 **Deployed to Play Store**

### 🎨 Native Splash Screen Improvements

#### flutter_native_splash Integration
- **Added `flutter_native_splash` package** for better splash screen control
- Configured light mode (`#FCFCFC`) and dark mode (`#000000`) backgrounds
- Splash automatically follows Android system dark mode setting
- Added `FlutterNativeSplash.preserve()` and `remove()` for smooth transition control

#### Splash Assets
- New splash logo at `assets/splash/splash_logo.png` (2048x2048 recommended for sharpness)
- Blue "MySched" text on transparent background works on both light/dark modes
- Regenerated splash resources for all Android density buckets (mdpi to xxxhdpi)

#### Theme Initialization Fix
- **Fixed accent color not showing on Flutter splash**: Moved `ThemeController.init()` BEFORE `FlutterNativeSplash.remove()`
- User's saved theme/accent color now loads before Flutter splash displays
- Resolves issue where splash showed default blue instead of user's chosen accent

### 🛠️ Build Fixes

#### NDK Configuration
- **Removed hardcoded `ndkVersion`** from `build.gradle.kts` - was referencing corrupted NDK 27.0.12077973
- Gradle now auto-detects a valid NDK version

#### Asset Configuration
- Ensured `.env` file is in `pubspec.yaml` assets list (required for release builds)
- Regenerated native splash assets after corruption from previous attempts

### 📱 pubspec.yaml Updates
```yaml
dependencies:
  flutter_native_splash: ^2.4.3

flutter_native_splash:
  color: "#FCFCFC"
  color_dark: "#000000"
  image: assets/splash/splash_logo.png
  image_dark: assets/splash/splash_logo.png
  android_12:
    color: "#FCFCFC"
    color_dark: "#000000"
    image: assets/splash/splash_logo.png
    image_dark: assets/splash/splash_logo.png
```

### 🔧 Patches (OTA via Shorebird)

#### Patch 14: Legal Modals & Dashboard Improvements
- **Legal modal dialogs**: Added `AppModal.legal()` and `AppModal.legalWidget()` for Terms & Conditions and Privacy Policy with formatted sections, styled headers, bullet points, and scrollable content
- **About & Privacy refactor**: Settings About and Privacy Policy now use legal-style modal dialogs with matching dimensions and dark barrier
- **Professional legal content**: Comprehensive Terms & Conditions and Privacy Policy text with thesis project details, RA 10173 compliance, and section formatting
- **Google Auth profile preservation**: Sign-in with Google no longer overwrites existing profile pictures - only sets avatar if user doesn't have one
- **Version badge format**: Dashboard now shows patch number in parentheses e.g., `2.0.4+14 (11)` instead of `P11`
- **Auto-resync alarms**: Dashboard resyncs notification schedules once per app session (using static flag to avoid repeated syncs)
- **Study Timer & Stats relocation**: Moved buttons from top of dashboard to between schedule cards and reminders section with proper spacing
- **Fix permissions button**: Settings now shows blue "Fix permissions" button when any Android permission (exact alarms, notifications, battery) is missing
- **Code quality**: Replaced hardcoded `maxWidth: 400` with `AppLayout.dialogMaxWidth` token in modals
- **Dark mode avatar support**: Added constant for dark mode avatar asset path
- **Effective date update**: Legal documents now show "December 01, 2025" effective date

> ⏳ Pending deployment

#### Patch 15: App Branding & Quick Actions Overhaul
- **New app icon & splash screen**: Updated `flutter_launcher_icons` and `flutter_native_splash` config with new logo assets
  - Uses `logo.png` for icons, `splash_light.png` and `splash_dark.png` for splash screens
  - Light splash: `#FCFCFC` background with blue "Ms" logo
  - Dark splash: `#000000` background with white "Ms" logo
- **Quick Actions improvements**:
  - Removed "Start study timer" option from modal
  - Auto-closes modal when switching tabs
  - Added swipe-down-to-close gesture
- **Instructor Finder schedule view**:
  - Time now shows start AND end time (e.g., "2:00 PM" on first line, "3:30 PM" below)
  - Past classes now more readable (increased opacity from `dim` to `medium`)
- **Crop profile photo dialog**: Fixed button layout (Primary + Cancel side-by-side in a Row)
- **Auth screen copy refresh**:
  - Login: Dynamic "Welcome!" (new users) vs "Welcome back!" (returning users)
  - Sign Up: "You vs. time — round two."
- **Legal links touch targets**: Increased tap area for Terms & Conditions / Privacy Policy links
- **Complete profile flow**: Now shows as modal dialog over dashboard instead of separate screen

> ✅ Deployed December 17, 2025 (Shorebird Patch 1 for 2.0.5+17)

#### Patch 13: Google Sign-In Profile Completion
- **Profile auto-creation for Google users**: Google sign-in now creates profile row with name, email, and avatar from Google account
- **Student ID requirement**: Google users must complete their profile by entering student ID before using the app
- **In-app prompt modal**: Existing users without student ID see a non-dismissible sheet (same style as change email modal)
- **Two-button layout**: "Save changes" and "Sign out" buttons for clear user choice
- **Bootstrap redirect**: New users without student ID redirected to complete-profile screen on app launch
- **`isProfileComplete()` method**: New AuthService method to check if user has student_id set
- **`_ensureProfileExists()` helper**: Creates/updates profile for OAuth users with error handling
- **SQL migration**: Database trigger to auto-create profiles on user signup + backfill existing users

> ⏳ Pending deployment

#### Patch 12: Auth Screen Complete Redesign
- **Unified AuthScreen**: Merged Login and Register into single screen with toggle switch
- **New "Blue Header + White Sheet" design**: Matches new design reference exactly
- **Toggle functionality**: Instant switch between Log In / Sign Up modes without page navigation
- **Deleted `register_screen.dart`**: Redundant file removed, all logic consolidated in `login_screen.dart`
- **Router updates**: Both `/login` and `/register` routes now use `AuthScreen` with `initialMode` parameter
- **Pixel-perfect styling**: Exact hex colors (`#3B7DFF` blue, `#F2F2F7` toggle bg, `#E5E5EA` borders)
- **Form field improvements**: Taller fields (56px), larger border radius (14px), proper hint colors
- **Standardized transitions**: All auth screens use consistent 300ms FadeTransition

> ⏳ Pending deployment

#### Patch 1-3: Fullscreen Alarm Permission Fix (Android 14+)
- **openFullScreenIntentSettings**: Added method to open Android 14+ fullscreen intent permission settings
- **AlarmReadiness check**: Now includes `fullScreenIntentAllowed` in the permission readiness check
- **Bootstrap prompt**: Shows fullscreen intent permission status for Android 14+ devices

#### Patch 4-5: Date/Time Display Fix
- **Fixed class "Added on" date showing wrong time**: Timestamps from database now correctly interpreted as UTC and converted to local device time
- **Patch version display**: Added "current ver 2.0.4+14 Patch (X)" in Admin tools for debugging

#### Patch 6: Instructor Finder Time Format Fix
- **Fixed reversed time order**: Schedule times in instructor finder now show start time first, then end time (was incorrectly showing end-start)

#### Patch 7: Version Badge on Dashboard
- **Moved version display**: Version text relocated from Settings admin card to Dashboard header
- **Admin-only visibility**: Version badge only visible to users with admin role
- **Dynamic versioning**: Now reads version from `package_info_plus` instead of hardcoded values
- **Format**: Shows "X.Y.Z+BUILD P[patch]" (e.g., "2.0.2+11 P7")

#### Patch 8: Auth Screen Keyboard Fix
- **Fixed keyboard cropping**: Login/register screens no longer clip content at top when keyboard appears
- **Adaptive layout**: Uses `MainAxisAlignment.start` when keyboard visible, `center` when hidden
- **Keyboard detection**: Via `MediaQuery.viewInsets.bottom > 0`

#### Patch 9: Remember Me on Login
- **Remember Me checkbox**: Added below password field on login screen
- **Email persistence**: Saves email to SharedPreferences when checked
- **Auto-fill**: Pre-fills email on next login if previously saved
- **Storage keys**: `auth.remember_email`, `auth.remember_me`

#### Patch 10: Instructor Search UI Overhaul
- **Alphabetical sorting**: Instructors sorted A-Z by last name (handles "Last, First" and "First Last" formats)
- **A-Z section headers**: Letter headers group instructors for easy scanning
- **Search highlighting**: Matching text highlighted in primary color with subtle background
- **Quick scroll sidebar**: Alphabet strip on right side for fast navigation (appears when 4+ letters)
- **Department colors**: Color-coded badges for visual distinction:
  - CSIT → Blue (#2196F3)
  - Accountancy → Green (#4CAF50)
  - Criminology → Deep Orange (#FF5722)
  - Education → Purple (#9C27B0)
  - Engineering → Orange (#FF9800)
  - Nursing → Pink (#E91E63)
  - Business → Cyan (#00BCD4)

#### Patch 11: Study Session Persistence & Cleanup ✅ Deployed 2024-12-16
- **Fixed Quick Action icons**: Android App Shortcuts now display blue icons (was white due to theme tinting)
- **Added Start Study Timer shortcut**: New quick action in launcher long-press menu
- **Added deep link handler**: `mysched://` scheme now registered in AndroidManifest for shortcuts
- **Removed Schedule Sharing**: Feature completely removed per user request
- **Removed Instructor Notes**: Feature completely removed per user request
- **Fixed Schedule Reset**: Now clears offline cache when resetting schedules
- **Study sessions now persist to Supabase**: Timer sessions saved to cloud database
- **Cross-device sync**: Stats visible on any device with same account
- **New `study_sessions` table**: Stores session type, duration, timestamps, linked class
- **StatsService refresh**: Stats now fetch from Supabase + in-memory data
- **Model improvements**: Added `copyWith`/`==`/`hashCode` to `Semester` model

> ✅ Patches 7-11 deployed 2024-12-16

---


## [2.0.3] - 2024-12-12

> 📦 **Deployed to Play Store** | Shorebird Patch 1 applied

### 🎨 Branding
- **New App Logo**: Updated launcher icons with new MySched branding
  - Replaced `ic_launcher_foreground.png` and `ic_launcher_background.png`
  - Regenerated adaptive icons for Android and iOS

### 🛠️ Patch 1
- **Battery Optimization Prompt**: Now shows on app start if not set to "Unrestricted"
  - Previously skipped if only exact alarms + notifications were granted

### 🔔 Alarm Reliability Improvements (Android 11-15)

#### New Native Components
- **AlarmForegroundService.java**: Foreground service for reliable alarm delivery on Android 11+
  - Prevents system from killing app during alarm
  - Uses wake locks for guaranteed execution
  - Auto-stops after alarm delivery (10 seconds)
- **BootReceiver.java**: Reschedules alarms after device reboot
  - Supports standard boot, quick boot, locked boot (direct boot)
  - Manufacturer-specific boot intents (HTC, QUICKBOOT)
  - Handles app updates (`MY_PACKAGE_REPLACED`)

#### Android Manifest Updates
- Added `USE_EXACT_ALARM` permission (auto-granted for alarm apps on Android 14+)
- Added `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_SPECIAL_USE` permissions
- Added `RECEIVE_BOOT_COMPLETED` + `LOCKED_BOOT_COMPLETED` permissions
- Added `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission
- Registered `AlarmForegroundService` with `foregroundServiceType="specialUse"`
- Registered `BootReceiver` with `directBootAware="true"`

#### AlarmReceiver.java Refactored
- Android 11+: Uses foreground service for reliable delivery
- Android 10 and below: Direct activity launch
- Always posts backup notification on Android 10+ (fallback if fullscreen blocked)
- Notification channel with `setBypassDnd(true)` for alarm priority

#### MainActivity.kt Enhancements
- Added `canUseFullScreenIntent()` check for Android 14+ (API 34)
- Added `fullScreenIntentAllowed` to `alarmReadiness()` response
- Added `openAutoStartSettings()` for Chinese OEMs (Xiaomi, OPPO, Vivo, Huawei, Samsung, OnePlus, ASUS, Lenovo)
- Added `getDeviceManufacturer()` method

#### Dart-Side Updates (local_notifs.dart)
- Added `fullScreenIntentAllowed` field to `AlarmReadiness` class
- Added `isFullyReady` getter for checking all Android 14+ requirements
- Added `openAutoStartSettings()` method
- Added `getDeviceManufacturer()` method
- Added `needsAutoStartPermission()` check for Chinese OEM devices
- Added `autoStartManufacturers` constant set

#### Onboarding (bootstrap_gate.dart)
- Added conditional auto-start permission row in `_AlarmPromptDialog`
- Shows manufacturer-specific instructions (e.g., "Required for Xiaomi")
- Only displays on devices that need auto-start permission

### 🛠️ Technical Details
| Android Version | Delivery Method |
|-----------------|-----------------|
| Android 15 (API 35) | Foreground service + Fullscreen intent |
| Android 14 (API 34) | Foreground service + USE_EXACT_ALARM |
| Android 13 (API 33) | Foreground service + backup notification |
| Android 12 (API 31-32) | Foreground service + setAlarmClock |
| Android 11 (API 30) | Foreground service |
| Android 10 and below | Direct activity launch |

---

## [2.0.2] - 2024-12-10

### 🎨 Responsive Scaling Refinements
- **Max Scale Capped**: Set `maxScale`, `maxTextScale`, `maxSpacingScale` to 1.0 in `responsive.dart`
  - Pixel 8 (~392dp) and larger screens: exactly 1.0 scale (no upscaling)
  - Infinix Hot 30i (~360dp): scales down 0.92-0.96 as intended
- **Dashboard Alignment**: Completed `instructor_finder_sheet.dart` responsive integration

### 🎨 Responsive Screen Compatibility
- **Global Responsive Scaling System**: Added `AppResponsive` utility and `ResponsiveProvider` for screen-aware scaling
- **Reference Width**: 390dp baseline - standard devices unchanged, compact screens (~360dp) scale down ~8%

### 📱 Updated Components (57+ total)
- **Core**: `entity_tile`, `buttons`, `MetricChip`, `states.dart`
- **Tiles**: `info_tile`, `detail_row`, `quick_action_tile`, `form_field_tile`, `time_field_tile`
- **Chips/Badges**: `status_badge`, `status_chip`, `info_chip`, `StatusInfoChip`, `queued_badge`
- **Rows**: `instructor_row`, `section_header`, `sheet_header_row`, `status_row`, `rows.dart`
- **Dialogs/Forms**: `option_picker`, `hint_bubble`, `error_banner`, `date_picker`, `time_picker`, `consent_dialog`
- **Navigation**: `back_button`, `segmented_pills`, `glass_navigation_bar`
- **Dashboard**: `dashboard_cards`, `hero_avatar`, `empty_hero_placeholder`, `brand_header`
- **Layout**: `containers.dart`, `snack_bars`, `simple_bullet`, `layout.dart`
- **Shells**: `screen_shell.dart`, `auth_shell`, `brand_scaffold`

### ✨ New Features
- **Instructor Mode**: Instructors now see their assigned classes instead of student schedules
- **Find Instructor**: Students can find professors and see their current class/room

### 🐛 Bug Fixes
- **Segmented Pills**: Fixed vertical text centering
- **Class Details**: Removed instructor email display for privacy
- **Instructor Mode**: Fixed mode reset on app restart
- **Stale Session Detection**: Fixed infinite "Refresh session" loop

### ⚡ Performance
- **Section ID Caching**: Reduced dashboard refresh queries from 5 to 3 (first call) or 1 (subsequent)

---

## [2.0.1] - 2024-12-09

### ✨ New Features
- **Custom Accent Color**: Pick from 7 preset colors in Settings → Appearance
- **Smooth Theme Transitions**: Screenshot-based crossfade animation when changing themes or accent colors

### 🎨 UI Consistency Fixes
- **Verify Email Screen**: Changed from route navigation to overlay approach
- **Report Issue Dialog**: Buttons now in 1 row (Primary + Cancel)
- **Settings Card Shadow**: Changed from modal shadow to lighter card shadow
- **Navbar Refinements**: Typography and indicator shadow now use global `AppTokens` factories

### 🐛 Bug Fixes
- **Verify Email Barrier**: Fixed black background on register verify email

---

## [2.0.0] - 2024-12-09

### ✨ Major Features
- **Semester System**: Schedule auto-switches when admin changes active semester
- **Semester Badge**: Shows section code (e.g., "BSCS 4-1") + semester on schedules screen
- **Shorebird OTA Updates**: Push app updates instantly without Play Store review
- **Onboarding Flow**: New onboarding screen for first-time users

### 🎨 Design System Overhaul
- **Global Design Tokens**: Replaced ~50% hardcoded values with `AppTokens` system
- **Full UI Redesign**: All screens, modals, dialogs redesigned with consistent styling

### 🆕 New UI Components
- `segmented_pills.dart`, `date_picker.dart`, `time_picker.dart`, `option_picker.dart`
- `empty_hero_placeholder.dart`, `error_banner.dart`, `back_button.dart`, `switch.dart`
- `rows.dart`, `time_field_tile.dart`

### 📁 Project Reorganization
- **Screens folder restructured**: `auth/`, `account/`, `admin/`, `scan/`, `onboarding/`
- **File renames**: `schedule_api.dart` → `schedule_repository.dart`, etc.

### 🆕 New Services & Models
- `semester_service.dart`, `user_settings_service.dart`, `semester.dart`, `schedule_filter.dart`

### 🐛 Bug Fixes
- Register screen: "Email already used" error now displays properly
- Error messages now display correctly in modals

---

## [1.6.0]

- Added: offline schedule cache w/ banner fallback; CSV export alongside PDF
- Changed: unified share guard; deps bumped
- Fixed: schedule screen surfaces saved data when offline
