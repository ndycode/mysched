import 'dart:async';
import 'package:flutter/foundation.dart';

import '../utils/app_log.dart';
import 'auth_service.dart';

class ProfileSummary {
  const ProfileSummary({this.name, this.email, this.avatarUrl, this.updatedAt});

  final String? name;
  final String? email;
  final String? avatarUrl;
  final DateTime? updatedAt;

  String initial({String fallback = 'M'}) {
    final prefer = name?.trim();
    final fromName = (prefer != null && prefer.isNotEmpty)
        ? prefer.split(' ').first.trim()
        : null;
    final source = fromName?.isNotEmpty == true
        ? fromName!
        : (email?.split('@').first.trim() ?? '');
    if (source.isEmpty) return fallback;
    return source.substring(0, 1).toUpperCase();
  }

  ProfileSummary copyWith(
      {String? name, String? email, String? avatarUrl, DateTime? updatedAt}) {
    return ProfileSummary(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ProfileCache {
  static ProfileSummary? _cached;
  static int _refreshCounter = 0;
  static final ValueNotifier<ProfileSummary?> notifier =
      ValueNotifier<ProfileSummary?>(null);

  static Future<ProfileSummary> load({bool forceRefresh = false}) async {
    if (forceRefresh || _cached == null) {
      await refresh();
    }
    if (_cached != null) notifier.value = _cached;
    return _cached ?? const ProfileSummary();
  }

  static Future<void> refresh() async {
    final summary = await _fetch();
    _cached = summary.copyWith(updatedAt: DateTime.now());
    notifier.value = _cached;
    _refreshCounter++;
    if (kDebugMode) {
      AppLog.debug('ProfileCache', 'Refreshed', data: {'count': _refreshCounter});
    }
  }

  static void clear() {
    _cached = null;
    _refreshCounter = 0;
    notifier.value = null;
  }

  static DateTime? lastUpdated() => _cached?.updatedAt;

  static Future<ProfileSummary> _fetch() async {
    try {
      final me = await AuthService.instance.me();
      final rawName = (me?['full_name'] ?? me?['fullName'] ?? '').toString();
      final rawEmail = (me?['email'] ?? me?['Email'] ?? '').toString();
      final rawAvatar = me?['avatar_url'] ?? me?['avatarUrl'];
      final avatar = rawAvatar is String
          ? rawAvatar.trim()
          : (rawAvatar?.toString().trim() ?? '');
      return ProfileSummary(
        name: rawName.trim().isEmpty ? null : rawName.trim(),
        email: rawEmail.trim().isEmpty ? null : rawEmail.trim(),
        avatarUrl: avatar.isEmpty ? null : avatar,
      );
    } catch (_) {
      return const ProfileSummary();
    }
  }
}
