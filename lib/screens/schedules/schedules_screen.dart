import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes.dart';
import '../../services/notification_scheduler.dart';
import '../../services/schedule_repository.dart' as sched;
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';
import '../../utils/nav.dart';
import 'add_class_screen.dart';
import '../scan/scan_options_screen.dart';
import '../scan/scan_preview_screen.dart';
import '../scan/schedule_import_screen.dart';
import 'schedules_cards.dart';
import 'schedules_controller.dart';
import 'schedules_data.dart';
import 'schedules_messages.dart';

class SchedulesPage extends StatefulWidget {
  SchedulesPage({
    super.key,
    sched.ScheduleApi? api,
    this.onAddClass,
    this.onScan,
    this.connectivityOverride,
  }) : api = api ?? sched.ScheduleApi();

  final sched.ScheduleApi api;
  final Future<bool?> Function()? onAddClass;
  final Future<void> Function()? onScan;
  final Future<bool> Function()? connectivityOverride;

  @override
  SchedulesPageState createState() => SchedulesPageState();
}

class SchedulesPageState extends State<SchedulesPage> with RouteAware {
  late final SchedulesController _controller;
  PageRoute<dynamic>? _routeSubscription;

  /// Keys for each day section - used to scroll into view after adding a class
  final Map<int, GlobalKey> _dayKeys = {};

  /// Day (1-7) to highlight after adding a new class. Cleared after scroll.
  int? _highlightDay;

  /// Get or create a GlobalKey for a specific day
  GlobalKey _keyForDay(int day) => _dayKeys.putIfAbsent(day, () => GlobalKey());

