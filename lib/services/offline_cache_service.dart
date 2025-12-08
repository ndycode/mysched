import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'schedule_repository.dart';

class OfflineCacheService {
  OfflineCacheService._(this._prefs);

  static const _scheduleKey = 'offline_schedule_v1';

  final SharedPreferences _prefs;

  static OfflineCacheService? _instance;

  static Future<OfflineCacheService> instance() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = OfflineCacheService._(prefs);
    return _instance!;
  }

  static void resetForTests() {
    _instance = null;
  }

  Future<void> saveSchedule({
    required String userId,
    required List<ClassItem> items,
  }) async {
    if (userId.trim().isEmpty) return;
    final snapshot = items.map((item) => item.toJson()).toList();
    final data = _decodeStore(_prefs.getString(_scheduleKey));
    data[userId] = snapshot;
    await _prefs.setString(_scheduleKey, jsonEncode(data));
  }

  Future<List<ClassItem>?> readSchedule(String userId) async {
    if (userId.trim().isEmpty) return null;
    final raw = _prefs.getString(_scheduleKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final scoped = decoded[userId];
      if (scoped is! List) return null;
      return scoped
          .whereType<Map<String, dynamic>>()
          .map(ClassItem.fromJson)
          .toList();
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<void> clearSchedule({String? userId}) async {
    if (userId == null) {
      await _prefs.remove(_scheduleKey);
      return;
    }
    final raw = _prefs.getString(_scheduleKey);
    if (raw == null) return;
    final decoded = _decodeStore(raw);
    decoded.remove(userId);
    if (decoded.isEmpty) {
      await _prefs.remove(_scheduleKey);
      return;
    }
    await _prefs.setString(_scheduleKey, jsonEncode(decoded));
  }

  Map<String, dynamic> _decodeStore(String? raw) {
    if (raw == null) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Ignore corrupted payloads and reset on next write.
    }
    return <String, dynamic>{};
  }
}
