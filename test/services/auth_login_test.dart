import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mysched/services/auth_service.dart';
import 'package:mysched/services/telemetry_service.dart';

class _LoginBackend implements AuthBackend {
  int calls = 0;
  @override
  Future<AuthResponse> signInWithPassword(
      {required String email, required String password}) async {
    if (calls++ == 0) throw Exception('fail');
    return AuthResponse.fromJson({
      'access_token': 'token',
      'token_type': 'bearer',
      'user': {
        'id': 'u1',
        'aud': 'authenticated',
      },
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  test('login retries then succeeds', () async {
    final events = <String>[];
    TelemetryService.overrideForTests(
        (name, data) => events.add('$name:${data?['attempt']}'));
    AuthService.overrideProfileLoader(() async => {'ok': true});
    AuthService.overrideBackend(_LoginBackend());
    await AuthService.instance.login(email: 'user@example.com', password: 'pw');
    expect(events.contains('auth_retry_success:2'), isTrue);
    AuthService.resetTestOverrides();
    TelemetryService.reset();
  });
}
