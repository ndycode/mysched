import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:mysched/services/schedule_api.dart';
import 'package:mysched/utils/app_log.dart';

const _scope = 'WidgetService';

/// Service to manage Android home screen widgets
class WidgetService {
  static Future<void> initialize() async {
    AppLog.debug(_scope, 'Initializing...');
    await HomeWidget.setAppGroupId('com.example.mysched');
    AppLog.debug(_scope, 'Initialized');
  }

  /// Update all widgets with latest data
  static Future<void> updateWidgets() async {
    try {
      AppLog.debug(_scope, 'Starting widget update...');
      final api = ScheduleApi();
      final classes = await api.getMyClasses();
      AppLog.debug(_scope, 'Fetched ${classes.length} classes');
      
      final now = DateTime.now();
      AppLog.debug(_scope, 'Current time: $now, weekday: ${now.weekday}');
      
      // Filter enabled classes only
      final enabledClasses = classes.where((c) => c.enabled).toList();
      AppLog.debug(_scope, '${enabledClasses.length} enabled classes');
      
      // Get next upcoming class
      final nextClass = _getNextClass(enabledClasses, now);
      
      if (nextClass != null) {
        AppLog.debug(_scope, 'Next class found: ${nextClass.title ?? nextClass.code}');
        final isOngoing = nextClass.start.compareTo('${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}') <= 0;
        await _saveNextClassData(nextClass, now, isOngoing);
      } else {
        AppLog.debug(_scope, 'No next class found, clearing widget data');
        await HomeWidget.saveWidgetData<String>('next_class_subject', null);
        await HomeWidget.saveWidgetData<String>('next_class_time', null);
        await HomeWidget.saveWidgetData<String>('next_class_location', null);
      }
      
      // Update widgets
      AppLog.debug(_scope, 'Triggering widget update on native side...');
      
      // Use platform channel to update all widget instances
      try {
        await const MethodChannel('com.example.mysched/widget')
            .invokeMethod('updateAllWidgets');
      } catch (e) {
        // Fallback to home_widget method if custom channel fails
        await HomeWidget.updateWidget(
          name: 'MySchedWidgetProvider',
          androidName: 'MySchedWidgetProvider',
        );
      }
      
      AppLog.debug(_scope, 'Widget update complete');
    } catch (e, stack) {
      AppLog.error(_scope, 'Widget update failed', error: e, stack: stack);
    }
  }

  static ClassItem? _getNextClass(List<ClassItem> classes, DateTime now) {
    final currentDay = now.weekday; // 1 = Monday, 7 = Sunday
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    AppLog.debug(_scope, 'Looking for current/next class on day $currentDay at $currentTime');
    
    ClassItem? currentClass;
    ClassItem? nextClass;
    String? minTime;
    
    for (final classItem in classes) {
      AppLog.debug(_scope, 'Checking class: ${classItem.title ?? classItem.code}, day=${classItem.day}, start=${classItem.start}, end=${classItem.end}');
      
      // Check if class occurs today
      if (classItem.day != currentDay) {
        AppLog.debug(_scope, '  Skipped: wrong day (${classItem.day} != $currentDay)');
        continue;
      }
      
      // Check if class is currently ongoing
      if (classItem.start.compareTo(currentTime) <= 0 && classItem.end.compareTo(currentTime) > 0) {
        AppLog.debug(_scope, '  Found ongoing class!');
        currentClass = classItem;
        break; // Prioritize current class
      }
      
      // Check for next upcoming class
      if (classItem.start.compareTo(currentTime) > 0) {
        if (minTime == null || classItem.start.compareTo(minTime) < 0) {
          AppLog.debug(_scope, '  Selected as next class');
          minTime = classItem.start;
          nextClass = classItem;
        }
      } else {
        AppLog.debug(_scope, '  Skipped: already ended (${classItem.start} <= $currentTime < ${classItem.end})');
      }
    }
    
    final result = currentClass ?? nextClass;
    
    if (result == null) {
      AppLog.debug(_scope, 'No current or upcoming class found for today');
    } else if (currentClass != null) {
      AppLog.debug(_scope, 'Showing CURRENT class: ${result.title ?? result.code} (${result.start} - ${result.end})');
    } else {
      AppLog.debug(_scope, 'Showing NEXT class: ${result.title ?? result.code} at ${result.start}');
    }
    
    return result;
  }

  static Future<void> _saveNextClassData(ClassItem classItem, DateTime now, bool isOngoing) async {
    final subject = classItem.title?.trim().isNotEmpty == true 
        ? classItem.title! 
        : (classItem.code?.trim().isNotEmpty == true ? classItem.code! : 'Class');
    
    final timeLabel = '${_formatTime(classItem.start)} - ${_formatTime(classItem.end)}';
    final location = classItem.room ?? '';
    final instructor = classItem.instructor ?? '';
    final instructorAvatar = classItem.instructorAvatar ?? '';
    
    AppLog.debug(_scope, 'Saving widget data', data: {
      'subject': subject,
      'time': timeLabel,
      'location': location,
      'instructor': instructor,
      'isOngoing': isOngoing,
    });
    
    await HomeWidget.saveWidgetData<String>('next_class_subject', subject);
    await HomeWidget.saveWidgetData<String>('next_class_time', timeLabel);
    await HomeWidget.saveWidgetData<String>('next_class_location', location);
    await HomeWidget.saveWidgetData<String>('next_class_instructor', instructor);
    await HomeWidget.saveWidgetData<String>('next_class_instructor_avatar', instructorAvatar);
    await HomeWidget.saveWidgetData<bool>('is_ongoing', isOngoing);
  }

  static String _formatTime(String timeStr) {
    // Convert HH:MM to 12-hour format
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return timeStr;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      
      return '$hour12:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return timeStr;
    }
  }
}
