import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:mysched/services/schedule_api.dart';

/// Service to manage Android home screen widgets
class WidgetService {
  static Future<void> initialize() async {
    debugPrint('[WidgetService] Initializing...');
    await HomeWidget.setAppGroupId('com.example.mysched');
    debugPrint('[WidgetService] Initialized');
  }

  /// Update all widgets with latest data
  static Future<void> updateWidgets() async {
    try {
      debugPrint('[WidgetService] Starting widget update...');
      final api = ScheduleApi();
      final classes = await api.getMyClasses();
      debugPrint('[WidgetService] Fetched ${classes.length} classes');
      
      final now = DateTime.now();
      debugPrint('[WidgetService] Current time: $now, weekday: ${now.weekday}');
      
      // Filter enabled classes only
      final enabledClasses = classes.where((c) => c.enabled).toList();
      debugPrint('[WidgetService] ${enabledClasses.length} enabled classes');
      
      // Get next upcoming class
      final nextClass = _getNextClass(enabledClasses, now);
      
      if (nextClass != null) {
        debugPrint('[WidgetService] Next class found: ${nextClass.title ?? nextClass.code}');
        final isOngoing = nextClass.start.compareTo('${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}') <= 0;
        await _saveNextClassData(nextClass, now, isOngoing);
      } else {
        debugPrint('[WidgetService] No next class found, clearing widget data');
        await HomeWidget.saveWidgetData<String>('next_class_subject', null);
        await HomeWidget.saveWidgetData<String>('next_class_time', null);
        await HomeWidget.saveWidgetData<String>('next_class_location', null);
      }
      
      // Update widgets
      debugPrint('[WidgetService] Triggering widget update on native side...');
      
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
      
      debugPrint('[WidgetService] Widget update complete');
    } catch (e, stack) {
      debugPrint('[WidgetService] Widget update failed: $e');
      debugPrint('[WidgetService] Stack trace: $stack');
    }
  }

  static ClassItem? _getNextClass(List<ClassItem> classes, DateTime now) {
    final currentDay = now.weekday; // 1 = Monday, 7 = Sunday
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    debugPrint('[WidgetService] Looking for current/next class on day $currentDay at $currentTime');
    
    ClassItem? currentClass;
    ClassItem? nextClass;
    String? minTime;
    
    for (final classItem in classes) {
      debugPrint('[WidgetService] Checking class: ${classItem.title ?? classItem.code}, day=${classItem.day}, start=${classItem.start}, end=${classItem.end}');
      
      // Check if class occurs today
      if (classItem.day != currentDay) {
        debugPrint('[WidgetService]   Skipped: wrong day (${classItem.day} != $currentDay)');
        continue;
      }
      
      // Check if class is currently ongoing
      if (classItem.start.compareTo(currentTime) <= 0 && classItem.end.compareTo(currentTime) > 0) {
        debugPrint('[WidgetService]   Found ongoing class!');
        currentClass = classItem;
        break; // Prioritize current class
      }
      
      // Check for next upcoming class
      if (classItem.start.compareTo(currentTime) > 0) {
        if (minTime == null || classItem.start.compareTo(minTime) < 0) {
          debugPrint('[WidgetService]   Selected as next class');
          minTime = classItem.start;
          nextClass = classItem;
        }
      } else {
        debugPrint('[WidgetService]   Skipped: already ended (${classItem.start} <= $currentTime < ${classItem.end})');
      }
    }
    
    final result = currentClass ?? nextClass;
    
    if (result == null) {
      debugPrint('[WidgetService] No current or upcoming class found for today');
    } else if (currentClass != null) {
      debugPrint('[WidgetService] Showing CURRENT class: ${result.title ?? result.code} (${result.start} - ${result.end})');
    } else {
      debugPrint('[WidgetService] Showing NEXT class: ${result.title ?? result.code} at ${result.start}');
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
    
    debugPrint('[WidgetService] Saving widget data:');
    debugPrint('[WidgetService]   Subject: $subject');
    debugPrint('[WidgetService]   Time: $timeLabel');
    debugPrint('[WidgetService]   Location: $location');
    debugPrint('[WidgetService]   Instructor: $instructor');
    debugPrint('[WidgetService]   Instructor Avatar: $instructorAvatar');
    debugPrint('[WidgetService]   Is Ongoing: $isOngoing');
    
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
