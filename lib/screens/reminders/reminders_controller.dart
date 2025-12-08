import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/reminder_scope.dart';
import '../../services/profile_cache.dart';
import '../../services/reminders_repository.dart';
import '../../services/telemetry_service.dart';
import '../../ui/theme/tokens.dart';
import '../../services/data_sync.dart';
import '../../services/offline_queue.dart';
import '../../services/export_queue.dart';
import '../../services/share_service.dart';
import 'reminders_data.dart';

/// Export format options for reminders.
enum ReminderExportFormat { csv, pdf }

/// Sort options for reminders.
enum ReminderSortOption { dueDate, title, createdAt }

extension ReminderSortOptionLabels on ReminderSortOption {
  /// Display label for dropdown menus.
  String get label => switch (this) {
    ReminderSortOption.dueDate => 'Sort by due date',
    ReminderSortOption.title => 'Sort by title',
    ReminderSortOption.createdAt => 'Sort by created',
  };

  /// Group header label when sorting by this option.
  String get groupLabel => switch (this) {
    ReminderSortOption.dueDate => 'All reminders',
    ReminderSortOption.title => 'Sorted by title',
    ReminderSortOption.createdAt => 'Sorted by created date',
  };
}

class RemindersController extends ChangeNotifier {
  RemindersController({
    RemindersApi? api,
    ReminderScope? initialScope,
    Future<bool> Function()? connectivityOverride,
  })  : _api = api ?? RemindersApi(),
        _scope = initialScope ?? ReminderScope.all,
        _connectivityOverride = connectivityOverride {
    _exportQueue = ExportQueue(connectivity: _hasConnectivity);
    _init();
  }

  final RemindersApi _api;
  final Future<bool> Function()? _connectivityOverride;
  late final ExportQueue _exportQueue;
  
  bool _loading = true;
  bool get loading => _loading;
  
  String? _error;
  String? get error => _error;
  
  List<ReminderEntry> _items = const [];
  List<ReminderEntry> get items => _items;
  Set<int> _queuedIds = const <int>{};
  Set<int> get queuedIds => Set<int>.unmodifiable(_queuedIds);
  
  bool _showCompleted = false;
  bool get showCompleted => _showCompleted;
  set showCompleted(bool value) {
    if (_showCompleted == value) return;
    _showCompleted = value;
    notifyListeners();
  }
  
  bool _dirty = false;
  bool get dirty => _dirty;
  
  String? _studentName;
  String? get studentName => _studentName;
  
  String? _studentEmail;
  String? get studentEmail => _studentEmail;
  
  String? _avatarUrl;
  String? get avatarUrl => _avatarUrl;
  
  bool _profileHydrated = false;
  bool get profileHydrated => _profileHydrated;
  
  ReminderScope _scope;
  ReminderScope get scope => _scope;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  ReminderSortOption _sortOption = ReminderSortOption.dueDate;
  ReminderSortOption get sortOption => _sortOption;

  bool _exporting = false;
  bool get exporting => _exporting;

  String? _exportError;
  String? get exportError => _exportError;

  ReminderExportFormat? _pendingExport;
  ReminderExportFormat? get pendingExport => _pendingExport;

  final bool _offlineMode = false;
  bool get offlineMode => _offlineMode;

  int _itemsVersion = 0;
  int _scopedVersion = -1;
  int _groupedVersion = -1;
  ReminderScope _cachedScopeForEntries = ReminderScope.today;
  bool _cachedShowCompleted = false;
  DateTime? _cachedReferenceDay;
  List<ReminderEntry> _scopedCache = const <ReminderEntry>[];
  List<ReminderGroup> _groupedCache = const <ReminderGroup>[];
  List<ReminderEntry> _groupedSource = const <ReminderEntry>[];
  StreamSubscription<RemindersEvent>? _syncSub;
  bool _queueRefreshInFlight = false;
  
  final DateFormat _dateLine = DateFormat('EEEE, MMM d');

  void _init() {
    ProfileCache.notifier.addListener(_onProfileChanged);
    _applyProfile(ProfileCache.notifier.value);
    
    // Don't sync with shared scope store - Reminders screen manages its own scope
    OfflineQueue.instance.pendingCount.addListener(_onPendingQueueChanged);
    
    loadProfile();
    _loadWithRetry();
    _syncSub = DataSync.instance.remindersEvents.listen((event) async {
      if (event.type == RemindersChangeType.refresh ||
          event.type == RemindersChangeType.reminderAdded ||
          event.type == RemindersChangeType.reminderUpdated ||
          event.type == RemindersChangeType.reminderDeleted ||
          event.type == RemindersChangeType.reminderCompleted ||
          event.type == RemindersChangeType.reminderSnoozed) {
        await refresh();
      }
    });
  }

