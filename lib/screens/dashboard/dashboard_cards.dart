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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hero = upcoming.primary;
    final trailing = hero == null
        ? <ClassOccurrence>[]
        : upcoming.occurrences
            .skip(1)
            .where(
              (occ) => DateUtils.isSameDay(occ.start, hero.start),
            )
            .toList();
    final trailingHeading = _resolveTrailingHeading(upcoming.focusDay);
    final cardBackground = elevatedCardBackground(theme);
    final borderColor = elevatedCardBorder(theme);

    final card = CardX(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      backgroundColor: cardBackground,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  greeting,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (refreshLabel != null) ...[
                const SizedBox(width: 12),
                _RefreshChip(label: refreshLabel!),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dateLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: hero != null
                ? _UpcomingHeroTile(
                    key: ValueKey(
                      'hero-${hero.item.id}-${hero.start.toIso8601String()}',
                    ),
                    occurrence: hero,
                    isLive: upcoming.isActive,
                    onViewDetails: onViewDetails,
                  )
                : const SizedBox(
                    key: ValueKey('hero-empty'),
                    height: 0,
                  ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DashboardMetricChip(
                  icon: Icons.hourglass_bottom_rounded,
                  tint: colors.primary,
                  label: 'Hours done',
                  value: summary.hoursDoneLabel,
                  caption: summary.hoursCaption,
                  progress: summary.hoursPlanned > 0
                      ? (summary.hoursDone / summary.hoursPlanned)
                          .clamp(0.0, 1.0)
                      : null,
                  highlight: summary.hoursDone > 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DashboardMetricChip(
                  icon: Icons.class_rounded,
                  tint: colors.secondary,
                  label: 'Classes left',
                  value: summary.classesRemainingLabel,
                  caption: summary.classesCaption,
                  progress: summary.classesPlanned > 0
                      ? (1 -
                              (summary.classesRemaining /
                                  summary.classesPlanned))
                          .clamp(0.0, 1.0)
                      : null,
                  highlight: summary.classesRemaining > 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DashboardMetricChip(
                  icon: Icons.task_alt_rounded,
                  tint: colors.tertiary,
                  label: 'Open tasks',
                  value: summary.tasksLabel,
                  caption: summary.tasksCaption,
                  highlight: summary.openTasks > 0,
                ),
              ),
            ],
          ),
          if (trailing.isNotEmpty) ...[
            const SizedBox(height: 20),
            CardX(
              padding: const EdgeInsets.all(18),
              backgroundColor: elevatedCardBackground(theme),
              borderColor: elevatedCardBorder(theme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trailingHeading,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      for (var i = 0; i < trailing.length && i < 3; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                i == math.min(trailing.length - 1, 2) ? 0 : 12,
                          ),
                          child: _UpcomingListTile(
                            occurrence: trailing[i],
                            onViewDetails: onViewDetails,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ] else if (hero == null) ...[
            const SizedBox(height: 20),
            Text(
              summary.classesPlanned == 0
                  ? 'No classes scheduled in this scope.'
                  : 'All classes for this scope are complete.',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              summary.classesPlanned == 0
                  ? 'Use Review schedule to add or enable a class.'
                  : 'Great job staying ahead. Review schedule to plan more.',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                color: kSummaryMuted,
              ),
            ),
          ],
          if (reminderAlert != null && onReviewReminders != null) ...[
            const SizedBox(height: 20),
            _ReminderAlertBanner(
              alert: reminderAlert!,
              onReview: onReviewReminders!,
            ),
          ],
        ],
      ),
    );

    return RepaintBoundary(child: card);
  }

  String _resolveTrailingHeading(DateTime? focusDay) {
    if (focusDay == null) {
      return 'Later today';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(focusDay.year, focusDay.month, focusDay.day);
    final difference = target.difference(today).inDays;

    if (difference <= 0) {
      return 'Later today';
    }
    if (difference == 1) {
      return 'Tomorrow';
    }
    if (difference < 7) {
      return DateFormat('EEEE').format(target);
    }
    return DateFormat('EEEE, MMM d').format(target);
  }
}

