// ignore_for_file: unused_element, unused_element_parameter, unused_local_variable
part of 'dashboard_screen.dart';

class _DashboardSummaryCard extends StatelessWidget {
  const _DashboardSummaryCard({
    required this.greeting,
    required this.dateLabel,
    required this.summary,
    required this.upcoming,
    this.reminderAlert,
    required this.scopeMessage,
    this.refreshLabel,
    this.onReviewReminders,
    required this.onViewDetails,
    required this.onToggleEnabled,
    this.onViewSchedule,
  });

  final String greeting;
  final String dateLabel;
  final _DashboardSummaryData summary;
  final _DashboardUpcoming upcoming;
  final _ReminderAlert? reminderAlert;
  final String scopeMessage;
  final String? refreshLabel;
  final VoidCallback? onReviewReminders;
  final ValueChanged<ClassItem> onViewDetails;
  final void Function(int id, bool enabled) onToggleEnabled;
  final VoidCallback? onViewSchedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hero = upcoming.primary;
    final spacing = AppTokens.spacing;

    final card = CardX(
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  greeting,
                  style: AppTokens.typography.title.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: colors.onSurface,
                  ),
                ),
              ),
              if (refreshLabel != null) _RefreshChip(label: refreshLabel!),
            ],
          ),
          SizedBox(height: spacing.lg),
          if (hero != null) ...[
            _UpcomingHeroTile(
              occurrence: hero,
              isLive: upcoming.isActive,
              onViewDetails: onViewDetails,
            ),
            SizedBox(height: spacing.lg),
          ],
          Row(
            children: [
              Expanded(
                child: _CompactMetricChip(
                  icon: Icons.hourglass_bottom_rounded,
                  value: summary.hoursDoneLabel,
                  label: 'Hours done',
                  tint: colors.primary,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: _CompactMetricChip(
                  icon: Icons.class_rounded,
                  value: summary.classesRemainingLabel,
                  label: 'Classes left',
                  tint: colors.secondary,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: _CompactMetricChip(
                  icon: Icons.task_alt_rounded,
                  value: summary.tasksLabel,
                  label: 'Open tasks',
                  tint: colors.tertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'View schedule',
                  onPressed: onViewSchedule,
                  minHeight: 48,
                  expanded: true,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: SecondaryButton(
                  label: 'Reminders',
                  onPressed: onReviewReminders,
                  minHeight: 48,
                  expanded: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return RepaintBoundary(child: card);
  }

}

class _RefreshChip extends StatelessWidget {
  const _RefreshChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.sm + 2,
        vertical: spacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: isDark ? 0.28 : 0.12),
        borderRadius: AppTokens.radius.pill,
        border: Border.all(
          color: colors.primary.withValues(alpha: isDark ? 0.4 : 0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.refresh_rounded, size: AppTokens.iconSize.xs, color: colors.primary),
          SizedBox(width: spacing.xs + 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: AppTokens.typography.caption.fontSize,
              fontWeight: FontWeight.w600,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactMetricChip extends StatelessWidget {
  const _CompactMetricChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.tint,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.lg),
      decoration: BoxDecoration(
        color: isDark ? tint.withValues(alpha: 0.12) : tint.withValues(alpha: 0.08),
        borderRadius: AppTokens.radius.md,
        border: Border.all(
          color: tint.withValues(alpha: 0.20),
          width: AppTokens.componentSize.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: spacing.edgeInsetsAll(spacing.sm),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.15),
              borderRadius: AppTokens.radius.sm,
            ),
            child: Icon(
              icon,
              size: AppTokens.iconSize.lg,
              color: tint,
            ),
          ),
          SizedBox(height: spacing.md),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: AppTokens.typography.headline.fontSize,
              height: 1.0,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: AppTokens.typography.caption.fontSize,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ReminderAlertBanner extends StatelessWidget {
  const _ReminderAlertBanner({
    required this.alert,
    required this.onReview,
  });

  final _ReminderAlert alert;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = AppTokens.spacing;
    final background = alert.tint.withValues(alpha: 0.14);
    final border = alert.tint.withValues(alpha: 0.22);
    final iconBackground = alert.tint.withValues(alpha: 0.18);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onReview,
        borderRadius: AppTokens.radius.lg,
        child: Container(
          padding: spacing.edgeInsetsAll(spacing.md + 2),
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppTokens.radius.lg,
            border: Border.all(color: border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: spacing.edgeInsetsAll(spacing.sm + 2),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: AppTokens.radius.md,
                ),
                child: Icon(alert.icon, color: alert.tint, size: AppTokens.iconSize.md),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: AppTokens.typography.title.fontSize,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      alert.message,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: AppTokens.typography.body.fontSize,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.md),
              TextButton(
                onPressed: onReview,
                style: TextButton.styleFrom(
                  foregroundColor: alert.tint,
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: AppTokens.typography.body.fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(alert.actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingHeroTile extends StatelessWidget {
  const _UpcomingHeroTile({
    super.key,
    required this.occurrence,
    required this.isLive,
    required this.onViewDetails,
  });

  final ClassOccurrence occurrence;
  final bool isLive;
  final ValueChanged<ClassItem> onViewDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;
    final subject = occurrence.item.subject;
    final timeLabel =
        '${DateFormat('h:mm a').format(occurrence.start).toUpperCase()} - ${DateFormat('h:mm a').format(occurrence.end).toUpperCase()}';
    final dateLabel = DateFormat('EEEE, MMMM d').format(occurrence.start);
    final location = occurrence.item.room.trim();
    final statusLabel = isLive ? 'Live Now' : 'Coming Up';
    final foreground = colors.onPrimary;

    // Calculate time until class
    final now = DateTime.now();
    final timeUntil = occurrence.start.difference(now);
    String timeUntilText = '';
    if (!isLive && timeUntil.inMinutes > 0) {
      if (timeUntil.inHours > 0) {
        timeUntilText = 'in ${timeUntil.inHours}h ${timeUntil.inMinutes % 60}m';
      } else {
        timeUntilText = 'in ${timeUntil.inMinutes}m';
      }
    }

    return Material(
      color: Colors.transparent,
      borderRadius: AppTokens.radius.lg,
      child: InkWell(
        borderRadius: AppTokens.radius.lg,
        onTap: () => onViewDetails(occurrence.item),
        child: Container(
          padding: spacing.edgeInsetsAll(spacing.xxl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary,
                colors.primary.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: AppTokens.radius.lg,
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status badge
              Row(
                children: [
                  Container(
                    padding: spacing.edgeInsetsSymmetric(
                      horizontal: spacing.md,
                      vertical: spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: foreground.withValues(alpha: 0.20),
                      borderRadius: AppTokens.radius.pill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLive)
                          Container(
                            width: AppTokens.componentSize.badgeSm,
                            height: AppTokens.componentSize.badgeSm,
                            margin: spacing.edgeInsetsOnly(right: spacing.sm),
                            decoration: BoxDecoration(
                              color: foreground,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: foreground.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          )
                        else
                          Icon(
                            Icons.schedule_rounded,
                            size: AppTokens.iconSize.sm,
                            color: foreground,
                          ),
                        if (!isLive) SizedBox(width: spacing.xs + 2),
                        Text(
                          statusLabel,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: AppTokens.typography.caption.fontSize,
                            color: foreground,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (timeUntilText.isNotEmpty) ...[
                    SizedBox(width: spacing.sm + 2),
                    Text(
                      timeUntilText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: foreground.withValues(alpha: 0.85),
                        fontSize: AppTokens.typography.caption.fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: spacing.xl),
              
              // Class title
            Text(
              subject,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: AppTokens.typography.headline.fontSize,
                height: 1.3,
                color: foreground,
                letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: spacing.lg + 2),
              
              // Time
              Row(
                children: [
                  Container(
                    padding: spacing.edgeInsetsAll(spacing.sm),
                    decoration: BoxDecoration(
                      color: foreground.withValues(alpha: 0.15),
                      borderRadius: AppTokens.radius.sm,
                    ),
                    child: Icon(
                      Icons.access_time_rounded,
                      size: AppTokens.iconSize.sm,
                      color: foreground,
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeLabel,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w600,
                            fontSize: AppTokens.typography.body.fontSize,
                          ),
                        ),
                        SizedBox(height: AppTokens.spacing.xs),
                        Text(
                          dateLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: foreground.withValues(alpha: 0.80),
                            fontSize: AppTokens.typography.caption.fontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.md + 2),
              
              // Location
              if (location.isNotEmpty) ...[
                Row(
                  children: [
                    Container(
                      padding: spacing.edgeInsetsAll(spacing.sm),
                      decoration: BoxDecoration(
                        color: foreground.withValues(alpha: 0.15),
                        borderRadius: AppTokens.radius.sm,
                      ),
                      child: Icon(
                        Icons.place_outlined,
                        size: AppTokens.iconSize.sm,
                        color: foreground,
                      ),
                    ),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: foreground.withValues(alpha: 0.90),
                          fontSize: AppTokens.typography.bodySecondary.fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Instructor
                if (occurrence.item.instructor.isNotEmpty) ...[
                  SizedBox(height: spacing.lg),
                  Container(
                    padding: spacing.edgeInsetsAll(spacing.md),
                    decoration: BoxDecoration(
                      color: foreground.withValues(alpha: 0.12),
                      borderRadius: AppTokens.radius.md,
                    ),
                    child: Row(
                    children: [
                      InstructorAvatar(
                        name: occurrence.item.instructor,
                        avatarUrl: (occurrence.item.instructorAvatar?.isEmpty ?? true)
                            ? null 
                            : occurrence.item.instructorAvatar,
                        tint: foreground,
                        inverse: true,
                        size: AppTokens.iconSize.xl,
                      ),
                      SizedBox(width: spacing.xs + 2),
                      Expanded(
                      child: Text(
                          occurrence.item.instructor,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: AppTokens.typography.bodySecondary.fontSize,
                            color: colors.onPrimary.withValues(alpha: 0.95),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingListTile extends StatelessWidget {
  const _UpcomingListTile({
    required this.occurrence,
    required this.onViewDetails,
    required this.onToggle,
    required this.enabled,
  });

  final ClassOccurrence occurrence;
  final ValueChanged<ClassItem> onViewDetails;
  final ValueChanged<bool> onToggle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final subject = occurrence.item.subject;
    final timeFormat = DateFormat('h:mm a');
    final timeRange = '${timeFormat.format(occurrence.start)} - ${timeFormat.format(occurrence.end)}';
    final location = occurrence.item.room.trim();
    final instructor = occurrence.item.instructor;
    
    final now = DateTime.now();
    final isPast = occurrence.end.isBefore(now);
    final isLive = occurrence.isOngoingAt(now);
    final disabled = !enabled;

    // Determine status for styling
    final isNext = !isPast && !isLive && !disabled;

    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      borderRadius: AppTokens.radius.lg,
      child: InkWell(
        onTap: () => onViewDetails(occurrence.item),
        borderRadius: AppTokens.radius.md,
        splashColor: colors.primary.withValues(alpha: 0.05),
        highlightColor: colors.primary.withValues(alpha: 0.02),
        child: Container(
          padding: spacing.edgeInsetsAll(spacing.lg),
          decoration: BoxDecoration(
            color: isDark ? colors.surfaceContainerHigh : colors.surface,
            borderRadius: AppTokens.radius.md,
            border: Border.all(
              color: (isLive || isNext) && !disabled
                  ? colors.primary.withValues(alpha: 0.30)
                  : colors.outline.withValues(alpha: isDark ? 0.12 : 0.4),
              width: (isLive || isNext) && !disabled ? 1.5 : 0.5,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: (isLive || isNext) && !disabled ? 0.08 : 0.04),
                      blurRadius: (isLive || isNext) && !disabled ? 12 : 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Title and Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      subject,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: AppTokens.typography.subtitle.fontSize,
                        letterSpacing: -0.2,
                        color: disabled
                            ? colors.onSurface.withValues(alpha: 0.5)
                            : (isPast
                                ? colors.onSurfaceVariant
                                : colors.onSurface),
                        decoration: disabled || isPast ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  if (!disabled)
                    Container(
                      padding: spacing.edgeInsetsSymmetric(
                        horizontal: spacing.md,
                        vertical: spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: isLive
                            ? colors.primary.withValues(alpha: 0.15)
                            : isPast 
                                ? colors.surfaceContainerHighest
                                : colors.primary.withValues(alpha: 0.08),
                        borderRadius: AppTokens.radius.sm,
                      ),
                      child: Text(
                        isLive ? 'Live' : (isPast ? 'Done' : 'Next'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: AppTokens.typography.caption.fontSize,
                          fontWeight: FontWeight.w700,
                          color: isLive 
                              ? colors.primary 
                              : isPast 
                                  ? colors.onSurfaceVariant
                                  : colors.primary,
                        ),
                      ),
                    ),
                  if (disabled)
                     Container(
                      padding: spacing.edgeInsetsSymmetric(
                        horizontal: spacing.md,
                        vertical: spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.1),
                        borderRadius: AppTokens.radius.sm,
                      ),
                      child: Text(
                        'Off',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: AppTokens.typography.caption.fontSize,
                          fontWeight: FontWeight.w700,
                          color: colors.error,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: spacing.md),
              // Bottom row: Time, Location, Toggle
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: AppTokens.iconSize.sm,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  SizedBox(width: spacing.xs + 2),
                  Text(
                    timeRange,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: AppTokens.typography.bodySecondary.fontSize,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.85),
                    ),
                  ),
                  if (location.isNotEmpty) ...[
                    SizedBox(width: spacing.lg),
                    Icon(
                      Icons.location_on_outlined,
                      size: AppTokens.iconSize.sm,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    SizedBox(width: spacing.xs + 2),
                    Expanded(
                      child: Text(
                        location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: AppTokens.typography.bodySecondary.fontSize,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (location.isEmpty) const Spacer(),
                  SizedBox(
                    height: AppTokens.componentSize.badgeLg,
                    child: Transform.scale(
                      scale: 0.8,
                      alignment: Alignment.centerRight,
                      child: Switch(
                        value: enabled,
                        onChanged: onToggle,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ),
              if (instructor.isNotEmpty) ...[
                SizedBox(height: spacing.sm + 2),
                _InstructorRow(
                  name: instructor,
                  avatarUrl: occurrence.item.instructorAvatar,
                  tint: colors.primary,
                  dense: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructorRow extends StatelessWidget {
  const _InstructorRow({
    required this.name,
    required this.tint,
    this.avatarUrl,
    this.inverse = false,
    this.dense = false,
  });

  final String name;
  final Color tint;
  final String? avatarUrl;
  final bool inverse;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final textColor = inverse ? tint : colors.onSurfaceVariant;
    final iconColor = inverse ? tint.withValues(alpha: 0.8) : tint;

    return Row(
      children: [
        if (avatarUrl != null && avatarUrl!.isNotEmpty)
          Container(
            width: dense ? 20 : 24,
            height: dense ? 20 : 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(avatarUrl!),
                fit: BoxFit.cover,
              ),
              border: inverse ? Border.all(color: tint, width: 1) : null,
            ),
          )
        else
          Icon(
            Icons.account_circle_rounded,
            size: dense ? 20 : 24,
            color: iconColor,
          ),
        SizedBox(width: spacing.xs + 2),
        Expanded(
          child: Text(
            name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: dense
                  ? AppTokens.typography.caption.fontSize
                  : AppTokens.typography.bodySecondary.fontSize,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DashboardMetricChip extends StatelessWidget {
  const _DashboardMetricChip({
    required this.icon,
    required this.tint,
    required this.label,
    required this.value,
    required this.caption,
    this.progress,
    this.highlight = false,
  });

  final IconData icon;
  final Color tint;
  final String label;
  final String value;
  final String caption;
  final double? progress;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.lg),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: highlight
              ? tint.withValues(alpha: 0.3)
              : colors.outline.withValues(alpha: isDark ? 0.12 : 0.4),
          width: highlight ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: highlight
                ? tint.withValues(alpha: 0.08)
                : colors.shadow.withValues(alpha: isDark ? 0 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: highlight
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tint.withValues(alpha: isDark ? 0.15 : 0.05),
                  tint.withValues(alpha: isDark ? 0.05 : 0.01),
                ],
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: spacing.edgeInsetsAll(spacing.sm),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.1),
                  borderRadius: AppTokens.radius.md,
                ),
                child: Icon(icon, size: AppTokens.iconSize.md, color: tint),
              ),
              const Spacer(),
              if (progress != null)
                SizedBox(
                  width: AppTokens.componentSize.badgeLg,
                  height: AppTokens.componentSize.badgeLg,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    backgroundColor: tint.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(tint),
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing.lg),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: AppTokens.typography.headline.fontSize,
              color: colors.onSurface,
              height: 1.0,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: AppTokens.typography.caption.fontSize,
            ),
          ),
          if (caption.isNotEmpty) ...[
            SizedBox(height: spacing.sm),
            Text(
              caption,
              style: theme.textTheme.bodySmall?.copyWith(
                color: tint,
                fontSize: AppTokens.typography.caption.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
