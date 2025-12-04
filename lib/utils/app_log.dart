import 'package:flutter/foundation.dart';

import '../app/constants.dart';

/// Lightweight logging helper that prints structured tags to logcat.
///
/// Usage:
/// ```dart
/// AppLog.debug('LocalNotifs', 'Scheduled alarm', data: {'id': id});
/// AppLog.error('Alarm', 'Failed to schedule', error: err, stack: stack);
/// ```
class AppLog {
  const AppLog._();

  static const _rootTag = AppConstants.appName;

  static void debug(
    String scope,
    String message, {
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    if (!kDebugMode) return;
    debugPrint(_format(scope, 'DEBUG', message, data: data));
  }

  static void info(
    String scope,
    String message, {
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    debugPrint(_format(scope, 'INFO', message, data: data));
  }

  static void warn(
    String scope,
    String message, {
    Map<String, Object?> data = const <String, Object?>{},
    Object? error,
  }) {
    debugPrint(_format(scope, 'WARN', message, data: data, error: error));
  }

  static void error(
    String scope,
    String message, {
    Map<String, Object?> data = const <String, Object?>{},
    Object? error,
    StackTrace? stack,
  }) {
    final buffer = StringBuffer(
      _format(scope, 'ERROR', message, data: data, error: error),
    );
    if (stack != null) {
      buffer.write('\n$stack');
    }
    debugPrint(buffer.toString());
  }

  static String _format(
    String scope,
    String level,
    String message, {
    Map<String, Object?> data = const <String, Object?>{},
    Object? error,
  }) {
    final buffer = StringBuffer('[$_rootTag][$level][$scope] $message');
    if (error != null) {
      buffer.write(' | error=$error');
    }
    if (data.isNotEmpty) {
      buffer.write(' | ');
      buffer.write(
        data.entries.map((entry) => '${entry.key}=${entry.value}').join(' '),
      );
    }
    return buffer.toString();
  }
}
