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
| Image Caching | ✅ Uses `cacheWidth`/`cacheHeight` |

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
| Image Caching | `cacheWidth`/`cacheHeight` based on device pixel ratio |

### schedule_list.dart ✅ COMPLETE  
Reusable schedule list grouped by day with toggle, delete, and refresh support.

| Pattern | Implementation |
|---------|----------------|
| Colors | `colorScheme.primary/error/tertiary/onSurface/onSurfaceVariant` |
| Spacing | `spacing.edgeInsetsOnly(...)`, `spacing.edgeInsetsSymmetric(...)` |
| BorderRadius | `AppTokens.radius.md` |
| Typography | `textTheme.headlineSmall/titleMedium/bodySmall` |
| Icon Sizes | `AppTokens.iconSize.sm` |

---

## Migrated Items (December 5, 2025)

| File | Before | After |
|------|--------|-------|
| schedule_list.dart | `EdgeInsets.fromLTRB(16, 16, 16, 24)` | `spacing.edgeInsetsOnly(...)` |
| schedule_list.dart | `EdgeInsets.only(top: 16, bottom: 8)` | `spacing.edgeInsetsOnly(top: spacing.lg, bottom: spacing.sm)` |
| schedule_list.dart | `EdgeInsets.only(right: 16)` | `spacing.edgeInsetsOnly(right: spacing.lg)` |
| schedule_list.dart | `EdgeInsets.symmetric(vertical: 4, horizontal: 8)` | `spacing.edgeInsetsSymmetric(...)` |
| schedule_list.dart | `EdgeInsets.symmetric(horizontal: 16, vertical: 14)` | `spacing.edgeInsetsSymmetric(...)` |
| schedule_list.dart | `EdgeInsets.only(right: 12)` | `spacing.edgeInsetsOnly(right: spacing.md)` |
| schedule_list.dart | `EdgeInsets.symmetric(vertical: 12)` | `spacing.edgeInsetsSymmetric(vertical: spacing.md)` |
| instructor_avatar.dart | `Image.network(...)` | Added `cacheWidth`/`cacheHeight` |

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

