import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_log.dart';
import 'schedule_repository.dart';

const _scope = 'WidgetService';

/// Service for updating the Android home screen widget.
class WidgetService {
  WidgetService._();
  static final WidgetService instance = WidgetService._();

  static const _channel = MethodChannel('com.ici.mysched/widget');
  static const _prefsName = 'NextClassWidgetPrefs';

  /// Update the widget with the next upcoming class.
  Future<void> updateWidget() async {
    try {
      final nextClass = await _getNextClass();
      
      // Store data in SharedPreferences for the native widget
      final prefs = await SharedPreferences.getInstance();
      
      if (nextClass != null) {
        await prefs.setString('${_prefsName}_class_title', nextClass.title ?? '');
        await prefs.setString('${_prefsName}_class_code', nextClass.code ?? '');
        await prefs.setString('${_prefsName}_start_time', nextClass.start);
        await prefs.setString('${_prefsName}_end_time', nextClass.end);
        await prefs.setString('${_prefsName}_room', nextClass.room ?? '');
        await prefs.setString('${_prefsName}_instructor', nextClass.instructor ?? '');
        await prefs.setBool('${_prefsName}_has_class', true);
      } else {
        await prefs.setBool('${_prefsName}_has_class', false);
      }

      await prefs.setString('${_prefsName}_last_update', DateTime.now().toIso8601String());

      // Trigger native widget update
      await _channel.invokeMethod('updateWidget');

      AppLog.debug(_scope, 'Widget updated', data: {
        'hasClass': nextClass != null,
        'title': nextClass?.title,
      });
    } catch (e, stack) {
      AppLog.error(_scope, 'Failed to update widget', error: e, stack: stack);
    }
  }

  /// Get the next upcoming class for today.
  Future<ClassItem?> _getNextClass() async {
    try {
      final scheduleApi = ScheduleApi();
      final classes = await scheduleApi.getMyClasses();
      if (classes.isEmpty) return null;

      final now = DateTime.now();
      final currentDayNumber = now.weekday; // Monday = 1

      // Filter classes for today
      final todayClasses = classes
          .where((c) => c.day == currentDayNumber && c.enabled)
          .toList();

      if (todayClasses.isEmpty) return null;

      // Sort by start time
      todayClasses.sort((a, b) => _timeToMinutes(a.start).compareTo(_timeToMinutes(b.start)));

      final nowMinutes = now.hour * 60 + now.minute;

      // Find next class (not yet ended)
      for (final c in todayClasses) {
        final endMinutes = _timeToMinutes(c.end);
        if (endMinutes > nowMinutes) {
          return c;
        }
      }

      return null; // All classes for today are done
    } catch (e) {
      AppLog.error(_scope, 'Failed to get next class', error: e);
      return null;
    }
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }
}
