import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTestBootstrap {
  static bool _initialized = false;
  static final GotrueAsyncStorage _memoryStorage = _MemoryGotrueAsyncStorage();

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    try {
      Supabase.instance.client;
      _initialized = true;
      return;
    } catch (_) {
      // not initialized yet
    }

    await Supabase.initialize(
      url: 'https://example.com',
      anonKey: 'fake-key',
      authOptions: FlutterAuthClientOptions(
        autoRefreshToken: false,
        detectSessionInUri: false,
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: _memoryStorage,
      ),
    );
    _initialized = true;
  }
}

class _MemoryGotrueAsyncStorage extends GotrueAsyncStorage {
  final Map<String, String> _store = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async => _store[key];

  @override
  Future<void> removeItem({required String key}) async {
    _store.remove(key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    _store[key] = value;
  }
}
