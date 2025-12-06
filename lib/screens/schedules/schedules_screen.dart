import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes.dart';
import '../../services/notif_scheduler.dart';
import '../../services/schedule_api.dart' as sched;
import '../../ui/kit/class_details_sheet.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';
import '../../utils/nav.dart';
import '../add_class_page.dart';
import '../scan_options_sheet.dart';
import '../scan_preview_sheet.dart';
import '../schedules_preview_sheet.dart';
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
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          alignment: 0.5, // Center the day section on screen
        );
      }
      // Clear highlight after 1 second
      Future.delayed(const Duration(seconds: 1), () {
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

    return PopupMenuButton<ScheduleAction>(
      key: const ValueKey('schedule-actions-menu'),
      onSelected: (action) => _handleAction(action),
      shape: RoundedRectangleBorder(
        borderRadius: AppTokens.radius.lg,
      ),
      elevation: isDark
          ? AppTokens.shadow.elevationDark
          : AppTokens.shadow.elevationLight,
      color: isDark ? colors.surfaceContainerHigh : colors.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: colors.shadow
          .withValues(alpha: isDark ? AppOpacity.divider : AppOpacity.medium),
      padding: EdgeInsets.zero,
      icon: SizedBox(
        width: AppTokens.componentSize.buttonXs,
        height: AppTokens.componentSize.buttonXs,
        child: Center(
          child: Icon(
            Icons.more_vert_rounded,
            size: AppTokens.iconSize.md,
            color: colors.onSurfaceVariant,
          ),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<ScheduleAction>(
          key: const ValueKey('schedule-export-pdf-item'),
          value: ScheduleAction.pdf,
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context, ScheduleAction.pdf),
              splashColor:
                  colors.primary.withValues(alpha: AppOpacity.highlight),
              highlightColor:
                  colors.primary.withValues(alpha: AppOpacity.micro),
              child: Padding(
                padding: AppTokens.spacing.edgeInsetsSymmetric(
                    horizontal: AppTokens.spacing.lg,
                    vertical: AppTokens.spacing.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding:
                          AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.sm),
                      decoration: BoxDecoration(
                        color:
                            colors.error.withValues(alpha: AppOpacity.overlay),
                        borderRadius: AppTokens.radius.sm,
                      ),
                      child: Icon(
                        Icons.picture_as_pdf_outlined,
                        size: AppTokens.iconSize.md,
                        color: colors.error,
                      ),
                    ),
                    SizedBox(
                        width: AppTokens.spacing.md + AppTokens.spacing.micro),
                    Flexible(
                      child: Text(
                        'Export as PDF',
                        style: AppTokens.typography.bodySecondary.copyWith(
                          fontWeight: AppTokens.fontWeight.medium,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        PopupMenuItem<ScheduleAction>(
          key: const ValueKey('schedule-export-csv-item'),
          value: ScheduleAction.csv,
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context, ScheduleAction.csv),
              splashColor:
                  colors.primary.withValues(alpha: AppOpacity.highlight),
              highlightColor:
                  colors.primary.withValues(alpha: AppOpacity.micro),
              child: Padding(
                padding: AppTokens.spacing.edgeInsetsSymmetric(
                    horizontal: AppTokens.spacing.lg,
                    vertical: AppTokens.spacing.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding:
                          AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.sm),
                      decoration: BoxDecoration(
                        color: colors.tertiary
                            .withValues(alpha: AppOpacity.overlay),
                        borderRadius: AppTokens.radius.sm,
                      ),
                      child: Icon(
                        Icons.table_chart_outlined,
                        size: AppTokens.iconSize.md,
                        color: colors.tertiary,
                      ),
                    ),
                    SizedBox(
                        width: AppTokens.spacing.md + AppTokens.spacing.micro),
                    Flexible(
                      child: Text(
                        'Export as CSV',
                        style: AppTokens.typography.bodySecondary.copyWith(
                          fontWeight: AppTokens.fontWeight.medium,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        PopupMenuItem<ScheduleAction>(
          enabled: false,
          height: AppTokens.componentSize.divider,
          padding: AppTokens.spacing.edgeInsetsSymmetric(
              horizontal: AppTokens.spacing.md, vertical: AppTokens.spacing.sm),
          child: Container(
            height: AppTokens.componentSize.divider,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.outline.withValues(alpha: AppOpacity.transparent),
                  colors.outline.withValues(
                      alpha: isDark ? AppOpacity.accent : AppOpacity.divider),
                  colors.outline.withValues(alpha: AppOpacity.transparent),
                ],
              ),
            ),
          ),
        ),
        PopupMenuItem<ScheduleAction>(
          value: ScheduleAction.reset,
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context, ScheduleAction.reset),
              splashColor:
                  colors.primary.withValues(alpha: AppOpacity.highlight),
              highlightColor:
                  colors.primary.withValues(alpha: AppOpacity.micro),
              child: Padding(
                padding: AppTokens.spacing.edgeInsetsSymmetric(
                    horizontal: AppTokens.spacing.lg,
                    vertical: AppTokens.spacing.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding:
                          AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.sm),
                      decoration: BoxDecoration(
                        color: colors.primary
                            .withValues(alpha: AppOpacity.overlay),
                        borderRadius: AppTokens.radius.sm,
                      ),
                      child: Icon(
                        Icons.restart_alt_outlined,
                        size: AppTokens.iconSize.md,
                        color: colors.primary,
                      ),
                    ),
                    SizedBox(
                        width: AppTokens.spacing.md + AppTokens.spacing.micro),
                    Flexible(
                      child: Text(
                        'Reset schedules',
                        style: AppTokens.typography.bodySecondary.copyWith(
                          fontWeight: AppTokens.fontWeight.medium,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAction(ScheduleAction action) async {
    if (action == ScheduleAction.reset) {
      await _confirmResetSchedules();
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
                  tintColor: colors.error,
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
                          color: colors.onSurfaceVariant,
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
