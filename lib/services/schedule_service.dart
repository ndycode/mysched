import 'package:supabase_flutter/supabase_flutter.dart'; // Ensures PostgrestException is available
import '../env.dart';

class ScheduleService {
  ScheduleService._();
  static final ScheduleService instance = ScheduleService._();

  /// Add the section for the current user (if missing) and
  /// unhide any previously deleted classes in that section.
  Future<void> linkOrRescanSection(int sectionId) async {
    try {
      await Env.supa.rpc('rescan_section', params: {
        'p_section_id': sectionId,
      });
      // Some adapters return null on success; nothing else to do.
      // If your project surfaces errors as PostgrestException, the catch below handles it.
      // Otherwise, res may contain data you can ignore.
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Read the user's schedule from the secured view.
  Future<List<Map<String, dynamic>>> fetchUserClasses() async {
    try {
      final rows = await Env.supa.from('user_classes_v').select();
      return (rows as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Hide / unhide one class for this user.
  Future<void> setClassDeleted(int classId, bool deleted) async {
    try {
      await Env.supa.rpc('set_class_deleted', params: {
        'p_class_id': classId,
        'p_deleted': deleted,
      });
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }
}
