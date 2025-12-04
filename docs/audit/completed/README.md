# Widgets Directory Audit ✅ COMPLETE

> `lib/widgets/` design system compliance
> **Last Updated**: December 5, 2025

## Summary

| Category | Status |
|----------|--------|
| BorderRadius | ✅ Uses `AppTokens.radius.*` |
| Typography | ✅ Uses `textTheme.*` |
| Spacing | ✅ Uses `AppTokens.spacing.*` |
| Colors | ✅ Uses `colorScheme.*` |
| Icon Sizes | ✅ Uses `AppTokens.iconSize.*` |

---

## Files

### instructor_avatar.dart ✅ COMPLETE
Displays instructor avatars with initials fallback.

| Pattern | Implementation |
|---------|----------------|
| Colors | `colorScheme.onPrimary`, dynamic `tint` param |
| Sizing | Configurable via `size` param (default 28) |
| BorderRadius | `BorderRadius.circular(size)` - circular avatar |
| Typography | `textTheme.labelSmall` |

### schedule_list.dart ✅ COMPLETE  
Reusable schedule list grouped by day with toggle, delete, and refresh support.

| Pattern | Implementation |
|---------|----------------|
| Colors | `colorScheme.primary/error/tertiary/onSurface/onSurfaceVariant` |
| Spacing | `AppTokens.spacing.md/sm/xs` |
| BorderRadius | `AppTokens.radius.md` |
| Typography | `textTheme.headlineSmall/titleMedium/bodySmall` |
| Icon Sizes | `AppTokens.iconSize.sm` |

---

## Migrated Items

| File | Line | Before | After |
|------|------|--------|-------|
| schedule_list.dart | 238 | `Colors.white` | `colors.onError` |
| schedule_list.dart | 100 | `SizedBox(height: 12)` | `SizedBox(height: AppTokens.spacing.md)` |
| schedule_list.dart | 306 | `fontSize: 15` | `fontSize: AppTokens.typography.body.fontSize` |
| schedule_list.dart | 313 | `SizedBox(width: 8)` | `SizedBox(width: AppTokens.spacing.sm)` |
| schedule_list.dart | 333 | `SizedBox(height: 6)` | `SizedBox(height: AppTokens.spacing.xs)` |

---

## Widget API Reference

### InstructorAvatar
```dart
InstructorAvatar({
  required String name,      // Instructor name for initials
  required Color tint,       // Avatar accent color
  String? avatarUrl,         // Optional network image URL
  bool inverse = false,      // Inverted color scheme
  double size = 28,          // Avatar diameter
  double borderWidth = 1,    // Border thickness
})
```

### ScheduleList
```dart
ScheduleList({
  required List<ClassItem> items,
  required Future<void> Function(ClassItem, bool) onToggle,
  required Future<void> Function(ClassItem) onDelete,
  required Future<void> Function() onRefresh,
  Future<void> Function(ClassItem)? onEdit,  // For custom entries
  String title = 'Class Schedules',
})
```

**Features:**
- Groups classes by weekday (Monday–Sunday)
- Shows status chips: "In progress", "Next", "Done"
- Swipe-to-delete with confirmation dialog
- Pull-to-refresh support
- Toggle switches for enabling/disabling classes

