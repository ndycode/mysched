import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/user_scope.dart';
import '../test_helpers/supabase_stub.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await SupabaseTestBootstrap.ensureInitialized();
  });

  tearDown(() {
    UserScope.overrideForTests(null);
  });

  group('UserScope', () {
    test('currentUserId returns null when override returns null', () {
      UserScope.overrideForTests(() => null);
      expect(UserScope.currentUserId(), isNull);
    });

    test('currentUserId returns override value when set', () {
      UserScope.overrideForTests(() => 'test-user-123');
      expect(UserScope.currentUserId(), 'test-user-123');
    });

    test('overrideForTests can change value multiple times', () {
      UserScope.overrideForTests(() => 'user-1');
      expect(UserScope.currentUserId(), 'user-1');

      UserScope.overrideForTests(() => 'user-2');
      expect(UserScope.currentUserId(), 'user-2');

      UserScope.overrideForTests(null);
      // Without a real auth session, returns null
      expect(UserScope.currentUserId(), isNull);
    });

    test('currentUserId handles Supabase exceptions gracefully', () {
      // With stub client but no actual auth session, should return null
      UserScope.overrideForTests(null);
      expect(UserScope.currentUserId(), isNull);
    });
  });
}
