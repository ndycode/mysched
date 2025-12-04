import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/telemetry_service.dart';

void main() {
  tearDown(() {
    TelemetryService.reset();
  });

  test('ensureRecorder installs only when missing', () {
    final recorded = <String>[];
    TelemetryService.ensureRecorder((name, data) {
      recorded.add('$name:${data?['v']}');
    });

    // Second ensureRecorder should not override
    TelemetryService.ensureRecorder((name, _) {
      recorded.add('override-$name');
    });

    TelemetryService.instance.recordEvent('once', data: {'v': 1});
    expect(recorded, ['once:1']);
  });

  test('install overrides existing recorder explicitly', () {
    final first = <String>[];
    final second = <String>[];
    TelemetryService.ensureRecorder((name, _) => first.add(name));
    TelemetryService.install((name, _) => second.add(name));

    TelemetryService.instance.recordEvent('swap');

    expect(first, isEmpty);
    expect(second, ['swap']);
  });
}