  /// Initial load with automatic retry if first attempt fails.
  Future<void> _loadWithRetry() async {
    await load();
    // If initial load failed, retry after a short delay
    if (_error != null) {
      await Future<void>.delayed(AppTokens.motion.slower * 1.6);
      await load();
    }
  }

  @override
  void dispose() {
    ProfileCache.notifier.removeListener(_onProfileChanged);
    OfflineQueue.instance.pendingCount.removeListener(_onPendingQueueChanged);
    _syncSub?.cancel();
    super.dispose();
  }

  void _onProfileChanged() {
    _applyProfile(ProfileCache.notifier.value);
  }

  void setScope(ReminderScope scope) {
    if (scope == _scope) return;
    _scope = scope;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (query == _searchQuery) return;
    _searchQuery = query;
    // Invalidate grouped cache since search affects the entries
    _groupedVersion = -1;
    _groupedCache = const <ReminderGroup>[];
    _groupedSource = const <ReminderEntry>[];
    notifyListeners();
  }

  void setSortOption(ReminderSortOption option) {
    if (option == _sortOption) return;
    _sortOption = option;
    // Invalidate grouped cache since grouping logic depends on sort option
    _groupedVersion = -1;
    _groupedCache = const <ReminderGroup>[];
    _groupedSource = const <ReminderEntry>[];
    notifyListeners();
  }

  void _onPendingQueueChanged() {
    final hadQueued = _queuedIds.isNotEmpty;
    final pending = OfflineQueue.instance.pendingCount.value;
    unawaited(_refreshQueuedIds(notify: true));
    if (pending == 0 && hadQueued && !_queueRefreshInFlight) {
      _queueRefreshInFlight = true;
      unawaited(() async {
        try {
          await refresh();
        } finally {
          _queueRefreshInFlight = false;
        }
      }());
    }
  }

  void _markItemsMutated() {
    _itemsVersion++;
    _scopedVersion = -1;
    _groupedVersion = -1;
    _cachedReferenceDay = null;
    _scopedCache = const <ReminderEntry>[];
    _groupedCache = const <ReminderGroup>[];
    _groupedSource = const <ReminderEntry>[];
  }

  int? _parseId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  Set<int> _collectQueuedIds(List<QueuedMutation> pending) {
    final ids = <int>{};
    for (final mutation in pending) {
      final payload = mutation.payload;
      switch (mutation.type) {
        case 'reminder_create':
          final tempId = _parseId(payload['temp_id']);
          final id = _parseId(payload['id']);
          if (tempId != null) {
            ids.add(tempId);
          } else if (id != null) {
            ids.add(id);
          }
          break;
        case 'reminder_update':
        case 'reminder_snooze':
        case 'reminder_delete':
          final id = _parseId(payload['id']);
          if (id != null) ids.add(id);
          break;
        case 'reminder_toggle':
          final entry = payload['entry'];
          if (entry is Map<String, dynamic>) {
            final id = _parseId(entry['id']);
            if (id != null) ids.add(id);
          }
          final id = _parseId(payload['id']);
          if (id != null) ids.add(id);
          break;
        default:
          break;
      }
    }
    return ids;
  }

  Future<bool> _refreshQueuedIds({bool notify = false}) async {
    final pending = await OfflineQueue.instance.getPending();
    final ids = _collectQueuedIds(pending);
    final changed = !setEquals(ids, _queuedIds);
    if (changed) {
      _queuedIds = ids;
      if (notify) notifyListeners();
    } else if (notify) {
      notifyListeners();
    }
    return changed;
  }

