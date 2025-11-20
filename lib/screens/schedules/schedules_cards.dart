part of 'schedules_screen.dart';

class _ScheduleGroupSliver extends StatelessWidget
    implements ScreenShellSliver {
  const _ScheduleGroupSliver({
    required this.header,
    required this.group,
    required this.onOpenDetails,
    required this.onToggleEnabled,
    required this.pendingToggleIds,
    this.highlightClassId,
    this.showHeader = true,
  });

  final Widget header;
  final DayGroup group;
  final void Function(sched.ClassItem item) onOpenDetails;
  final void Function(sched.ClassItem item, bool enable) onToggleEnabled;
  final Set<int> pendingToggleIds;
  final int? highlightClassId;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return ScreenStickyGroup(
      header: header,
      child: _ScheduleGroupCard(
        group: group,
        onOpenDetails: onOpenDetails,
        onToggleEnabled: onToggleEnabled,
        pendingToggleIds: pendingToggleIds,
        highlightClassId: highlightClassId,
        showHeader: showHeader,
      ),
    );
  }

  @override
  List<Widget> buildSlivers(
    BuildContext context,
    double maxWidth,
    EdgeInsetsGeometry horizontalPadding,
  ) {
    final surface = Theme.of(context).colorScheme.surface;

    return [
      SliverPadding(
        padding: horizontalPadding,
        sliver: SliverPersistentHeader(
          pinned: false,
          delegate: _PinnedHeaderDelegate(
            height: 56,
            maxWidth: maxWidth,
            backgroundColor: surface,
            child: header,
          ),
        ),
      ),
      SliverPadding(
        padding: horizontalPadding,
        sliver: SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: _ScheduleGroupCard(
                group: group,
                onOpenDetails: onOpenDetails,
                onToggleEnabled: onToggleEnabled,
                pendingToggleIds: pendingToggleIds,
                highlightClassId: highlightClassId,
                showHeader: false,
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

class _ScheduleGroupCard extends StatelessWidget {
  const _ScheduleGroupCard({
    required this.group,
    required this.onOpenDetails,
    required this.onToggleEnabled,
    required this.pendingToggleIds,
    this.highlightClassId,
    this.showHeader = true,
  });

  final DayGroup group;
  final void Function(sched.ClassItem item) onOpenDetails;
  final void Function(sched.ClassItem item, bool enable) onToggleEnabled;
  final Set<int> pendingToggleIds;
  final int? highlightClassId;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final background = elevatedCardBackground(theme, solid: true);
    final borderColor = elevatedCardBorder(theme, solid: true);
    final shadowColor = colors.outline.withValues(alpha: 0.08);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: theme.brightness == Brightness.dark
            ? const []
            : [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 18,
                  offset: const Offset(0, 14),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Text(
              group.label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
          ],
          for (var i = 0; i < group.items.length; i++) ...[
            _ScheduleRow(
              item: group.items[i],
              isLast: i == group.items.length - 1,
              highlight: highlightClassId == group.items[i].id,
              onOpenDetails: () => onOpenDetails(group.items[i]),
              onToggleEnabled: (enable) =>
                  onToggleEnabled(group.items[i], enable),
              toggleBusy: pendingToggleIds.contains(group.items[i].id),
            ),
            if (i != group.items.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ScheduleSummaryCard extends StatelessWidget {
  const _ScheduleSummaryCard({
    required this.summary,
    required this.now,
    required this.onAddClass,
    required this.onScanCard,
    required this.menuButton,
  });

  final _ScheduleSummary summary;
  final DateTime now;
  final VoidCallback onAddClass;
  final VoidCallback onScanCard;
  final Widget menuButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final cardBackground = elevatedCardBackground(theme);
    final borderColor = elevatedCardBorder(theme);
    final highlight = summary.highlight;

    final card = CardX(
      padding: const EdgeInsets.all(20),
      backgroundColor: cardBackground,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedules overview',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _dayOfWeekFormat.format(now),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                height: 36,
                width: 36,
                child: Center(child: menuButton),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (highlight != null) ...[
            _ScheduleHighlightHero(highlight: highlight, now: now),
            const SizedBox(height: 18),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: AppTokens.radius.lg,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.self_improvement_outlined,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No schedules yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Scan your student card or add a class manually to import your timetable.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          Row(
            children: [
              Expanded(
                child: _ScheduleMetricChip(
                  icon: Icons.class_outlined,
                  tint: colors.primary,
                  label: 'Scheduled',
                  value: summary.total,
                  caption: '${summary.active} active',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ScheduleMetricChip(
                  icon: Icons.toggle_off_outlined,
                  tint: colors.error,
                  label: 'Disabled',
                  value: summary.disabled,
                  caption: summary.disabled == 0
                      ? 'All sessions live'
                      : 'Temporarily hidden',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ScheduleMetricChip(
                  icon: Icons.edit_note_outlined,
                  tint: colors.tertiary,
                  label: 'Custom',
                  value: summary.custom,
                  caption: summary.custom == 0
                      ? 'Synced only'
                      : 'Includes custom classes',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onAddClass,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTokens.radius.xl,
                    ),
                  ),
                  child: const Text('Add class'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onScanCard,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTokens.radius.xl,
                    ),
                  ),
                  child: const Text('Scan student card'),
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

class _ScheduleHighlightHero extends StatelessWidget {
  const _ScheduleHighlightHero({
    required this.highlight,
    required this.now,
  });

  final _ScheduleHighlight highlight;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final item = highlight.item;
    final rawTitle = (item.title ?? item.code ?? '').trim();
    final subject = rawTitle.isEmpty ? 'Upcoming class' : rawTitle;
    final location = (item.room ?? '').trim();
    final instructor = (item.instructor ?? '').trim();
    final instructorAvatar = (item.instructorAvatar ?? '').trim();
    final hasInstructor = instructor.isNotEmpty;
    final isLive = highlight.status == _ScheduleHighlightStatus.ongoing;
    final statusLabel = isLive ? 'Happening now' : 'Up next';
    final badgeLabel = isLive ? 'Live' : 'Next';
    final timeLabel =
        '${DateFormat('h:mm a').format(highlight.start)} - ${DateFormat('h:mm a').format(highlight.end)}';
    final dateLabel = DateFormat('EEE, MMM d').format(highlight.start);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = colors.primary;
    final gradient = [
      baseColor.withValues(alpha: isDark ? 0.85 : 0.95),
      baseColor.withValues(alpha: isDark ? 0.65 : 0.7),
    ];
    final shadowColor = baseColor.withValues(alpha: isDark ? 0.32 : 0.22);
    final foreground = colors.onPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: AppTokens.radius.lg,
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
              _ScheduleHeroChip(
                icon: isLive
                    ? Icons.play_arrow_rounded
                    : Icons.arrow_forward_rounded,
                label: statusLabel,
                background: foreground.withValues(alpha: 0.16),
                foreground: foreground.withValues(alpha: 0.9),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: foreground.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.flash_on_rounded,
                      size: 18,
                      color: foreground.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      badgeLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: foreground.withValues(alpha: 0.85),
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
              color: foreground,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: foreground.withValues(alpha: 0.78),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  timeLabel,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: foreground,
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
                color: foreground.withValues(alpha: 0.75),
              ),
              const SizedBox(width: 6),
              Text(
                dateLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: foreground.withValues(alpha: 0.78),
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
                  color: foreground.withValues(alpha: 0.76),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    location,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: foreground.withValues(alpha: 0.82),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (hasInstructor) ...[
            const SizedBox(height: 14),
            _ScheduleInstructorRow(
              name: instructor,
              avatarUrl: instructorAvatar.isEmpty ? null : instructorAvatar,
              tint: foreground,
              inverse: true,
              dense: false,
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleHeroChip extends StatelessWidget {
  const _ScheduleHeroChip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleMetricChip extends StatelessWidget {
  const _ScheduleMetricChip({
    required this.icon,
    required this.tint,
    required this.label,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final Color tint;
  final String label;
  final int value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = tint.withValues(alpha: isDark ? 0.20 : 0.10);
    final border = tint.withValues(alpha: isDark ? 0.28 : 0.18);
    final iconBackground = tint.withValues(alpha: isDark ? 0.22 : 0.16);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppTokens.radius.lg,
        border: Border.all(color: border),
      ),
      constraints: const BoxConstraints(minHeight: 132),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: tint.withValues(alpha: 0.95),
              size: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'SFProRounded',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            caption,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
              fontSize: 14,
            ),
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.fade,
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.item,
    required this.isLast,
    required this.highlight,
    required this.onOpenDetails,
    required this.onToggleEnabled,
    required this.toggleBusy,
  });

  final sched.ClassItem item;
  final bool isLast;
  final bool highlight;
  final VoidCallback onOpenDetails;
  final void Function(bool enable) onToggleEnabled;
  final bool toggleBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final nextStart = _nextOccurrence(item, now);
    final nextEnd = _endFor(item, nextStart);
    final rawSubject = ((item.title ?? item.code ?? '').trim());
    final subjectText = rawSubject.isEmpty ? 'Class ${item.id}' : rawSubject;
    final location = (item.room ?? '').trim();
    final instructor = (item.instructor ?? '').trim();
    final instructorAvatar = (item.instructorAvatar ?? '').trim();
    final disabled = !item.enabled;
    final timeLabel =
        '${DateFormat('h:mm a').format(nextStart)} - ${DateFormat('h:mm a').format(nextEnd)}';

    String? statusLabel;
    IconData? statusIcon;
    Color statusForeground = colors.onSurfaceVariant;
    Color statusBackground = colors.surfaceContainerHigh;

    if (disabled) {
      statusLabel = 'Hidden';
      statusIcon = Icons.visibility_off_outlined;
      statusForeground = colors.error;
      statusBackground = colors.error.withValues(alpha: 0.12);
    } else if (nextEnd.isBefore(now)) {
      statusLabel = 'Done';
      statusIcon = Icons.check_rounded;
      statusForeground = colors.tertiary;
      statusBackground = colors.tertiary.withValues(alpha: 0.16);
    } else if (!nextStart.isAfter(now) && nextEnd.isAfter(now)) {
      statusLabel = 'In progress';
      statusIcon = Icons.play_arrow_rounded;
      statusForeground = colors.primary;
      statusBackground = colors.primary.withValues(alpha: 0.16);
    } else if (highlight) {
      statusLabel = 'Next';
      statusIcon = Icons.arrow_forward_rounded;
      statusForeground = colors.primary;
      statusBackground = colors.primary.withValues(alpha: 0.12);
    }

    final isHidden = !item.enabled;
    final isNext = highlight && !disabled && nextStart.isAfter(now);
    final nextBackground = Color.alphaBlend(
      colors.primary.withValues(alpha: isDark ? 0.18 : 0.12),
      isDark ? colors.surfaceContainerHighest : colors.surface,
    );
    final background = isNext ? nextBackground : colors.surfaceContainerHigh;
    final border = isNext
        ? colors.primary.withValues(alpha: isDark ? 0.32 : 0.26)
        : colors.outlineVariant.withValues(alpha: 0.24);
    final capsuleColor = isHidden
        ? colors.error.withValues(alpha: 0.12)
        : colors.primary.withValues(alpha: 0.14);
    final capsuleTextColor = isHidden ? colors.error : colors.primary;
    final overlayBase =
        isHidden ? colors.error : colors.primary.withValues(alpha: 0.8);
    final applyOverlay = !highlight && !isHidden;
    final highlightOverlay =
        applyOverlay ? overlayBase.withValues(alpha: 0.08) : Colors.transparent;
    final splashOverlay =
        applyOverlay ? overlayBase.withValues(alpha: 0.12) : Colors.transparent;

    String? leadBadgeLabel;
    final Color leadBadgeColor = colors.primary;
    if (!disabled) {
      if (!nextStart.isAfter(now) && nextEnd.isAfter(now)) {
        leadBadgeLabel = 'Live';
      } else if (highlight) {
        leadBadgeLabel = 'Next';
      }
    }
    final shouldShowTrailingStatus =
        statusLabel != null && leadBadgeLabel == null;
    final shadowColor = isNext
        ? colors.primary.withValues(alpha: isDark ? 0.26 : 0.18)
        : colors.outline.withValues(alpha: 0.08);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenDetails,
        borderRadius: AppTokens.radius.lg,
        splashColor: splashOverlay,
        highlightColor: highlightOverlay,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppTokens.radius.lg,
            border: Border.all(color: border),
            boxShadow: [
              if (!isHidden)
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 18,
                  offset: const Offset(0, 14),
                ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadBadgeLabel != null) ...[
                    _ScheduleLeadBadge(
                      label: leadBadgeLabel,
                      color: leadBadgeColor,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: capsuleColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('EEE').format(nextStart).toUpperCase(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: capsuleTextColor,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d').format(nextStart),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                colors.onSurfaceVariant.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subjectText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        decoration: nextEnd.isBefore(now)
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color:
                              colors.onSurfaceVariant.withValues(alpha: 0.68),
                        ),
                      ),
                    ],
                    if (instructor.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _ScheduleInstructorRow(
                        name: instructor,
                        avatarUrl:
                            instructorAvatar.isEmpty ? null : instructorAvatar,
                        tint: colors.primary,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (shouldShowTrailingStatus)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ScheduleStatusChip(
                        icon: statusIcon ?? Icons.schedule_rounded,
                        label: statusLabel,
                        background: statusBackground,
                        foreground: statusForeground,
                      ),
                    ),
                  Switch.adaptive(
                    value: !disabled,
                    onChanged: toggleBusy ? null : onToggleEnabled,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleStatusChip extends StatelessWidget {
  const _ScheduleStatusChip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleLeadBadge extends StatelessWidget {
  const _ScheduleLeadBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.28 : 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: color,
        ),
      ),
    );
  }
}

class _ScheduleInstructorRow extends StatelessWidget {
  const _ScheduleInstructorRow({
    required this.name,
    required this.tint,
    this.avatarUrl,
    this.inverse = false,
    this.dense = true,
  });

  final String name;
  final Color tint;
  final String? avatarUrl;
  final bool inverse;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle =
        (dense ? theme.textTheme.bodyMedium : theme.textTheme.bodyLarge)
            ?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: dense ? 15 : 16,
      color: inverse
          ? Colors.white.withValues(alpha: 0.95)
          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
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

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedHeaderDelegate({
    required this.child,
    required this.height,
    required this.maxWidth,
    required this.backgroundColor,
  });

  final Widget child;
  final double height;
  final double maxWidth;
  final Color backgroundColor;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return child != oldDelegate.child ||
        height != oldDelegate.height ||
        maxWidth != oldDelegate.maxWidth ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
