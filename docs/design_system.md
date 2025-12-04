# MySched Design System

> Centralized design tokens and UI components for consistent styling across the app.

## Quick Reference

```dart
// Colors - ALWAYS use Theme.of(context).colorScheme
final colors = Theme.of(context).colorScheme;
colors.primary       // Primary accent
colors.surface       // Card backgrounds
colors.onSurface     // Text on surface
colors.error         // Destructive/error

// Spacing
AppTokens.spacing.lg  // 16

// Radii
AppTokens.radius.xl   // BorderRadius.circular(24)

// Typography
AppTokens.typography.title.copyWith(color: colors.onSurface)

// Motion
AppTokens.motion.medium  // 200ms
```

---

## 1. Design Tokens

**Location:** `lib/ui/theme/tokens.dart`

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| `none` | 0 | No spacing |
| `xs` | 4 | Tight gaps |
| `sm` | 8 | Small gaps |
| `md` | 12 | Medium gaps |
| `lg` | 16 | Standard gaps |
| `xl` | 20 | Large gaps |
| `xxl` | 24 | Section padding |
| `xxxl` | 32 | Major sections |
| `quad` | 40 | Hero sections |

**Helpers:**
```dart
AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.lg)
AppTokens.spacing.edgeInsetsSymmetric(horizontal: 20, vertical: 16)
AppTokens.spacing.edgeInsetsOnly(left: 16, top: 8)
```

### Border Radii

| Token | Value | Usage |
|-------|-------|-------|
| `sm` | 8 | Small elements |
| `md` | 12 | Standard cards |
| `lg` | 16 | Larger cards |
| `xl` | 24 | Hero cards, sheets |
| `xxl` | 28 | Dialogs |
| `xxxl` | 32 | Large modals |
| `pill` | 999 | Chips, badges, pills |

### Typography

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `display` | 32px | w700 | Hero numbers |
| `headline` | 26px | w600 | Page titles |
| `title` | 20px | w600 | Section headers |
| `subtitle` | 16px | w500 | Card titles |
| `body` | 16px | w400 | Body text |
| `bodySecondary` | 14px | w400 | Secondary text |
| `caption` | 12px | w500 | Labels, metadata |
| `label` | 14px | w600 | Button labels |

### Motion

**Durations:**
| Token | Value | Usage |
|-------|-------|-------|
| `instant` | 80ms | Micro interactions |
| `fast` | 120ms | Quick transitions |
| `medium` | 200ms | Standard animations |
| `slow` | 320ms | Emphasis animations |
| `slower` | 500ms | Page transitions |

**Curves:**
| Token | Curve | Usage |
|-------|-------|-------|
| `ease` | easeOutCubic | Default |
| `easeIn` | easeInCubic | Exit animations |
| `easeOut` | easeOutCubic | Enter animations |
| `spring` | easeOutBack | Bouncy elements |
| `bounce` | elasticOut | Playful feedback |

**Interaction Values:**
```dart
AppTokens.motion.pressScale        // 0.96
AppTokens.motion.pressScaleSubtle  // 0.985
AppTokens.motion.pressOpacity      // 0.85
AppTokens.motion.disabledOpacity   // 0.5
```

### Colors

**Access via:** `Theme.of(context).colorScheme`

| Semantic | Light | Dark | Usage |
|----------|-------|------|-------|
| `primary` | #0066FF | #0066FF | CTAs, links |
| `surface` | #FFFFFF | #1A1A1A | Cards |
| `surfaceContainerHigh` | #F7F7F7 | #262626 | Muted backgrounds |
| `outline` | #EBEBEB | #333333 | Borders |
| `error` | #E54B4F | #E54B4F | Destructive |
| `tertiary` | #1FB98F | #44E5BC | Success/positive |
| `secondary` | #FFAE04 | #FFAE04 | Warning |

**Extended Palette** (via `AppTokens.lightColors`/`darkColors`):
- `muted` - Secondary text color
- `mutedSecondary` - Tertiary text color
- `brand` - Splash/loading accent
- `positive`, `warning`, `danger`, `info` - Semantic colors

---

## 2. UI Kit Components

**Location:** `lib/ui/kit/`

### Containers

#### `CardX` - Primary Card Component
```dart
CardX(
  variant: CardVariant.elevated,  // elevated, outlined, filled, glass, hero
  onTap: () {},
  padding: AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.xl),
  borderRadius: AppTokens.radius.xl,
  hapticFeedback: true,
  child: ...
)
```

