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

    final display = selectedScope == 'This week'
        ? <ClassOccurrence>[...upcoming, ...completed]
        : List<ClassOccurrence>.from(occurrences);

    final hasItems = display.isNotEmpty;
    final highlightIndex = display
        .indexWhere((occ) => occ.end.isAfter(now) || occ.isOngoingAt(now));
    final targetIndex = highlightIndex >= 0 ? highlightIndex : -1;
    final totalToShow = hasItems ? math.min(display.length, 5) : 0;
    final displaySignature = hasItems
        ? display
            .take(totalToShow)
            .map((occ) => '${occ.item.id}-${occ.start.toIso8601String()}')
            .join('|')
        : '';

    final cardBackground = elevatedCardBackground(theme);
    final cardBorder = elevatedCardBorder(theme);
    final dateLabel = DateFormat('EEEE, MMM d').format(now);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: AppTokens.radius.xl,
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.table_rows_rounded,
                  color: colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$scopeLabel overview',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.78),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 36,
                width: 36,
                child: IconButton(
                  tooltip: 'Refresh schedules',
                  onPressed: refreshing ? null : onRefresh,
                  icon: refreshing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.refresh_rounded,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.9),
                        ),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                height: 36,
                width: 36,
                child: IconButton(
                  tooltip: 'Review schedule',
                  onPressed: onOpenSchedules,
                  icon: Icon(
                    Icons.calendar_view_week_rounded,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            scopeLabel == 'Today'
                ? 'Stay on top of today\'s classes and make changes instantly.'
                : 'Review your weekly plan, add sessions, or rescan as needed.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.78),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
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
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              side: WidgetStateProperty.resolveWith(
                (states) => BorderSide(
                  color: states.contains(WidgetState.selected)
                      ? colors.primary
                      : colors.outline.withValues(alpha: 0.45),
                  width: 1.2,
                ),
              ),
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? colors.primary.withValues(alpha: 0.14)
                    : colors.surfaceContainerHighest.withValues(alpha: 0.45),
              ),
              foregroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? colors.primary
                    : colors.onSurfaceVariant.withValues(alpha: 0.9),
              ),
            ),
            segments: const [
              ButtonSegment(
                value: 'Today',
                label: Text('Today'),
              ),
              ButtonSegment(
                value: 'This week',
                label: Text('This week'),
              ),
            ],
            selected: <String>{selectedScope},
            onSelectionChanged: (value) {
              if (value.isNotEmpty) onScopeChanged(value.first);
            },
          ),
          const SizedBox(height: 12),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
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
                          const SizedBox(height: 12),
                          Text(
                            '+${display.length - totalToShow} more class'
                            '${display.length - totalToShow == 1 ? '' : 'es'} in scope',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              color: kSummaryMuted,
                            ),
                          ),
                        ],
                      ],
                    )
                  : Column(
                      key: ValueKey('empty-$selectedScope-$query'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasQuery
                              ? 'No classes match your search.'
                              : selectedScope == 'Today'
                                  ? 'No classes scheduled today.'
                                  : 'No classes scheduled for this week.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasQuery
                              ? 'Try a different name, classroom, or scope.'
                              : 'Switch filters or add a class from Review schedule.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            color: kSummaryMuted,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 18),
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
    final dividerColor = colors.outlineVariant.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.24 : 0.12,
    );

    Widget buildSectionHeader(String label, Color textColor) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 1,
            decoration: BoxDecoration(
              color: dividerColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }

    for (var i = 0; i < totalToShow; i++) {
      if (selectedScope == 'This week') {
        if (i == 0 && upcomingCount > 0) {
          widgets.add(buildSectionHeader('Upcoming', colors.primary));
        }
        if (i == upcomingCount && upcomingCount < display.length) {
          widgets.add(
            buildSectionHeader(
              'Completed',
              colors.onSurfaceVariant,
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
        widgets.add(const SizedBox(height: 12));
      }
    }

    return widgets;
  }

  Widget _buildReviewButton() {
    return FilledButton(
      onPressed: refreshing ? null : onOpenSchedules,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.radius.xl,
        ),
        padding: AppTokens.spacing.edgeInsetsSymmetric(
          horizontal: AppTokens.spacing.lg,
          vertical: AppTokens.spacing.sm,
        ),
        foregroundColor: colors.onPrimary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Icon(Icons.event_note_rounded, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'Review schedule',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: colors.onPrimary,
              ),
            ),
          ),
        ],
      ),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final subject = occurrence.item.subject;
    final timeLabel =
        '${DateFormat('h:mm a').format(occurrence.start)} - ${DateFormat('h:mm a').format(occurrence.end)}';
    final room = occurrence.item.room.trim();
    final isOngoing = occurrence.isOngoingAt(now);
    final isPast = occurrence.end.isBefore(now);

    String? statusLabel;
    IconData? statusIcon;
    Color statusForeground = colors.onSurfaceVariant;
    Color statusBackground = colors.surfaceContainerHigh;

    if (isPast) {
      statusLabel = 'Done';
      statusIcon = Icons.check_rounded;
      statusForeground = colors.tertiary;
      statusBackground = colors.tertiary.withValues(alpha: 0.16);
    } else if (isOngoing) {
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

    final background = highlight
        ? colors.primary.withValues(alpha: 0.08)
        : colors.surfaceContainerHigh;
    final border = highlight
        ? colors.primary.withValues(alpha: 0.24)
        : colors.outline.withValues(alpha: 0.12);
    final badgeLabel = statusLabel;
    final badgeIcon = statusIcon ?? Icons.schedule_rounded;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTokens.radius.lg,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppTokens.radius.lg,
            border: Border.all(color: border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEE').format(occurrence.start).toUpperCase(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d').format(occurrence.start),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
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
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              decoration:
                                  isPast ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badgeLabel != null) ...[
                          const SizedBox(width: 12),
                          _StatusChip(
                            icon: badgeIcon,
                            label: badgeLabel,
                            background: statusBackground,
                            foreground: statusForeground,
                            compact: true,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.9),
                      ),
                    ),
                    if (room.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        room,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color:
                              colors.onSurfaceVariant.withValues(alpha: 0.68),
                        ),
                      ),
                    ],
                    if (occurrence.item.instructor.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _InstructorRow(
                        name: occurrence.item.instructor,
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
