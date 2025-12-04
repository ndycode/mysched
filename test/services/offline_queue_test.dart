import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/connection_monitor.dart';
import 'package:mysched/services/offline_queue.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    OfflineQueue.resetInstance();
    ConnectionMonitor.resetInstance();
  });

  test('enqueue tracks pending mutations', () async {
    ConnectionMonitor.instance.setStateForTesting(ConnectionState.offline);
    final queue = OfflineQueue.instance;
    await queue.init();

    await queue.enqueue(
      QueuedMutation.create(type: 'demo', payload: {'foo': 'bar'}),
    );

    expect(queue.pendingCount.value, 1);
    final pending = await queue.getPending();
    expect(pending, hasLength(1));
    expect(pending.single.type, 'demo');
  });

  test('processQueue runs handlers when online', () async {
    ConnectionMonitor.instance.setStateForTesting(ConnectionState.online);
    final queue = OfflineQueue.instance;
    await queue.init();

    var processed = 0;
    OfflineQueue.registerHandler('process', (payload) async {
      processed += payload['value'] as int;
    });

    await queue.enqueue(
      QueuedMutation.create(type: 'process', payload: {'value': 2}),
    );
    expect(queue.pendingCount.value, 1);

    await queue.processQueue();

    expect(processed, 2);
    expect(queue.pendingCount.value, 0);
    final remaining = await queue.getPending();
    expect(remaining, isEmpty);
  });

  test('processQueue does nothing when offline', () async {
    ConnectionMonitor.instance.setStateForTesting(ConnectionState.offline);
    final queue = OfflineQueue.instance;
    await queue.init();

    var processed = 0;
    OfflineQueue.registerHandler('offline', (payload) async {
      processed++;
    });

    await queue.enqueue(
      QueuedMutation.create(type: 'offline', payload: const {}),
    );

    await queue.processQueue();

    expect(processed, 0);
    expect(queue.pendingCount.value, 1);
  });

  test('mutations drop after max retries', () async {
    ConnectionMonitor.instance.setStateForTesting(ConnectionState.online);
    final queue = OfflineQueue.instance;
    await queue.init();

    var attempts = 0;
    OfflineQueue.registerHandler('fail', (payload) async {
      attempts++;
      throw Exception('fail');
    });

    await queue.enqueue(
      QueuedMutation.create(type: 'fail', payload: const {}),
    );

    // Exceed the retry budget (5 attempts allowed)
    for (var i = 0; i < 5; i++) {
      await queue.processQueue();
    }

    expect(attempts, 5);
    expect(queue.pendingCount.value, 0);
    final pending = await queue.getPending();
    expect(pending, isEmpty);
  });
}
