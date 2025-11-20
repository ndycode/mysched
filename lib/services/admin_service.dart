import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'telemetry_service.dart';

enum AdminRoleState {
  unknown,
  notSignedIn,
  notAdmin,
  admin,
  error,
}

class ClassIssueReport {
  ClassIssueReport({
    required this.id,
    required this.userId,
    required this.classId,
    required this.status,
    required this.createdAt,
    required this.snapshot,
    this.sectionId,
    this.note,
    this.reporterName,
    this.reporterEmail,
    this.resolutionNote,
  });

  final int id;
  final String userId;
  final int classId;
  final int? sectionId;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic> snapshot;
  final String? note;
  final String? reporterName;
  final String? reporterEmail;
  final String? resolutionNote;

  String? get title => _readString(snapshot['title']);
  String? get code => _readString(snapshot['code']);
  String? get sectionCode => _readString(snapshot['section_code']);
  String? get sectionNumber => _readString(snapshot['section_number']);
  String? get room => _readString(snapshot['room']);
  String? get instructorName => _readString(snapshot['instructor_name']);
  int? get day => _readInt(snapshot['day']);
  String? get start =>
      _readString(snapshot['start']) ?? _readString(snapshot['start_time']);
  String? get end =>
      _readString(snapshot['end']) ?? _readString(snapshot['end_time']);

  ClassIssueReport copyWith({
    String? status,
    String? note,
    String? resolutionNote,
  }) {
    return ClassIssueReport(
      id: id,
      userId: userId,
      classId: classId,
      sectionId: sectionId,
      status: status ?? this.status,
      createdAt: createdAt,
      snapshot: snapshot,
      note: note ?? this.note,
      reporterName: reporterName,
      reporterEmail: reporterEmail,
      resolutionNote: resolutionNote ?? this.resolutionNote,
    );
  }

  static ClassIssueReport fromMap(
    Map<String, dynamic> map, {
    ReporterInfo? reporter,
  }) {
    return ClassIssueReport(
      id: _readInt(map['id']) ?? 0,
      userId: _readString(map['user_id']) ?? '',
      classId: _readInt(map['class_id']) ?? 0,
      sectionId: _readInt(map['section_id']),
      status: _readString(map['status']) ?? 'new',
      note: _readString(map['note']),
      resolutionNote: _readString(map['resolution_note']),
      createdAt: _readDate(map['created_at']) ?? DateTime.now().toUtc(),
      snapshot: Map<String, dynamic>.from(
        (map['snapshot'] as Map?) ?? <String, dynamic>{},
      ),
      reporterName: reporter?.name,
      reporterEmail: reporter?.email,
    );
  }

  static String? _readString(Object? value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    return value.toString();
  }

  static int? _readInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static DateTime? _readDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value.toUtc();
    return DateTime.tryParse(value.toString())?.toUtc();
  }
}

class ReporterInfo {
  const ReporterInfo({required this.id, this.name, this.email});

  final String id;
  final String? name;
  final String? email;
}

