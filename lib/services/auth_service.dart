// lib/services/auth_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../env.dart';
import '../ui/theme/motion.dart';
import '../ui/theme/tokens.dart';
import '../utils/local_notifs.dart';
import '../utils/validation_utils.dart';
import 'instructor_service.dart';
import 'offline_cache_service.dart';
import 'schedule_repository.dart';
import 'telemetry_service.dart';

abstract class AuthBackend {
  Future<void> ensureStudentIdAvailable(String studentId);
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
  });
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<void> resetPassword(String email);
}

class _SupabaseAuthBackend implements AuthBackend {
  _SupabaseAuthBackend(this._client);

  final SupabaseClient Function() _client;

  @override
  Future<void> ensureStudentIdAvailable(String studentId) async {
    final sid = studentId.trim();
    final ok =
        await _client().rpc('is_student_id_available', params: {'p_id': sid});
    if (ok is bool && !ok) {
      throw Exception('EmailOrId: student_id_in_use');
    }
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
  }) async {
    try {
      final res = await _client().auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName.trim(),
          'student_id': studentId.trim(),
        },
      );
      if (res.user == null) throw Exception('Signup: failed');
      // Note: Supabase signUp already sends a confirmation email
      // User remains in unconfirmed state until email is verified
    } on AuthException catch (e) {
      // Log the actual error for debugging
      TelemetryService.instance.recordEvent(
        'signup_auth_exception',
        data: {
          'message': e.message,
          'statusCode': e.statusCode ?? 'null',
        },
      );
      
      final m = e.message.toLowerCase();
      // Check for duplicate email errors
      if (m.contains('user already registered') || 
          m.contains('already registered') ||
          m.contains('duplicate') ||
          m.contains('unique constraint') ||
          m.contains('already exists') ||
          (m.contains('email') && m.contains('taken'))) {
        throw Exception('EmailOrId: email_in_use');
      }
      rethrow;
    } catch (e) {
      // Log the actual error for debugging
      TelemetryService.instance.recordEvent(
        'signup_error_debug',
        data: {'error': e.toString(), 'type': e.runtimeType.toString()},
      );
      
      final m = e.toString().toLowerCase();
      // Check for duplicate email errors in generic exceptions
      if (m.contains('user already registered') || 
          m.contains('already registered') ||
          m.contains('duplicate') ||
          m.contains('unique constraint') ||
          m.contains('already exists') ||
          (m.contains('email') && m.contains('taken'))) {
        throw Exception('EmailOrId: email_in_use');
      }
      rethrow;
    }
  }

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _client().auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() => _client().auth.signOut();

  @override
  Future<void> resetPassword(String email) =>
      _client().auth.resetPasswordForEmail(email.trim());
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static AuthBackend? _testBackend;
  static Future<void> Function(Duration duration)? _delayOverride;
  static Future<Map<String, dynamic>?> Function()? _profileOverride;
  static Future<void> Function({required String email, required String token})?
      _verifyOtpOverride;
  static Future<void> Function({
    required String fullName,
    required String studentId,
  })? _profileUpdateOverride;
  static Future<void> Function({required String email})? _resendOtpOverride;
  static Future<void> Function({required String email, required String token})?
      _verifyEmailChangeOverride;
  static Future<void> Function({required String email})?
      _resendEmailChangeOverride;
  Future<void> _warmProfileCache() async {
    Map<String, dynamic>? profile;
    for (var i = 0; i < 3; i++) {
      profile = await _loadAndPersistProfile();
      if (profile != null) break;
      await _sleep(AppMotionSystem.standard); // 200ms
    }
  }

  AuthBackend get _backend => _testBackend ?? _SupabaseAuthBackend(() => _sb);

  Future<void> _sleep(Duration duration) {
    final delay = _delayOverride;
    return delay == null ? Future.delayed(duration) : delay(duration);
  }

  static void overrideBackend(AuthBackend backend) {
    _testBackend = backend;
  }

  static void overrideDelay(Future<void> Function(Duration duration) delay) {
    _delayOverride = delay;
  }

  static void overrideProfileLoader(
    Future<Map<String, dynamic>?> Function() loader,
  ) {
    _profileOverride = loader;
  }

  static void overrideVerifyOtp(
    Future<void> Function({required String email, required String token})
        handler,
  ) {
    _verifyOtpOverride = handler;
  }

  static void overrideResendOtp(
    Future<void> Function({required String email}) handler,
  ) {
    _resendOtpOverride = handler;
  }

  static void overrideVerifyEmailChangeOtp(
    Future<void> Function({required String email, required String token})
        handler,
  ) {
    _verifyEmailChangeOverride = handler;
  }

  static void overrideProfileUpdater(
    Future<void> Function(
            {required String fullName, required String studentId})?
        handler,
  ) {
    _profileUpdateOverride = handler;
  }

  static void overrideResendEmailChangeOtp(
    Future<void> Function({required String email}) handler,
  ) {
    _resendEmailChangeOverride = handler;
  }

  static void resetTestOverrides() {
    _testBackend = null;
    _delayOverride = null;
    _profileOverride = null;
    _verifyOtpOverride = null;
    _resendOtpOverride = null;
    _verifyEmailChangeOverride = null;
    _resendEmailChangeOverride = null;
  }

  @visibleForTesting
  static bool shouldRetryOtpError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.isEmpty) return true;

    final invalidCode = (message.contains('invalid') &&
            (message.contains('otp') ||
                message.contains('token') ||
                message.contains('code'))) ||
        message.contains('invalid otp') ||
        message.contains('verify_invalid_code');
    final expiredCode =
        message.contains('expired') || message.contains('verify_expired');
    final missingEmail = message.contains('missing email') ||
        message.contains('verify_missing_email');
    final notFound = message.contains('not found');
    final rateLimited = message.contains('rate limit') ||
        message.contains('ratelimit') ||
        message.contains('too many requests') ||
        message.contains('block');

    return !(invalidCode ||
        expiredCode ||
        missingEmail ||
        notFound ||
        rateLimited);
  }

  Future<SharedPreferences> _sp() => SharedPreferences.getInstance();
  SupabaseClient get _sb => Env.supa;

  int _stableIntFromUuid(String uuid) {
    const int fnvPrime = 16777619;
    int hash = 0x811c9dc5;
    for (final cu in uuid.codeUnits) {
      hash ^= cu;
      hash = (hash * fnvPrime) & 0xffffffff;
    }
    if (hash & 0x80000000 != 0) hash = hash ^ 0x80000000;
    return hash;
  }

  Future<Map<String, dynamic>?> _loadAndPersistProfile() async {
    final override = _profileOverride;
    if (override != null) return override();
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return null;

    final rows = await _sb.from('profiles').select().eq('id', uid).limit(1);
    final list = (rows as List).cast<Map<String, dynamic>>();
    final profile = list.isNotEmpty ? list.first : null;

    final sp = await _sp();
    final av = profile?['avatar_url'];
    if (av is String && av.isNotEmpty) {
      await sp.setString('avatar_url', av);
    }

    final appUserId = profile?['app_user_id'];
    final asInt = appUserId is int ? appUserId : _stableIntFromUuid(uid);
    await sp.setInt('userId', asInt);

    return profile;
  }

  Future<T> _runWithAuthRetry<T>({
    required String operation,
    required Future<T> Function() task,
    bool Function(Object error)? shouldRetry,
  }) async {
    const maxAttempts = 3;
    var attempt = 0;
    var delay = AppMotionSystem.medium; // 300ms
    while (true) {
      attempt += 1;
      try {
        final result = await task();
        if (attempt > 1) {
          TelemetryService.instance.recordEvent(
            'auth_retry_success',
            data: {'operation': operation, 'attempt': attempt},
          );
        }
        return result;
      } catch (e) {
        final retryAllowed = shouldRetry == null ? true : shouldRetry(e);
        if (!retryAllowed || attempt >= maxAttempts) {
          TelemetryService.instance.recordEvent(
            'auth_retry_failed',
            data: {
              'operation': operation,
              'attempt': attempt,
              'error': e.toString()
            },
          );
          rethrow;
        }
        await _sleep(delay);
        delay *= 2;
      }
    }
  }

  Future<void> register({
    required String fullName,
    required String studentId,
    required String email,
    required String password,
  }) async {
    await _runWithAuthRetry<void>(
      operation: 'signup_check_id',
      task: () => _backend.ensureStudentIdAvailable(studentId),
      shouldRetry: (error) {
        final message = error.toString().toLowerCase();
        final studentInUse = message.contains('student') &&
            (message.contains('in_use') || message.contains('already used'));
        return !studentInUse;
      },
    );
    await _runWithAuthRetry<void>(
      operation: 'signup',
      task: () => _backend.signUp(
        email: email,
        password: password,
        fullName: fullName,
        studentId: studentId,
      ),
      shouldRetry: (error) {
        final message = error.toString().toLowerCase();
        final emailConflict = message.contains('emailorid') ||
            message.contains('email_or_id') ||
            message.contains('already registered') ||
            (message.contains('email') && message.contains('in use')) ||
            (message.contains('email') && message.contains('already used'));
        if (emailConflict) {
          return false;
        }
        return true;
      },
    );
  }

  Future<void> updateProfileDetails({
    required String fullName,
    required String studentId,
  }) async {
    final normalizedName = fullName.trim();
    if (normalizedName.length < 3) {
      throw Exception('profile_invalid_name');
    }
    final normalizedId = studentId.trim().toUpperCase();
    if (!ValidationUtils.isValidStudentId(normalizedId)) {
      throw Exception('profile_invalid_student_id');
    }
    final override = _profileUpdateOverride;
    if (override != null) {
      await override(fullName: normalizedName, studentId: normalizedId);
      return;
    }

    final uid = _sb.auth.currentUser?.id;
    if (uid == null) throw Exception('profile_not_authenticated');

    try {
      String? currentId;
      final List<dynamic> rows = await _sb
          .from('profiles')
          .select('student_id')
          .eq('id', uid)
          .limit(1);
      if (rows.isNotEmpty) {
        final map = Map<String, dynamic>.from(rows.first as Map);
        currentId = (map['student_id'] ?? '').toString().toUpperCase();
      }

      final changedId = (currentId ?? '') != normalizedId;
      if (changedId) {
        await _backend.ensureStudentIdAvailable(normalizedId);
      }

      await _sb.from('profiles').upsert(
        {
          'id': uid,
          'full_name': normalizedName,
          'student_id': normalizedId,
        },
        onConflict: 'id',
      );

      await _warmProfileCache();
      TelemetryService.instance.recordEvent(
        'profile_updated',
        data: {'student_id_changed': changedId},
      );
    } catch (error) {
      final message = error.toString().toLowerCase();
      if (message.contains('student') &&
          (message.contains('in_use') || message.contains('already'))) {
        throw Exception('profile_student_id_in_use');
      }
      if (message.contains('not authenticated')) {
        throw Exception('profile_not_authenticated');
      }
      throw Exception('profile_update_failed');
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final em = email.trim().toLowerCase();
    if (em.isEmpty || password.isEmpty) {
      throw Exception('Login: missing');
    }

    try {
      final r = await _runWithAuthRetry<AuthResponse>(
        operation: 'login',
        task: () => _backend
            .signInWithPassword(email: em, password: password)
            .timeout(AppTokens.durations.networkTimeout),
      );
      if (r.session == null) throw Exception('Login: failed');

      await _warmProfileCache();
      // Check if user is an instructor after successful login
      await InstructorService.instance.checkInstructorStatus();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('email not confirmed') ||
          msg.contains('confirm_email')) {
        throw Exception('Login: confirm_email');
      }
      if (msg.contains('invalid')) {
        throw Exception('Login: invalid_credentials');
      }
      if (msg.contains('timeout')) {
        throw Exception('Login: timeout');
      }
      throw Exception('Login: error');
    }
  }

  Future<void> logout() async {
    final previousUid = _sb.auth.currentUser?.id;
    await _sb.auth.signOut();
    // Clear instructor status on logout
    InstructorService.instance.clear();
    final sp = await _sp();
    await sp.remove('userId');
    await sp.remove('avatar_url');
    ScheduleApi.invalidateCache(userId: previousUid);
    try {
      final cache = await OfflineCacheService.instance();
      if (previousUid != null) {
        await cache.clearSchedule(userId: previousUid);
      } else {
        await cache.clearSchedule();
      }
    } catch (_) {
      // Ignore cache clear failures; proceed with logout.
    }
    // Clear any scheduled local notifications on logout (Android-only)
    if (Platform.isAndroid) {
      final scheduled = await LocalNotifs.scheduledIdMap(userId: previousUid);
      final ids = scheduled.values.expand((ids) => ids).toSet();
      if (ids.isNotEmpty) {
        await LocalNotifs.cancelMany(ids, userId: previousUid);
      }
      await LocalNotifs.clearPersistentState(userId: previousUid);
    }
  }

  Future<void> resetPassword({required String email}) async {
    await _runWithAuthRetry<void>(
      operation: 'reset_password',
      task: () => _backend.resetPassword(email),
    );
  }

