import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/connection_monitor.dart';

void main() {
  group('ConnectionMonitor', () {
    setUp(() {
      ConnectionMonitor.resetInstance();
    });

    tearDown(() {
      ConnectionMonitor.resetInstance();
    });

    test('singleton returns same instance', () {
      final instance1 = ConnectionMonitor.instance;
      final instance2 = ConnectionMonitor.instance;
      expect(identical(instance1, instance2), true);
    });

    test('initial state is unknown', () {
      final monitor = ConnectionMonitor.instance;
      expect(monitor.state.value, ConnectionState.unknown);
    });

    test('setStateForTesting updates state', () {
      final monitor = ConnectionMonitor.instance;
      
      monitor.setStateForTesting(ConnectionState.online);
      expect(monitor.state.value, ConnectionState.online);
      expect(monitor.isOnline, true);
      expect(monitor.isOffline, false);
      
      monitor.setStateForTesting(ConnectionState.offline);
      expect(monitor.state.value, ConnectionState.offline);
      expect(monitor.isOnline, false);
      expect(monitor.isOffline, true);
    });

    test('isOnline returns true only when online', () {
      final monitor = ConnectionMonitor.instance;
      
      monitor.setStateForTesting(ConnectionState.online);
      expect(monitor.isOnline, true);
      
      monitor.setStateForTesting(ConnectionState.offline);
      expect(monitor.isOnline, false);
      
      monitor.setStateForTesting(ConnectionState.unknown);
      expect(monitor.isOnline, false);
    });

    test('isOffline returns true only when offline', () {
      final monitor = ConnectionMonitor.instance;
      
      monitor.setStateForTesting(ConnectionState.offline);
      expect(monitor.isOffline, true);
      
      monitor.setStateForTesting(ConnectionState.online);
      expect(monitor.isOffline, false);
      
      monitor.setStateForTesting(ConnectionState.unknown);
      expect(monitor.isOffline, false);
    });

    test('stopMonitoring cancels timer', () {
      final monitor = ConnectionMonitor.instance;
      monitor.startMonitoring(); // No-op in test mode
      monitor.stopMonitoring();
      // Should not throw
    });

    test('resetInstance clears singleton', () {
      final instance1 = ConnectionMonitor.instance;
      instance1.setStateForTesting(ConnectionState.online);
      
      ConnectionMonitor.resetInstance();
      
      final instance2 = ConnectionMonitor.instance;
      expect(identical(instance1, instance2), false);
      expect(instance2.state.value, ConnectionState.unknown);
    });
  });

  group('ConnectionState', () {
    test('has all expected values', () {
      expect(ConnectionState.values.length, 3);
      expect(ConnectionState.values.contains(ConnectionState.unknown), true);
      expect(ConnectionState.values.contains(ConnectionState.online), true);
      expect(ConnectionState.values.contains(ConnectionState.offline), true);
    });
  });
}
