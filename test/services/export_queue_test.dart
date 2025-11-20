import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/export_queue.dart';

void main() {
  test('flush waits for connectivity', () async {
    var online = false;
    final queue = ExportQueue(connectivity: () async => online);
    var ran = false;
    queue.enqueue(() async => ran = true);
    await queue.flush();
    expect(ran, isFalse);
    expect(queue.pending, 1);
    online = true;
    await queue.flush();
    expect(ran, isTrue);
    expect(queue.pending, 0);
  });
  test('failed job stays queued until next flush', () async {
    final online = true;
    final attempts = <int>[0];
    final queue = ExportQueue(connectivity: () async => online);
    queue.enqueue(() async {
      if (attempts[0]++ == 0) {
        throw Exception('oops');
      }
    });
    await queue.flush();
    expect(queue.pending, 1);
    await queue.flush();
    expect(queue.pending, 0);
  });
}