  Future<List<ReminderEntry>> _mergeOptimisticQueued(
    List<ReminderEntry> base,
  ) async {
    final pending = await OfflineQueue.instance.getPending();
    final queued = _collectQueuedIds(pending);
    if (!setEquals(_queuedIds, queued)) {
      _queuedIds = queued;
    }
    if (pending.isEmpty) return base;

    final merged = List<ReminderEntry>.from(base);
    for (final mutation in pending) {
      switch (mutation.type) {
        case 'reminder_create':
          final payload = mutation.payload;
          final id = payload['temp_id'] as int? ??
              (payload['id'] as int? ??
                  (DateTime.now().millisecondsSinceEpoch & 0x7fffffff));
          final dueRaw = payload['due_at'] as String? ?? '';
          final due = DateTime.tryParse(dueRaw) ?? DateTime.now();
          merged.add(
            ReminderEntry(
              id: id,
              userId: (payload['user_id'] as String?) ?? '',
              title: (payload['title'] ?? 'Reminder') as String,
              details: payload['details'] as String?,
              dueAt: due,
              status: ReminderStatus.pending,
              snoozeUntil: null,
              completedAt: null,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          break;
        case 'reminder_update':
          final payload = mutation.payload;
          final id = payload['id'] as int? ?? -1;
          final idx = merged.indexWhere((entry) => entry.id == id);
          if (idx == -1) break;
          final current = merged[idx];
          merged[idx] = current.copyWith(
            title: payload['title'] as String?,
            details: payload['details'] as String?,
            dueAt: payload['due_at'] == null
                ? null
                : DateTime.tryParse(payload['due_at'] as String),
            status: payload['status'] == null
                ? null
                : reminderStatusFromString(payload['status'] as String),
            snoozeUntil: payload['snooze_until'] == null
                ? null
                : DateTime.tryParse(payload['snooze_until'] as String),
            completedAt: payload['completed_at'] == null
                ? null
                : DateTime.tryParse(payload['completed_at'] as String),
          );
          break;
        default:
          break;
      }
    }
    return merged;
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      _loading = true;
      _error = null;
      notifyListeners();
    } else {
      _error = null;
      notifyListeners();
    }

    try {
      final items = await _api.fetchReminders(includeCompleted: true);
      _items = await _mergeOptimisticQueued(items);
      _loading = false;
      _error = null;
      _markItemsMutated();
      notifyListeners();
    } catch (e) {
      final optimistic = await _mergeOptimisticQueued(_items);
      _items = optimistic;
      _error = friendlyError(e);
      _loading = false;
      _markItemsMutated();
      notifyListeners();
    }
  }

  Future<void> loadProfile({bool refresh = false}) async {
    try {
      final profile = await ProfileCache.load(forceRefresh: refresh);
      _applyProfile(profile);
    } catch (e, stack) {
      TelemetryService.instance.logError('reminders_load_profile', error: e, stack: stack);
      if (!_profileHydrated) {
        _profileHydrated = true;
        notifyListeners();
      }
    }
  }

  void _applyProfile(ProfileSummary? profile) {
    if (profile == null) {
      if (_profileHydrated) return;
      _profileHydrated = true;
      notifyListeners();
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
    
    _studentName = nextName;
    _studentEmail = nextEmail;
    _avatarUrl = nextAvatar;
    _profileHydrated = true;
    notifyListeners();
  }

  Future<void> refresh() => load(silent: true);

  Future<void> refreshOnRouteFocus() async {
    await Future.wait([
      refresh(),
      loadProfile(refresh: true),
    ]);
  }

  Future<void> toggleCompleted(ReminderEntry entry, bool completed, {required Function(String) onMessage}) async {
    try {
      final updated = await _api.toggleCompleted(entry, completed);
      _items = _items
          .map((item) => item.id == updated.id ? updated : item)
          .toList(growable: false);
      _dirty = true;
      await _refreshQueuedIds();
      _markItemsMutated();
      notifyListeners();
      onMessage(completed ? 'Marked as done.' : 'Moved back to pending.');
    } catch (error) {
      onMessage(friendlyError(error));
    }
  }

  Future<void> deleteReminder(ReminderEntry entry, {required Function(String) onMessage}) async {
    try {
      await _api.deleteReminder(entry.id);
      _items = _items.where((item) => item.id != entry.id).toList();
      _dirty = true;
      await _refreshQueuedIds();
      _markItemsMutated();
      notifyListeners();
      onMessage('Reminder deleted.');
    } catch (error) {
      onMessage(friendlyError(error));
    }
  }

  Future<void> snoozeReminder(ReminderEntry entry, Duration duration, {required Function(String) onMessage, required String Function(DateTime) formatDue}) async {
    try {
      final updated = await _api.snoozeReminder(entry.id, duration);
      _items = _items
          .map((item) => item.id == updated.id ? updated : item)
          .toList(growable: false);
      _dirty = true;
      await _refreshQueuedIds();
      _markItemsMutated();
      notifyListeners();
      onMessage('Snoozed to ${formatDue(updated.dueAt)}.');
    } catch (error) {
      onMessage(friendlyError(error));
    }
  }

  Future<void> resetReminders() async {
    await _api.resetReminders();
    _items = [];
    _dirty = true;
    _markItemsMutated();
    notifyListeners();
  }

  List<ReminderEntry> entriesForScope(DateTime now) {
    final referenceDay = DateTime(now.year, now.month, now.day);
    final canReuse = _scopedVersion == _itemsVersion &&
        _cachedScopeForEntries == _scope &&
        _cachedShowCompleted == _showCompleted &&
        _cachedReferenceDay != null &&
        _isSameDay(referenceDay, _cachedReferenceDay!);
    if (canReuse) {
      return _applySortAndSearch(_scopedCache);
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
    return _applySortAndSearch(filtered);
  }

  List<ReminderEntry> _applySortAndSearch(List<ReminderEntry> entries) {
    var result = entries;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((entry) {
        return entry.title.toLowerCase().contains(query) ||
            (entry.details?.toLowerCase().contains(query) ?? false);
      }).toList(growable: false);
    }
    
    // Apply sort
    switch (_sortOption) {
      case ReminderSortOption.dueDate:
        result = List<ReminderEntry>.from(result)
          ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
        break;
      case ReminderSortOption.title:
        result = List<ReminderEntry>.from(result)
          ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case ReminderSortOption.createdAt:
        result = List<ReminderEntry>.from(result)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    
    return result;
  }

  List<ReminderGroup> groupedEntries(List<ReminderEntry> entries) {
    if (entries.isEmpty) {
      _groupedCache = const <ReminderGroup>[];
      _groupedSource = entries;
      _groupedVersion = _scopedVersion;
      return const <ReminderGroup>[];
    }

    // When sorting by title or createdAt, don't group by date - show as single flat list
    if (_sortOption != ReminderSortOption.dueDate) {
      _groupedCache = [ReminderGroup(label: _sortOption.groupLabel, items: entries)];
      _groupedSource = entries;
      _groupedVersion = _scopedVersion;
      return _groupedCache;
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
    final groups = <ReminderGroup>[];
    for (final key in keys) {
      final list = List<ReminderEntry>.from(map[key]!);
      // Keep the order from _applySortAndSearch (already sorted by dueAt)
      groups.add(ReminderGroup(label: _labelForDate(key), items: list));
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
  
  void notifyDirty() {
    _dirty = true;
  }

  Future<bool> _hasConnectivity() async {
    if (_connectivityOverride != null) {
      return _connectivityOverride();
    }
    try {
      // Using the offline queue's pending count as a proxy for connectivity
      // If there are pending items, we might be offline
      return OfflineQueue.instance.pendingCount.value == 0 || _items.isNotEmpty;
    } catch (e) {
      return true;
    }
  }

  /// Export reminders in the specified format.
  Future<void> handleExportAction(
    ReminderExportFormat format, {
    required Function(String) onInfo,
  }) async {
    if (_exporting) return;
    final entries = _items.where((e) => !e.isCompleted).toList();
    if (entries.isEmpty) {
      onInfo('Nothing to export just yet.');
      return;
    }

    _exporting = true;
    _exportError = null;
    _pendingExport = format;
    notifyListeners();

    final now = DateTime.now();
    ShareParams params;
    if (format == ReminderExportFormat.csv) {
      final csv = buildRemindersCsv(entries, now: now);
      params = ShareParams(
        text: csv,
        subject: 'MySched reminders',
        files: [
          XFile.fromData(
            Uint8List.fromList(utf8.encode(csv)),
            mimeType: 'text/csv',
            name: 'mysched-reminders.csv',
          ),
        ],
        fileNameOverrides: ['mysched-reminders.csv'],
      );
      TelemetryService.instance.logEvent(
        'reminder_export_csv',
        data: {'count': entries.length},
      );
    } else {
      final pdfBytes = await buildRemindersPdf(entries, now: now);
      final text = buildRemindersPlainText(entries, now: now);
      params = ShareParams(
        text: text,
        subject: 'MySched reminders',
        files: [
          XFile.fromData(
            pdfBytes,
            mimeType: 'application/pdf',
            name: 'mysched-reminders.pdf',
          ),
          XFile.fromData(
            Uint8List.fromList(utf8.encode(text)),
            mimeType: 'text/plain',
            name: 'mysched-reminders.txt',
          ),
        ],
        fileNameOverrides: [
          'mysched-reminders.pdf',
          'mysched-reminders.txt',
        ],
      );
      TelemetryService.instance.logEvent(
        'reminder_export_pdf',
        data: {'count': entries.length},
      );
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
      _exporting = false;
      _exportError = null;
      _pendingExport = null;
      notifyListeners();
    } catch (error, stack) {
      _exporting = false;
      _exportError = 'Export failed. Please try again.';
      notifyListeners();
      TelemetryService.instance.logError(
        'reminder_export_failed',
        error: error,
        stack: stack,
        data: {'format': format.name},
      );
    }
  }

  void retryPendingExport({required Function(String) onInfo}) {
    final pending = _pendingExport;
    if (pending == null || _exporting) return;
    handleExportAction(pending, onInfo: onInfo);
  }
}
