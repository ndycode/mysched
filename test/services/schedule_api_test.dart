import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/schedule_api.dart';
import 'package:mysched/services/telemetry_service.dart';
import 'package:mysched/services/user_scope.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../test_helpers/supabase_stub.dart';

class TestScheduleApi extends ScheduleApi {
  TestScheduleApi(this._responses);

  final List<List<ClassItem>> _responses;
  int fetchCalls = 0;

  @override
  Future<List<ClassItem>> fetchClasses() async {
    final index =
        fetchCalls < _responses.length ? fetchCalls : _responses.length - 1;
    fetchCalls++;
    return _responses[index];
  }
}

ClassItem sampleItem(int id, {int day = 1, String? title}) {
  return ClassItem(
    id: id,
    day: day,
    start: '08:00',
    end: '09:00',
    title: title ?? 'Subject $id',
    code: null,
    units: null,
    room: 'R$id',
    instructor: 'Teacher',
    enabled: true,
    isCustom: false,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await SupabaseTestBootstrap.ensureInitialized();
    UserScope.overrideForTests(() => 'cache-user');
  });
  tearDownAll(() {
    UserScope.overrideForTests(null);
  });
  tearDown(() {
    TelemetryService.reset();
  });
  setUp(() {
    ScheduleApi.clearCache(userId: 'cache-user');
    ScheduleApi.setCacheTimestamp(null, userId: 'cache-user');
  });

  group('dayIntToDbString', () {
    test('maps valid day numbers to strings', () {
      expect(ScheduleApi.dayIntToDbString(1), 'Mon');
      expect(ScheduleApi.dayIntToDbString(7), 'Sun');
    });

    test('defaults to Monday when day is out of range', () {
      expect(ScheduleApi.dayIntToDbString(0), 'Mon');
      expect(ScheduleApi.dayIntToDbString(10), 'Mon');
    });
  });

  group('caching', () {
    test('uses cached classes within TTL and refreshes after expiry', () async {
      final api = TestScheduleApi([
        [sampleItem(1)],
        [sampleItem(2)],
      ]);

      final first = await api.getMyClasses();
      expect(api.fetchCalls, 1);
      expect(first.single.id, 1);

      final second = await api.getMyClasses();
      expect(api.fetchCalls, 1, reason: 'should serve from cache');
      expect(second.single.id, 1);

      ScheduleApi.setCacheTimestamp(
          DateTime.now().subtract(const Duration(minutes: 5)),
          userId: 'cache-user');

      final third = await api.getMyClasses();
      expect(api.fetchCalls, 2, reason: 'cache expired, fetch again');
      expect(third.single.id, 2);
    });
  });

  group('retry logic', () {
    test('retries transient errors then succeeds', () async {
      final events = <String>[];
      TelemetryService.overrideForTests((name, _) => events.add(name));
      final api = ScheduleApi();
      var attempts = 0;

      final result = await api.debugRetry<int>(
        () async {
          attempts++;
          if (attempts < 3) throw Exception('network timeout');
          return 42;
        },
        operationName: 'retry_test',
      );

      expect(result, 42);
      expect(attempts, 3);
      expect(events.contains('schedule_api_retry_success'), isTrue);
    });

    test('aborts on non-retryable error', () async {
      final api = ScheduleApi();
      var attempts = 0;

      expect(
        () => api.debugRetry<void>(
          () async {
            attempts++;
            throw const AuthException('not allowed');
          },
          operationName: 'no_retry',
        ),
        throwsA(isA<AuthException>()),
      );
      expect(attempts, 1);
    });

    test('classifies retryable errors', () {
      final api = ScheduleApi();
      expect(
        api.debugIsRetryable(Exception('socket timeout connecting to host')),
        isTrue,
      );
      expect(
        api.debugIsRetryable(Exception('permission denied')),
        isFalse,
      );
      expect(api.debugIsRetryable(const AuthException('bad')), isFalse);
      expect(
        api.debugIsRetryable(Exception('duplicate key value')),
        isFalse,
      );
    });
  });
}
