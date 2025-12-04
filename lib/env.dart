import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/telemetry_service.dart';

class Env {
  static late final SupabaseClient supa;
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static const supabaseUrlFromDefine = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const supabaseAnonKeyFromDefine = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  static Future<void> init() async {
    if (_initialized) {
      return;
    }

    if (!dotenv.isInitialized) {
      const candidate = '.env';
      try {
        await dotenv.load(fileName: candidate);
        TelemetryService.instance.recordEvent(
          'config_env_loaded',
          data: {'source': candidate},
        );
      } catch (e) {
        TelemetryService.instance.recordEvent(
          'config_env_missing',
          data: {'candidate': candidate, 'error': e.toString()},
        );
      }
    }

    final url = _getEnvValue('SUPABASE_URL', supabaseUrlFromDefine);
    final anonKey =
        _getEnvValue('SUPABASE_ANON_KEY', supabaseAnonKeyFromDefine);

    if (url.isEmpty || anonKey.isEmpty) {
      TelemetryService.instance.recordEvent(
        'config_supabase_missing',
        data: {'url_missing': url.isEmpty, 'key_missing': anonKey.isEmpty},
      );
      throw StateError(
        'Missing Supabase configuration. Provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define or an .env file.',
      );
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    supa = Supabase.instance.client;
    _initialized = true;
    TelemetryService.instance.recordEvent(
      'config_supabase_initialized',
      data: {'url': url},
    );
  }

  static String _getEnvValue(String key, String fallback) {
    try {
      return dotenv.maybeGet(key) ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  static Future<String?> accessToken() async {
    try {
      return supa.auth.currentSession?.accessToken;
    } catch (_) {
      return null;
    }
  }

  /// For widget tests only: inject a mock Supabase client to skip real init.
  @visibleForTesting
  static void debugInstallMock(SupabaseClient client) {
    if (_initialized) return;
    supa = client;
    _initialized = true;
  }
}
