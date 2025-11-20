import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/auth_service.dart';
import 'package:mysched/services/telemetry_service.dart';

class _SignupBackend implements AuthBackend {
  int attempts = 0;
  @override
  Future<void> ensureStudentIdAvailable(String studentId) async {}
  @override
  Future<void> signUp(
      {required String email,
      required String password,
      required String fullName,
      required String studentId}) async {
    attempts++;
    throw Exception('down');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  test('signup emits failure telemetry after retries', () async {
    final events = <String>[];
    TelemetryService.overrideForTests((n, _) => events.add(n));
    final backend = _SignupBackend();
    AuthService.overrideBackend(backend);
    await expectLater(
      AuthService.instance.register(
        fullName: 'Name',
        studentId: '123',
        email: 'user@example.com',
        password: 'pw',
      ),
      throwsException,
    );
    expect(events.contains('auth_retry_failed'), isTrue);
    expect(backend.attempts, 3);
    AuthService.resetTestOverrides();
    TelemetryService.reset();
  });
}
