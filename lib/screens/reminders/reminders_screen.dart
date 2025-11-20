import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/reminder_scope.dart';
import '../../services/profile_cache.dart';
import '../../services/reminder_scope_store.dart';
import '../../services/reminders_api.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/card_styles.dart';
import '../../ui/theme/tokens.dart';
import '../../utils/nav.dart';
import '../../app/routes.dart';
import '../add_reminder_page.dart';

part 'reminders_models.dart';
part 'reminders_cards.dart';
part 'reminders_messages.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({
    super.key,
    RemindersApi? api,
    this.initialScope,
  }) : _apiOverride = api;

  final RemindersApi? _apiOverride;
  final ReminderScope? initialScope;

  @override
  RemindersPageState createState() => RemindersPageState();
}

class RemindersPageState extends State<RemindersPage> with RouteAware {
  static const double _bottomNavSafePadding = 120;
  late final RemindersApi _api;
  bool _loading = true;
  String? _error;
  List<ReminderEntry> _items = const [];
  bool _showCompleted = false;
  bool _dirty = false;
  String? _studentName;
  String? _studentEmail;
  String? _avatarUrl;
  bool _profileHydrated = false;
  ReminderScope _scope = ReminderScope.today;
  VoidCallback? _profileListener;
  PageRoute<dynamic>? _routeSubscription;
  VoidCallback? _scopeListener;
  int _itemsVersion = 0;
  int _scopedVersion = -1;
  int _groupedVersion = -1;
  ReminderScope _cachedScopeForEntries = ReminderScope.today;
  bool _cachedShowCompleted = false;
  DateTime? _cachedReferenceDay;
  List<ReminderEntry> _scopedCache = const <ReminderEntry>[];
  List<_ReminderGroup> _groupedCache = const <_ReminderGroup>[];
  List<ReminderEntry> _groupedSource = const <ReminderEntry>[];

  final DateFormat _timeFormat = DateFormat('h:mm a');
  final DateFormat _dateLine = DateFormat('EEEE, MMM d');

  @override
  void initState() {
    super.initState();
    _api = widget._apiOverride ?? RemindersApi();
    _dismissKeyboard();
    _loadProfile();
    _profileListener = () {
      final profile = ProfileCache.notifier.value;
      _applyProfile(profile);
    };
    ProfileCache.notifier.addListener(_profileListener!);
    _applyProfile(ProfileCache.notifier.value);
    final initialScope =
        widget.initialScope ?? ReminderScopeStore.instance.value;
    _scope = initialScope;
    ReminderScopeStore.instance.update(initialScope);
    _scopeListener = () {
      final next = ReminderScopeStore.instance.value;
      if (!mounted || next == _scope) return;
      setState(() => _scope = next);
    };
    ReminderScopeStore.instance.addListener(_scopeListener!);
    _load();
  }

  void _dismissKeyboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  void _markItemsMutated() {
    _itemsVersion++;
    _scopedVersion = -1;
    _groupedVersion = -1;
    _cachedReferenceDay = null;
    _scopedCache = const <ReminderEntry>[];
    _groupedCache = const <_ReminderGroup>[];
    _groupedSource = const <ReminderEntry>[];
  }

