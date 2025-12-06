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
    this.onRefresh,
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
  final VoidCallback? onRefresh;
  final VoidCallback? onReviewReminders;
  final ValueChanged<ClassItem> onViewDetails;
  final void Function(int id, bool enabled) onToggleEnabled;
  final VoidCallback? onViewSchedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final hero = upcoming.primary;
    final spacing = AppTokens.spacing;

    final card = Container(
      padding: spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: isDark ? colors.outline.withValues(alpha: AppOpacity.overlay) : colors.outline,
          width: isDark ? AppTokens.componentSize.divider : AppTokens.componentSize.dividerThin,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: AppOpacity.faint),
                  blurRadius: AppTokens.shadow.md,
                  offset: AppShadowOffset.sm,
                ),
              ],
      ),
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
                    fontWeight: AppTokens.fontWeight.bold,
                    letterSpacing: AppLetterSpacing.snug,
                    color: colors.onSurface,
                  ),
                ),
              ),
              if (onRefresh != null)
                SizedBox(
                  height: AppTokens.componentSize.buttonXs,
                  child: IconButton(
                    onPressed: onRefresh,
                    tooltip: refreshLabel != null ? 'Refreshed $refreshLabel' : 'Refresh',
                    style: IconButton.styleFrom(
                      minimumSize: Size.square(AppTokens.componentSize.buttonXs),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: colors.onSurfaceVariant,
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTokens.radius.md,
                      ),
                    ),
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: AppTokens.iconSize.md,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing.xl),
          if (hero != null) ...[
            _UpcomingHeroTile(
              occurrence: hero,
              isLive: upcoming.isActive,
              onViewDetails: onViewDetails,
            ),
            SizedBox(height: spacing.xl),
          ] else ...[
            _EmptyHeroPlaceholder(
              icon: Icons.check_circle_outline_rounded,
              title: 'All caught up',
              subtitle: 'No upcoming classes right now.',
            ),
            SizedBox(height: spacing.xl),
          ],
          Row(
            children: [
              Expanded(
                child: MetricChip(
                  icon: Icons.hourglass_bottom_rounded,
                  value: summary.hoursDoneLabel,
                  label: 'Hours done',
                  tint: colors.primary,
                  displayStyle: true,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: MetricChip(
                  icon: Icons.class_rounded,
                  value: summary.classesRemainingLabel,
                  label: 'Classes left',
                  tint: colors.secondary,
                  displayStyle: true,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: MetricChip(
                  icon: Icons.task_alt_rounded,
                  value: summary.tasksLabel,
                  label: 'Open tasks',
                  tint: palette.positive,
                  backgroundTint: palette.positive.withValues(
                    alpha: AppOpacity.dim,
                  ),
                  displayStyle: true,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xl),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'View schedule',
                  onPressed: onViewSchedule,
                  minHeight: AppTokens.componentSize.buttonMd,
                  expanded: true,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: SecondaryButton(
                  label: 'Reminders',
                  onPressed: onReviewReminders,
                  minHeight: AppTokens.componentSize.buttonMd,
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
                colors.primary.withValues(alpha: AppOpacity.prominent),
              ],
            ),
            borderRadius: AppTokens.radius.lg,
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: AppOpacity.ghost),
                blurRadius: AppTokens.shadow.xl,
                offset: AppShadowOffset.lg,
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
                      vertical: spacing.sm - spacing.micro,
                    ),
                    decoration: BoxDecoration(
                      color: foreground.withValues(alpha: AppOpacity.border),
                      borderRadius: AppTokens.radius.pill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLive)
                          Container(
                            width: AppTokens.componentSize.badgeSm,
                            height: AppTokens.componentSize.badgeSm,
                            margin: EdgeInsets.only(right: spacing.sm),
                            decoration: BoxDecoration(
                              color: foreground,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: foreground.withValues(alpha: AppOpacity.subtle),
                                  blurRadius: AppTokens.shadow.xs,
                                  spreadRadius: AppTokens.componentSize.divider,
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
                        if (!isLive) SizedBox(width: spacing.xsPlus),
                        Text(
                          statusLabel,
                          style: AppTokens.typography.caption.copyWith(
                            fontWeight: AppTokens.fontWeight.semiBold,
                            color: foreground,
                            letterSpacing: AppLetterSpacing.wider,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (timeUntilText.isNotEmpty) ...[
                    SizedBox(width: spacing.smMd),
                    Text(
                      timeUntilText,
                      style: AppTokens.typography.caption.copyWith(
                        color: foreground.withValues(alpha: AppOpacity.prominent),
                        fontWeight: AppTokens.fontWeight.medium,
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
              style: AppTokens.typography.headline.copyWith(
                fontWeight: AppTokens.fontWeight.bold,
                height: AppLineHeight.compact,
                color: foreground,
                letterSpacing: AppLetterSpacing.tight,
              ),
            ),
              SizedBox(height: spacing.lgPlus),
              
              // Time
              Row(
                children: [
                  Container(
                    padding: spacing.edgeInsetsAll(spacing.sm),
                    decoration: BoxDecoration(
                      color: foreground.withValues(alpha: AppOpacity.medium),
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
                          style: AppTokens.typography.subtitle.copyWith(
                            color: foreground,
                            fontWeight: AppTokens.fontWeight.semiBold,
                          ),
                        ),
                        SizedBox(height: AppTokens.spacing.xs),
                        Text(
                          dateLabel,
                          style: AppTokens.typography.caption.copyWith(
                            color: foreground.withValues(alpha: AppOpacity.secondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (location.isNotEmpty) ...[
                SizedBox(height: spacing.md + AppTokens.spacing.micro),
                Row(
                  children: [
                    Container(
                      padding: spacing.edgeInsetsAll(spacing.sm),
                      decoration: BoxDecoration(
                        color: foreground.withValues(alpha: AppOpacity.medium),
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
                        style: AppTokens.typography.body.copyWith(
                          color: foreground.withValues(alpha: AppOpacity.high),
                          fontWeight: AppTokens.fontWeight.medium,
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
                      color: foreground.withValues(alpha: AppOpacity.overlay),
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
                        size: AppTokens.componentSize.avatarSmDense,
                      ),
                      SizedBox(width: spacing.sm),
                      Expanded(
                      child: Text(
                          occurrence.item.instructor,
                          style: AppTokens.typography.subtitle.copyWith(
                            fontWeight: AppTokens.fontWeight.semiBold,
                            color: colors.onPrimary.withValues(alpha: AppOpacity.full),
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

class _EmptyHeroPlaceholder extends StatelessWidget {
  const _EmptyHeroPlaceholder({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spacing = AppTokens.spacing;
    return Container(
      width: double.infinity,
      padding: spacing.edgeInsetsAll(spacing.xxxl),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: AppOpacity.micro),
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: colors.primary.withValues(alpha: AppOpacity.dim),
          width: AppTokens.componentSize.divider,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: spacing.emptyStateSize,
            height: spacing.emptyStateSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primary.withValues(alpha: AppOpacity.medium),
                  colors.primary.withValues(alpha: AppOpacity.highlight),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.primary.withValues(alpha: AppOpacity.accent),
                width: AppTokens.componentSize.dividerThick,
              ),
            ),
            child: Icon(
              icon,
              size: AppTokens.iconSize.xxl,
              color: colors.primary,
            ),
          ),
          SizedBox(height: spacing.xl),
          Text(
            title,
            style: AppTokens.typography.subtitle.copyWith(
              fontWeight: AppTokens.fontWeight.bold,
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.sm),
          Text(
            subtitle,
            style: AppTokens.typography.bodySecondary.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: AppOpacity.secondary),
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
    final palette = theme.brightness == Brightness.dark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final subject = occurrence.item.subject;
    final timeFormat = DateFormat('h:mm a');
    final timeRange = '${timeFormat.format(occurrence.start)} - ${timeFormat.format(occurrence.end)}';
    final location = occurrence.item.room.trim();
    final instructor = occurrence.item.instructor;
    final isCustom = occurrence.item.isCustom;
    
    final now = DateTime.now();
    final isPast = occurrence.end.isBefore(now);
    final isLive = occurrence.isOngoingAt(now);
    final disabled = !enabled;

    // Determine status for styling
    final isNext = !isPast && !isLive && !disabled;

    final isDark = theme.brightness == Brightness.dark;

    // Normalize trailing control footprint to match schedules rows
    final double trailingWidth = AppTokens.componentSize.buttonMd;

    return Material(
      color: Colors.transparent,
      borderRadius: AppTokens.radius.lg,
      child: InkWell(
        onTap: () => onViewDetails(occurrence.item),
        borderRadius: AppTokens.radius.md,
        splashColor: colors.primary.withValues(alpha: AppOpacity.faint),
        highlightColor: colors.primary.withValues(alpha: AppOpacity.faint),
        child: Container(
          padding: spacing.edgeInsetsAll(spacing.lg),
          decoration: BoxDecoration(
            color: isDark ? colors.surfaceContainerHigh : colors.surface,
            borderRadius: AppTokens.radius.md,
            border: Border.all(
              color: (isLive || isNext) && !disabled
                  ? colors.primary.withValues(alpha: AppOpacity.ghost)
                  : colors.outline.withValues(alpha: isDark ? AppOpacity.overlay : AppOpacity.barrier),
              width: (isLive || isNext) && !disabled ? AppTokens.componentSize.dividerThick : AppTokens.componentSize.dividerThin,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: (isLive || isNext) && !disabled ? AppOpacity.highlight : AppOpacity.faint),
                      blurRadius: (isLive || isNext) && !disabled ? AppTokens.shadow.md : AppTokens.shadow.sm,
                      offset: AppShadowOffset.xs,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject,
                          style: AppTokens.typography.subtitle.copyWith(
                            fontWeight: AppTokens.fontWeight.bold,
                            letterSpacing: AppLetterSpacing.compact,
                            color: disabled
                                ? colors.onSurface.withValues(alpha: AppOpacity.subtle)
                                : (isPast
                                    ? colors.onSurfaceVariant
                                    : colors.onSurface),
                            decoration: disabled || isPast ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isCustom && !disabled) ...[
                          SizedBox(height: spacing.microHalf),
                          StatusBadge(
                            label: 'Custom',
                            variant: StatusBadgeVariant.next,
                            accent: palette.positive,
                            compact: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  SizedBox(
                    width: trailingWidth,
                    height: AppTokens.componentSize.listItemSm,
                    child: Center(
                      child: disabled
                          ? _StatusPill(
                              label: 'Off',
                              color: colors.onSurfaceVariant,
                              background: colors.error.withValues(alpha: AppOpacity.overlay),
                            )
                          : isLive
                              ? _StatusPill(
                                  label: 'Live',
                                  color: colors.primary,
                                  background: colors.primary.withValues(alpha: AppOpacity.statusBg),
                                )
                              : isPast
                                  ? _StatusPill(
                                      label: 'Done',
                                      color: colors.onSurfaceVariant,
                                      background: colors.surfaceContainerHighest,
                                    )
                                  : Transform.scale(
                                      scale: AppScale.dense,
                                      child: Switch(
                                        value: enabled,
                                        onChanged: onToggle,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
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
                    color: colors.onSurfaceVariant.withValues(alpha: AppOpacity.muted),
                  ),
                  SizedBox(width: spacing.xsPlus),
                  Text(
                    timeRange,
                    style: AppTokens.typography.bodySecondary.copyWith(
                      fontWeight: AppTokens.fontWeight.medium,
                      color: colors.onSurfaceVariant.withValues(alpha: AppOpacity.prominent),
                    ),
                  ),
                  if (location.isNotEmpty) ...[
                    SizedBox(width: spacing.lg),
                    Icon(
                      Icons.location_on_outlined,
                      size: AppTokens.iconSize.sm,
                      color: colors.onSurfaceVariant.withValues(alpha: AppOpacity.muted),
                    ),
                    SizedBox(width: spacing.xsPlus),
                    Expanded(
                      child: Text(
                        location,
                        style: AppTokens.typography.bodySecondary.copyWith(
                          fontWeight: AppTokens.fontWeight.medium,
                          color: colors.onSurfaceVariant.withValues(alpha: AppOpacity.prominent),
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
                      scale: AppScale.compact,
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
                SizedBox(height: spacing.smMd),
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
    final iconColor = inverse ? tint.withValues(alpha: AppOpacity.prominent) : tint;

    return Row(
      children: [
        if (avatarUrl != null && avatarUrl!.isNotEmpty)
          Container(
            width: dense ? AppTokens.iconSize.md : AppTokens.iconSize.lg,
            height: dense ? AppTokens.iconSize.md : AppTokens.iconSize.lg,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(avatarUrl!),
                fit: BoxFit.cover,
              ),
              border: inverse ? Border.all(color: tint, width: AppTokens.componentSize.divider) : null,
            ),
          )
        else
          Icon(
            Icons.account_circle_rounded,
            size: dense ? AppTokens.iconSize.md : AppTokens.iconSize.lg,
            color: iconColor,
          ),
        SizedBox(width: spacing.xsPlus),
        Expanded(
          child: Text(
            name,
            style: (dense ? AppTokens.typography.caption : AppTokens.typography.bodySecondary).copyWith(
              color: textColor,
              fontWeight: AppTokens.fontWeight.medium,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    return Container(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppTokens.radius.pill,
      ),
      child: Text(
        label,
        style: AppTokens.typography.caption.copyWith(
          color: color,
          fontWeight: AppTokens.fontWeight.semiBold,
        ),
      ),
    );
  }
}

