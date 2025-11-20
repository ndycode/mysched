import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/auth_service.dart';
import 'package:mysched/services/telemetry_service.dart';

class _ResetBackend implements AuthBackend {
  int attempts = 0;
  @override
  Future<void> resetPassword(String email) async {
    attempts++;
    if (attempts < 3) throw Exception('net');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  test('reset password logs retry success', () async {
    final events = <String>[];
    TelemetryService.overrideForTests(
        (n, d) => events.add('$n:${d?['attempt']}'));
    final backend = _ResetBackend();
    AuthService.overrideBackend(backend);
    await AuthService.instance.resetPassword(email: 'user@example.com');
    expect(events.contains('auth_retry_success:3'), isTrue);
    expect(backend.attempts, 3);
    AuthService.resetTestOverrides();
    TelemetryService.reset();
  });
}
