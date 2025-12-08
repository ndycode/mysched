import 'package:flutter/foundation.dart';

import '../../services/admin_service.dart';
import '../../services/telemetry_service.dart';

class AdminReportsController extends ChangeNotifier {
  AdminReportsController({AdminService? adminService})
      : _adminService = adminService ?? AdminService.instance;

  final AdminService _adminService;

  bool _loading = true;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  String _filter = 'all';
  String get filter => _filter;

  List<ClassIssueReport> _reports = const <ClassIssueReport>[];
  List<ClassIssueReport> get reports => _reports;

  Future<void> bootstrap() async {
    try {
      await _adminService.refreshRole();
      if (_adminService.role.value != AdminRoleState.admin) {
        _loading = false;
        _error = 'Admin access is required to view these reports.';
        notifyListeners();
        return;
      }
      await loadReports();
    } catch (error, stack) {
      TelemetryService.instance.logError(
        'admin_reports_bootstrap_failed',
        error: error,
        stack: stack,
      );
      _loading = false;
      _error = 'Unable to verify admin access right now.';
      notifyListeners();
    }
  }

  Future<void> loadReports() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _adminService.fetchReports(status: _filter);
      _reports = data;
      await _adminService.refreshNewReportCount();
    } catch (error, stack) {
      TelemetryService.instance.logError(
        'admin_reports_fetch_failed',
        error: error,
        stack: stack,
        data: {'filter': _filter},
      );
      _error = 'Unable to load reports. Pull to refresh or try again later.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setFilter(String value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
    loadReports();
  }

  Future<bool> changeStatus(
    ClassIssueReport report,
    String status, {
    String? resolutionNote,
  }) async {
    if (status == report.status) return false;

    String? finalNote = resolutionNote;
    bool clearResolutionNote = false;

    if (status == 'resolved') {
      if (finalNote == null) {
        // Caller should ensure note is provided for resolved status
        // or we treat it as empty if logic permits, but here we expect it.
      }
      finalNote = finalNote?.trim();
    } else if (report.resolutionNote != null &&
        report.resolutionNote!.trim().isNotEmpty) {
      clearResolutionNote = true;
      finalNote = null;
    }

    final previousStatus = report.status;
    final previousNote = report.resolutionNote;

    // Optimistic update
    _reports = _reports.map((entry) {
      if (entry.id != report.id) return entry;
      return entry.copyWith(
        status: status,
        resolutionNote: status == 'resolved'
            ? finalNote
            : (clearResolutionNote ? null : entry.resolutionNote),
      );
    }).toList();
    notifyListeners();

    try {
      await _adminService.updateReportStatus(
        report: report,
        status: status,
        resolutionNote: status == 'resolved' ? finalNote : null,
        clearResolutionNote: clearResolutionNote,
      );
      
      // Remove from list if filter active and no longer matches
      if (_filter != 'all' && status != _filter) {
        _reports = _reports.where((entry) => entry.id != report.id).toList();
        notifyListeners();
      }
      return true;
    } catch (error, stack) {
      TelemetryService.instance.logError(
        'admin_report_status_failed',
        error: error,
        stack: stack,
        data: {'report_id': report.id, 'status': status},
      );
      
      // Revert optimistic update
      _reports = _reports.map((entry) {
        if (entry.id != report.id) return entry;
        return entry.copyWith(
          status: previousStatus,
          resolutionNote: previousNote,
        );
      }).toList();
      notifyListeners();
      return false;
    }
  }
  
  ValueListenable<int> get newReportCount => _adminService.newReportCount;
}
