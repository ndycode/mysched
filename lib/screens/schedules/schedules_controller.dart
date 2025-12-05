import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/export_queue.dart';
import '../../services/notif_scheduler.dart';
import '../../services/offline_cache_service.dart';
import '../../services/profile_cache.dart';
import '../../services/schedule_api.dart' as sched;
import '../../services/share_service.dart';
import '../../services/telemetry_service.dart';
import '../../services/user_scope.dart';
import '../../services/data_sync.dart';
import '../../utils/schedule_overlap.dart' as schedule_overlap;
import 'schedules_data.dart';

class SchedulesController extends ChangeNotifier {
  SchedulesController({
    sched.ScheduleApi? api,
    Future<bool> Function()? connectivityOverride,
  })  : _api = api ?? sched.ScheduleApi(),
        _connectivityOverride = connectivityOverride {
    _exportQueue = ExportQueue(connectivity: _hasConnectivity);
    _init();
  }

  final sched.ScheduleApi _api;
  final Future<bool> Function()? _connectivityOverride;
  late final ExportQueue _exportQueue;

  List<sched.ClassItem> _classes = const [];
  List<sched.ClassItem> get classes => _classes;

  bool _loading = true;
  bool get loading => _loading;

  bool _offlineFallback = false;
  bool get offlineFallback => _offlineFallback;

  bool _retrySuggested = false;
  bool get retrySuggested => _retrySuggested;

  bool dirty = false;

  bool _exporting = false;
  bool get exporting => _exporting;

  String? _exportError;
  String? get exportError => _exportError;

  ScheduleAction? _pendingExport;
  ScheduleAction? get pendingExport => _pendingExport;

  String? _profileName;
  String? get profileName => _profileName;

  String? _profileEmail;
  String? get profileEmail => _profileEmail;

  String? _profileAvatar;
  String? get profileAvatar => _profileAvatar;

  bool _profileHydrated = false;
  bool get profileHydrated => _profileHydrated;

  String? _criticalError;
  String? get criticalError => _criticalError;

  DateTime? _lastFetchedAt;
  DateTime? get lastFetchedAt => _lastFetchedAt;

  final Set<int> _pendingToggleClassIds = <int>{};
  Set<int> get pendingToggleClassIds => _pendingToggleClassIds;

  int _classesVersion = 0;
  int _groupedVersion = -1;
  List<DayGroup> _groupedCache = const [];
  StreamSubscription<ScheduleEvent>? _scheduleSub;

  void _init() {
    ProfileCache.notifier.addListener(_onProfileChanged);
    _applyProfile(ProfileCache.notifier.value);
    loadProfile();
    load(initial: true);
    _scheduleSub = DataSync.instance.scheduleEvents.listen((event) async {
      if (event.type == ScheduleChangeType.refresh ||
          event.type == ScheduleChangeType.cacheInvalidated ||
          event.type == ScheduleChangeType.classAdded ||
          event.type == ScheduleChangeType.classUpdated ||
          event.type == ScheduleChangeType.classDeleted) {
        await refresh();
      }
    });
  }

  @override
  void dispose() {
    ProfileCache.notifier.removeListener(_onProfileChanged);
    _scheduleSub?.cancel();
    super.dispose();
  }

  void _onProfileChanged() {
    _applyProfile(ProfileCache.notifier.value);
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
    final changed = nextName != _profileName ||
        nextEmail != _profileEmail ||
        nextAvatar != _profileAvatar ||
        !_profileHydrated;
    if (!changed) return;

    _profileName = nextName;
    _profileEmail = nextEmail;
    _profileAvatar = nextAvatar;
    _profileHydrated = true;
    notifyListeners();
  }

  Future<void> loadProfile({bool refresh = false}) async {
    try {
      final profile = await ProfileCache.load(forceRefresh: refresh);
      _applyProfile(profile);
    } catch (e, stack) {
      TelemetryService.instance
          .logError('schedules_load_profile', error: e, stack: stack);
      if (!_profileHydrated) {
        _profileHydrated = true;
        notifyListeners();
      }
    }
  }