  @override
  void initState() {
    super.initState();
    _controller = SchedulesController(
      api: widget.api,
      connectivityOverride: widget.connectivityOverride,
    );
    _dismissKeyboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_routeSubscription != null) {
      routeObserver.unsubscribe(this);
      _routeSubscription = null;
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute && route != _routeSubscription) {
      if (_routeSubscription != null) {
        routeObserver.unsubscribe(this);
      }
      _routeSubscription = route;
      routeObserver.subscribe(this, route);
    }
  }

  void _dismissKeyboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  Future<void> refreshOnTabVisit() {
    return _controller.refresh();
  }

  Future<void> reload({bool silent = false}) {
    return _controller.load(silent: silent);
  }

  Future<void> _openAccount() async {
    await context.push(AppRoutes.account);
    if (!mounted) return;
    await _controller.loadProfile(refresh: true);
  }

  Future<void> _openAddClass({sched.ClassItem? initial}) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (initial == null && widget.onAddClass != null) {
      final created = await widget.onAddClass!.call();
      if (!mounted) return;
      if (created == true) {
        _controller.dirty = true;
        await _controller.refresh();
        await _controller.refresh(); // Double refresh as in original?
      }
      return;
    }

    // Returns the day (1-7) of the added/edited class, or null if cancelled
    final addedDay = await AppModal.sheet<int?>(
      context: context,
      builder: (_) => AddClassSheet(api: widget.api, initialClass: initial),
    );
    if (!mounted) return;
    if (addedDay != null) {
      _controller.dirty = true;
      await _controller.refresh();
      // Set highlight and scroll to the newly added class
      _scrollToAddedClass(addedDay);
    }
  }

  void _scrollToAddedClass(int day) {
    setState(() => _highlightDay = day);
    // Wait for the next frame so the list is rebuilt with the new data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final dayKey = _dayKeys[day];
      final keyContext = dayKey?.currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          duration: AppTokens.motion.slow,
          curve: Curves.easeOutCubic,
          alignment: 0.5, // Center the day section on screen
        );
      }
      // Clear highlight after duration
      Future.delayed(AppTokens.durations.highlightDuration, () {
        if (mounted && _highlightDay == day) {
          setState(() => _highlightDay = null);
        }
      });
    });
  }

  Future<void> _openScanOptions() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (widget.onScan != null) {
      await widget.onScan!.call();
      return;
    }
    while (mounted) {
      if (!mounted) return;
      final path = await AppModal.sheet<String?>(
        context: context,
        builder: (_) => const ScanOptionsSheet(),
      );
      if (!mounted || path == null) return;

      if (!mounted) return;
      final preview = await AppModal.sheet<ScanPreviewOutcome?>(
        context: context,
        builder: (_) => ScanPreviewSheet(imagePath: path),
      );
      if (!mounted) return;
      if (preview == null) return;
      if (preview.retake) {
        continue;
      }
      if (!preview.isSuccess) return;

      if (!mounted) return;
      final outcome = await AppModal.sheet<ScheduleImportOutcome?>(
        context: context,
        builder: (_) => SchedulesPreviewSheet(
          imagePath: preview.imagePath!,
          section: preview.section!,
          classes: preview.classes,
        ),
      );
      if (!mounted) return;
      if (outcome == null) return;
      if (outcome.retake) {
        continue;
      }
      if (outcome.imported) {
        _controller.dirty = true;
        await _controller.refresh();
        _notify(
          'Schedule imported successfully.',
          type: AppSnackBarType.success,
        );
      }
      return;
    }
  }

  Future<void> _openClassDetails(sched.ClassItem item) async {
    final initial = _controller.classes.firstWhere(
      (element) => element.id == item.id,
      orElse: () => item,
    );
    await AppModal.sheet<void>(
      context: context,
      builder: (_) => ClassDetailsSheet(
        api: widget.api,
        item: initial,
        isInstructor: _controller.isInstructor,
        onDetailsChanged: (details) async {
          _controller.applyClassEnabled(details.id, details.enabled);
          await NotifScheduler.resync(api: widget.api);
        },
        onEditCustom: initial.isCustom
            ? (details) async {
                final editable = sched.ClassItem(
                  id: details.id,
                  day: details.day,
                  start: details.start,
                  end: details.end,
                  title: details.title,
                  code: details.code,
                  units: details.units,
                  room: details.room,
                  instructor: details.instructorName,
                  instructorAvatar: details.instructorAvatar,
                  enabled: details.enabled,
                  isCustom: true,
                );
                await _openAddClass(initial: editable);
              }
            : null,
        onDeleteCustom: initial.isCustom
            ? (details) async {
                await _controller.deleteCustom(
                  details.id,
                  onSuccess: (msg) =>
                      _notify(msg, type: AppSnackBarType.success),
                  onError: (err) => _notify(err, type: AppSnackBarType.error),
                );
              }
            : null,
      ),
    );
  }

  void _openInstructorFinder(BuildContext context) {
    AppModal.sheet<void>(
      context: context,
      builder: (_) => const InstructorFinderSheet(),
    );
  }

  void _notify(
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
  }) {
    if (!mounted) return;
    showAppSnackBar(context, message, type: type);
  }

  Widget _buildActionsMenu(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    return AppPopupMenuButton<ScheduleAction>(
      key: const ValueKey('schedule-actions-menu'),
      onSelected: (action) => _handleAction(action),
      itemBuilder: (context) => [
        AppPopupMenuItem<ScheduleAction>(
          key: const ValueKey('schedule-export-pdf-item'),
          value: ScheduleAction.pdf,
          icon: Icons.picture_as_pdf_outlined,
          label: 'Export as PDF',
          tint: palette.danger,
        ),
        AppPopupMenuItem<ScheduleAction>(
          key: const ValueKey('schedule-export-csv-item'),
          value: ScheduleAction.csv,
          icon: Icons.table_chart_outlined,
          label: 'Export as CSV',
          tint: colors.tertiary,
        ),
        const AppPopupMenuDivider<ScheduleAction>(),
        if (!_controller.isInstructor)
          AppPopupMenuItem<ScheduleAction>(
            key: const ValueKey('schedule-find-instructor-item'),
            value: ScheduleAction.findInstructor,
            icon: Icons.search_rounded,
            label: 'Find instructor',
            tint: colors.secondary,
          ),
        AppPopupMenuItem<ScheduleAction>(
          value: ScheduleAction.reset,
          icon: Icons.restart_alt_rounded,
          label: 'Reset schedules',
          tint: palette.danger,
        ),
      ],
    );
  }

  Future<void> _handleAction(ScheduleAction action) async {
    if (action == ScheduleAction.reset) {
      await _confirmResetSchedules();
      return;
    }
    if (action == ScheduleAction.findInstructor) {
      _openInstructorFinder(context);
      return;
    }
    await _controller.handleExportAction(
      action,
      onInfo: (msg) => _notify(msg),
    );
  }

  Future<void> _confirmResetSchedules() async {
    if (_controller.loading) return;
    final confirm = await AppModal.confirm(
      context: context,
      title: 'Reset schedules?',
      message:
          'This will remove all linked classes and custom additions for this account. You can rescan or sync again later.',
      confirmLabel: 'Reset',
      isDanger: true,
    );
    if (confirm != true) return;

    await _controller.resetSchedules(
      onSuccess: (msg) => _notify(msg, type: AppSnackBarType.success),
      onError: (err) => _notify(err, type: AppSnackBarType.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final media = MediaQuery.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final hero = ScreenBrandHeader(
          name: _controller.profileName,
          email: _controller.profileEmail,
          avatarUrl: _controller.profileAvatar,
          onAccountTap: _openAccount,
          showChevron: false,
          loading: !_controller.profileHydrated,
        );
        final shellPadding = spacing.edgeInsetsOnly(
          left: spacing.xl,
          right: spacing.xl,
          top: media.padding.top + spacing.xxxl,
          bottom: spacing.quad + AppLayout.bottomNavSafePadding,
        );

        if (_controller.loading && _controller.classes.isEmpty) {
          return ScreenShell(
            screenName: 'schedules',
            hero: hero,
            sections: [
              const ScreenSection(
                decorated: false,
                child: SkeletonDashboardCard(),
              ),
              ScreenSection(
                decorated: false,
                child: SizedBox(height: spacing.lg),
              ),
              const ScreenSection(
                decorated: false,
                child: SkeletonScheduleSection(),
              ),
            ],
            padding: shellPadding,
            onRefresh: () => _controller.refresh(),
            refreshColor: colors.primary,
            safeArea: false,
            cacheExtent: AppLayout.listCacheExtent,
          );
        }

        final now = DateTime.now();
        final summary = ScheduleSummary.resolve(_controller.classes, now);
        final groups = _controller.groupedDays();

        final sections = <Widget>[];

        if (_controller.criticalError != null && _controller.classes.isEmpty) {
          sections.add(
            ScreenSection(
              decorated: false,
              child: StateDisplay(
                variant: StateVariant.error,
                title: 'Schedule not loaded',
                message: _controller.criticalError!,
                primaryActionLabel: 'Retry',
                onPrimaryAction: () => _controller.load(silent: false),
                secondaryActionLabel: 'Scan student card',
                onSecondaryAction: _openScanOptions,
                compact: true,
              ),
            ),
          );
        } else {
          if (_controller.offlineFallback) {
            sections.add(
              ScreenSection(
                decorated: false,
                child: OfflineBanner(
                  key: const ValueKey('offline-cache-banner'),
                  lastSynced: _controller.lastFetchedAt,
                ),
              ),
            );
          }

          if (_controller.retrySuggested) {
            sections.add(
              ScreenSection(
                decorated: false,
                child: MessageCard(
                  icon: Icons.sync_problem_outlined,
                  title: 'Almost caught up',
                  message:
                      'A network hiccup interrupted the last sync. Retry to fetch the latest classes.',
                  primaryLabel: 'Retry sync',
                  onPrimary: () => _controller.refresh(),
                  secondaryLabel: 'Scan card',
                  onSecondary: _openScanOptions,
                  tintColor: colors.primary,
                ),
              ),
            );
          }

          if (_controller.exportError != null &&
              _controller.pendingExport != null) {
            sections.add(
              ScreenSection(
                decorated: false,
                child: MessageCard(
                  icon: Icons.block,
                  title: 'Export unavailable',
                  message: _controller.exportError!,
                  primaryLabel: 'Try again',
                  onPrimary: () => _controller.retryPendingExport(
                    onInfo: (msg) => _notify(msg),
                  ),
                  tintColor: palette.danger,
                ),
              ),
            );
          }

          sections.add(
            ScreenSection(
              decorated: false,
              child: ScheduleSummaryCard(
                summary: summary,
                now: now,
                onAddClass: () => _openAddClass(),
                onScanCard: _openScanOptions,
                menuButton: _buildActionsMenu(context),
                isInstructor: _controller.isInstructor,
              ),
            ),
          );

          if (_controller.classes.isNotEmpty) {
            // Unified card container for class list - matches dashboard style
            sections.add(
              ScreenSection(
                decorated: false,
                child: ScheduleClassListCard(
                  groups: groups,
                  now: now,
                  highlightClassId: summary.highlight?.item.id,
                  highlightDay: _highlightDay,
                  dayKeyBuilder: _keyForDay,
                  onOpenDetails: _openClassDetails,
                  onToggleEnabled: (item, enable) {
                    _controller.toggleClassEnabled(
                      item,
                      enable,
                      onError: (msg) =>
                          _notify(msg, type: AppSnackBarType.error),
                    );
                  },
                  pendingToggleIds: _controller.pendingToggleClassIds,
                  onDelete: (id) => _controller.deleteCustom(
                    id,
                    onSuccess: (msg) =>
                        _notify(msg, type: AppSnackBarType.success),
                    onError: (err) => _notify(err, type: AppSnackBarType.error),
                  ),
                  onRefresh: () => _controller.refresh(),
                  refreshing: _controller.loading,
                  searchQuery: _controller.searchQuery,
                  onSearchChanged: _controller.setSearchQuery,
                  filter: _controller.filter,
                  onFilterChanged: _controller.setFilter,
                  isInstructor: _controller.isInstructor,
                ),
              ),
            );
            sections.add(
              SizedBox(
                height: spacing.quad + media.padding.bottom + spacing.xl,
              ),
            );
          } else {
            final isDark = theme.brightness == Brightness.dark;
            sections.add(
              ScreenSection(
                decorated: false,
                child: Container(
                  padding: spacing.edgeInsetsSymmetric(
                    horizontal: spacing.xxl,
                    vertical: spacing.quad,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDark ? colors.surfaceContainerHigh : colors.surface,
                    borderRadius: AppTokens.radius.xl,
                    border: Border.all(
                      color: colors.outline.withValues(
                          alpha: isDark ? AppOpacity.overlay : AppOpacity.divider),
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
                              colors.primary
                                  .withValues(alpha: AppOpacity.medium),
                              colors.primary
                                  .withValues(alpha: AppOpacity.highlight),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.primary
                                .withValues(alpha: AppOpacity.accent),
                            width: AppTokens.componentSize.dividerThick,
                          ),
                        ),
                        child: Icon(
                          Icons.calendar_month_outlined,
                          size: spacing.quad,
                          color: colors.primary,
                        ),
                      ),
                      SizedBox(height: spacing.xxlPlus),
                      Text(
                        'No schedules yet',
                        style: AppTokens.typography.headline.copyWith(
                          fontWeight: AppTokens.fontWeight.bold,
                          letterSpacing: AppLetterSpacing.tight,
                          color: colors.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: spacing.md),
                      Text(
                        'Get started by adding your first class or scanning your student card using the buttons above',
                        style: AppTokens.typography.bodySecondary.copyWith(
                          height: AppLineHeight.body,
                          color: palette.muted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }

        if (sections.isEmpty) {
          sections.add(const SizedBox.shrink());
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            Navigator.of(context).pop(_controller.dirty);
          },
          child: ScreenShell(
            screenName: 'schedules',
            hero: hero,
            sections: sections,
            padding: shellPadding,
            onRefresh: () => _controller.refresh(),
            refreshColor: colors.primary,
            safeArea: false,
            cacheExtent: AppLayout.listCacheExtent,
            useSlivers: false,
          ),
        );
      },
    );
  }
}
