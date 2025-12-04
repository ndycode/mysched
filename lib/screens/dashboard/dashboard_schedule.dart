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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? colors.outline.withValues(alpha: 0.12) : const Color(0xFFE5E5E5),
          width: isDark ? 1 : 0.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
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
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primary.withValues(alpha: 0.15),
                      colors.primary.withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: colors.primary,
                  size: 26,
                ),
              ),
              SizedBox(width: spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$scopeLabel overview',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 21,
                        letterSpacing: -0.5,
                        color: isDark ? colors.onSurface : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? colors.onSurfaceVariant.withValues(alpha: 0.75) : const Color(0xFF757575),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onRefresh != null) ...[
                SizedBox(
                  height: 36,
                  width: 36,
                  child: IconButton(
                    onPressed: refreshing ? null : onRefresh,
                    icon: refreshing
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(colors.primary),
                            ),
                          )
                        : Icon(
                            Icons.refresh_rounded,
                            color: isDark ? colors.onSurfaceVariant.withValues(alpha: 0.9) : const Color(0xFF757575),
                            size: 20,
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
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.78),
              fontSize: 14,
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
                          SizedBox(height: spacing.md),
                          Text(
                            '+${display.length - totalToShow} more class'
                            '${display.length - totalToShow == 1 ? '' : 'es'} in scope',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    )
                  : Container(
                      key: ValueKey('empty-$selectedScope-$query'),
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark ? colors.surfaceContainerHighest.withValues(alpha: 0.4) : colors.primary.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? colors.outline.withValues(alpha: 0.12) : colors.primary.withValues(alpha: 0.10),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? colors.primary.withValues(alpha: 0.15) : colors.primary.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              hasQuery
                                  ? Icons.search_off_rounded
                                  : Icons.event_available_outlined,
                              size: 40,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            hasQuery
                                ? 'No matches found'
                                : selectedScope == 'Today'
                                    ? 'No classes today'
                                    : 'No classes this week',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: isDark ? colors.onSurfaceVariant : const Color(0xFF424242),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            hasQuery
                                ? 'Try a different name, classroom, or scope.'
                                : 'Switch filters or add a class from Review schedule.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              color: isDark ? colors.onSurfaceVariant.withValues(alpha: 0.8) : const Color(0xFF757575),
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
    final dividerColor = colors.outlineVariant.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.24 : 0.12,
    );

    Widget buildSectionHeader(String label, Color color, IconData icon, int count) {
      final isDark = theme.brightness == Brightness.dark;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.10),
                color.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: 0.20),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    letterSpacing: -0.3,
                    color: isDark ? colors.onSurface : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count ${count == 1 ? 'class' : 'classes'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
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
    final isDark = theme.brightness == Brightness.dark;
    
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

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: colors.primary.withValues(alpha: 0.05),
        highlightColor: colors.primary.withValues(alpha: 0.02),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? colors.surfaceContainerHigh : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isOngoing 
                  ? colors.primary.withValues(alpha: 0.30)
                  : isDark ? colors.outline.withValues(alpha: 0.12) : const Color(0xFFE5E5E5),
              width: isOngoing ? 1.5 : 0.5,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isOngoing ? 0.08 : 0.04),
                      blurRadius: isOngoing ? 12 : 6,
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
                        fontSize: 16,
                        letterSpacing: -0.2,
                        color: isPast
                            ? (isDark ? colors.onSurfaceVariant : const Color(0xFF9E9E9E))
                            : (isDark ? colors.onSurface : const Color(0xFF1A1A1A)),
                        decoration: isPast ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isOngoing || isNext || isPast)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOngoing
                            ? colors.primary.withValues(alpha: 0.15)
                            : isPast 
                                ? (isDark ? colors.surfaceContainerHighest : const Color(0xFFF5F5F5))
                                : colors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOngoing ? 'Live' : (isPast ? 'Done' : 'Next'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isOngoing 
                              ? colors.primary 
                              : isPast 
                                  ? (isDark ? colors.onSurfaceVariant : const Color(0xFF9E9E9E))
                                  : colors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Bottom row: Time, Location, Instructor
              Row(
                children: [
                  // Time
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: isDark ? colors.onSurfaceVariant.withValues(alpha: 0.7) : const Color(0xFF757575),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeRange,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? colors.onSurfaceVariant.withValues(alpha: 0.85) : const Color(0xFF616161),
                    ),
                  ),
                  if (location.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: isDark ? colors.onSurfaceVariant.withValues(alpha: 0.7) : const Color(0xFF757575),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? colors.onSurfaceVariant.withValues(alpha: 0.85) : const Color(0xFF616161),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              if (instructor.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (instructorAvatar.isNotEmpty)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(instructorAvatar),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            instructor[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        instructor,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? colors.onSurfaceVariant.withValues(alpha: 0.8) : const Color(0xFF757575),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
