import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/admin_service.dart';

void main() {
  group('statusRank', () {
    test('orders statuses as expected', () {
      expect(statusRank('new'), lessThan(statusRank('in_review')));
      expect(statusRank('in_review'), lessThan(statusRank('resolved')));
      expect(statusRank('resolved'), lessThan(statusRank('archived')));
    });

    test('unknown statuses fall to the end', () {
      final rankUnknown = statusRank('mystery');
      expect(rankUnknown, greaterThan(statusRank('resolved')));
    });
  });
}