class _RefreshChip extends StatelessWidget {
  const _RefreshChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: isDark ? 0.28 : 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colors.primary.withValues(alpha: isDark ? 0.4 : 0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.refresh_rounded, size: 14, color: colors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.primary,
            ),
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
    final background = alert.tint.withValues(alpha: 0.14);
    final border = alert.tint.withValues(alpha: 0.22);
    final iconBackground = alert.tint.withValues(alpha: 0.18);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onReview,
        borderRadius: AppTokens.radius.lg,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppTokens.radius.lg,
            border: Border.all(color: border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(alert.icon, color: alert.tint, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.message,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: onReview,
                style: TextButton.styleFrom(
                  foregroundColor: alert.tint,
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
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
    final subject = occurrence.item.subject;
    final timeLabel =
        '${DateFormat('h:mm a').format(occurrence.start)} - ${DateFormat('h:mm a').format(occurrence.end)}';
    final dateLabel = DateFormat('EEE, MMM d').format(occurrence.start);
    final location = occurrence.item.room.trim();
    final statusLabel = isLive ? 'Happening now' : 'Up next';

    final radius = AppTokens.radius.lg;
    final baseColor = colors.primary;
    final gradientColors = [
      baseColor.withValues(alpha: isDark ? 0.85 : 0.95),
      baseColor.withValues(alpha: isDark ? 0.65 : 0.7),
    ];
    final shadowColor = baseColor.withValues(alpha: isDark ? 0.32 : 0.22);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => onViewDetails(occurrence.item),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 24,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusChip(
                    icon: isLive
                        ? Icons.play_arrow_rounded
                        : Icons.arrow_forward_rounded,
                    label: statusLabel,
                    background: colors.onPrimary.withValues(alpha: 0.16),
                    foreground: colors.onPrimary.withValues(alpha: 0.9),
                    compact: true,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.onPrimary.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.flash_on_rounded,
                          size: 18,
                          color: colors.onPrimary.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isLive ? 'Live' : 'Next',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colors.onPrimary.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                subject,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: colors.onPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: colors.onPrimary.withValues(alpha: 0.78),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      timeLabel,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: colors.onPrimary.withValues(alpha: 0.75),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onPrimary.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
              if (location.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 16,
                      color: colors.onPrimary.withValues(alpha: 0.76),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onPrimary.withValues(alpha: 0.82),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (occurrence.item.instructor.isNotEmpty) ...[
                const SizedBox(height: 14),
                _InstructorRow(
                  name: occurrence.item.instructor,
                  avatarUrl: occurrence.item.instructorAvatar,
                  tint: colors.onPrimary,
                  inverse: true,
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
  });

  final ClassOccurrence occurrence;
  final ValueChanged<ClassItem> onViewDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final subject = occurrence.item.subject;
    final dayLabel = DateFormat('EEE').format(occurrence.start).toUpperCase();
    final dateLabel = DateFormat('MMM d').format(occurrence.start);
    final timeLabel =
        '${DateFormat('h:mm a').format(occurrence.start)} - ${DateFormat('h:mm a').format(occurrence.end)}';
    final location = occurrence.item.room.trim();
    final instructor = occurrence.item.instructor;
    final now = DateTime.now();
    final isPast = occurrence.end.isBefore(now);
    final isLive = occurrence.isOngoingAt(now);

    String statusLabel;
    IconData statusIcon = Icons.schedule_rounded;
    Color statusForeground = colors.primary;
    Color statusBackground = colors.primary.withValues(alpha: 0.12);

    if (isPast) {
      statusLabel = 'Done';
      statusIcon = Icons.check_rounded;
      statusForeground = colors.tertiary;
      statusBackground = colors.tertiary.withValues(alpha: 0.16);
    } else if (isLive) {
      statusLabel = 'Happening now';
      statusIcon = Icons.play_arrow_rounded;
      statusForeground = colors.primary;
      statusBackground = colors.primary.withValues(alpha: 0.16);
    } else {
      statusLabel = 'Upcoming';
      statusIcon = Icons.arrow_forward_rounded;
      statusForeground = colors.primary;
      statusBackground = colors.primary.withValues(alpha: 0.12);
    }

    final tileBackground = isLive
        ? colors.primary.withValues(alpha: 0.1)
        : colors.surfaceContainerHigh;
    final tileBorder = isLive
        ? colors.primary.withValues(alpha: 0.22)
        : colors.outlineVariant.withValues(alpha: 0.3);
    final radius = AppTokens.radius.lg;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => onViewDetails(occurrence.item),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: tileBackground,
            borderRadius: radius,
            border: Border.all(color: tileBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            subject,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(
                          icon: statusIcon,
                          label: statusLabel,
                          background: statusBackground,
                          foreground: statusForeground,
                          compact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color:
                            colors.onSurfaceVariant.withValues(alpha: 0.82),
                      ),
                    ),
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          color: colors.onSurfaceVariant
                              .withValues(alpha: 0.68),
                        ),
                      ),
                    ],
                    if (instructor.isNotEmpty) ...[
                      const SizedBox(height: 8),
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
    final textColor =
        inverse ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    final textStyle =
        (dense ? theme.textTheme.bodyMedium : theme.textTheme.bodyLarge)
            ?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: dense ? 15 : 16,
      color: textColor,
    );

    return Row(
      children: [
        InstructorAvatar(
          name: name,
          avatarUrl: avatarUrl,
          tint: tint,
          inverse: inverse,
          size: dense ? 26 : 28,
        ),
        SizedBox(width: dense ? 6 : 8),
        Expanded(
          child: Text(
            name,
            style: textStyle,
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
    this.caption,
    this.progress,
    this.highlight = false,
  });

  final IconData icon;
  final Color tint;
  final String label;
  final String value;
  final String? caption;
  final double? progress;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final num? rawProgress = progress?.clamp(0.0, 1.0);
    final double? normalizedProgress =
        rawProgress != null && rawProgress.isFinite
            ? rawProgress.toDouble()
            : null;
    final bool showProgressRing =
        normalizedProgress != null && normalizedProgress > 0;
    final bool isDark = theme.brightness == Brightness.dark;
    final background = tint.withValues(alpha: isDark ? 0.20 : 0.10);
    final border = tint.withValues(alpha: isDark ? 0.28 : 0.18);
    final iconBackground = tint.withValues(
      alpha: highlight ? (isDark ? 0.35 : 0.24) : (isDark ? 0.22 : 0.16),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppTokens.radius.lg,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 36,
            width: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (showProgressRing)
                  SizedBox(
                    height: 36,
                    width: 36,
                    child: CircularProgressIndicator(
                      value: normalizedProgress,
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        tint.withValues(alpha: 0.9),
                      ),
                      backgroundColor: tint.withValues(alpha: 0.18),
                    ),
                  ),
                Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: tint.withValues(alpha: 0.95),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'SFProRounded',
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.fade,
          ),
          if (normalizedProgress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: normalizedProgress,
                minHeight: 4,
                backgroundColor: tint.withValues(alpha: 0.18),
                valueColor: AlwaysStoppedAnimation<Color>(
                  tint.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
          if (caption != null) ...[
            const SizedBox(height: 8),
            Text(
              caption!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                fontSize: 15,
              ),
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.fade,
            ),
          ],
        ],
      ),
    );
  }
}