Future<Map<String, dynamic>?> me() async => _loadAndPersistProfile();

  /// Ensures a profile row exists for the given user.
  /// Used for OAuth sign-ins (Google) where profile may not be auto-created.
  /// Only sets avatar_url if the profile doesn't already have one.
  Future<void> _ensureProfileExists({
    required String userId,
    String? email,
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      // First, check if profile already exists with an avatar
      final existing = await _sb
          .from('profiles')
          .select('avatar_url')
          .eq('id', userId)
          .maybeSingle();

      final data = <String, dynamic>{'id': userId};
      if (email != null && email.isNotEmpty) {
        data['email'] = email;
      }
      if (fullName != null && fullName.isNotEmpty) {
        data['full_name'] = fullName;
      }
      // Only set avatar_url if profile doesn't already have one
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        final existingAvatar = existing?['avatar_url'] as String?;
        if (existingAvatar == null || existingAvatar.isEmpty) {
          data['avatar_url'] = avatarUrl;
        }
      }

      await _sb.from('profiles').upsert(data, onConflict: 'id');
    } catch (e) {
      // Log but don't fail sign-in if profile creation fails
      TelemetryService.instance.logError(
        'profile_ensure_failed',
        error: e,
        data: {'userId': userId},
      );
    }
  }

  /// Checks if the current user's profile is complete (has student_id).
  /// Returns true if profile is complete, false if student_id is missing.
  Future<bool> isProfileComplete() async {
    final profile = await _loadAndPersistProfile();
    if (profile == null) return false;

    final studentId = profile['student_id'];
    return studentId != null &&
        studentId is String &&
        studentId.trim().isNotEmpty;
  }

  /// Email change with password check + Supabase OTP verification.
  Future<void> updateEmailWithPassword({
    required String currentEmail,
    required String currentPassword,
    required String newEmail,
  }) async {
    final em = currentEmail.trim().toLowerCase();
    final ne = newEmail.trim().toLowerCase();
    if (ne == em) {
      throw Exception('same_email');
    } // short-circuit

    // 1) re-auth for password confirmation; normalize error message
    try {
      final r = await _sb.auth
          .signInWithPassword(email: em, password: currentPassword);
      if (r.session == null) throw Exception('invalid_password');
    } catch (_) {
      throw Exception('invalid_password');
    }

    // 2) ask Supabase to start email change OTP flow
    try {
      await _sb.auth.updateUser(UserAttributes(email: ne));
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already') || msg.contains('exists')) {
        throw Exception('email_in_use');
      }
      throw Exception('email_change_failed');
    } catch (_) {
      throw Exception('email_change_failed');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // 0) sanity
    if (newPassword.length < 8) {
      throw Exception('weak_password');
    }
    // 1) re-auth to verify current password
    final u = _sb.auth.currentUser;
    final email = u?.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) throw Exception('not_signed_in');

    // check same password (cheap client-side)
    if (currentPassword == newPassword) {
      throw Exception('same_password');
    }

    try {
      final r = await _sb.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );
      if (r.session == null) throw Exception('invalid_password');
    } catch (_) {
      throw Exception('invalid_password');
    }

    // 2) update password
    await _sb.auth.updateUser(UserAttributes(password: newPassword));

    // 3) refresh auth state
    await _sb.auth.refreshSession();
    await _sb.auth.getUser();
  }

  Future<void> verifySignupCode({
    required String email,
    required String token,
  }) async {
    final override = _verifyOtpOverride;
    if (override != null) return override(email: email, token: token);
    final normalizedEmail = email.trim().toLowerCase();
    final code = token.trim();
    if (normalizedEmail.isEmpty) {
      throw Exception('verify_missing_email');
    }
    if (code.length != 6) {
      throw Exception('verify_invalid_code');
    }

    try {
      final response = await _runWithAuthRetry<AuthResponse>(
        operation: 'verify_signup_otp',
        shouldRetry: shouldRetryOtpError,
        task: () async {
          try {
            return await _sb.auth.verifyOTP(
              email: normalizedEmail,
              token: code,
              type: OtpType.email,
            );
          } catch (_) {
            return _sb.auth.verifyOTP(
              email: normalizedEmail,
              token: code,
              type: OtpType.signup,
            );
          }
        },
      );
      if (response.session == null) {
        throw Exception('verify_no_session');
      }
      await _warmProfileCache();
      // Check if verified user is an instructor
      await InstructorService.instance.checkInstructorStatus();
    } catch (error) {
      final message = error.toString().toLowerCase();
      if (message.contains('expired')) {
        throw Exception('verify_expired');
      }
      if (message.contains('invalid') ||
          message.contains('not found') ||
          message.contains('otp')) {
        throw Exception('verify_invalid_code');
      }
      if (message.contains('block') || message.contains('rate')) {
        throw Exception('verify_rate_limited');
      }
      rethrow;
    }
  }

  Future<void> resendSignupCode({
    required String email,
  }) async {
    final override = _resendOtpOverride;
    if (override != null) return override(email: email);
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw Exception('verify_missing_email');
    }
    try {
      await _runWithAuthRetry<void>(
        operation: 'resend_signup_otp',
        shouldRetry: shouldRetryOtpError,
        task: () async {
          await _sb.auth.signInWithOtp(
            email: normalizedEmail,
            shouldCreateUser: false,
          );
        },
      );
    } catch (error) {
      final message = error.toString().toLowerCase();
      if (message.contains('block') || message.contains('rate')) {
        throw Exception('verify_rate_limited');
      }
      rethrow;
    }
  }

  Future<void> verifyEmailChangeCode({
    required String email,
    required String token,
  }) async {
    final override = _verifyEmailChangeOverride;
    if (override != null) return override(email: email, token: token);
    final normalizedEmail = email.trim().toLowerCase();
    final code = token.trim();
    if (normalizedEmail.isEmpty) {
      throw Exception('verify_missing_email');
    }
    if (code.length != 6) {
      throw Exception('verify_invalid_code');
    }
    try {
      await _runWithAuthRetry<AuthResponse>(
        operation: 'verify_email_change',
        shouldRetry: shouldRetryOtpError,
        task: () => _sb.auth.verifyOTP(
          email: normalizedEmail,
          token: code,
          type: OtpType.emailChange,
        ),
      );
      await _sb.auth.refreshSession();
      final user = (await _sb.auth.getUser()).user;
      if (user != null) {
        await _sb
            .from('profiles')
            .upsert({'id': user.id, 'email': user.email}, onConflict: 'id');
      }
      await _warmProfileCache();
    } catch (error) {
      final message = error.toString().toLowerCase();
      if (message.contains('expired')) {
        throw Exception('verify_expired');
      }
      if (message.contains('invalid') ||
          message.contains('otp') ||
          message.contains('not found')) {
        throw Exception('verify_invalid_code');
      }
      if (message.contains('block') || message.contains('rate')) {
        throw Exception('verify_rate_limited');
      }
      rethrow;
    }
  }

  Future<void> resendEmailChangeCode({required String email}) async {
    final override = _resendEmailChangeOverride;
    if (override != null) return override(email: email);
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw Exception('verify_missing_email');
    }
    try {
      await _runWithAuthRetry<void>(
        operation: 'resend_email_change',
        shouldRetry: shouldRetryOtpError,
        task: () => _sb.auth.resend(
          type: OtpType.emailChange,
          email: normalizedEmail,
        ),
      );
    } catch (error) {
      final message = error.toString().toLowerCase();
      if (message.contains('block') || message.contains('rate')) {
        throw Exception('verify_rate_limited');
      }
      rethrow;
    }
  }

  /// Verify password reset OTP code only (without setting password).
  /// Returns true if verification succeeded and user is now authenticated.
  Future<void> verifyPasswordResetCode({
    required String email,
    required String token,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final code = token.trim();
    if (normalizedEmail.isEmpty) {
      throw Exception('verify_missing_email');
    }
    if (code.length != 6) {
      throw Exception('verify_invalid_code');
    }
    try {
      await _runWithAuthRetry<AuthResponse>(
        operation: 'verify_password_reset',
        shouldRetry: shouldRetryOtpError,
        task: () => _sb.auth.verifyOTP(
          email: normalizedEmail,
          token: code,
          type: OtpType.recovery,
        ),
      );
    } catch (error) {
      final message = error.toString().toLowerCase();
      if (message.contains('expired')) {
        throw Exception('verify_expired');
      }
      if (message.contains('invalid') ||
          message.contains('otp') ||
          message.contains('not found')) {
        throw Exception('verify_invalid_code');
      }
      if (message.contains('block') || message.contains('rate')) {
        throw Exception('verify_rate_limited');
      }
      rethrow;
    }
  }

  /// Set new password after successful OTP verification.
  /// Must be called after verifyPasswordResetCode succeeds.
  Future<void> setNewPassword({required String newPassword}) async {
    if (newPassword.length < 8) {
      throw Exception('weak_password');
    }
    try {
      await _sb.auth.updateUser(UserAttributes(password: newPassword));
      await _sb.auth.refreshSession();
    } catch (error) {
      final message = error.toString().toLowerCase();
      if (message.contains('weak') || message.contains('password')) {
        throw Exception('weak_password');
      }
      rethrow;
    }
  }

  /// Resend password reset OTP code.
  Future<void> resendPasswordResetCode({required String email}) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw Exception('verify_missing_email');
    }
    try {
      await _runWithAuthRetry<void>(
        operation: 'resend_password_reset',
        shouldRetry: shouldRetryOtpError,
        task: () => _backend.resetPassword(normalizedEmail),
      );
    } catch (error) {
      final message = error.toString().toLowerCase();
      if (message.contains('block') || message.contains('rate')) {
        throw Exception('verify_rate_limited');
      }
      rethrow;
    }
  }

  Future<void> deleteAccount({required String password}) async {
    final u = _sb.auth.currentUser;
    if (u == null) throw Exception('Not signed in.');
    final email = u.email ?? '';
    if (email.isEmpty) {
      throw Exception('No email associated with this account.');
    }

    // Re-authenticate to confirm the user truly owns the session
    final r = await _sb.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    if (r.session == null) {
      throw Exception('Incorrect password. Please try again.');
    }

    // Call Edge Function (uses current user's JWT automatically)
    final resp = await _sb.functions.invoke('delete_account');
    if (resp.data is! Map || resp.data['ok'] != true) {
      // FunctionsResponse in supabase_flutter v2 returns `data` or throws
      throw Exception('Delete failed. Please try again.');
    }

    // Clear local state and sign out
    await logout();
  }

  Future<String> uploadAvatar(String filePath) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');

    final file = File(filePath);

    // (optional) size guard: 5 MB
    final bytes = await file.length();
    if (bytes > 5 * 1024 * 1024) {
      throw Exception('Image too large (max 5MB).');
    }

    // pick MIME/ext from path
    final ext = filePath.split('.').last.toLowerCase();
    final mime = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'jpg' || 'jpeg' => 'image/jpeg',
      _ => 'image/jpeg',
    };

    // always overwrite same object -> no clutter
    final path = 'user_$uid/avatar.$ext';

    await _sb.storage.from('avatars').upload(
          path,
          file,
          fileOptions: FileOptions(
            upsert: true, // <-- overwrite existing avatar
            contentType: mime,
          ),
        );

    final url = _sb.storage.from('avatars').getPublicUrl(path);
    // cache-bust so UI refreshes immediately
    final bust = '$url?ts=${DateTime.now().millisecondsSinceEpoch}';

    await _sb.from('profiles').upsert(
      {'id': uid, 'avatar_url': bust},
      onConflict: 'id',
    );

    final sp = await _sp();
    await sp.setString('avatar_url', bust);

    return bust;
  }

  /// Checks if an error indicates a stale/expired session that cannot be recovered.
  /// When true, the user should be forced to re-login.
  static bool isStaleSessionError(Object error) {
    final message = error.toString().toLowerCase();
    
    // Auth exceptions indicating invalid session
    if (message.contains('not authenticated') ||
        message.contains('invalid refresh token') ||
        message.contains('refresh token expired') ||
        message.contains('refresh token not found') ||
        message.contains('session expired') ||
        message.contains('jwt expired')) {
      return true;
    }
    
    // Rate limiting during auth refresh attempts
    if ((message.contains('rate limit') || message.contains('too many requests')) &&
        (message.contains('auth') || message.contains('refresh') || message.contains('token'))) {
      return true;
    }
    
    return false;
  }

  /// Force logout and clear stale session state.
  /// Call this when a stale session is detected to ensure clean re-login.
  Future<void> forceRelogin() async {
    TelemetryService.instance.recordEvent('auth_force_relogin');
    try {
      await logout();
    } catch (_) {
      // Ignore errors during forced logout - session is already invalid
    }
  }

  /// Sign in with Google using native Google Sign-In flow.
  /// Requires Google OAuth to be configured in Supabase Dashboard.
  /// 
  /// Setup required:
  /// 1. Enable Google provider in Supabase Dashboard > Authentication > Providers
  /// 2. Add Web Client ID and Secret from Google Cloud Console
  /// 3. For Android: Add SHA-1 fingerprint and create Android OAuth client
  /// 4. For iOS: Add iOS OAuth client and configure URL schemes
  Future<void> signInWithGoogle() async {
    // Web client ID from Google Cloud Console (same one used in Supabase Dashboard)
    const webClientId = '740244053742-ft4o4kgjp9apm9odqd00hpmpp5rrn8gt.apps.googleusercontent.com';
    // iOS client ID - create separate iOS OAuth client in Google Cloud Console
    // For now, using web client ID as placeholder (iOS setup required later)
    const iosClientId = '740244053742-ft4o4kgjp9apm9odqd00hpmpp5rrn8gt.apps.googleusercontent.com';

    final googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('google_sign_in_cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('google_sign_in_no_id_token');
      }

      // Sign in to Supabase using the Google ID token
      final response = await _sb.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.session == null) {
        throw Exception('google_sign_in_no_session');
      }

      // Create or update profile for Google sign-in users
      final user = response.user;
      if (user != null) {
        await _ensureProfileExists(
          userId: user.id,
          email: user.email,
          fullName: user.userMetadata?['full_name'] as String? ??
              user.userMetadata?['name'] as String? ??
              googleUser.displayName,
          avatarUrl: user.userMetadata?['avatar_url'] as String? ??
              user.userMetadata?['picture'] as String? ??
              googleUser.photoUrl,
        );
      }

      // Warm profile cache after successful sign-in
      await _warmProfileCache();
      
      // Check if user is an instructor
      await InstructorService.instance.checkInstructorStatus();

      TelemetryService.instance.recordEvent('google_sign_in_success');
    } on AuthException catch (e) {
      TelemetryService.instance.recordEvent(
        'google_sign_in_auth_error',
        data: {'message': e.message, 'statusCode': e.statusCode ?? 'null'},
      );
      
      final msg = e.message.toLowerCase();
      if (msg.contains('user already registered') || msg.contains('already exists')) {
        throw Exception('google_sign_in_email_exists');
      }
      throw Exception('google_sign_in_failed');
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('cancelled') || msg.contains('canceled')) {
        throw Exception('google_sign_in_cancelled');
      }
      if (msg.contains('network')) {
        throw Exception('google_sign_in_network_error');
      }
      
      TelemetryService.instance.recordEvent(
        'google_sign_in_error',
        data: {'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Sign in with Apple (iOS only).
  /// Creates or links an account using Apple ID credentials.
  Future<void> signInWithApple() async {
    // Only available on iOS
    if (!Platform.isIOS) {
      throw Exception('apple_sign_in_not_available');
    }

    try {
      // Import dynamically to avoid issues on Android
      final signInWithApple = await _performAppleSignIn();
      
      if (signInWithApple == null) {
        throw Exception('apple_sign_in_cancelled');
      }

      final idToken = signInWithApple['idToken'];
      if (idToken == null) {
        throw Exception('apple_sign_in_no_id_token');
      }

      // Sign in to Supabase using the Apple ID token
      final response = await _sb.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );

      if (response.session == null) {
        throw Exception('apple_sign_in_no_session');
      }

      // Create or update profile for Apple sign-in users
      final user = response.user;
      if (user != null) {
        // Apple may hide email, use what's available
        final email = signInWithApple['email'] ?? user.email;
        final fullName = signInWithApple['fullName'] ??
            user.userMetadata?['full_name'] as String? ??
            user.userMetadata?['name'] as String?;

        await _ensureProfileExists(
          userId: user.id,
          email: email,
          fullName: fullName,
          avatarUrl: null, // Apple doesn't provide avatar
        );
      }

      // Warm profile cache after successful sign-in
      await _warmProfileCache();
      
      // Check if user is an instructor
      await InstructorService.instance.checkInstructorStatus();

      TelemetryService.instance.recordEvent('apple_sign_in_success');
    } on AuthException catch (e) {
      TelemetryService.instance.recordEvent(
        'apple_sign_in_auth_error',
        data: {'message': e.message, 'statusCode': e.statusCode ?? 'null'},
      );
      
      final msg = e.message.toLowerCase();
      if (msg.contains('user already registered') || msg.contains('already exists')) {
        throw Exception('apple_sign_in_email_exists');
      }
      throw Exception('apple_sign_in_failed');
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('cancelled') || msg.contains('canceled')) {
        throw Exception('apple_sign_in_cancelled');
      }
      if (msg.contains('network')) {
        throw Exception('apple_sign_in_network_error');
      }
      
      TelemetryService.instance.recordEvent(
        'apple_sign_in_error',
        data: {'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Perform Apple Sign-In and return credentials.
  Future<Map<String, String?>?> _performAppleSignIn() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Build full name from given and family name
      final fullName = [
        credential.givenName,
        credential.familyName,
      ].where((s) => s != null && s.isNotEmpty).join(' ');

      return {
        'idToken': credential.identityToken,
        'email': credential.email,
        'fullName': fullName.isNotEmpty ? fullName : null,
      };
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return null;
      }
      rethrow;
    }
  }

  /// Check if Apple Sign-In is available on this device.
  static bool get isAppleSignInAvailable => Platform.isIOS;
}
