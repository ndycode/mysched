import 'dart:async';

import 'test_helpers/supabase_stub.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await SupabaseTestBootstrap.ensureInitialized();
  await testMain();
}