  @override
  void dispose() {
    if (_profileListener != null) {
      ProfileCache.notifier.removeListener(_profileListener!);
    }
    if (_scopeListener != null) {
      ReminderScopeStore.instance.removeListener(_scopeListener!);
    }
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

  Future<void> _load({bool silent = false}) async {
    if (!mounted) return;
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      setState(() {
        _error = null;
      });
    }

    try {
      final items = await _api.fetchReminders(includeCompleted: true);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
        _error = null;
        _markItemsMutated();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _friendlyError(error);
        _loading = false;
      });
    }
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
        nextAvatar != _avatarUrl ||
        !_profileHydrated;
    if (!changed) return;
    setState(() {
      _studentName = nextName;
      _studentEmail = nextEmail;
      _avatarUrl = nextAvatar;
      _profileHydrated = true;
    });
  }

  Future<void> _refresh() => _load(silent: true);

  Future<void> _refreshOnRouteFocus() async {
    _dismissKeyboard();
    await Future.wait([
      _refresh(),
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

  Future<void> _openAddPage([ReminderEntry? editing]) async {
    final media = MediaQuery.of(context);
    final changed = await showOverlaySheet<bool>(
      context: context,
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(
        20,
        media.padding.top + 24,
        20,
        media.padding.bottom + 24,
      ),
      builder: (_) => AddReminderSheet(
        api: _api,
        editing: editing,
      ),
    );
    if (changed == true) {
      _dirty = true;
      await _load(silent: false);
    }
  }

  Future<void> _openAccount() async {
    await context.push(AppRoutes.account);
    if (!mounted) return;
    await _loadProfile(refresh: true);
  }

  Widget _buildReminderStickyHeader({
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
                '$count reminder${count == 1 ? '' : 's'}',
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

  Future<void> _toggleCompleted(ReminderEntry entry, bool completed) async {
    try {
      final updated = await _api.toggleCompleted(entry, completed);
      if (!mounted) return;
      setState(() {
        _items = _items
            .map((item) => item.id == updated.id ? updated : item)
            .toList(growable: false);
        _dirty = true;
        _markItemsMutated();
      });
      _toast(completed ? 'Marked as done.' : 'Moved back to pending.');
    } catch (error) {
      _toast(_friendlyError(error), isError: true);
    }
  }

  Future<void> _deleteReminder(ReminderEntry entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: const Text(
          'This reminder will be removed and any scheduled notifications will be cancelled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _api.deleteReminder(entry.id);
      if (!mounted) return;
      setState(() {
        _items = _items.where((item) => item.id != entry.id).toList();
        _dirty = true;
        _markItemsMutated();
      });
      _toast('Reminder deleted.');
    } catch (error) {
      _toast(_friendlyError(error), isError: true);
    }
  }

  Future<void> _snoozeReminder(ReminderEntry entry) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final duration = await showModalBottomSheet<Duration>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SnoozeSheet(
        entry: entry,
        formatDue: _formatDue,
      ),
    );
    if (duration == null) return;

    try {
      final updated = await _api.snoozeReminder(entry.id, duration);
      if (!mounted) return;
      setState(() {
        _items = _items
            .map((item) => item.id == updated.id ? updated : item)
            .toList(growable: false);
        _dirty = true;
        _markItemsMutated();
      });
      _toast('Snoozed to ${_formatDue(updated.dueAt)}.');
    } catch (error) {
      _toast(_friendlyError(error), isError: true);
    }
  }

  String _formatDue(DateTime due) {
    final local = due.toLocal();
    return '${_dateLine.format(local)} at ${_timeFormat.format(local)}';
  }

  void _toast(String message, {bool isError = false}) {
    if (!mounted) return;
    showAppSnackBar(
      context,
      message,
      type: isError ? AppSnackBarType.error : AppSnackBarType.success,
    );
  }

  List<ReminderEntry> _entriesForScope(DateTime now) {
    final referenceDay = DateTime(now.year, now.month, now.day);
    final canReuse = _scopedVersion == _itemsVersion &&
        _cachedScopeForEntries == _scope &&
        _cachedShowCompleted == _showCompleted &&
        _cachedReferenceDay != null &&
        _isSameDay(referenceDay, _cachedReferenceDay!);
    if (canReuse) {
      return _scopedCache;
    }
    final filtered = _items.where((entry) {
      if (!_showCompleted && entry.isCompleted) return false;
      return _scope.includes(entry.dueAt.toLocal(), now);
    }).toList(growable: false)
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    _scopedCache = filtered;
    _scopedVersion = _itemsVersion;
    _cachedScopeForEntries = _scope;
    _cachedShowCompleted = _showCompleted;
    _cachedReferenceDay = referenceDay;
    return filtered;
  }

  Widget _buildMenuButton({Color? iconColor}) {
    return PopupMenuButton<_ReminderSummaryMenu>(
      tooltip: 'Reminders options',
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: AppTokens.radius.md,
      ),
      icon: Icon(
        Icons.more_vert_rounded,
        color: iconColor,
      ),
      onSelected: (action) {
        switch (action) {
          case _ReminderSummaryMenu.newReminder:
            _openAddPage();
            break;
          case _ReminderSummaryMenu.toggleCompleted:
            setState(() => _showCompleted = !_showCompleted);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _ReminderSummaryMenu.newReminder,
          child: Row(
            children: const [
              Icon(Icons.add_alarm_rounded, size: 18),
              SizedBox(width: 12),
              Text('New reminder'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _ReminderSummaryMenu.toggleCompleted,
          child: Row(
            children: [
              Icon(
                _showCompleted
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
              ),
              const SizedBox(width: 12),
              Text(_showCompleted ? 'Hide completed' : 'Show completed'),
            ],
          ),
        ),
      ],
    );
  }

  List<_ReminderGroup> _groupedEntries(List<ReminderEntry> entries) {
    if (entries.isEmpty) {
      _groupedCache = const <_ReminderGroup>[];
      _groupedSource = entries;
      _groupedVersion = _scopedVersion;
      return const <_ReminderGroup>[];
    }

    final canReuse = _groupedVersion == _scopedVersion &&
        identical(entries, _groupedSource);
    if (canReuse) return _groupedCache;

    final map = <DateTime, List<ReminderEntry>>{};
    for (final entry in entries) {
      final local = entry.dueAt.toLocal();
      final dayKey = DateTime(local.year, local.month, local.day);
      map.putIfAbsent(dayKey, () => []).add(entry);
    }
    final keys = map.keys.toList()..sort();
    final groups = <_ReminderGroup>[];
    for (final key in keys) {
      final list = List<ReminderEntry>.from(map[key]!);
      list.sort((a, b) => a.dueAt.compareTo(b.dueAt));
      groups.add(_ReminderGroup(label: _labelForDate(key), items: list));
    }
    _groupedCache = groups;
    _groupedSource = entries;
    _groupedVersion = _scopedVersion;
    return groups;
  }

  String _labelForDate(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = day.difference(today).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    return _dateLine.format(day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final scopedEntries = _entriesForScope(now);
    final summary = _ReminderSummary.resolve(scopedEntries, now);
    final groups = _groupedEntries(scopedEntries);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final media = MediaQuery.of(context);

    final spacing = AppTokens.spacing;
    final hero = ScreenBrandHeader(
      name: _studentName,
      email: _studentEmail,
      avatarUrl: _avatarUrl,
      onAccountTap: _openAccount,
      showChevron: false,
      loading: !_profileHydrated,
    );
    final shellPadding = EdgeInsets.fromLTRB(
      20,
      media.padding.top + spacing.xxxl,
      20,
      spacing.quad + _bottomNavSafePadding,
    );

    if (_loading) {
      return ScreenShell(
        screenName: 'reminders',
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

    final menuButton = _buildMenuButton(
      iconColor: colors.onSurfaceVariant.withValues(alpha: 0.9),
    );

    final sections = <Widget>[];

    if (_error != null) {
      sections.add(
        ScreenSection(
          decorated: false,
          child: _MessageCard(
            icon: Icons.error_outline,
            title: 'Reminders not refreshed',
            message: _error!,
            primaryLabel: 'Retry',
            onPrimary: () => _load(silent: false),
          ),
        ),
      );
    }

    sections.add(
      ScreenSection(
        decorated: false,
        child: _SummaryCard(
          summary: summary,
          now: now,
          onCreate: () => _openAddPage(),
          onToggleCompleted: () {
            setState(() => _showCompleted = !_showCompleted);
          },
          showCompleted: _showCompleted,
          menuButton: menuButton,
          scope: _scope,
          onScopeChanged: (scope) {
            if (scope == _scope) return;
            ReminderScopeStore.instance.update(scope);
          },
        ),
      ),
    );

    if (groups.isEmpty) {
      sections.add(
        ScreenSection(
          decorated: false,
          child: _MessageCard(
            icon: Icons.notifications_none_rounded,
            title: 'No reminders yet',
            message:
                'Tap "New reminder" to create one. We\'ll keep it in sync across devices.',
            primaryLabel: 'New reminder',
            onPrimary: () => _openAddPage(),
          ),
        ),
      );
    } else {
      sections.add(
        ScreenSection(
          decorated: false,
          title: 'Scheduled reminders',
          subtitle: 'Pinned headers keep each day visible.',
          child: Text(
            'Toggle reminders inline or tap a card to edit details.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      );
      for (final group in groups) {
        sections.add(
          _ReminderGroupSliver(
            header: _buildReminderStickyHeader(
              label: group.label,
              count: group.items.length,
            ),
            group: group,
            timeFormat: _timeFormat,
            onToggle: (entry, isActive) =>
                _toggleCompleted(entry, !isActive),
            onEdit: (entry) => _openAddPage(entry),
            onDelete: _deleteReminder,
            onSnooze: _snoozeReminder,
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
        screenName: 'reminders',
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

enum _ReminderSummaryMenu { newReminder, toggleCompleted }
