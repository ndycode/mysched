import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final sourcePath = _readArg(args, '--source') ?? 'telemetry_dashboard.json';
  final dashboard = _readDashboard(sourcePath);
  if (args.contains('--summary') || args.isEmpty) {
    _printSummary(dashboard);
  }
  final exportPath = _readArg(args, '--export');
  if (exportPath != null) {
    await _writeFile(exportPath, dashboard);
  }
}

String? _readArg(List<String> args, String flag) {
  final index = args.indexOf(flag);
  if (index != -1 && index + 1 < args.length) {
    return args[index + 1];
  }
  return null;
}

Map<String, dynamic> _readDashboard(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return _empty();
  }
  try {
    final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return decoded;
  } catch (_) {
    return _empty();
  }
}

void _printSummary(Map<String, dynamic> dashboard) {
  stdout.writeln('MySched Telemetry Summary');
  stdout.writeln('---------------------------');
  stdout.writeln('Events: ');
  stdout.writeln('Errors: ');
  stdout.writeln('Calendar sync success: ');
  stdout.writeln('Calendar sync failed: ');
  stdout.writeln('Export retry success: ');
  stdout.writeln('Support notified: ');
  stdout.writeln('Last updated: ');
}

Future<void> _writeFile(String path, Map<String, dynamic> dashboard) async {
  final file = File(path);
  await file.writeAsString(jsonEncode(dashboard));
  stdout.writeln('Dashboard written to ');
}

Map<String, dynamic> _empty() => {
      'events': 0,
      'errors': 0,
      'calendarSuccess': 0,
      'calendarFailed': 0,
      'exportSuccess': 0,
      'supportNotified': 0,
      'updatedAt': null,
    };