| Variant | Description |
|---------|-------------|
| `elevated` | Standard shadow card (default) |
| `outlined` | Border, no shadow |
| `filled` | Solid background, no border |
| `glass` | Glassmorphism with blur |
| `hero` | Gradient with accent shadow |

#### `Section` - Grouped Content
```dart
Section(
  title: 'Section Title',
  subtitle: 'Description',
  trailing: TextButton(...),
  spacing: AppTokens.spacing.md,
  children: [...],
)
```

#### `DividerX` - Themed Divider
```dart
DividerX(inset: 16)
```

### Buttons

| Component | Usage |
|-----------|-------|
| `PrimaryButton` | Main CTAs |
| `SecondaryButton` | Secondary actions (outlined) |
| `DestructiveButton` | Delete, dangerous actions |
| `IconTonalButton` | Icon + label |

```dart
PrimaryButton(
  label: 'Continue',
  onPressed: () {},
  leading: Icon(Icons.arrow_forward),
  icon: Icons.check,           // Alternative to leading
  loading: false,
  loadingLabel: 'Saving...',
  expanded: true,              // Full width
  minHeight: 52,
)

SecondaryButton(label: 'Cancel', onPressed: () {})

DestructiveButton(label: 'Delete', icon: Icons.delete, onPressed: () {})

IconTonalButton(icon: Icons.share, label: 'Share', onPressed: () {})
```

### State Displays

#### Full-Screen States
```dart
StateDisplay.empty(
  title: 'No items yet',
  message: 'Add your first item to get started',
  icon: Icons.inbox_outlined,
  actionLabel: 'Add Item',
  onAction: () {},
  compact: false,
)

StateDisplay.error(
  title: 'Something went wrong',
  message: 'Please check your connection',
  retryLabel: 'Try again',
  onRetry: () {},
)

StateDisplay.success(
  title: 'All done!',
  message: 'Your changes have been saved',
)
```

#### Inline States
```dart
MessageCard(
  icon: Icons.lightbulb_outline,
  title: 'Pro Tip',
  message: 'Swipe left to dismiss reminders',
  tintColor: colors.primary,
  primaryLabel: 'Got it',
  onPrimary: () {},
)

InfoBanner(
  message: 'New features available',
  icon: Icons.info_outline,
  variant: InfoBannerVariant.info,  // info, warning, error, success
)
```

### Skeletons (Loading States)

```dart
// Building blocks
SkeletonBlock(height: 16, width: 120)
SkeletonCircle(size: 48)

// Pre-built composites
SkeletonCard(lineCount: 3, showAvatar: true)
SkeletonListTile(showLeading: true, showTrailing: true)
SkeletonDashboardCard()
SkeletonList(itemCount: 4, showHeader: true)
```

### Interactive Animations

#### `PressableScale` - Tap Animation Wrapper
```dart
PressableScale(
  variant: PressableVariant.standard,  // standard, subtle, deep, bouncy
  onTap: () {},
  onLongPress: () {},
  hapticFeedback: true,
  child: ...
)
```

| Variant | Scale | Usage |
|---------|-------|-------|
| `standard` | 0.96 | Most buttons |
| `subtle` | 0.985 | List items, large surfaces |
| `deep` | 0.92 | FABs, primary CTAs |
| `bouncy` | 0.9 | Playful elements |

#### `AnimatedListTile` - Hover/Press Tile
```dart
AnimatedListTile(
  onTap: () {},
  borderRadius: AppTokens.radius.lg,
  hapticFeedback: true,
  child: ...
)
```

#### `AnimatedIconButton`
```dart
AnimatedIconButton(
  icon: Icons.add,
  onPressed: () {},
  size: 24,
  tooltip: 'Add item',
  rotateOnPress: true,
)
```

#### `BouncyTap` - Elastic Press Effect
```dart
BouncyTap(
  onTap: () {},
  hapticFeedback: true,
  child: ...
)
```

### Animation Utilities

#### Staggered List Animations
```dart
// Extension on List<Widget>
children.staggered()           // Standard fade+slide up
children.staggeredFast()       // Fast, for dense lists
children.staggeredDramatic()   // Slow, for hero content
children.staggeredScale()      // Scale-in for grids
```

