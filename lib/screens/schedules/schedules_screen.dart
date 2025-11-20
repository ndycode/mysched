import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../app/routes.dart';
import '../../services/export_queue.dart';
import '../../services/offline_cache_service.dart';
import '../../services/profile_cache.dart';
import '../../services/schedule_api.dart' as sched;
import '../../services/share_service.dart';
import '../../services/telemetry_service.dart';
import '../../services/user_scope.dart';
import '../../ui/kit/class_details_sheet.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/card_styles.dart';
import '../../ui/theme/tokens.dart';
import '../../utils/nav.dart';
import '../add_class_page.dart';
import '../scan_options_sheet.dart';
import '../scan_preview_sheet.dart';
import '../schedules_preview_sheet.dart';
import '../../widgets/instructor_avatar.dart';

part 'schedules_models.dart';
part 'schedules_cards.dart';
part 'schedules_messages.dart';

const double _kScheduleBottomSafePadding = 120;
final DateFormat _dayOfWeekFormat = DateFormat('EEEE, MMM d');

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
  late final sched.ScheduleApi _api = widget.api;

  List<sched.ClassItem> _classes = const [];
  bool _loading = true;
  bool _offlineFallback = false;
  bool _retrySuggested = false;
  bool _dirty = false;

  late final ExportQueue _exportQueue;
  bool _exporting = false;
  String? _exportError;
  _ScheduleAction? _pendingExport;

  String? _profileName;
  String? _profileEmail;
  String? _profileAvatar;
  bool _profileHydrated = false;
  String? _criticalError;
  DateTime? _lastFetchedAt;

  VoidCallback? _profileListener;
  PageRoute<dynamic>? _routeSubscription;
  final Set<int> _pendingToggleClassIds = <int>{};
  int _classesVersion = 0;
  int _groupedVersion = -1;
  List<DayGroup> _groupedCache = const [];

  @override
  void initState() {
    super.initState();
    _exportQueue = ExportQueue(connectivity: _hasConnectivity);
    _dismissKeyboard();
    _profileListener = () {
      _applyProfile(ProfileCache.notifier.value);
    };
    ProfileCache.notifier.addListener(_profileListener!);
    _applyProfile(ProfileCache.notifier.value);
    _loadProfile();
    _load(initial: true);
  }

  @override
  void dispose() {
    if (_profileListener != null) {
      ProfileCache.notifier.removeListener(_profileListener!);
    }
    if (_routeSubscription != null) {
      routeObserver.unsubscribe(this);
      _routeSubscription = null;
    }
    super.dispose();
  }

  String? _activeUserId() => UserScope.currentUserId();

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

  Future<void> reload({bool silent = false}) {
    return _load(silent: silent);
  }

  void _dismissKeyboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  Future<void> _loadProfile({bool refresh = false}) async {
    try {
      final profile = await ProfileCache.load(forceRefresh: refresh);
      _applyProfile(profile);
    } catch (_) {
      if (!mounted) return;
      if (!_profileHydrated) {
        setState(() => _profileHydrated = true);
      }
    }
  }

  void _setClasses(List<sched.ClassItem> items) {
    _classes = items;
    _classesVersion++;
    _groupedVersion = -1;
  }

  List<DayGroup> _groupedDays() {
    if (_groupedVersion != _classesVersion) {
      _groupedCache = groupClassesByDay(_classes);
      _groupedVersion = _classesVersion;
    }
    return _groupedCache;
  }

  void _applyProfile(ProfileSummary? profile) {
    if (!mounted) return;
    if (profile == null) {
      if (_profileHydrated) return;
      setState(() => _profileHydrated = true);
      return;
    }
    final nextName = profile.name;
    final nextEmail = profile.email;
    final nextAvatar = profile.avatarUrl;
    final changed = nextName != _profileName ||
        nextEmail != _profileEmail ||
        nextAvatar != _profileAvatar ||
        !_profileHydrated;
    if (!changed) return;
    setState(() {
      _profileName = nextName;
      _profileEmail = nextEmail;
      _profileAvatar = nextAvatar;
      _profileHydrated = true;
    });
  }

  Future<bool> _hasConnectivity() async {
    final override = widget.connectivityOverride;
    if (override != null) {
      return override();
    }
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  Future<void> _load({bool initial = false, bool silent = false}) async {
    final cached = _api.getCachedClasses();
    if (initial && cached != null && cached.isNotEmpty) {
      setState(() {
        _setClasses(List<sched.ClassItem>.from(cached));
        _loading = false;
        _criticalError = null;
      });
    }

    if (!mounted) return;

    if (!silent) {
      setState(() {
        if (_classes.isEmpty) {
          _loading = true;
        }
        _criticalError = null;
        if (!initial) _retrySuggested = false;
      });
    }

    final uid = _activeUserId();

    try {
      final items = await _api.getMyClasses(forceRefresh: true);
      if (uid != null) {
        final cache = await OfflineCacheService.instance();
        await cache.saveSchedule(userId: uid, items: items);
      }
      if (!mounted) return;
      setState(() {
        _setClasses(items);
        _loading = false;
        _offlineFallback = false;
        _criticalError = null;
        _retrySuggested = false;
        _lastFetchedAt = DateTime.now();
      });
    } catch (error, stack) {
      List<sched.ClassItem>? offline;
      if (uid != null) {
        final cache = await OfflineCacheService.instance();
        offline = await cache.readSchedule(uid);
      }
      if (!mounted) return;
      final fallback = offline ?? cached;
      if (fallback != null && fallback.isNotEmpty) {
        final fallbackList = List<sched.ClassItem>.from(fallback);
        setState(() {
          _setClasses(fallbackList);
          _loading = false;
          _offlineFallback = offline != null && offline.isNotEmpty;
          _retrySuggested = true;
          _criticalError = null;
        });
      } else {
        setState(() {
          _setClasses(const []);
          _loading = false;
          _offlineFallback = false;
          _retrySuggested = false;
          _criticalError =
              'We couldn\'t refresh your schedules. Retry now or scan your card again.';
        });
      }
      TelemetryService.instance.logError(
        'schedule_refresh_failed',
        error: error,
        stack: stack,
      );
    }
  }

  Future<void> _refresh() {
    return _load(silent: true);
  }

  Future<void> refreshOnTabVisit() {
    return _refresh();
  }

  Future<void> _openAccount() async {
    await context.push(AppRoutes.account);
    if (!mounted) return;
    await _loadProfile(refresh: true);
  }

  Widget _buildScheduleStickyHeader({
    required String label,
    required int count,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$count class${count == 1 ? '' : 'es'}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openAddClass({sched.ClassItem? initial}) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (initial == null && widget.onAddClass != null) {
      final created = await widget.onAddClass!.call();
      if (!mounted) return;
      if (created == true) {
        _dirty = true;
        await _refresh();
      }
      return;
    }

    final media = MediaQuery.of(context);
    final result = await showOverlaySheet<bool>(
      context: context,
      alignment: Alignment.center,
      barrierDismissible: false,
      padding: EdgeInsets.fromLTRB(
        20,
        media.padding.top + 24,
        20,
        media.padding.bottom + 24,
      ),
      builder: (_) => AddClassSheet(api: _api, initialClass: initial),
    );
    if (!mounted) return;
    if (result == true) {
      _dirty = true;
      await _refresh();
    }
  }

  Future<void> _openScanOptions() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (widget.onScan != null) {
      await widget.onScan!.call();
      return;
    }
    while (mounted) {
      if (!mounted) return;
      final path = await showModalBottomSheet<String?>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => const ScanOptionsSheet(),
      );
      if (!mounted || path == null) return;

      if (!mounted) return;
      final preview = await showModalBottomSheet<ScanPreviewOutcome?>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ScanPreviewSheet(imagePath: path),
      );
      if (!mounted) return;
      if (preview == null) return;
      if (preview.retake) {
        // User tapped retake; restart from capture options.
        continue;
      }
      if (!preview.isSuccess) return;

      if (!mounted) return;
      final outcome = await showModalBottomSheet<ScheduleImportOutcome?>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => SchedulesPreviewSheet(
          imagePath: preview.imagePath!,
          section: preview.section!,
          classes: preview.classes,
        ),
      );
      if (!mounted) return;
      if (outcome == null) return;
      if (outcome.retake) {
        // User wants to recapture; restart flow.
        continue;
      }
      if (outcome.imported) {
        _dirty = true;
        await _refresh();
        _notify(
          'Schedule imported successfully.',
          type: AppSnackBarType.success,
        );
      }
      return;
    }
  }

  Future<void> _openClassDetails(sched.ClassItem item) async {
    final media = MediaQuery.of(context);
    final initial = _classes.firstWhere(
      (element) => element.id == item.id,
      orElse: () => item,
    );
    await showOverlaySheet<void>(
      context: context,
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(
        20,
        media.padding.top + 24,
        20,
        media.padding.bottom + 24,
      ),
      builder: (_) => ClassDetailsSheet(
        api: _api,
        item: initial,
        onDetailsChanged: (details) {
          _applyClassEnabled(details.id, details.enabled);
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
                await _deleteCustom(details.id);
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

  Future<void> _deleteCustom(int id) async {
    try {
      await _api.deleteCustomClass(id);
      if (!mounted) return;
      _dirty = true;
      await _refresh();
      _notify(
        'Custom class removed.',
        type: AppSnackBarType.success,
      );
    } catch (error) {
      _notify(
        'Failed to delete class: $error',
        type: AppSnackBarType.error,
      );
    }
  }

  void _applyClassEnabled(int id, bool enabled) {
    setState(() {
      _setClasses(
        _classes
            .map((c) => c.id == id ? c.copyWith(enabled: enabled) : c)
            .toList(growable: false),
      );
    });
    _dirty = true;
  }

  Future<void> _toggleClassEnabled(
    sched.ClassItem item,
    bool enable,
  ) async {
    if (_pendingToggleClassIds.contains(item.id)) return;
    setState(() => _pendingToggleClassIds.add(item.id));
    try {
      await _api.setClassEnabled(item, enable);
      _applyClassEnabled(item.id, enable);
    } catch (error) {
      if (mounted) {
        showAppSnackBar(
          context,
          enable
              ? 'Unable to enable class. Try again.'
              : 'Unable to disable class. Try again.',
          type: AppSnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _pendingToggleClassIds.remove(item.id));
      }
    }
  }

  Widget _buildActionsMenu({Color? iconColor}) {
    return PopupMenuButton<_ScheduleAction>(
      key: const ValueKey('schedule-actions-menu'),
      tooltip: 'Schedule actions',
      enabled: !_exporting,
      onSelected: (action) => _handleAction(action),
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        PopupMenuItem<_ScheduleAction>(
          key: const ValueKey('schedule-reset-item'),
          value: _ScheduleAction.reset,
          child: Row(
            children: const [
              Icon(Icons.restart_alt_outlined),
              SizedBox(width: 12),
              Text('Reset schedules'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<_ScheduleAction>(
          key: const ValueKey('schedule-export-pdf-item'),
          value: _ScheduleAction.pdf,
          child: Row(
            children: const [
              Icon(Icons.picture_as_pdf_outlined),
              SizedBox(width: 12),
              Text('Export as PDF'),
            ],
          ),
        ),
        PopupMenuItem<_ScheduleAction>(
          key: const ValueKey('schedule-export-csv-item'),
          value: _ScheduleAction.csv,
          child: Row(
            children: const [
              Icon(Icons.table_chart_outlined),
              SizedBox(width: 12),
              Text('Export as CSV'),
            ],
          ),
        ),
      ],
      child: Icon(
        Icons.more_vert_rounded,
        color: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Future<void> _handleAction(_ScheduleAction action) async {
    if (action == _ScheduleAction.reset) {
      await _confirmResetSchedules();
      return;
    }

    if (_exporting) return;
    final groups = groupClassesByDay(_classes);
    if (groups.isEmpty) {
      _notify('Nothing to export just yet.');
      return;
    }

    setState(() {
      _exporting = true;
      _exportError = null;
      _pendingExport = action;
    });

    final now = DateTime.now();
    ShareParams params;
    if (action == _ScheduleAction.pdf) {
      final pdfBytes = await buildSchedulePdf(groups, now: now);
      final text = buildSchedulePlainText(groups, now: now);
      params = ShareParams(
        text: text,
        subject: 'MySched timetable',
        files: [
          XFile.fromData(
            pdfBytes,
            mimeType: 'application/pdf',
            name: 'mysched-timetable.pdf',
          ),
          XFile.fromData(
            Uint8List.fromList(utf8.encode(text)),
            mimeType: 'text/plain',
            name: 'mysched-timetable.txt',
          ),
        ],
        fileNameOverrides: [
          'mysched-timetable.pdf',
          'mysched-timetable.txt',
        ],
      );
      TelemetryService.instance.logEvent(
        'schedule_export_pdf',
        data: {'count': groups.fold<int>(0, (sum, g) => sum + g.items.length)},
      );
    } else {
      final csv = buildScheduleCsv(_classes, now: now);
      params = ShareParams(
        text: csv,
        subject: 'MySched timetable',
        files: [
          XFile.fromData(
            Uint8List.fromList(utf8.encode(csv)),
            mimeType: 'text/csv',
            name: 'mysched-timetable.csv',
          ),
        ],
        fileNameOverrides: ['mysched-timetable.csv'],
      );
      TelemetryService.instance.logEvent(
        'schedule_export_csv',
        data: {'count': _classes.length},
      );
    }

    final hasNetwork = await _hasConnectivity();
    if (!hasNetwork) {
      if (!mounted) return;
      setState(() {
        _exporting = false;
        _exportError =
            'No internet connection. Try again once you\'re back online.';
      });
      return;
    }

    final completer = Completer<void>();
    _exportQueue.enqueue(() async {
      try {
        await ShareService.share(params);
        if (!completer.isCompleted) {
          completer.complete();
        }
      } catch (error, stack) {
        if (!completer.isCompleted) {
          completer.completeError(error, stack);
        }
      }
    });

    await _exportQueue.flush();

    try {
      await completer.future;
      if (!mounted) return;
      setState(() {
        _exporting = false;
        _exportError = null;
        _pendingExport = null;
      });
    } catch (error, stack) {
      if (!mounted) return;
      setState(() {
        _exporting = false;
        _exportError = 'Check your internet connection and try again.';
      });
      TelemetryService.instance.logError(
        'schedule_export_failed',
        error: error,
        stack: stack,
        data: {'format': action.name},
      );
    }
  }

  void _retryPendingExport() {
    final pending = _pendingExport;
    if (pending == null || _exporting) return;
    _handleAction(pending);
  }

  Future<void> _confirmResetSchedules() async {
    if (_loading) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset schedules?'),
          content: const Text(
            'This will remove all linked classes and custom additions for this account. You can rescan or sync again later.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;

    setState(() {
      _loading = true;
      _criticalError = null;
      _exportError = null;
    });

    try {
      await _api.resetAllForCurrentUser();
      if (!mounted) return;
      setState(() {
        _setClasses(const []);
        _loading = false;
        _offlineFallback = false;
        _retrySuggested = false;
        _dirty = true;
        _lastFetchedAt = DateTime.now();
      });
      _notify(
        'Schedules reset.',
        type: AppSnackBarType.success,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _notify(
        'Reset failed. Please try again. ($error)',
        type: AppSnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final media = MediaQuery.of(context);
    final hero = ScreenBrandHeader(
      name: _profileName,
      email: _profileEmail,
      avatarUrl: _profileAvatar,
      onAccountTap: _openAccount,
      showChevron: false,
      loading: !_profileHydrated,
    );
    final shellPadding = EdgeInsets.fromLTRB(
      20,
      media.padding.top + spacing.xxxl,
      20,
      spacing.quad + _kScheduleBottomSafePadding,
    );

    if (_loading && _classes.isEmpty) {
      return ScreenShell(
        screenName: 'schedules',
        hero: hero,
        sections: const [
          ScreenSection(
            decorated: false,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
        padding: shellPadding,
        onRefresh: _refresh,
        refreshColor: colors.primary,
        safeArea: false,
        cacheExtent: 800,
      );
    }

    final now = DateTime.now();
    final summary = _ScheduleSummary.resolve(_classes, now);
    final groups = _groupedDays();

    final sections = <Widget>[];

    if (_criticalError != null && _classes.isEmpty) {
      sections.add(
        ScreenSection(
          decorated: false,
          child: _ScheduleMessageCard(
            icon: Icons.error_outline,
            title: 'Schedule not loaded',
            message:
                'We couldn\'t refresh your schedules. Retry now or scan your card again.',
            primaryLabel: 'Retry',
            onPrimary: () => _load(silent: false),
            secondaryLabel: 'Scan student card',
            onSecondary: _openScanOptions,
          ),
        ),
      );
    } else {
      if (_offlineFallback) {
        sections.add(
          ScreenSection(
            decorated: false,
            child: _OfflineBanner(
              key: const ValueKey('offline-cache-banner'),
              lastSynced: _lastFetchedAt,
            ),
          ),
        );
      }

      if (_retrySuggested) {
        sections.add(
          ScreenSection(
            decorated: false,
            child: _ScheduleMessageCard(
              icon: Icons.sync_problem_outlined,
              title: 'Almost caught up',
              message:
                  'A network hiccup interrupted the last sync. Retry to fetch the latest classes.',
              primaryLabel: 'Retry sync',
              onPrimary: _refresh,
              secondaryLabel: 'Scan card',
              onSecondary: _openScanOptions,
            ),
          ),
        );
      }

      if (_exportError != null && _pendingExport != null) {
        sections.add(
          ScreenSection(
            decorated: false,
            child: _ScheduleMessageCard(
              icon: Icons.block,
              title: 'Export unavailable',
              message: _exportError!,
              primaryLabel: 'Try again',
              onPrimary: _retryPendingExport,
            ),
          ),
        );
      }

      sections.add(
        ScreenSection(
          decorated: false,
          child: _ScheduleSummaryCard(
            summary: summary,
            now: now,
            onAddClass: () => _openAddClass(),
            onScanCard: _openScanOptions,
            menuButton: _buildActionsMenu(
              iconColor: colors.onSurfaceVariant.withValues(alpha: 0.9),
            ),
          ),
        ),
      );

      final flattened = [
        for (final group in groups) ...group.items,
      ];

      if (flattened.isEmpty) {
        sections.add(
          ScreenSection(
            decorated: false,
            child: _ScheduleMessageCard(
              icon: Icons.event_busy_outlined,
              title: 'No schedules yet',
              message:
                  'Use the actions above to add custom classes or scan your student card to import your timetable.',
            ),
          ),
        );
      } else {
      sections.add(
        ScreenSection(
          decorated: false,
          title: 'Upcoming classes',
          subtitle: 'Day headers stay pinned as you scroll.',
            child: Text(
              'Tap a class to view details, enable alarms, or edit reminders.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        );
        for (final group in groups) {
          sections.add(
            _ScheduleGroupSliver(
              header: _buildScheduleStickyHeader(
                label: group.label,
                count: group.items.length,
              ),
              group: group,
              highlightClassId: summary.highlight?.item.id,
              onOpenDetails: _openClassDetails,
              onToggleEnabled: _toggleClassEnabled,
              pendingToggleIds: _pendingToggleClassIds,
              showHeader: false,
            ),
          );
        }
        sections.add(
          SizedBox(
            height: spacing.quad + media.padding.bottom + spacing.xl,
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
        Navigator.of(context).pop(_dirty);
      },
      child: ScreenShell(
        screenName: 'schedules',
        hero: hero,
        sections: sections,
        padding: shellPadding,
        onRefresh: _refresh,
        refreshColor: colors.primary,
        safeArea: false,
        cacheExtent: 800,
        useSlivers: true,
      ),
    );
  }
}
