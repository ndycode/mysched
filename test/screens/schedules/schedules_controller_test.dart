import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/screens/schedules/schedules_controller.dart';
import 'package:mysched/services/auth_service.dart';
import 'package:mysched/services/schedule_repository.dart';
import 'package:mysched/services/share_service.dart';
import 'package:mysched/services/user_scope.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockScheduleApi extends ScheduleApi {
  List<ClassItem>? _cachedClasses;
  List<ClassItem> _remoteClasses = [];
  final bool _failRemote = false;
  
  // Track calls
  int setClassEnabledCalls = 0;
  int deleteCustomClassCalls = 0;
  int resetAllCalls = 0;

  @override
  List<ClassItem>? getCachedClasses() => _cachedClasses;

  @override
  Future<List<ClassItem>> getMyClasses({bool forceRefresh = false}) async {
    if (_failRemote) throw Exception('Network error');
    return _remoteClasses;
  }

  @override
  Future<void> setClassEnabled(ClassItem c, bool enable) async {
    setClassEnabledCalls++;
  }

  @override
  Future<void> deleteCustomClass(int id) async {
    deleteCustomClassCalls++;
  }

  @override
  Future<void> resetAllForCurrentUser() async {
    resetAllCalls++;
  }
}

void main() {
  late MockScheduleApi mockApi;
  late SchedulesController controller;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    
    mockApi = MockScheduleApi();
    UserScope.overrideForTests(() => 'test-user-id');
    AuthService.overrideProfileLoader(() async => {
      'full_name': 'Test User',
      'email': 'test@example.com',
      'avatar_url': 'https://example.com/avatar.png',
    });
    
    // Mock ShareService to prevent actual sharing
    ShareService.overrideForTests((params) async {
      return const ShareResult('success', ShareResultStatus.success);
    });
  });

  tearDown(() {
    UserScope.overrideForTests(null);
    AuthService.resetTestOverrides();
    ShareService.reset();
    controller.dispose();
  });

  test('Initial load from remote success', () async {
    mockApi._remoteClasses = [
      ClassItem(id: 1, day: 1, start: '08:00', end: '09:00', title: 'Math'),
    ];

    controller = SchedulesController(
      api: mockApi,
      connectivityOverride: () async => true,
    );

    // Initial state
    expect(controller.loading, true);
    
    // Wait for async init
    await Future.delayed(Duration.zero);

    expect(controller.loading, false);
    expect(controller.classes.length, 1);
    expect(controller.classes.first.title, 'Math');
    expect(controller.criticalError, null);
  });

  test('Initial load uses cache then remote', () async {
    mockApi._cachedClasses = [
      ClassItem(id: 2, day: 2, start: '10:00', end: '11:00', title: 'Science'),
    ];
    mockApi._remoteClasses = [
      ClassItem(id: 1, day: 1, start: '08:00', end: '09:00', title: 'Math'),
    ];

    controller = SchedulesController(
      api: mockApi,
      connectivityOverride: () async => true,
    );

    // Should show cached immediately
    expect(controller.classes.length, 1);
    expect(controller.classes.first.title, 'Science');
    expect(controller.loading, false);

    // Wait for remote fetch
    await Future.delayed(Duration.zero);

    // Should update to remote
    expect(controller.classes.length, 1);
    expect(controller.classes.first.title, 'Math');
  });

  test('Toggle class enabled', () async {
    mockApi._remoteClasses = [
      ClassItem(id: 1, day: 1, start: '08:00', end: '09:00', title: 'Math', enabled: true),
    ];

    controller = SchedulesController(
      api: mockApi,
      connectivityOverride: () async => true,
    );
    await Future.delayed(Duration.zero);

    bool errorCalled = false;
    await controller.toggleClassEnabled(
      controller.classes.first, 
      false, 
      onError: (_) => errorCalled = true,
    );

    expect(mockApi.setClassEnabledCalls, 1);
    expect(controller.classes.first.enabled, false);
    expect(errorCalled, false);
    expect(controller.dirty, true);
  });

  test('Delete custom class', () async {
    mockApi._remoteClasses = [
      ClassItem(id: 99, day: 1, start: '08:00', end: '09:00', title: 'Custom', isCustom: true),
    ];

    controller = SchedulesController(
      api: mockApi,
      connectivityOverride: () async => true,
    );
    await Future.delayed(Duration.zero);

    bool successCalled = false;
    bool errorCalled = false;

    await controller.deleteCustom(
      99,
      onSuccess: (_) => successCalled = true,
      onError: (_) => errorCalled = true,
    );

    expect(mockApi.deleteCustomClassCalls, 1);
    expect(successCalled, true);
    expect(errorCalled, false);
    expect(controller.dirty, true);
  });

  test('Reset schedules', () async {
    controller = SchedulesController(
      api: mockApi,
      connectivityOverride: () async => true,
    );
    await Future.delayed(Duration.zero);

    bool successCalled = false;
    await controller.resetSchedules(
      onSuccess: (_) => successCalled = true,
      onError: (_) {},
    );

    expect(mockApi.resetAllCalls, 1);
    expect(controller.classes, isEmpty);
    expect(successCalled, true);
    expect(controller.dirty, true);
  });
  
  test('Profile loading', () async {
    controller = SchedulesController(
      api: mockApi,
      connectivityOverride: () async => true,
    );
    
    // Wait for profile load
    await Future.delayed(Duration.zero);
    // ProfileCache needs a moment
    await Future.delayed(Duration.zero);

    expect(controller.profileName, 'Test User');
    expect(controller.profileEmail, 'test@example.com');
    expect(controller.profileAvatar, 'https://example.com/avatar.png');
  });
}