#### `StaggeredAnimatedList` Widget
```dart
StaggeredAnimatedList(
  children: [...],
  delay: Duration.zero,
  staggerDuration: const Duration(milliseconds: 50),
  variant: StaggerVariant.slideUp,  // slideUp, slideRight, scale, fade
  spacing: 12,
)
```

#### Entrance Animations
```dart
FadeInWidget(
  child: ...,
  delay: Duration.zero,
  slideOffset: 12,    // optional
  scaleFrom: 0.9,     // optional
)

ScaleInWidget(child: ..., beginScale: 0.85)

CardEntranceAnimation(
  child: ...,
  variant: CardEntranceVariant.standard,  // standard, hero, subtle
)
```

#### Continuous Animations
```dart
PulseAnimation(child: ..., scale: 1.06)
BreathingEffect(child: ..., minScale: 0.96)
ShimmerEffect(child: ...)
AnimatedLoadingIndicator(size: 24)
```

#### Animated Counters
```dart
AnimatedCounter(value: 42, style: textStyle, prefix: '$', suffix: 'k')
AnimatedDoubleCounter(value: 3.5, decimals: 1, style: textStyle)
```

### Layout Components

#### `AppScaffold` - Analytics-Wired Scaffold
```dart
AppScaffold(
  screenName: 'dashboard',
  appBar: AppBarX(title: 'Dashboard'),
  body: ...,
  safeArea: true,
)
```

#### `PageBody` - Centered Scrollable Content
```dart
PageBody(
  maxWidth: 600,
  scrollable: true,
  centerContent: false,
  padding: AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.xxl),
  child: ...
)
```

#### `AppBackground` - Themed Background
```dart
AppBackground(child: ...)
```

---

## 3. App Durations

**Location:** `AppTokens.durations`

| Token | Value | Usage |
|-------|-------|-------|
| `networkTimeout` | 20s | API request timeout |
| `cacheTtl` | 1min | Schedule cache lifetime |
| `tickerInterval` | 1min | UI time updates |
| `headsUpLead` | 1min | Notification lead time |
| `fetchDebounce` | 3s | Min fetch interval |
| `defaultSnooze` | 1hr | Reminder snooze |
| `staggerDelay` | 220ms | Animation stagger |
| `submitDelay` | 500ms | Form submission feedback |

---

## 4. Best Practices

### ✅ Do

```dart
// Use theme colors
Theme.of(context).colorScheme.primary

// Use spacing tokens
SizedBox(height: AppTokens.spacing.lg)
Padding(padding: AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.xl))

// Use typography tokens
Text('Title', style: AppTokens.typography.title.copyWith(
  color: Theme.of(context).colorScheme.onSurface,
))

// Use radius tokens
BorderRadius: AppTokens.radius.xl

// Use kit components
CardX(variant: CardVariant.elevated, ...)
PrimaryButton(label: 'Save', ...)
StateDisplay.empty(...)
```

### ❌ Don't

```dart
// Hardcoded colors
Color(0xFF0066FF)
Colors.blue

// Hardcoded spacing
SizedBox(height: 16)
EdgeInsets.all(24)

// Hardcoded radii
BorderRadius.circular(12)

// Hardcoded text styles
TextStyle(fontSize: 16, fontWeight: FontWeight.w600)

// Custom card implementations when CardX works
Container(decoration: BoxDecoration(...))
```

---

## 5. File Structure

```
lib/ui/
├── kit/
│   ├── kit.dart              # Barrel export
│   ├── buttons.dart          # Button components
│   ├── containers.dart       # CardX, Section, DividerX
│   ├── states.dart           # StateDisplay, MessageCard, InfoBanner
│   ├── skeletons.dart        # Loading skeletons
│   ├── layout.dart           # AppScaffold, PageBody
│   ├── pressable_scale.dart  # Press animations
│   ├── animations.dart       # Animation utilities
│   ├── snack_bars.dart       # Snackbar variants
│   └── ...
└── theme/
    ├── tokens.dart           # Design tokens
    ├── app_theme.dart        # ThemeData builders
    └── motion.dart           # Motion system constants
```

---

## 6. Imports

```dart
// Design tokens
import 'package:mysched/ui/theme/tokens.dart';

// Full UI kit
import 'package:mysched/ui/kit/kit.dart';

// Individual components (if needed)
import 'package:mysched/ui/kit/buttons.dart';
import 'package:mysched/ui/kit/containers.dart';
```
