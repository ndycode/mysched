import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/navigation_channel.dart';

void main() {
  group('NavigationChannel', () {
    test('singleton returns same instance', () {
      final instance1 = NavigationChannel.instance;
      final instance2 = NavigationChannel.instance;
      expect(identical(instance1, instance2), true);
    });

    testWidgets('init can be called multiple times safely', (tester) async {
      WidgetsFlutterBinding.ensureInitialized();
      final channel = NavigationChannel.instance;
      
      // Should not throw
      await channel.init();
      await channel.init();
      await channel.init();
    });
  });
}
