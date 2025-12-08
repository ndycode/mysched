import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/offline_cache_service.dart';
import 'package:mysched/services/schedule_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

ClassItem _sampleItem(int id) {
  return ClassItem(
    id: id,
    day: 1 + id % 7,
    start: '08:0$id',
    end: '09:0$id',
    title: 'Class $id',
    code: 'C$id',
    units: 3,
    room: 'Room $id',
    instructor: 'Doe, Jane',
    enabled: id.isEven,
    isCustom: id.isOdd,
  );
}

void main() {
  const userId = 'test-user';

  setUp(() {
    OfflineCacheService.resetForTests();
    SharedPreferences.setMockInitialValues({});
  });

  test('saveSchedule persists and readSchedule restores data', () async {
    final service = await OfflineCacheService.instance();
    final records = [
      _sampleItem(1),
      _sampleItem(2).copyWith(enabled: false, isCustom: true),
    ];

    await service.saveSchedule(userId: userId, items: records);

    final restored = await service.readSchedule(userId);
    expect(restored, isNotNull);
    expect(restored, hasLength(2));
    expect(restored!.first.title, 'Class 1');
    expect(restored.last.isCustom, isTrue);
    expect(restored.last.enabled, isFalse);
  });

  test('clearSchedule removes cached data', () async {
    final service = await OfflineCacheService.instance();
    await service.saveSchedule(userId: userId, items: [_sampleItem(3)]);

    await service.clearSchedule(userId: userId);

    final restored = await service.readSchedule(userId);
    expect(restored, isNull);
  });

  test('readSchedule ignores non-map entries', () async {
    OfflineCacheService.resetForTests();
    SharedPreferences.setMockInitialValues({
      'offline_schedule_v1':
          '{"$userId":[{"id":1,"day":1,"start":"08:00","end":"09:00","title":"Valid","enabled":true,"isCustom":false},"bad"]}',
    });

    final service = await OfflineCacheService.instance();
    final restored = await service.readSchedule(userId);
    expect(restored, isNotNull);
    expect(restored, hasLength(1));
    expect(restored!.single.title, 'Valid');
  });

  test('readSchedule returns null when payload is malformed', () async {
    OfflineCacheService.resetForTests();
    SharedPreferences.setMockInitialValues({
      'offline_schedule_v1': 'not-json',
    });

    final service = await OfflineCacheService.instance();
    final restored = await service.readSchedule(userId);
    expect(restored, isNull);
  });
}