  Future<bool> _hasConnectivity() async {
    if (_connectivityOverride != null) {
      return _connectivityOverride();
    }
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  String? _activeUserId() => UserScope.currentUserId();

  void _setClasses(List<sched.ClassItem> items) {
    _classes = items;
    _classesVersion++;
    _groupedVersion = -1;
  }

  List<DayGroup> groupedDays() {
    if (_groupedVersion != _classesVersion) {
      _groupedCache = groupClassesByDay(_classes);
      _groupedVersion = _classesVersion;
    }
    return _groupedCache;
  }

  Future<void> load({bool initial = false, bool silent = false}) async {
    final cached = _api.getCachedClasses();
    if (initial && cached != null && cached.isNotEmpty) {
      _setClasses(List<sched.ClassItem>.from(cached));
      _loading = false;
      _criticalError = null;
      notifyListeners();
    }

    if (!silent) {
      if (_classes.isEmpty) {
        _loading = true;
      }
      _criticalError = null;
      if (!initial) _retrySuggested = false;
      notifyListeners();
    }

    final uid = _activeUserId();

    try {
      final items = await _api.getMyClasses(forceRefresh: true);
      if (uid != null) {
        final cache = await OfflineCacheService.instance();
        await cache.saveSchedule(userId: uid, items: items);
      }
      _setClasses(items);
      _loading = false;
      _offlineFallback = false;
      _criticalError = null;
      _retrySuggested = false;
      _lastFetchedAt = DateTime.now();
      notifyListeners();
      // Widgets removed: no widget update
    } catch (error, stack) {
      List<sched.ClassItem>? offline;
      if (uid != null) {
        final cache = await OfflineCacheService.instance();
        offline = await cache.readSchedule(uid);
      }

      final fallback = offline ?? cached;
      if (fallback != null && fallback.isNotEmpty) {
        final fallbackList = List<sched.ClassItem>.from(fallback);
        _setClasses(fallbackList);
        _loading = false;
        _offlineFallback = offline != null && offline.isNotEmpty;
        _retrySuggested = true;
        _criticalError = null;
      } else {
        _setClasses(const []);
        _loading = false;
        _offlineFallback = false;
        _retrySuggested = false;
        _criticalError =
            'We couldn\'t refresh your schedules. Retry now or scan your card again.';
      }
      notifyListeners();
      TelemetryService.instance.logError(
        'schedule_refresh_failed',
        error: error,
        stack: stack,
      );
    }
  }

  Future<void> refresh() {
    return load(silent: true);
  }

  Future<void> toggleClassEnabled(
    sched.ClassItem item,
    bool enable, {
    required Function(String) onError,
  }) async {
    if (_pendingToggleClassIds.contains(item.id)) return;
    if (enable) {
      for (final other in _classes) {
        if (!other.enabled) continue;
        if (other.id == item.id) continue;
        if (other.day != item.day) continue;
        if (schedule_overlap.classesOverlap(item, other)) {
          final label = other.title ?? other.code ?? 'another class';
          onError('Enabling this class conflicts with $label. Adjust times first.');
          return;
        }
      }
    }
    _pendingToggleClassIds.add(item.id);
    notifyListeners();

    try {
      await _api.setClassEnabled(item, enable);
      _applyClassEnabled(item.id, enable);
      await NotifScheduler.resync(api: _api);
      // Widgets removed: no widget update
    } catch (error) {
      onError(enable
          ? 'Unable to enable class. Try again.'
          : 'Unable to disable class. Try again.');
    } finally {
      _pendingToggleClassIds.remove(item.id);
      notifyListeners();
    }
  }

  void _applyClassEnabled(int id, bool enabled) {
    _setClasses(
      _classes
          .map((c) => c.id == id ? c.copyWith(enabled: enabled) : c)
          .toList(growable: false),
    );
    dirty = true;
    notifyListeners();
  }

  // Public version for external use (e.g. sheet callbacks)
  void applyClassEnabled(int id, bool enabled) {
    _applyClassEnabled(id, enabled);
  }

  Future<void> deleteCustom(
    int id,
    {
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      await _api.deleteCustomClass(id);
      dirty = true;
      await refresh(); // This already calls widget update
      await NotifScheduler.resync(api: _api);
      onSuccess('Custom class removed.');
    } catch (error) {
      onError('Failed to delete class: $error');
    }
  }

  Future<void> resetSchedules({
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    _loading = true;
    _criticalError = null;
    _exportError = null;
    notifyListeners();

    try {
      await _api.resetAllForCurrentUser();
      _setClasses(const []);
      _loading = false;
      _offlineFallback = false;
      _retrySuggested = false;
      dirty = true;
      _lastFetchedAt = DateTime.now();
      notifyListeners();
      onSuccess('Schedules reset.');
    } catch (error) {
      _loading = false;
      notifyListeners();
      onError('Reset failed. Please try again. ($error)');
    }
  }

  Future<void> handleExportAction(
    ScheduleAction action,
    {
    required Function(String) onInfo,
  }) async {
    if (_exporting) return;
    final groups = groupedDays();
    if (groups.isEmpty) {
      onInfo('Nothing to export just yet.');
      return;
    }

    _exporting = true;
    _exportError = null;
    _pendingExport = action;
    notifyListeners();

    final now = DateTime.now();
    ShareParams params;
    if (action == ScheduleAction.pdf) {
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
      _exporting = false;
      _exportError =
          'No internet connection. Try again once you\'re back online.';
      notifyListeners();
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
      _exporting = false;
      _exportError = null;
      _pendingExport = null;
      notifyListeners();
    } catch (error, stack) {
      _exporting = false;
      _exportError = 'Check your internet connection and try again.';
      notifyListeners();
      TelemetryService.instance.logError(
        'schedule_export_failed',
        error: error,
        stack: stack,
        data: {'format': action.name},
      );
    }
  }

  void retryPendingExport({required Function(String) onInfo}) {
    final pending = _pendingExport;
    if (pending == null || _exporting) return;
    handleExportAction(pending, onInfo: onInfo);
  }
}
