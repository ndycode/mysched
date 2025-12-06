// ignore_for_file: unnecessary_null_comparison, unused_local_variable
part of 'dashboard_screen.dart';

class _DashboardSchedulePeek extends StatelessWidget {
  const _DashboardSchedulePeek({
    required this.occurrences,
    required this.now,
    required this.scopeLabel,
    required this.onScopeChanged,
    required this.colors,
    required this.theme,
    required this.selectedScope,
    required this.searchController,
    required this.searchFocusNode,
    required this.searchActive,
    required this.onSearchTap,
    required this.onSearchClear,
    required this.onSearchChanged,
    required this.onOpenSchedules,
    required this.onAddClass,
    required this.refreshing,
    required this.onRefresh,
    required this.onViewDetails,
  });

  final List<ClassOccurrence> occurrences;
  final DateTime now;
  final String scopeLabel;
  final ValueChanged<String> onScopeChanged;
  final ColorScheme colors;
  final ThemeData theme;
  final String selectedScope;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final bool searchActive;
  final VoidCallback onSearchTap;
  final VoidCallback onSearchClear;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenSchedules;
  final VoidCallback onAddClass;
  final bool refreshing;
  final Future<void> Function() onRefresh;
  final ValueChanged<ClassItem> onViewDetails;

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim();
    final hasQuery = query.isNotEmpty;

    final upcoming = <ClassOccurrence>[];
    final completed = <ClassOccurrence>[];
    for (final occ in occurrences) {
      if (occ.end.isAfter(now) || occ.isOngoingAt(now)) {
        upcoming.add(occ);
      } else {
        completed.add(occ);
      }
    }

    final display = (selectedScope == 'This week' || selectedScope == 'All')
        ? <ClassOccurrence>[...upcoming, ...completed]
        : List<ClassOccurrence>.from(occurrences);

    final hasItems = display.isNotEmpty;
    final highlightIndex = display
        .indexWhere((occ) => occ.end.isAfter(now) || occ.isOngoingAt(now));
    final targetIndex = highlightIndex >= 0 ? highlightIndex : -1;
    final totalToShow = hasItems
        ? math.min(display.length, AppDisplayLimits.schedulePreviewCount)
        : 0;
    final displaySignature = hasItems
        ? display
            .take(totalToShow)
            .map((occ) => '${occ.item.id}-${occ.start.toIso8601String()}')
            .join('|')
        : '';

