import 'package:supabase_flutter/supabase_flutter.dart';

typedef UserIdResolver = String? Function();

/// Centralized accessor for the current authenticated user id.
class UserScope {
  UserScope._();

  static UserIdResolver? _override;

  static void overrideForTests(UserIdResolver? resolver) {
    _override = resolver;
  }

  static String? currentUserId() {
    final resolver = _override;
    if (resolver != null) {
      return resolver();
    }
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }
}
