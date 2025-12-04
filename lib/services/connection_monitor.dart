import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Monitors network connectivity and provides a reactive state.
class ConnectionMonitor {
  ConnectionMonitor._();

  static ConnectionMonitor? _instance;
  static ConnectionMonitor get instance {
    _instance ??= ConnectionMonitor._();
    return _instance!;
  }

  final ValueNotifier<ConnectionState> state = ValueNotifier(ConnectionState.unknown);
  
  Timer? _checkTimer;
  static const _checkInterval = Duration(seconds: 30);
  static const _timeout = Duration(seconds: 5);
  static const bool _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');
  bool get _isTestRun =>
      _isFlutterTest || (Platform.environment['FLUTTER_TEST'] == 'true');

  /// Start periodic connectivity checks.
  void startMonitoring() {
    if (_isTestRun) return;
    _checkTimer?.cancel();
    _checkNow();
    _checkTimer = Timer.periodic(_checkInterval, (_) => _checkNow());
  }

  /// Stop monitoring.
  void stopMonitoring() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  /// Force an immediate check.
  Future<bool> checkNow() async {
    return _checkNow();
  }

  Future<bool> _checkNow() async {
    try {
      // Try to resolve a reliable host
      final result = await InternetAddress.lookup('dns.google')
          .timeout(_timeout);
      
      final hasConnection = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      state.value = hasConnection ? ConnectionState.online : ConnectionState.offline;
      return hasConnection;
    } on SocketException {
      state.value = ConnectionState.offline;
      return false;
    } on TimeoutException {
      state.value = ConnectionState.offline;
      return false;
    } catch (_) {
      state.value = ConnectionState.unknown;
      return false;
    }
  }

  /// Check if currently online (non-blocking, uses cached state).
  bool get isOnline => state.value == ConnectionState.online;

  /// Check if currently offline (non-blocking, uses cached state).
  bool get isOffline => state.value == ConnectionState.offline;

  @visibleForTesting
  static void resetInstance() {
    _instance?.stopMonitoring();
    _instance = null;
  }

  @visibleForTesting
  void setStateForTesting(ConnectionState newState) {
    state.value = newState;
  }
}

enum ConnectionState {
  unknown,
  online,
  offline,
}