class AdminService {
  AdminService._({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  static AdminService? _instance;

  static AdminService get instance {
    _instance ??= AdminService._();
    return _instance!;
  }

  @visibleForTesting
  static void overrideInstance(AdminService? service) {
    _instance = service;
  }

  final SupabaseClient _client;
  final ValueNotifier<AdminRoleState> role =
      ValueNotifier<AdminRoleState>(AdminRoleState.unknown);
  final ValueNotifier<int> newReportCount = ValueNotifier<int>(0);

  bool _roleLoading = false;

  Future<void> refreshRole({bool force = false}) async {
    if (_roleLoading && !force) return;

    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      role.value = AdminRoleState.notSignedIn;
      return;
    }

    _roleLoading = true;
    try {
      final res = await _client
          .from('admins')
          .select('user_id')
          .eq('user_id', uid)
          .maybeSingle();
      role.value = res == null ? AdminRoleState.notAdmin : AdminRoleState.admin;
    } catch (error, stack) {
      TelemetryService.instance.logError(
        'admin_role_check_failed',
        error: error,
        stack: stack,
      );
      role.value = AdminRoleState.error;
    } finally {
      _roleLoading = false;
    }
  }

  Future<List<ClassIssueReport>> fetchReports({String? status}) async {
    await _ensureAdminAccess();

    final dynamic response = await _client
        .from('class_issue_reports')
        .select(
          'id, user_id, class_id, section_id, note, resolution_note, status, snapshot, created_at',
        )
        .order('status', ascending: true)
        .order('created_at', ascending: false);
    final dynamic rawData;
    if (response is List) {
      rawData = response;
    } else if (response is Map && response['data'] is List) {
      rawData = response['data'];
    } else if (response != null && (response as dynamic).data is List) {
      rawData = (response as dynamic).data as List;
    } else {
      rawData = const <dynamic>[];
    }

    final rows = (rawData as List)
        .map<Map<String, dynamic>>(
          (row) => Map<String, dynamic>.from(row as Map),
        )
        .toList();

    final reporters = await _loadReporters(
      rows
          .map((row) => ClassIssueReport._readString(row['user_id']))
          .whereType<String>()
          .toSet(),
    );

    final reports = rows.map((row) {
      final userId = ClassIssueReport._readString(row['user_id']);
      return ClassIssueReport.fromMap(
        row,
        reporter: userId == null ? null : reporters[userId],
      );
    }).toList();

    reports.sort((a, b) {
      final orderA = statusRank(a.status);
      final orderB = statusRank(b.status);
      if (orderA != orderB) return orderA.compareTo(orderB);
      return b.createdAt.compareTo(a.createdAt);
    });

    if (status != null && status.isNotEmpty && status != 'all') {
      return reports.where((report) => report.status == status).toList();
    }
    return reports;
  }

  Future<void> refreshNewReportCount() async {
    if (role.value != AdminRoleState.admin) {
      newReportCount.value = 0;
      return;
    }
    try {
      final response = await _client
          .from('class_issue_reports')
          .select('id')
          .eq('status', 'new')
          .count(CountOption.exact);
      newReportCount.value = response.count;
    } catch (error, stack) {
      TelemetryService.instance.logError(
        'admin_new_report_count_failed',
        error: error,
        stack: stack,
      );
    }
  }

  Future<void> updateReportStatus({
    required ClassIssueReport report,
    required String status,
    String? resolutionNote,
    bool clearResolutionNote = false,
  }) async {
    await _ensureAdminAccess();
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw const AuthException('Not authenticated');

    final updatePayload = <String, dynamic>{
      'status': status,
    };
    if (clearResolutionNote) {
      updatePayload['resolution_note'] = null;
    } else if (resolutionNote != null) {
      updatePayload['resolution_note'] = resolutionNote.trim();
    }

    await _client.from('class_issue_reports').update(updatePayload).eq(
          'id',
          report.id,
        );

    final auditDetails = <String, dynamic>{
      'from': report.status,
      'to': status,
    };
    if (clearResolutionNote) {
      auditDetails['cleared_resolution_note'] = true;
    } else if (resolutionNote != null && resolutionNote.trim().isNotEmpty) {
      auditDetails['resolution_note'] = resolutionNote.trim();
    }

    await _client.from('audit_log').insert({
      'user_id': uid,
      'action': 'class_issue_status_update',
      'table_name': 'class_issue_reports',
      'row_id': report.id,
      'details': auditDetails,
    });

    await refreshNewReportCount();
  }

  Future<Map<String, ReporterInfo>> _loadReporters(Set<String> userIds) async {
    if (userIds.isEmpty) return const <String, ReporterInfo>{};

    final conditions = userIds.map((id) => 'id.eq.$id').join(',');
    final result = await _client
        .from('profiles')
        .select('id, full_name, email')
        .or(conditions);

    final entries = <String, ReporterInfo>{};
    for (final row in (result as List).cast<Map<String, dynamic>>()) {
      final id = ClassIssueReport._readString(row['id']);
      if (id == null) continue;
      entries[id] = ReporterInfo(
        id: id,
        name: ClassIssueReport._readString(row['full_name']),
        email: ClassIssueReport._readString(row['email']),
      );
    }
    return entries;
  }

  Future<void> _ensureAdminAccess() async {
    if (role.value == AdminRoleState.unknown ||
        role.value == AdminRoleState.error) {
      await refreshRole(force: true);
    }
    if (role.value != AdminRoleState.admin) {
      throw Exception('Admin access required.');
    }
  }
}

@visibleForTesting
int statusRank(String status) {
  switch (status) {
    case 'new':
      return 0;
    case 'in_review':
      return 1;
    case 'resolved':
      return 2;
    default:
      return 3;
  }
}
