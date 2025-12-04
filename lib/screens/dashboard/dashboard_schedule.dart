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

    final dateLabel = DateFormat('EEEE, MMM d').format(now);
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;

    return CardX(
      padding: spacing.edgeInsetsAll(spacing.xl),
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
                      colors.primary.withValues(alpha: 0.15),
                      colors.primary.withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: AppTokens.radius.md,
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.25),
                    width: 1.5,
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
                      style: AppTokens.typography.headline.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      dateLabel,
                      style: AppTokens.typography.bodySecondary.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onRefresh != null) ...[
                SizedBox(
                  height: AppTokens.componentSize.avatarMd,
                  width: AppTokens.componentSize.avatarMd,
                  child: IconButton(
                    onPressed: refreshing ? null : onRefresh,
                    icon: refreshing
                        ? SizedBox(
                            width: AppTokens.componentSize.badgeMd,
                            height: AppTokens.componentSize.badgeMd,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(colors.primary),
                            ),
                          )
                        : Icon(
                            Icons.refresh_rounded,
                            color: colors.onSurfaceVariant,
                            size: AppTokens.iconSize.md,
                          ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: spacing.md),
          Text(
            scopeLabel == 'Today'
                ? 'Stay on top of today\'s classes and make changes instantly.'
                : 'Review your weekly plan, add sessions, or rescan as needed.',
            style: AppTokens.typography.bodySecondary.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.78),
            ),
          ),
          SizedBox(height: spacing.lg),
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
                horizontal: spacing.md + 2,
                vertical: spacing.md,
              ),
              border: OutlineInputBorder(
                borderRadius: AppTokens.radius.lg,
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          Center(
            child: SegmentedButton<String>(
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                padding: WidgetStateProperty.all(
                  spacing.edgeInsetsSymmetric(
                    horizontal: spacing.xl,
                    vertical: spacing.sm + 2,
                  ),
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
                          SizedBox(height: spacing.md),
                          Text(
                            '+${display.length - totalToShow} more class'
                            '${display.length - totalToShow == 1 ? '' : 'es'} in scope',
                            style: AppTokens.typography.body.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    )
                  : Container(
                      key: ValueKey('empty-$selectedScope-$query'),
                      width: double.infinity,
                      padding: spacing.edgeInsetsAll(spacing.xxxl),
                      decoration: BoxDecoration(
                        color: isDark ? colors.surfaceContainerHighest.withValues(alpha: 0.4) : colors.primary.withValues(alpha: 0.04),
                        borderRadius: AppTokens.radius.lg,
                        border: Border.all(
                          color: isDark ? colors.outline.withValues(alpha: 0.12) : colors.primary.withValues(alpha: 0.10),
                          width: AppTokens.componentSize.divider,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: spacing.edgeInsetsAll(spacing.lg),
                            decoration: BoxDecoration(
                              color: isDark ? colors.primary.withValues(alpha: 0.15) : colors.primary.withValues(alpha: 0.10),
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
                                    : 'No classes this week',
                            style: AppTokens.typography.subtitle.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: spacing.sm),
                          Text(
                            hasQuery
                                ? 'Try a different name, classroom, or scope.'
                                : 'Switch filters or add a class from Review schedule.',
                            style: AppTokens.typography.bodySecondary.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          SizedBox(height: spacing.lg + 2),
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
    final dividerColor = colors.outlineVariant.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.24 : 0.12,
    );

    Widget buildSectionHeader(String label, Color color, IconData icon, int count) {
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
                color.withValues(alpha: 0.10),
                color.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: AppTokens.radius.md,
            border: Border.all(
              color: color.withValues(alpha: 0.20),
              width: AppTokens.componentSize.divider,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: spacing.edgeInsetsAll(spacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
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
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Container(
                padding: spacing.edgeInsetsSymmetric(
                  horizontal: spacing.md,
                  vertical: spacing.xs + 1,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppTokens.radius.sm,
                ),
                child: Text(
                  '$count ${count == 1 ? 'class' : 'classes'}',
                  style: AppTokens.typography.caption.copyWith(
                    fontWeight: FontWeight.w700,
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
              colors.onSurfaceVariant,
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
        widgets.add(SizedBox(height: AppTokens.spacing.md));
      }
    }

    return widgets;
  }

  Widget _buildReviewButton() {
    return PrimaryButton(
      label: 'Review schedule',
      onPressed: refreshing ? null : onOpenSchedules,
      minHeight: AppTokens.componentSize.buttonLg,
      expanded: true,
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
    
    final isOngoing = occurrence.isOngoingAt(now);
    final isPast = occurrence.end.isBefore(now);
    final isNext = highlight && !isOngoing && !isPast;
    
    final timeFormat = DateFormat('h:mm a');
    final timeRange = '${timeFormat.format(occurrence.start)} - ${timeFormat.format(occurrence.end)}';

    // Build metadata items
    final metadata = <MetadataItem>[
      MetadataItem(icon: Icons.access_time_rounded, label: timeRange),
      if (location.isNotEmpty)
        MetadataItem(icon: Icons.location_on_outlined, label: location, expanded: true),
    ];

    // Build status badge
    StatusBadge? badge;
    if (isOngoing) {
      badge = const StatusBadge(label: 'Live', variant: StatusBadgeVariant.live);
    } else if (isNext) {
      badge = const StatusBadge(label: 'Next', variant: StatusBadgeVariant.next);
    } else if (isPast) {
      badge = const StatusBadge(label: 'Done', variant: StatusBadgeVariant.done);
    }

    return EntityTile(
      title: subject,
      isActive: !isPast,
      isStrikethrough: isPast,
      isHighlighted: isOngoing,
      metadata: metadata,
      badge: badge,
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
