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
                    letterSpacing: AppLetterSpacing.snug,
                    color: colors.onSurface,
                  ),
                ),
              ),
              if (refreshLabel != null) RefreshChip(label: refreshLabel!),
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
                  tint: colors.tertiary,
                  displayStyle: true,
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
                      vertical: spacing.sm,
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
                            margin: spacing.edgeInsetsOnly(right: spacing.sm),
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
                        if (!isLive) SizedBox(width: spacing.xs + spacing.micro),
                        Text(
                          statusLabel,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: AppTokens.typography.caption.fontSize,
                            color: foreground,
                            letterSpacing: AppLetterSpacing.wider,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (timeUntilText.isNotEmpty) ...[
                    SizedBox(width: spacing.sm + spacing.micro),
                    Text(
                      timeUntilText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: foreground.withValues(alpha: AppOpacity.prominent),
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
                height: AppLineHeight.compact,
                color: foreground,
                letterSpacing: AppLetterSpacing.tight,
                ),
              ),
              SizedBox(height: spacing.lg + spacing.micro),
              
              // Time
              Row(
                children: [
                  Container(
                    padding: spacing.edgeInsetsAll(spacing.sm),
                    decoration: BoxDecoration(
                      color: foreground.withValues(alpha: AppOpacity.statusBg),
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
                            color: foreground.withValues(alpha: AppOpacity.prominent),
                            fontSize: AppTokens.typography.caption.fontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.md + spacing.micro),
              
              // Location
              if (location.isNotEmpty) ...[
                Row(
                  children: [
                    Container(
                      padding: spacing.edgeInsetsAll(spacing.sm),
                      decoration: BoxDecoration(
                        color: foreground.withValues(alpha: AppOpacity.statusBg),
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
                          color: foreground.withValues(alpha: AppOpacity.prominent),
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
                        size: AppTokens.iconSize.xl,
                      ),
                      SizedBox(width: spacing.xs + spacing.micro),
                      Expanded(
                      child: Text(
                          occurrence.item.instructor,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: AppTokens.typography.bodySecondary.fontSize,
                            color: colors.onPrimary.withValues(alpha: AppOpacity.prominent),
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
                    child: Text(
                      subject,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: AppTokens.typography.subtitle.fontSize,
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
                            ? colors.primary.withValues(alpha: AppOpacity.statusBg)
                            : isPast 
                                ? colors.surfaceContainerHighest
                                : colors.primary.withValues(alpha: AppOpacity.highlight),
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
                        color: colors.error.withValues(alpha: AppOpacity.overlay),
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
                    color: colors.onSurfaceVariant.withValues(alpha: AppOpacity.muted),
                  ),
                  SizedBox(width: spacing.xs + spacing.micro),
                  Text(
                    timeRange,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: AppTokens.typography.bodySecondary.fontSize,
                      fontWeight: FontWeight.w500,
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
                    SizedBox(width: spacing.xs + spacing.micro),
                    Expanded(
                      child: Text(
                        location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: AppTokens.typography.bodySecondary.fontSize,
                          fontWeight: FontWeight.w500,
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
                SizedBox(height: spacing.sm + spacing.micro),
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
        SizedBox(width: spacing.xs + spacing.micro),
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


