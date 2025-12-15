import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';
import 'schedule_overlap.dart';

/// Shows a warning dialog when schedule conflicts are detected.
///
/// Returns `true` if the user chooses to proceed anyway, `false` if they cancel.
Future<bool> showConflictWarningDialog({
  required BuildContext context,
  required List<ClassConflict> conflicts,
}) async {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;
  final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
  final spacing = AppTokens.spacing;
  final scale = ResponsiveProvider.scale(context);
  final spacingScale = ResponsiveProvider.spacing(context);

  final result = await AppModal.alert<bool>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: spacing.edgeInsetsAll(spacing.xl * spacingScale),
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppLayout.dialogWidthSmall),
        decoration: BoxDecoration(
          color: isDark ? colors.surfaceContainerHigh : colors.surface,
          borderRadius: AppTokens.radius.xl,
          border: Border.all(
            color: isDark
                ? colors.outline.withValues(alpha: AppOpacity.overlay)
                : colors.outline.withValues(alpha: AppOpacity.faint),
            width: AppTokens.componentSize.dividerThin,
          ),
          boxShadow: isDark
              ? null
              : [
                  AppTokens.shadow.modal(
                    colors.shadow.withValues(alpha: AppOpacity.border),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: AppTokens.radius.xl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: spacing.edgeInsetsAll(spacing.xl * spacingScale),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colors.outline.withValues(alpha: AppOpacity.faint),
                      width: AppTokens.componentSize.dividerThin,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: spacing.edgeInsetsAll(spacing.sm * spacingScale),
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: AppOpacity.overlay),
                        borderRadius: AppTokens.radius.sm,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: colors.error,
                        size: AppTokens.iconSize.md * scale,
                      ),
                    ),
                    SizedBox(width: spacing.md * spacingScale),
                    Expanded(
                      child: Text(
                        'Schedule Conflict',
                        style: AppTokens.typography.subtitleScaled(scale).copyWith(
                          fontWeight: AppTokens.fontWeight.semiBold,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: spacing.edgeInsetsAll(spacing.xl * spacingScale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conflicts.length == 1
                          ? 'This class overlaps with an existing class:'
                          : 'This class overlaps with ${conflicts.length} existing classes:',
                      style: AppTokens.typography.bodyScaled(scale).copyWith(
                        color: palette.muted,
                      ),
                    ),
                    SizedBox(height: spacing.md * spacingScale),
                    // Conflict list
                    ...conflicts.map((conflict) => _ConflictTile(
                          conflict: conflict,
                          scale: scale,
                          spacingScale: spacingScale,
                        )),
                    SizedBox(height: spacing.md * spacingScale),
                    // Warning info
                    Container(
                      padding: spacing.edgeInsetsAll(spacing.md * spacingScale),
                      decoration: BoxDecoration(
                        color: colors.errorContainer.withValues(alpha: AppOpacity.overlay),
                        borderRadius: AppTokens.radius.md,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: AppTokens.iconSize.sm * scale,
                            color: colors.error,
                          ),
                          SizedBox(width: spacing.sm * spacingScale),
                          Expanded(
                            child: Text(
                              'Adding this class may cause scheduling issues.',
                              style: AppTokens.typography.captionScaled(scale).copyWith(
                                color: colors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Footer with buttons
              Container(
                padding: spacing.edgeInsetsAll(spacing.lg * spacingScale),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colors.outline.withValues(alpha: AppOpacity.faint),
                      width: AppTokens.componentSize.dividerThin,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(false),
                        minHeight: AppTokens.componentSize.buttonSm,
                      ),
                    ),
                    SizedBox(width: spacing.md * spacingScale),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Add Anyway',
                        onPressed: () => Navigator.of(context).pop(true),
                        minHeight: AppTokens.componentSize.buttonSm,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return result ?? false;
}

class _ConflictTile extends StatelessWidget {
  const _ConflictTile({
    required this.conflict,
    required this.scale,
    required this.spacingScale,
  });

  final ClassConflict conflict;
  final double scale;
  final double spacingScale;

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2024, 1, 1, hour, minute);
      return DateFormat.jm().format(dt);
    } catch (_) {
      return time;
    }
  }

  String _dayName(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (day >= 1 && day <= 7) return days[day - 1];
    return 'Day $day';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final existing = conflict.existingClass;

    return Container(
      margin: spacing.edgeInsetsOnly(bottom: spacing.sm * spacingScale),
      padding: spacing.edgeInsetsAll(spacing.md * spacingScale),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: AppTokens.radius.md,
        border: Border.all(
          color: colors.error.withValues(alpha: AppOpacity.accent),
          width: AppTokens.componentSize.divider,
        ),
      ),
      child: Row(
        children: [
          // Warning icon
          Container(
            padding: spacing.edgeInsetsAll(spacing.xs * spacingScale),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: AppOpacity.overlay),
              borderRadius: AppTokens.radius.sm,
            ),
            child: Icon(
              Icons.schedule_rounded,
              size: AppTokens.iconSize.sm * scale,
              color: colors.error,
            ),
          ),
          SizedBox(width: spacing.md * spacingScale),

          // Class details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existing.title ?? existing.code ?? 'Class',
                  style: AppTokens.typography.label.copyWith(
                    fontSize: (AppTokens.typography.label.fontSize ?? 14) * scale,
                    color: colors.onSurface,
                    fontWeight: AppTokens.fontWeight.semiBold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.micro * spacingScale),
                Text(
                  '${_dayName(existing.day)} • ${_formatTime(existing.start)} - ${_formatTime(existing.end)}',
                  style: AppTokens.typography.captionScaled(scale).copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Overlap badge
          Container(
            padding: spacing.edgeInsetsSymmetric(
              horizontal: spacing.sm * spacingScale,
              vertical: spacing.micro * spacingScale,
            ),
            decoration: BoxDecoration(
              color: colors.error,
              borderRadius: AppTokens.radius.pill,
            ),
            child: Text(
              '${conflict.overlapMinutes}min',
              style: AppTokens.typography.microScaled(scale).copyWith(
                color: colors.onError,
                fontWeight: AppTokens.fontWeight.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
