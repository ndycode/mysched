// coverage:ignore-file
// lib/screens/dashboard/dashboard_screen.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/routes.dart';
import '../../models/reminder_scope.dart';
import '../../services/profile_cache.dart';
import '../../services/reminder_scope_store.dart';
import '../../services/reminders_api.dart';
import '../../services/telemetry_service.dart';
import '../../services/root_nav_controller.dart';
import '../../services/schedule_api.dart' as sched;
import '../../ui/kit/class_details_sheet.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/motion.dart';
import '../../ui/theme/tokens.dart';
import '../../utils/nav.dart';
import '../../widgets/instructor_avatar.dart';

import '../add_class_page.dart';
import '../add_reminder_page.dart';
import '../reminders_page.dart';
import '../schedules_page.dart';

part 'dashboard_models.dart';
part 'dashboard_cards.dart';
part 'dashboard_schedule.dart';
part 'dashboard_reminders.dart';
part 'dashboard_messages.dart';

// Use AppTokens.lightColors.muted / mutedSecondary for themed access
const _kDashboardScopePref = 'dashboard.scope.selected';

typedef _DashboardSectionBuilder = Widget Function(BuildContext context);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.api,
    RemindersApi? remindersApi,
    this.scheduleLoaderOverride,
    this.remindersLoaderOverride,
    this.debugForceScheduleError = false,
  })  : _remindersOverride = remindersApi;

  final sched.ScheduleApi api;
  final RemindersApi? _remindersOverride;
  final Future<List<ClassItem>> Function()? scheduleLoaderOverride;
  final Future<List<ReminderEntry>> Function()? remindersLoaderOverride;
  final bool debugForceScheduleError;

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver, RouteAware {
  late final RemindersApi _remindersApi;

  late final ValueNotifier<DateTime> _nowTick;
  Timer? _ticker;

  List<ClassItem> _classes = <ClassItem>[];
  List<ClassItem> _allClasses = <ClassItem>[];
  final Map<int, sched.ClassItem> _classSource = <int, sched.ClassItem>{};
  final Map<int, sched.ClassDetails> _classDetailsCache =
      <int, sched.ClassDetails>{};
  List<ReminderEntry> _reminders = const [];
  ReminderScope _reminderScope = ReminderScope.today;
  final Set<int> _pendingReminderActions = <int>{};
  DateTime? _lastScheduleFetchAt;

  bool _scheduleLoading = true;
  bool _remindersLoading = true;
  String? _remindersError;
  String? _scheduleError;

  String? _studentName;
  String? _studentEmail;
  String? _studentAvatar;
  bool _profileHydrated = false;

  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _searchFocusNode = FocusNode();
  bool _searchActive = false;
  String _selectedScope = 'Today';
  DateTime? _lastRefreshedAt;
  VoidCallback? _profileListener;
  PageRoute<dynamic>? _routeSubscription;
  VoidCallback? _reminderScopeListener;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remindersApi = widget._remindersOverride ?? RemindersApi();
    _nowTick = ValueNotifier<DateTime>(DateTime.now());
    _dismissKeyboard();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus &&
          mounted &&
          _searchController.text.isEmpty &&
          _searchActive) {
        setState(() => _searchActive = false);
      }
    });
    _profileListener = () {
      final profile = ProfileCache.notifier.value;
      _applyProfile(profile);
    };
    ProfileCache.notifier.addListener(_profileListener!);
    _applyProfile(ProfileCache.notifier.value);
    _reminderScope = ReminderScopeStore.instance.value;
    _reminderScopeListener = () {
      final next = ReminderScopeStore.instance.value;
      if (!mounted || next == _reminderScope) return;
      setState(() => _reminderScope = next);
    };
    ReminderScopeStore.instance.addListener(_reminderScopeListener!);
    _restoreDashboardPrefs();
    _startTicker();
    _loadProfile();
    if (widget.debugForceScheduleError) {
      _scheduleLoading = false;
      _scheduleError = 'Schedules not refreshed';
    } else {
      _loadAll();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_routeSubscription != null) {
      routeObserver.unsubscribe(this);
      _routeSubscription = null;
    }
    _ticker?.cancel();
    _nowTick.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    if (_profileListener != null) {
      ProfileCache.notifier.removeListener(_profileListener!);
    }
    if (_reminderScopeListener != null) {
      ReminderScopeStore.instance.removeListener(_reminderScopeListener!);
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

  Future<void> _restoreDashboardPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedScope = prefs.getString(_kDashboardScopePref);
    if (!mounted) return;
    if (storedScope != null &&
        (storedScope == 'Today' || storedScope == 'This week')) {
      setState(() {
        _selectedScope = storedScope;
      });
      _recomputeFilteredClasses();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // ignore: discarded_futures
      _refreshOnRouteFocus();
    }
  }

  Future<void> _refreshOnRouteFocus() async {
    _dismissKeyboard();
    await Future.wait([
      _loadAll(),
      _loadProfile(refresh: true),
    ]);
  }

  Future<void> refreshOnTabVisit() {
    return _refreshOnRouteFocus();
  }

  @override
  void didPopNext() {
    // ignore: discarded_futures
    _refreshOnRouteFocus();
  }

  Future<void> _loadProfile({bool refresh = false}) async {
    try {
      final profile = await ProfileCache.load(forceRefresh: refresh);
      _applyProfile(profile);
    } catch (e, stack) {
      TelemetryService.instance.logError('dashboard_load_profile', error: e, stack: stack);
      if (!mounted) return;
      if (!_profileHydrated) {
        setState(() => _profileHydrated = true);
      }
    }
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
    final changed = nextName != _studentName ||
        nextEmail != _studentEmail ||
        nextAvatar != _studentAvatar ||
        !_profileHydrated;
    if (!changed) return;
    setState(() {
      _studentName = nextName;
      _studentEmail = nextEmail;
      _studentAvatar = nextAvatar;
      _profileHydrated = true;
    });
  }

  Future<void> _loadAll() async {
    if (mounted) {
      setState(() {
        _scheduleLoading = true;
        _remindersLoading = true;
        _remindersError = null;
      });
    }

    await Future.wait([
      _loadScheduleFromSupabase(),
      _loadReminders(),
    ]);
  }

  Future<void> _loadScheduleFromSupabase({bool softRefresh = false}) async {
    if (mounted) {
      setState(() {
        _scheduleError = null;
      });
    }
    try {
      final now = DateTime.now();
      final cached = widget.api.getCachedClasses();
      if (cached != null && cached.isNotEmpty) {
        await _applySchedule(cached);
      }

      final shouldSkipRemote = softRefresh &&
          _lastScheduleFetchAt != null &&
          now.difference(_lastScheduleFetchAt!) < const Duration(seconds: 3);
      if (shouldSkipRemote) {
        return;
      }

      final fetcher = widget.scheduleLoaderOverride == null
          ? widget.api.refreshMyClasses
          : widget.scheduleLoaderOverride!;
      final fresh = await fetcher();
      _lastScheduleFetchAt = DateTime.now();
      await _applySchedule(List<sched.ClassItem>.from(fresh));
    } catch (e, stack) {
      TelemetryService.instance.logError('dashboard_load_schedule', error: e, stack: stack);
      if (!mounted) return;
      setState(() {
        _scheduleLoading = false;
        _scheduleError = 'Schedules not refreshed. Tap retry.';
      });
    }
  }

  Future<void> _applySchedule(List<sched.ClassItem> raw) async {
    final mapped = raw.map(ClassItem.fromApi).toList()
      ..sort((a, b) {
        if (a.weekday != b.weekday) return a.weekday.compareTo(b.weekday);
        if (a.startTime.hour != b.startTime.hour) {
          return a.startTime.hour.compareTo(b.startTime.hour);
        }
        return a.startTime.minute.compareTo(b.startTime.minute);
      });

    final source = <int, sched.ClassItem>{};
    for (final item in raw) {
      source[item.id] = item;
    }

    if (!mounted) return;
    final refreshedAt = DateTime.now();
    setState(() {
      _allClasses = mapped;
      _classSource
        ..clear()
        ..addAll(source);
      _classDetailsCache.removeWhere((key, _) => !source.containsKey(key));
      _scheduleLoading = false;
      _scheduleError = null;
      _lastRefreshedAt = refreshedAt;
    });
    _lastScheduleFetchAt = refreshedAt;
    _recomputeFilteredClasses();
  }

  Future<void> _loadReminders() async {
    if (!mounted) return;
    setState(() {
      _remindersLoading = true;
      _remindersError = null;
    });
    try {
      final loader = widget.remindersLoaderOverride == null
          ? () => _remindersApi.fetchReminders(includeCompleted: true)
          : widget.remindersLoaderOverride!;
      final items = await loader().timeout(const Duration(seconds: 8));
      if (!mounted) return;
      setState(() {
        _reminders = List<ReminderEntry>.unmodifiable(items);
        _remindersLoading = false;
        _lastRefreshedAt = DateTime.now();
      });
    } catch (e, stack) {
      TelemetryService.instance.logError('dashboard_load_reminders', error: e, stack: stack);
      if (!mounted) return;
      setState(() {
        _reminders = const [];
        _remindersLoading = false;
        _remindersError = 'Reminders failed to refresh. Please try again soon.';
      });
    }
  }

  void _recomputeFilteredClasses() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final query = _searchController.text.trim().toLowerCase();

    bool matchesScope(ClassItem item) {
      switch (_selectedScope) {
        case 'Today':
          return item.weekday == weekday;
        case 'This week':
          return true;
        default:
          return true;
      }
    }

    int sortKey(ClassItem item) {
      final offset = (item.weekday - weekday + 7) % 7;
      return offset * 24 * 60 +
          item.startTime.hour * 60 +
          item.startTime.minute;
    }

    final filtered = _allClasses.where((item) {
      if (!item.enabled) return false;
      if (!matchesScope(item)) return false;
      if (query.isNotEmpty) {
        final haystack =
            '${item.subject} ${item.room} ${item.instructor}'.toLowerCase();
        if (!haystack.contains(query)) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final keyA = sortKey(a);
        final keyB = sortKey(b);
        if (keyA != keyB) return keyA.compareTo(keyB);
        return a.id.compareTo(b.id);
      });

    if (!mounted) return;
    setState(() {
      _classes = filtered;
    });
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      _nowTick.value = DateTime.now();
    });
  }

  void _applyClassEnabled(int classId, bool enabled) {
    if (!mounted) return;
    setState(() {
      if (_classSource.containsKey(classId)) {
        _classSource[classId] =
            _classSource[classId]!.copyWith(enabled: enabled);
      }
      _allClasses = _allClasses
          .map((c) => c.id == classId ? c.copyWith(enabled: enabled) : c)
          .toList(growable: false);
    });
    _recomputeFilteredClasses();
  }

  Future<void> _handleCustomDeleted(int classId) async {
    if (!mounted) return;
    setState(() {
      _classSource.remove(classId);
      _classDetailsCache.remove(classId);
      _allClasses =
          _allClasses.where((c) => c.id != classId).toList(growable: false);
    });
    _recomputeFilteredClasses();
    await _loadScheduleFromSupabase(softRefresh: true);
  }

  Future<void> _editCustomClass(sched.ClassItem schedItem) async {
    final media = MediaQuery.of(context);
    final spacing = AppTokens.spacing;
    final updated = await showOverlaySheet<bool>(
      context: context,
      alignment: Alignment.center,
      barrierDismissible: false,
      dimBackground: true,
      padding: spacing.edgeInsetsOnly(
        left: spacing.xl,
        right: spacing.xl,
        top: media.padding.top + spacing.xxl,
        bottom: media.padding.bottom + spacing.xxl,
      ),
      builder: (_) => AddClassSheet(
        api: widget.api,
        initialClass: schedItem,
      ),
    );
    if (updated == true) {
      await _loadScheduleFromSupabase(softRefresh: true);
    }
  }

  Future<void> _openClassDetails(ClassItem item) async {
    final media = MediaQuery.of(context);
    final spacing = AppTokens.spacing;
    final base = _classSource[item.id];
    final sched.ClassItem schedItem = base ??
        sched.ClassItem(
          id: item.id,
          day: item.weekday,
          start: _timeOfDayToDb(item.startTime),
          end: _timeOfDayToDb(item.endTime),
          title: item.subject,
          code: item.subject,
          room: item.room.isEmpty ? null : item.room,
          instructor: item.instructor.isEmpty ? null : item.instructor,
          instructorAvatar: item.instructorAvatar,
          enabled: item.enabled,
          isCustom: base?.isCustom ?? false,
        );
    final cached = _classDetailsCache[item.id];
    await showOverlaySheet<void>(
      context: context,
      alignment: Alignment.center,
      dimBackground: true,
      padding: spacing.edgeInsetsOnly(
        left: spacing.xl,
        right: spacing.xl,
        top: media.padding.top + spacing.xxl,
        bottom: media.padding.bottom + spacing.xxl,
      ),
      builder: (_) => ClassDetailsSheet(
        api: widget.api,
        item: schedItem,
        initial: cached,
        onLoaded: (details) {
          _classDetailsCache[item.id] = details;
        },
        onDetailsChanged: (details) {
          _classDetailsCache[item.id] = details;
          _applyClassEnabled(details.id, details.enabled);
        },
        onEditCustom: schedItem.isCustom
            ? (details) async {
                await _editCustomClass(schedItem);
              }
            : null,
        onDeleteCustom: schedItem.isCustom
            ? (details) async {
                await _handleCustomDeleted(details.id);
              }
            : null,
      ),
    );
  }

  String _timeOfDayToDb(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _refreshAll() async {
    await _loadProfile(refresh: true);
    await _loadAll();
  }

  Future<void> _openAddReminder() async {
    final media = MediaQuery.of(context);
    final spacing = AppTokens.spacing;
    final created = await showOverlaySheet<bool>(
      context: context,
      alignment: Alignment.center,
      dimBackground: true,
      padding: spacing.edgeInsetsOnly(
        left: spacing.xl,
        right: spacing.xl,
        top: media.padding.top + spacing.xxl,
        bottom: media.padding.bottom + spacing.xxl,
      ),
      builder: (_) => AddReminderSheet(api: _remindersApi),
    );
    if (created == true && mounted) {
      await _loadReminders();
    }
  }

  Future<void> _openReminders() async {
    final targetScope = _reminderScope;
    ReminderScopeStore.instance.update(targetScope);
    if (RootNavController.handle != null) {
      await RootNavController.goToTab(RootNavTabs.reminders);
      return;
    }
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RemindersPage(initialScope: targetScope),
      ),
    );
    if (changed == true && mounted) {
      await _loadReminders();
    }
  }

  Future<void> _openSchedules() async {
    if (RootNavController.handle != null) {
      await RootNavController.goToTab(RootNavTabs.schedules);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SchedulesPage(api: widget.api)),
    );
  }

  Future<void> _openAccount() async {
    await context.push(AppRoutes.account);
    if (!mounted) return;
    await _loadProfile(refresh: true);
  }

  Future<void> _handleReminderToggle(
      ReminderEntry entry, bool completed) async {
    if (!mounted || _pendingReminderActions.contains(entry.id)) return;
    setState(() => _pendingReminderActions.add(entry.id));
    try {
      await _remindersApi.toggleCompleted(entry, completed);
      await _loadReminders();
    } catch (e, stack) {
      TelemetryService.instance.logError('dashboard_toggle_reminder', error: e, stack: stack);
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Unable to update reminder. Try again.',
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _pendingReminderActions.remove(entry.id));
      }
    }
  }

  Future<void> _handleReminderSnooze(ReminderEntry entry) async {
    if (!mounted || _pendingReminderActions.contains(entry.id)) return;
    setState(() => _pendingReminderActions.add(entry.id));
    try {
      await _remindersApi.snoozeReminder(entry.id, const Duration(hours: 1));
      await _loadReminders();
    } catch (e, stack) {
      TelemetryService.instance.logError('dashboard_snooze_reminder', error: e, stack: stack);
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Could not snooze reminder.',
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _pendingReminderActions.remove(entry.id));
      }
    }
  }

  String _formatReminderDue(ReminderEntry entry) {
    final base = entry.snoozeUntil ?? entry.dueAt;
    final local = base.toLocal();
    final fmt = DateFormat('MMM d, h:mm a');
    if (entry.isCompleted) {
      if (entry.completedAt != null) {
        return 'Completed ${fmt.format(entry.completedAt!.toLocal())}';
      }
      return 'Completed';
    }
    if (entry.snoozeUntil != null &&
        entry.snoozeUntil!.isAfter(DateTime.now())) {
      return 'Snoozed until ${fmt.format(local)}';
    }
    if (base.isBefore(DateTime.now())) {
      return 'Overdue since ${fmt.format(local)}';
    }
    return 'Due ${fmt.format(local)}';
  }

  DateTime _effectiveReminderMoment(ReminderEntry entry) =>
      (entry.snoozeUntil ?? entry.dueAt).toLocal();

  _ReminderAlert? _resolveReminderAlert(
    DateTime now,
    ColorScheme colors,
  ) {
    final pending = _reminders.where((entry) => !entry.isCompleted).toList()
      ..sort(
        (a, b) =>
            _effectiveReminderMoment(a).compareTo(_effectiveReminderMoment(b)),
      );

    if (pending.isEmpty) return null;

    final overdue = pending
        .where(
          (entry) => _effectiveReminderMoment(entry).isBefore(now),
        )
        .toList();

    if (overdue.isNotEmpty) {
      final first = overdue.first;
      final elapsed = now.difference(_effectiveReminderMoment(first));
      final approx = _humanizeDeltaCompact(elapsed);
      return _ReminderAlert(
        icon: Icons.warning_amber_rounded,
        title: 'Overdue reminder',
        message: '${first.title} • $approx overdue',
        tint: colors.error,
        actionLabel: 'Open reminders',
      );
    }

    final upcoming = pending.first;
    final diff = _effectiveReminderMoment(upcoming).difference(now);
    if (!diff.isNegative && diff.inMinutes <= 60) {
      final approx = _humanizeDeltaCompact(diff);
      return _ReminderAlert(
        icon: Icons.alarm_rounded,
        title: 'Reminder coming up',
        message: '${upcoming.title} • in $approx',
        tint: colors.primary,
        actionLabel: 'Review',
      );
    }

    return null;
  }

  String _humanizeDeltaCompact(Duration delta) {
    final absDelta = delta.abs();
    if (absDelta.inMinutes < 1) return '<1m';
    if (absDelta.inMinutes < 60) {
      return '${absDelta.inMinutes}m';
    }
    final hours = absDelta.inHours;
    final minutes = absDelta.inMinutes - hours * 60;
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final initialLoading = _scheduleLoading &&
        _classes.isEmpty &&
        _remindersLoading &&
        _reminders.isEmpty;

    if (initialLoading) {
      final spacing = AppTokens.spacing;
      final media = MediaQuery.of(context);
      return ScreenShell(
        screenName: 'dashboard',
        hero: const ScreenHeroCard(
          title: 'Dashboard',
          subtitle: 'Loading your schedule and reminders...',
        ),
        sections: const [
          ScreenSection(
            decorated: false,
            child: SkeletonDashboardCard(),
          ),
        ],
        padding: spacing.edgeInsetsOnly(
          left: spacing.xl,
          right: spacing.xl,
          top: media.padding.top + spacing.xxxl,
          bottom: spacing.xl,
        ),
        safeArea: false,
      );
    }

    final spacing = AppTokens.spacing;
    final topInset = MediaQuery.of(context).padding.top;

    return ValueListenableBuilder<DateTime>(
      valueListenable: _nowTick,
      builder: (context, now, _) {
        final enabledClasses =
            _classes.where((c) => c.enabled).toList(growable: false);
        final allEnabledClasses =
            _allClasses.where((c) => c.enabled).toList(growable: false);
        final occurrences = _resolveScheduleOccurrences(enabledClasses, now);
        final summary = _DashboardSummaryData.resolve(
          occurrences: occurrences,
          now: now,
          reminders: _reminders,
          scopeLabel: _selectedScope,
        );
        final upcoming = _resolveUpcoming(
          _TickSnapshot.resolve(now, allEnabledClasses),
          allEnabledClasses,
          now,
        );

        final sections = _buildDashboardSections(
          context: context,
          summary: summary,
          upcoming: upcoming,
          now: now,
          scheduleOccurrences: occurrences,
          searchController: _searchController,
          selectedScope: _selectedScope,
          onScopeChanged: _handleScopeChange,
          onSearchChanged: _handleSearchChanged,
        )
            .map(
              (builder) => ScreenSection(
                decorated: false,
                child: builder(context),
              ),
            )
            .toList();

        return ScreenShell(
          screenName: 'dashboard',
          hero: ScreenBrandHeader(
            name: _studentName,
            email: _studentEmail,
            avatarUrl: _studentAvatar,
            onAccountTap: _openAccount,
            showChevron: false,
            loading: !_profileHydrated,
          ),
          sections: sections,
          padding: spacing.edgeInsetsOnly(
            left: spacing.xl,
            right: spacing.xl,
            top: topInset + spacing.xxxl,
            bottom: spacing.xl,
          ),
          safeArea: false,
          onRefresh: _refreshAll,
          refreshColor: Theme.of(context).colorScheme.primary,
        );
      },
    );
  }

  List<_DashboardSectionBuilder> _buildDashboardSections({
    required BuildContext context,
    required _DashboardSummaryData summary,
    required _DashboardUpcoming upcoming,
    required DateTime now,
    required List<ClassOccurrence> scheduleOccurrences,
    required TextEditingController searchController,
    required String selectedScope,
    required ValueChanged<String> onScopeChanged,
    required ValueChanged<String> onSearchChanged,
  }) {
    final sections = <_DashboardSectionBuilder>[];
    void addSection(_DashboardSectionBuilder builder) =>
        sections.add(builder);
    void addSpacing(double value) =>
        sections.add((_) => SizedBox(height: value));

    final greeting = 'Good day, ${_resolveDisplayName()}! \u{1F44B}';
    final dateLabel = DateFormat('EEEE, MMM d').format(now);
    final colors = Theme.of(context).colorScheme;
    final reminderAlert = _resolveReminderAlert(now, colors);
    final scopeMessage = _resolveScopeMessage(summary);
    final refreshLabel = _formatRefreshLabel(now);

    if (_remindersError != null) {
      addSection(
        (_) => _DashboardMessageCard(
          icon: Icons.error_outline,
          title: 'Reminders not refreshed',
          message: _remindersError!,
          primaryLabel: 'Retry',
          onPrimary: _loadReminders,
        ),
      );
      addSpacing(AppTokens.spacing.md);
    }

    addSection(
      (_) => _DashboardSummaryCard(
        greeting: greeting,
        dateLabel: dateLabel,
        summary: summary,
        upcoming: upcoming,
        reminderAlert: reminderAlert,
        scopeMessage: scopeMessage,
        refreshLabel: refreshLabel,
        onReviewReminders: _openReminders,
        onViewDetails: _openClassDetails,
        onToggleEnabled: _applyClassEnabled,
        onViewSchedule: _openSchedules,
      ),
    );
    addSpacing(AppTokens.spacing.xxl);

    if (_scheduleError != null) {
      addSection(
        (_) => MessageCard(
          key: const ValueKey('dashboard-schedule-error'),
          icon: Icons.error_outline,
          title: 'Schedules not refreshed',
          message: _scheduleError!,
          primaryLabel: 'Retry',
          onPrimary: _loadScheduleFromSupabase,
          secondaryLabel: 'Open schedules',
          onSecondary: _openSchedules,
          tintColor: Theme.of(context).colorScheme.primary,
        ),
      );
      addSpacing(AppTokens.spacing.lg);
    }



    addSection(
      (_) => _DashboardSchedulePeek(
        occurrences: scheduleOccurrences,
        now: now,
        scopeLabel: selectedScope,
        onScopeChanged: onScopeChanged,
        colors: colors,
        theme: Theme.of(context),
        selectedScope: selectedScope,
        searchController: searchController,
        onSearchChanged: onSearchChanged,
        onOpenSchedules: _openSchedules,
        refreshing: _scheduleLoading || _remindersLoading,
        searchFocusNode: _searchFocusNode,
        searchActive: _searchActive,
        onSearchTap: _handleSearchTapped,
        onSearchClear: _handleSearchClear,
        onRefresh: _loadAll,
        onViewDetails: _openClassDetails,
      ),
    );
    addSpacing(AppTokens.spacing.xxl);

    addSection(
      (_) => _DashboardReminderCard(
        reminders: _reminders,
        loading: _remindersLoading,
        pendingActions: _pendingReminderActions,
        formatDue: _formatReminderDue,
        onOpenReminders: _openReminders,
        onAddReminder: _openAddReminder,
        onToggle: _handleReminderToggle,
        onSnooze: _handleReminderSnooze,
        scope: _reminderScope,
        onScopeChanged: (scope) {
          if (_reminderScope == scope) return;
          ReminderScopeStore.instance.update(scope);
        },
      ),
    );

    addSpacing(AppTokens.spacing.quad + AppLayout.bottomNavSafePadding);

    return sections;
  }

  void _handleScopeChange(String value) {
    if (_selectedScope == value) return;
    setState(() => _selectedScope = value);
    _recomputeFilteredClasses();
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString(_kDashboardScopePref, value));
  }

  void _handleSearchChanged(String value) {
    setState(() {
      if (!_searchActive && _searchFocusNode.hasFocus) {
        _searchActive = true;
      }
    });
    _recomputeFilteredClasses();
  }

  void _handleSearchTapped() {
    if (_searchActive) return;
    setState(() => _searchActive = true);
    Future.microtask(() {
      if (!_searchFocusNode.hasFocus) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _handleSearchClear() {
    final hadText = _searchController.text.isNotEmpty;
    if (hadText) {
      _searchController.clear();
      _recomputeFilteredClasses();
    }
    FocusScope.of(context).unfocus();
    if (_searchActive || hadText) {
      setState(() => _searchActive = false);
    }
  }

  String _resolveDisplayName() {
    var firstName = (_studentName ?? '').trim();
    if (firstName.contains(' ')) {
      firstName = firstName.split(' ').first;
    }
    if (firstName.isEmpty) {
      final email = (_studentEmail ?? '').trim();
      firstName = email.contains('@') ? email.split('@').first : 'Student';
    }
    return firstName.isEmpty ? 'Student' : firstName;
  }

  String? _formatRefreshLabel(DateTime now) {
    final refreshed = _lastRefreshedAt;
    if (refreshed == null) return null;
    final diff = now.difference(refreshed);
    if (diff < const Duration(minutes: 1)) {
      return 'Just now';
    }
    if (diff < const Duration(hours: 1)) {
      final minutes = diff.inMinutes;
      return '$minutes min ago';
    }
    if (diff < const Duration(days: 1)) {
      final hours = diff.inHours;
      return '${hours}h ago';
    }
    return DateFormat("MMM d 'at' h:mm a").format(refreshed);
  }

  String _resolveScopeMessage(_DashboardSummaryData summary) {
    if (_selectedScope == 'Today') {
      if (summary.classesRemaining == 0) {
        return 'Today looks clear.';
      }
      if (summary.classesRemaining == 1) {
        return '1 class left today.';
      }
      return '${summary.classesRemaining} classes lined up today.';
    }
    if (summary.classesRemaining == 0) {
      return 'Your week is all set.';
    }
    return '${summary.classesRemaining} classes left this week.';
  }

  _DashboardUpcoming _resolveUpcoming(
    _TickSnapshot snapshot,
    List<ClassItem> enabledClasses,
    DateTime now,
  ) {
    final current = snapshot.current;
    final next = snapshot.next;

    ClassOccurrence? reference;
    bool isActive = false;
    DateTime? focusDay;

    if (current != null && current.end.isAfter(now)) {
      reference = current;
      isActive = true;
    } else if (next != null && next.end.isAfter(now)) {
      reference = next;
      isActive = false;
    }

    List<ClassOccurrence> occurrences = [];

    if (reference != null) {
      focusDay = DateTime(
          reference.start.year, reference.start.month, reference.start.day);
      occurrences = _buildDayOccurrences(
        reference,
        enabledClasses,
        reference.start,
      ).where((occ) => occ.end.isAfter(now)).toList();
    }

    if (occurrences.isEmpty) {
      final futureOccurrences = <ClassOccurrence>[];
      for (final item in enabledClasses) {
        final start = item.nextStartAfter(now);
        final occ = item.occurrenceAt(start);
        if (occ != null && occ.end.isAfter(now)) {
          futureOccurrences.add(occ);
        }
      }
      if (futureOccurrences.isEmpty) {
        return _DashboardUpcoming.empty(isActive: false);
      }
      futureOccurrences.sort((a, b) => a.start.compareTo(b.start));
      final primary = futureOccurrences.first;
      reference = primary;
      isActive = primary.isOngoingAt(now);
      focusDay = DateTime(
        primary.start.year,
        primary.start.month,
        primary.start.day,
      );
      occurrences = futureOccurrences
          .where((occ) => _isSameDay(occ.start, primary.start))
          .toList()
        ..sort((a, b) => a.start.compareTo(b.start));
    }

    return _DashboardUpcoming(
      occurrences: occurrences,
      isActive: isActive,
      focusDay: focusDay,
    );
  }

  List<ClassOccurrence> _resolveScheduleOccurrences(
    List<ClassItem> classes,
    DateTime now,
  ) {
    if (classes.isEmpty) return const [];
    final today = DateTime(now.year, now.month, now.day);

    final occurrences = <ClassOccurrence>[];

    if (_selectedScope == 'Today') {
      for (final item in classes) {
        final occ = item.occurrenceOn(today);
        if (occ != null) occurrences.add(occ);
      }
    } else {
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      for (var offset = 0; offset < 7; offset++) {
        final day = startOfWeek.add(Duration(days: offset));
        for (final item in classes) {
          final occ = item.occurrenceOn(day);
          if (occ != null) occurrences.add(occ);
        }
      }
    }
    occurrences.sort((a, b) => a.start.compareTo(b.start));
    return occurrences;
  }

  List<ClassOccurrence> _buildDayOccurrences(
    ClassOccurrence seed,
    List<ClassItem> classes,
    DateTime anchor,
  ) {
    final day = DateTime(anchor.year, anchor.month, anchor.day);
    final matches = <ClassOccurrence>[];
    for (final item in classes) {
      final occ = item.occurrenceOn(day);
      if (occ != null) matches.add(occ);
    }
    matches.sort((a, b) => a.start.compareTo(b.start));
    return matches;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
