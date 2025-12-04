import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/schedule_service.dart';

void main() {
  group('ScheduleService', () {
    test('singleton returns same instance', () {
      final instance1 = ScheduleService.instance;
      final instance2 = ScheduleService.instance;
      expect(identical(instance1, instance2), true);
    });
  });
}
