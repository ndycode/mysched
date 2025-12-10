# Changelog

## [Patch 13] - 2024-12-10

### 🎨 Responsive Screen Compatibility
- **Global Responsive Scaling System**: Added `AppResponsive` utility and `ResponsiveProvider` for screen-aware scaling
- **Reference Width**: 390dp baseline - standard devices unchanged, compact screens (~360dp) scale down ~8%
- Uses global `AppLayout` tokens (`referenceWidth`, `compactThreshold`, `wideThreshold`)

### 📱 Updated Components (57+ total)
- **Core**: `entity_tile`, `buttons`, `MetricChip`, `states.dart` (StateDisplay, MessageCard, InfoBanner)
- **Tiles**: `info_tile`, `detail_row`, `quick_action_tile`, `form_field_tile`, `time_field_tile`
- **Chips/Badges**: `status_badge`, `status_chip`, `info_chip`, `StatusInfoChip`, `queued_badge`
- **Rows**: `instructor_row`, `section_header`, `sheet_header_row`, `status_row`, `rows.dart` (SettingsRow)
- **Dialogs/Forms**: `option_picker`, `hint_bubble`, `error_banner`, `date_picker`, `time_picker`, `consent_dialog`
- **Navigation**: `back_button`, `segmented_pills`, `glass_navigation_bar`
- **Dashboard**: `dashboard_cards`, `hero_avatar`, `empty_hero_placeholder`, `brand_header`
- **Layout**: `containers.dart`, `snack_bars`, `simple_bullet`, `layout.dart` (PageBody)
- **Shells**: `screen_shell.dart` (ScreenHeroCard, ScreenSection), `auth_shell`, `brand_scaffold`
- **Utilities**: `modals.dart`, `skeletons.dart` (responsive-ready)

### 🛠️ New Extensions
- `ResponsiveSpacing`: Scaled spacing helpers for EdgeInsets
- `ResponsiveTypography`: Scaled font size methods for all text styles

---

## 2.0.2 - 2024-12-10

### ✨ New Features
- **Instructor Mode**: Instructors now see their assigned classes instead of student schedules
  - Auto-detects instructor role on login via `public.instructors` table
  - Fetches classes from `instructor_schedule` view filtered by active semester
  - Section names (e.g., "BSCS 4-1") displayed instead of instructor names
- **Find Instructor**: Students can find professors and see their current class/room
  - Modal accessible via 3-dot menu → "Find instructor"
  - Displays instructor list filtered by user's academic department
  - Shows "TEACHING NOW" status with countdown (e.g., "ends in 30m")
  - Today's full schedule shown with current class highlighted
  - Skeleton loading matching actual content structure

### 🎨 Instructor UI Customizations
- **Class Details Modal**: Hidden student-specific elements (Synced badge, Disable/Report buttons)
- **Section Icon**: Replaced circular avatars with `Icons.class_outlined` in rounded container
- **Centered Message**: "Linked classes can only be edited by an administrator" now centered
- **Empty States**: Custom messaging for instructors ("No classes assigned")

### 🐛 Bug Fixes
- **Stale Session Detection**: Fixed infinite "Refresh session" loop when auth token expires
  - Added `AuthService.isStaleSessionError()` to detect non-recoverable auth errors
  - Shows "Your session has expired. Please sign out and sign in again." instead of generic error
  - Prevents Supabase SDK from spamming refresh attempts

### ⚡ Performance
- **Section ID Caching**: Reduced dashboard refresh queries from 5 to 3 (first call) or 1 (subsequent)
  - `getCurrentSectionId()` now caches result with 5-minute TTL
  - Cache auto-invalidates on user change

### 🛠️ Code Changes
- Added `InstructorService` for role detection and class fetching
- Added `isInstructor` parameter to dashboard and schedule widgets
- Added `showSectionIcon` parameter to `InstructorRow` widget
- Updated `SchedulesController` to conditionally fetch instructor classes
- Added `InstructorFinderSheet` modal with department-based filtering
- Added `findInstructor` action to `ScheduleAction` enum

---

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
