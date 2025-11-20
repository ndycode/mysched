import 'package:supabase_flutter/supabase_flutter.dart';

import '../env.dart';
import 'schedule_api.dart';
import 'user_scope.dart';

class ScanService {
  final ScheduleApi _api = ScheduleApi();

  Future<void> importAsCustomSchedule({
    required List<Map<String, dynamic>> rows,
    required Map<int, bool> enabledMap,
  }) async {
    await _api.resetAllForCurrentUser();
    for (final row in rows) {
      final classId = (row['id'] as num?)?.toInt();
      if (classId != null && (enabledMap[classId] == false)) {
        continue;
      }
      final day = (row['day'] as num?)?.toInt() ?? 1;
      final start = _normalizeTime(row['start'] ?? row['start_time']);
      if (start == null) continue;
      final end = _normalizeTime(row['end'] ?? row['end_time']) ?? start;
      final rawTitle =
          (row['title'] ?? row['code'] ?? 'Class').toString().trim();
      final title = rawTitle.isEmpty ? 'Class' : rawTitle;
      final room = (row['room'] ?? '').toString().trim();
      final instructor = (row['instructor'] ?? '').toString().trim();

      await _api.addCustomClass(
        day: day,
        startTime: start,
        endTime: end,
        title: title,
        room: room.isEmpty ? null : room,
        instructor: instructor.isEmpty ? null : instructor,
      );
    }
  }

  Future<void> importSectionSchedule({
    required int sectionId,
    required Map<int, bool> enabledMap,
  }) async {
    final uid = UserScope.currentUserId();
    if (uid == null) throw const AuthException('Not authenticated');

    // Clear prior schedule state, then link the scanned section so future fetches stay in sync.
    await _api.resetAllForCurrentUser();

    await Env.supa.from('user_sections').upsert(
      {
        'user_id': uid,
        'section_id': sectionId,
        'added_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id,section_id',
    );

    await Env.supa.rpc('rescan_section', params: {
      'p_section_id': sectionId,
    });

    final disabled = enabledMap.entries
        .where((entry) => entry.value == false)
        .map(
          (entry) => {
            'user_id': uid,
            'class_id': entry.key,
            'enabled': false,
          },
        )
        .toList();

    if (disabled.isNotEmpty) {
      await Env.supa.from('user_class_overrides').upsert(
            disabled,
            onConflict: 'user_id,class_id',
          );
    }

    ScheduleApi.invalidateCache(userId: uid);
  }

  String? _normalizeTime(dynamic raw) {
    if (raw == null) return null;
    final text = raw.toString().trim();
    if (text.isEmpty) return null;
    final cleaned = text.toLowerCase().replaceAll('.', '');
    var meridian = '';
    var payload = cleaned;
    if (payload.endsWith('am') || payload.endsWith('pm')) {
      meridian = payload.substring(payload.length - 2);
      payload = payload.substring(0, payload.length - 2).trim();
    }
    int hour;
    int minute;
    if (payload.contains(':')) {
      final parts = payload.split(':');
      hour = int.tryParse(parts.first) ?? 0;
      minute = int.tryParse(parts[1]) ?? 0;
    } else {
      hour = int.tryParse(payload) ?? 0;
      minute = 0;
    }

    if (meridian == 'pm' && hour != 12) hour += 12;
    if (meridian == 'am' && hour == 12) hour = 0;

    hour = hour.clamp(0, 23);
    minute = minute.clamp(0, 59);
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
