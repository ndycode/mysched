import 'dart:math';

import '../env.dart';
import '../utils/app_log.dart';
import 'schedule_repository.dart';
import 'telemetry_service.dart';

const _scope = 'ScheduleShareService';

/// A shareable schedule link with metadata.
class SharedScheduleLink {
  const SharedScheduleLink({
    required this.id,
    required this.shareCode,
    required this.userId,
    this.expiresAt,
    this.createdAt,
    this.viewCount = 0,
  });

  final int id;
  final String shareCode;
  final String userId;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final int viewCount;

  /// Shareable text with the code (no domain needed).
  String get shareText => 'View my class schedule in MySched! Code: $shareCode';

  /// Deep link for opening in app.
  String get deepLink => 'mysched://schedule/shared/$shareCode';

  /// Whether the link has expired.
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  factory SharedScheduleLink.fromMap(Map<String, dynamic> map) {
    return SharedScheduleLink(
      id: (map['id'] as num).toInt(),
      shareCode: map['share_code'] as String,
      userId: map['user_id'] as String,
      expiresAt: _parseTimestamp(map['expires_at']),
      createdAt: _parseTimestamp(map['created_at']),
      viewCount: (map['view_count'] as num?)?.toInt() ?? 0,
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

/// Service for creating and managing shareable schedule links.
class ScheduleShareService {
  ScheduleShareService._();
  static final ScheduleShareService instance = ScheduleShareService._();

  /// Generate a unique share code.
  String _generateShareCode() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Create a shareable link for the current user's schedule.
  /// [expirationDays] - Number of days until the link expires (null = never)
  Future<SharedScheduleLink?> createShareLink({int? expirationDays}) async {
    if (!Env.isInitialized) return null;

    final userId = Env.supa.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final shareCode = _generateShareCode();
      final expiresAt = expirationDays != null
          ? DateTime.now().add(Duration(days: expirationDays))
          : null;

      final result = await Env.supa.from('schedule_shares').insert({
        'user_id': userId,
        'share_code': shareCode,
        'expires_at': expiresAt?.toIso8601String(),
      }).select().single();

      final link = SharedScheduleLink.fromMap(result);

      TelemetryService.instance.recordEvent(
        'schedule_share_created',
        data: {'expires_in_days': expirationDays},
      );

      AppLog.info(_scope, 'Share link created', data: {'code': shareCode});
      return link;
    } catch (e, stack) {
      TelemetryService.instance.logError(
        'schedule_share_create',
        error: e,
        stack: stack,
      );
      AppLog.error(_scope, 'Failed to create share link', error: e);
      return null;
    }
  }

  /// Get all active share links for the current user.
  Future<List<SharedScheduleLink>> getMyShareLinks() async {
    if (!Env.isInitialized) return [];

    final userId = Env.supa.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final rows = await Env.supa
          .from('schedule_shares')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = (rows as List).cast<Map<String, dynamic>>();
      return list.map(SharedScheduleLink.fromMap).toList();
    } catch (e) {
      AppLog.error(_scope, 'Failed to get share links', error: e);
      return [];
    }
  }

  /// Get a shared schedule by share code (for viewing).
  Future<List<ClassItem>?> getSharedSchedule(String shareCode) async {
    if (!Env.isInitialized) return null;

    try {
      // Get the share link
      final shareRows = await Env.supa
          .from('schedule_shares')
          .select()
          .eq('share_code', shareCode)
          .limit(1);

      final shareList = (shareRows as List).cast<Map<String, dynamic>>();
      if (shareList.isEmpty) return null;

      final share = SharedScheduleLink.fromMap(shareList.first);

      // Check expiration
      if (share.isExpired) return null;

      // Increment view count
      await Env.supa
          .from('schedule_shares')
          .update({'view_count': share.viewCount + 1})
          .eq('id', share.id);

      // Get the user's classes
      final classRows = await Env.supa
          .from('user_schedule_view')
          .select()
          .eq('user_id', share.userId);

      final classList = (classRows as List).cast<Map<String, dynamic>>();
      return classList.map((m) => ClassItem.fromMap(m)).toList();
    } catch (e) {
      AppLog.error(_scope, 'Failed to get shared schedule', error: e);
      return null;
    }
  }

  /// Delete a share link.
  Future<bool> deleteShareLink(int linkId) async {
    if (!Env.isInitialized) return false;

    final userId = Env.supa.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await Env.supa
          .from('schedule_shares')
          .delete()
          .eq('id', linkId)
          .eq('user_id', userId);

      AppLog.info(_scope, 'Share link deleted', data: {'id': linkId});
      return true;
    } catch (e) {
      AppLog.error(_scope, 'Failed to delete share link', error: e);
      return false;
    }
  }

  /// Revoke all share links for the current user.
  Future<bool> revokeAllLinks() async {
    if (!Env.isInitialized) return false;

    final userId = Env.supa.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await Env.supa
          .from('schedule_shares')
          .delete()
          .eq('user_id', userId);

      TelemetryService.instance.recordEvent('schedule_shares_revoked_all');
      AppLog.info(_scope, 'All share links revoked');
      return true;
    } catch (e) {
      AppLog.error(_scope, 'Failed to revoke all links', error: e);
      return false;
    }
  }
}