    final dateLabel = DateFormat('EEEE, MMM d').format(now);
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    return Container(
      padding: spacing.edgeInsetsAll(spacing.xxl),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(
          color: isDark
              ? colors.outline.withValues(alpha: AppOpacity.overlay)
              : colors.outline,
          width: isDark
              ? AppTokens.componentSize.divider
              : AppTokens.componentSize.dividerThin,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: AppOpacity.veryFaint),
                  blurRadius: AppTokens.shadow.lg,
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
              Container(
                height: AppTokens.componentSize.avatarXl,
                width: AppTokens.componentSize.avatarXl,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primary.withValues(alpha: AppOpacity.medium),
                      colors.primary.withValues(alpha: AppOpacity.dim),
                    ],
                  ),
                  borderRadius: AppTokens.radius.md,
                  border: Border.all(
                    color: colors.primary
                        .withValues(alpha: AppOpacity.borderEmphasis),
                    width: AppTokens.componentSize.dividerThick,
                  ),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: colors.primary,
                  size: AppTokens.iconSize.xl,
                ),
              ),
              SizedBox(width: spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$scopeLabel overview',
                      style: AppTokens.typography.title.copyWith(
                        fontWeight: AppTokens.fontWeight.extraBold,
                        letterSpacing: AppLetterSpacing.tight,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      dateLabel,
                      style: AppTokens.typography.bodySecondary.copyWith(
                        color: palette.muted,
                        fontWeight: AppTokens.fontWeight.medium,
                      ),
                    ),
                  ],
                ),
              ),
              if (onRefresh != null) ...[
                SizedBox(
                  height: AppTokens.componentSize.buttonXs,
                  width: AppTokens.componentSize.buttonXs,
                  child: IconButton(
                    onPressed: refreshing ? null : onRefresh,
                    tooltip: 'Refresh',
                    style: IconButton.styleFrom(
                      minimumSize:
                          Size.square(AppTokens.componentSize.buttonXs),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: palette.muted,
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTokens.radius.md,
                      ),
                    ),
                    icon: refreshing
                        ? SizedBox(
                            width: AppTokens.componentSize.badgeMd,
                            height: AppTokens.componentSize.badgeMd,
                            child: CircularProgressIndicator(
                              strokeWidth: AppInteraction.progressStrokeWidth,
                              valueColor:
                                  AlwaysStoppedAnimation(colors.primary),
                            ),
                          )
                        : Icon(
                            Icons.refresh_rounded,
                            size: AppTokens.iconSize.md,
                          ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: spacing.sm),
          Text(
            scopeLabel == 'Today'
                ? 'Stay on top of today\'s classes and make changes instantly.'
                : scopeLabel == 'All'
                    ? 'View all your scheduled classes at a glance.'
                    : 'Review your weekly plan, add sessions, or rescan as needed.',
            style: AppTokens.typography.caption.copyWith(
              color: palette.muted,
            ),
          ),
          SizedBox(height: spacing.xl),
          TextField(
            controller: searchController,
            focusNode: searchFocusNode,
            readOnly: !searchActive,
            onTap: onSearchTap,
            onChanged: onSearchChanged,
            onEditingComplete: () {
              searchFocusNode.unfocus();
            },
            textInputAction: TextInputAction.search,
            autocorrect: false,
            style: AppTokens.typography.body.copyWith(
              color: colors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Search classes, instructors, reminders',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchActive || searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: onSearchClear,
                    )
                  : null,
              filled: true,
              fillColor: colors.surfaceContainerHigh,
              contentPadding: spacing.edgeInsetsSymmetric(
                horizontal: spacing.mdLg,
                vertical: spacing.md,
              ),
              border: OutlineInputBorder(
                borderRadius: AppTokens.radius.lg,
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero,
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  spacing.edgeInsetsSymmetric(
                    horizontal: spacing.md,
                    vertical: spacing.md,
                  ),
                ),
                side: WidgetStateProperty.resolveWith(
                  (states) => BorderSide(
                    color: states.contains(WidgetState.selected)
                        ? colors.primary
                        : colors.outline.withValues(alpha: AppOpacity.barrier),
                    width: AppTokens.componentSize.dividerMedium,
                  ),
                ),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? colors.primary.withValues(alpha: AppOpacity.statusBg)
                      : colors.surfaceContainerHighest
                          .withValues(alpha: AppOpacity.barrier),
                ),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? colors.primary
                      : palette.muted
                          .withValues(alpha: AppOpacity.prominent),
                ),
              ),
              segments: const [
                ButtonSegment(
                  value: 'Today',
                  label: Text('Today', softWrap: false),
                ),
                ButtonSegment(
                  value: 'This week',
                  label: Text('This week', softWrap: false),
                ),
                ButtonSegment(
                  value: 'All',
                  label: Text('All', softWrap: false),
                ),
              ],
              selected: <String>{selectedScope},
              onSelectionChanged: (value) {
                if (value.isNotEmpty) onScopeChanged(value.first);
              },
            ),
          ),
          SizedBox(height: spacing.md),
          AnimatedSize(
            duration: AppMotionSystem.medium,
            curve: AppMotionSystem.easeOut,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: AppMotionSystem.standard,
              switchInCurve: AppMotionSystem.easeOut,
              switchOutCurve: AppMotionSystem.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: AppShadowOffset.slideIn,
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: hasItems
                  ? Column(
                      key: ValueKey(
                        'list-$selectedScope-$query-$displaySignature',
                      ),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._buildScheduleList(
                          context: context,
                          display: display,
                          totalToShow: totalToShow,
                          upcomingCount: upcoming.length,
                          targetIndex: targetIndex,
                          now: now,
                          onOccurrenceTap: (occ) => onViewDetails(occ.item),
                        ),
                        if (display.length > totalToShow) ...[
                          SizedBox(height: spacing.md),
                          Text(
                            '+${display.length - totalToShow} more class'
                            '${display.length - totalToShow == 1 ? '' : 'es'} in scope',
                            style: AppTokens.typography.body.copyWith(
                              color: palette.muted,
                            ),
                          ),
                        ],
                      ],
                    )
                  : Container(
                      key: ValueKey('empty-$selectedScope-$query'),
                      width: double.infinity,
                      padding: spacing.edgeInsetsAll(spacing.xxl),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colors.surfaceContainerHighest
                                .withValues(alpha: AppOpacity.divider)
                            : colors.primary
                                .withValues(alpha: AppOpacity.micro),
                        borderRadius: AppTokens.radius.lg,
                        border: Border.all(
                          color: isDark
                              ? colors.outline
                                  .withValues(alpha: AppOpacity.overlay)
                              : colors.primary
                                  .withValues(alpha: AppOpacity.dim),
                          width: AppTokens.componentSize.divider,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: spacing.edgeInsetsAll(spacing.lg),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? colors.primary
                                      .withValues(alpha: AppOpacity.medium)
                                  : colors.primary
                                      .withValues(alpha: AppOpacity.dim),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              hasQuery
                                  ? Icons.search_off_rounded
                                  : Icons.event_available_outlined,
                              size: AppTokens.iconSize.xxl,
                              color: colors.primary,
                            ),
                          ),
                          SizedBox(height: spacing.xl),
                          Text(
                            hasQuery
                                ? 'No matches found'
                                : selectedScope == 'Today'
                                    ? 'No classes today'
                                    : selectedScope == 'All'
                                        ? 'No classes yet'
                                        : 'No classes this week',
                            style: AppTokens.typography.subtitle.copyWith(
                              fontWeight: AppTokens.fontWeight.bold,
                              color: palette.muted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: spacing.sm),
                          Text(
                            hasQuery
                                ? 'Try a different name, classroom, or scope.'
                                : 'Switch filters or add a class from Review schedule.',
                            style: AppTokens.typography.bodySecondary.copyWith(
                              color: palette.muted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          SizedBox(height: spacing.lgPlus),
          _buildReviewButton(),
        ],
      ),
    );
  }

  List<Widget> _buildScheduleList({
    required BuildContext context,
    required List<ClassOccurrence> display,
    required int totalToShow,
    required int upcomingCount,
    required int targetIndex,
    required DateTime now,
    required ValueChanged<ClassOccurrence> onOccurrenceTap,
  }) {
    final widgets = <Widget>[];
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final dividerColor = colors.outlineVariant.withValues(
      alpha: theme.brightness == Brightness.dark
          ? AppOpacity.border
          : AppOpacity.overlay,
    );

    Widget buildSectionHeader(
        String label, Color color, IconData icon, int count) {
      final isDark = theme.brightness == Brightness.dark;
      return Padding(
        padding: spacing.edgeInsetsOnly(bottom: spacing.md),
        child: Container(
          padding: spacing.edgeInsetsAll(spacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: AppOpacity.dim),
                color.withValues(alpha: AppOpacity.veryFaint),
              ],
            ),
            borderRadius: AppTokens.radius.md,
            border: Border.all(
              color: color.withValues(alpha: AppOpacity.accent),
              width: AppTokens.componentSize.divider,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: spacing.edgeInsetsAll(spacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: AppOpacity.medium),
                  borderRadius: AppTokens.radius.sm,
                ),
                child: Icon(
                  icon,
                  size: AppTokens.iconSize.sm,
                  color: color,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTokens.typography.subtitle.copyWith(
                    fontWeight: AppTokens.fontWeight.extraBold,
                    letterSpacing: AppLetterSpacing.snug,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Container(
                padding: spacing.edgeInsetsSymmetric(
                  horizontal: spacing.smMd,
                  vertical: spacing.xsHalf,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: AppOpacity.overlay),
                  borderRadius: AppTokens.radius.sm,
                ),
                child: Text(
                  '$count ${count == 1 ? 'class' : 'classes'}',
                  style: AppTokens.typography.caption.copyWith(
                    fontWeight: AppTokens.fontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    for (var i = 0; i < totalToShow; i++) {
      if (selectedScope == 'This week') {
        if (i == 0 && upcomingCount > 0) {
          widgets.add(
            buildSectionHeader(
              'Upcoming',
              colors.primary,
              Icons.calendar_today_rounded,
              upcomingCount,
            ),
          );
        }
        if (i == upcomingCount && upcomingCount < display.length) {
          widgets.add(
            buildSectionHeader(
              'Completed',
              palette.muted,
              Icons.task_alt_rounded,
              display.length - upcomingCount,
            ),
          );
        }
      }

      widgets.add(
        _ScheduleRow(
          occurrence: display[i],
          highlight: i == targetIndex,
          now: now,
          onTap: () => onOccurrenceTap(display[i]),
        ),
      );

      if (i != totalToShow - 1) {
        widgets.add(
            SizedBox(height: AppTokens.spacing.sm + AppTokens.spacing.micro));
      }
    }

    return widgets;
  }

  Widget _buildReviewButton() {
    final spacing = AppTokens.spacing;
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            label: 'Add class',
            onPressed: refreshing ? null : onAddClass,
            minHeight: AppTokens.componentSize.buttonMd,
            expanded: true,
          ),
        ),
        SizedBox(width: spacing.md),
        Expanded(
          child: SecondaryButton(
            label: 'Schedules',
            onPressed: refreshing ? null : onOpenSchedules,
            minHeight: AppTokens.componentSize.buttonMd,
            expanded: true,
          ),
        ),
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.occurrence,
    required this.highlight,
    required this.now,
    required this.onTap,
  });

  final ClassOccurrence occurrence;
  final bool highlight;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final item = occurrence.item;
    final subject = item.subject;
    final location = item.room.trim();
    final instructor = item.instructor.trim();
    final instructorAvatar = (item.instructorAvatar ?? '').trim();
    final isCustom = item.isCustom;

    final isOngoing = occurrence.isOngoingAt(now);
    final isPast = occurrence.end.isBefore(now);
    final isNext = highlight && !isOngoing && !isPast;
    final isDisabled = !item.enabled;

    final timeFormat = DateFormat('h:mm a');
    final timeRange =
        '${timeFormat.format(occurrence.start)} - ${timeFormat.format(occurrence.end)}';

    // Build metadata items
    final metadata = <MetadataItem>[
      MetadataItem(icon: Icons.access_time_rounded, label: timeRange),
      if (location.isNotEmpty)
        MetadataItem(
            icon: Icons.location_on_outlined, label: location, expanded: true),
    ];

    // Build status badge
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    StatusBadge? badge;
    if (isOngoing) {
      badge = StatusBadge(
        label: StatusBadgeVariant.live.label,
        variant: StatusBadgeVariant.live,
      );
    } else if (isNext) {
      badge = StatusBadge(
        label: StatusBadgeVariant.next.label,
        variant: StatusBadgeVariant.next,
      );
    } else if (isPast) {
      badge = StatusBadge(
        label: StatusBadgeVariant.done.label,
        variant: StatusBadgeVariant.done,
      );
    }

    return EntityTile(
      title: subject,
      isActive: !isDisabled,
      isStrikethrough: isPast || isDisabled,
      isHighlighted: isOngoing,
      metadata: metadata,
      badge: badge,
      tags: isCustom && !isDisabled
          ? [
              StatusBadge(
                label: StatusBadgeVariant.custom.label,
                variant: StatusBadgeVariant.custom,
                compact: true,
              ),
            ]
          : const [],
      bottomContent: instructor.isNotEmpty
          ? InstructorRow(
              name: instructor,
              avatarUrl: instructorAvatar.isNotEmpty ? instructorAvatar : null,
            )
          : null,
      onTap: onTap,
    );
  }
}
