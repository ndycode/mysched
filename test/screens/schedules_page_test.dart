import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/screens/schedules_page.dart';
import 'package:mysched/services/offline_cache_service.dart';
import 'package:mysched/services/schedule_api.dart';
import 'package:mysched/screens/schedules/schedules_data.dart';
import '../test_helpers/supabase_stub.dart';
import 'package:mysched/services/share_service.dart';
import 'package:mysched/services/telemetry_service.dart';
import 'package:mysched/services/user_scope.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeScheduleApi extends ScheduleApi {
  FakeScheduleApi({
    this.cached,
    Future<List<ClassItem>> Function(bool forceRefresh)? fetcher,
  }) : _fetcher = fetcher ?? ((_) async => <ClassItem>[]);

  final List<ClassItem>? cached;
  final Future<List<ClassItem>> Function(bool forceRefresh) _fetcher;

  @override
  List<ClassItem>? getCachedClasses() => cached;

  @override
  Future<List<ClassItem>> getMyClasses({bool forceRefresh = false}) =>
      _fetcher(forceRefresh);

  @override
  Future<List<ClassItem>> refreshMyClasses() => _fetcher(true);
}

ClassItem serviceItem({
  required int id,
  required int day,
  required String title,
  String start = '08:00',
  String end = '09:00',
  String room = 'Room',
  String instructor = 'Instructor',
  String? instructorAvatar,
}) {
  return ClassItem(
    id: id,
    day: day,
    start: start,
    end: end,
    title: title,
    code: null,
    units: null,
    room: room,
    instructor: instructor,
    instructorAvatar: instructorAvatar,
    enabled: true,
    isCustom: false,
  );
}

class RecordingShareRecorder {
  final List<ShareParams> calls = [];

  Future<ShareResult> share(ShareParams params) async {
    calls.add(params);
    return const ShareResult('success', ShareResultStatus.success);
  }
}

class DelayingShareRecorder {
  DelayingShareRecorder() : _completer = Completer<void>();

  final Completer<void> _completer;
  int callCount = 0;
  ShareParams? lastParams;

  Future<ShareResult> share(ShareParams params) async {
    callCount++;
    lastParams = params;
    await _completer.future;
    return const ShareResult('success', ShareResultStatus.success);
  }

  void complete() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }
}

class FlakyShareRecorder {
  int callCount = 0;
  bool failFirst = true;

  Future<ShareResult> share(ShareParams params) async {
    callCount++;
    if (failFirst) {
      failFirst = false;
      throw Exception('offline');
    }
    return const ShareResult('success', ShareResultStatus.success);
  }
}

late RecordingShareRecorder _recordingShare;

Future<void> _pumpPage(WidgetTester tester, ScheduleApi api, {Size? surfaceSize}) async {
  // Use a larger surface size to prevent overflow issues with popup menus
  tester.view.physicalSize = surfaceSize ?? const Size(1080, 1920);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SchedulesPage(
          api: api,
          connectivityOverride: () async => true,
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    await SupabaseTestBootstrap.ensureInitialized();
    UserScope.overrideForTests(() => 'test-user');
  });
  setUp(() {
    ScheduleApi.clearCache(userId: 'test-user');
    ScheduleApi.setCacheTimestamp(null, userId: 'test-user');
    OfflineCacheService.resetForTests();
    SharedPreferences.setMockInitialValues({});
    _recordingShare = RecordingShareRecorder();
    ShareService.overrideForTests(_recordingShare.share);
  });

  tearDown(() {
    ShareService.reset();
    UserScope.overrideForTests(() => 'test-user');
  });

  tearDownAll(() {
    UserScope.overrideForTests(null);
  });

  testWidgets('shows cached schedules immediately', (tester) async {
    final cachedItems = [
      serviceItem(id: 1, day: 1, title: 'Math 101'),
    ];
    final completer = Completer<List<ClassItem>>();
    final api = FakeScheduleApi(
      cached: cachedItems,
      fetcher: (_) => completer.future,
    );

    await _pumpPage(tester, api);
    await tester.pumpAndSettle();

    expect(find.textContaining('Math 101'), findsWidgets);

    completer.complete(cachedItems);
    await tester.pumpAndSettle();
  });

  testWidgets('shows friendly error state', (tester) async {
    final api = FakeScheduleApi(
      fetcher: (_) => Future.error('boom'),
    );

    await _pumpPage(tester, api);
    await tester.pumpAndSettle(); // allow future completion

    expect(find.text('Schedule not loaded'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Scan student card'), findsOneWidget);
  });

  testWidgets('shows cached data alongside retry message', (tester) async {
    final cachedItems = [
      serviceItem(id: 1, day: 1, title: 'Math 101'),
    ];
    final api = FakeScheduleApi(
      cached: cachedItems,
      fetcher: (_) => Future.error('boom'),
    );

    await _pumpPage(tester, api);
    await tester.pump(); // first frame shows cached schedule

    await tester.pump(); // error state rendered, cached content retained
    expect(find.text('Retry sync'), findsOneWidget);
  });

  testWidgets('shows offline banner on fallback and hides after refresh',
      (tester) async {
    final offlineItem =
        serviceItem(id: 9, day: 2, title: 'Offline Algebra').copyWith(
      code: 'ALG-201',
      room: 'B201',
    );
    OfflineCacheService.resetForTests();
    SharedPreferences.setMockInitialValues({
      'offline_schedule_v1': jsonEncode({
        'test-user': [offlineItem.toJson()]
      }),
    });
    var shouldFail = true;
    final api = FakeScheduleApi(
      fetcher: (_) {
        if (shouldFail) {
          return Future<List<ClassItem>>.error('offline');
        }
        return Future.value([
          serviceItem(id: 5, day: 2, title: 'Fresh Update'),
        ]);
      },
    );

    await _pumpPage(tester, api);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byKey(const ValueKey('offline-cache-banner')), findsOneWidget);
    expect(find.textContaining('Offline Algebra'), findsWidgets);

    shouldFail = false;
    final state = tester.state<SchedulesPageState>(find.byType(SchedulesPage));
    await state.reload();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byKey(const ValueKey('offline-cache-banner')), findsNothing);
    expect(find.textContaining('Fresh Update'), findsWidgets);
  });

  testWidgets('retry triggers a fresh fetch', (tester) async {
    final calls = <bool>[];
    var shouldFail = true;
    final api = FakeScheduleApi(
      fetcher: (forceRefresh) {
        calls.add(forceRefresh);
        if (shouldFail) {
          shouldFail = false;
          return Future<List<ClassItem>>.error('boom');
        }
        return Future.value([
          serviceItem(id: 2, day: 2, title: 'Physics 202'),
        ]);
      },
    );

    await _pumpPage(tester, api);
    await tester.pump();
    await tester.pump();

    expect(find.text('Schedule not loaded'), findsOneWidget);
    expect(calls, [true]);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump();

    expect(calls, [true, true], reason: 'retry should force refresh again');
    expect(find.text('Physics 202'), findsWidgets);
    expect(find.text('Schedule not loaded'), findsNothing);
  });

  testWidgets('retry keeps cached data visible while refreshing',
      (tester) async {
    final cachedItems = [
      serviceItem(id: 1, day: 1, title: 'Math 101'),
    ];
    final completer = Completer<List<ClassItem>>();
    final calls = <bool>[];
    final api = FakeScheduleApi(
      cached: cachedItems,
      fetcher: (forceRefresh) {
        calls.add(forceRefresh);
        if (calls.length == 1) {
          return Future<List<ClassItem>>.error('boom');
        }
        return completer.future;
      },
    );

    await _pumpPage(tester, api);
    await tester.pump();
    await tester.pump();

    expect(find.text('Retry sync'), findsOneWidget);

    await tester.tap(find.text('Retry sync'));
    await tester.pump();

    expect(calls, [true, true]);
    completer.complete([
      serviceItem(id: 2, day: 2, title: 'Physics 202'),
    ]);
    await tester.pump();
    await tester.pump();

    expect(find.text('Physics 202'), findsWidgets);
    expect(find.text('Retry sync'), findsNothing);
  });

  testWidgets('shows empty state when no schedules', (tester) async {
    final api = FakeScheduleApi(
      fetcher: (_) async => <ClassItem>[],
    );

    await _pumpPage(tester, api);
    await tester.pumpAndSettle();

    expect(find.text('No schedules yet'), findsWidgets);
    expect(find.textContaining('scanning your student card'), findsWidgets);
  });

  test('buildSchedulePlainText formats grouped schedule', () {
    final grouped = groupClassesByDay([
      serviceItem(
          id: 1, day: 1, title: 'Calculus', start: '08:00', end: '09:30'),
      serviceItem(
          id: 2, day: 1, title: 'Physics', start: '10:00', end: '11:30'),
      serviceItem(
          id: 3, day: 2, title: 'History', start: '13:00', end: '14:00'),
    ]);

    final text = buildSchedulePlainText(grouped, now: DateTime(2025, 10, 22));

    expect(text, contains('MySched timetable'));
    expect(text, contains('Generated at'));
    expect(text, contains('Monday'));
    expect(text, contains('8:00 AM - 9:30 AM'));
    expect(text, contains('Room: Room'));
    expect(text, contains('Tuesday'));
    expect(text, contains('History'));
  });

  test('buildSchedulePlainText handles empty data', () {
    final text =
        buildSchedulePlainText(const <DayGroup>[], now: DateTime(2025, 10, 22));
    expect(text, contains('No classes scheduled.'));
  });

  test('buildScheduleCsv uses 24-hour times and quotes fields', () {
    final items = [
      serviceItem(
        id: 1,
        day: 1,
        title: 'Advanced, Calculus',
        start: '8:00 AM',
        end: '9:30 am',
      ).copyWith(code: 'CALC-101', room: 'Lab 2\nWing'),
      serviceItem(
        id: 2,
        day: 2,
        title: 'History',
        start: '1:00 pm',
        end: '3:15 PM',
      ).copyWith(
        isCustom: true,
        enabled: false,
        instructor: 'Doe, Jane',
      ),
    ];
    final csv = buildScheduleCsv(items, now: DateTime(2025, 10, 22, 9, 0));
    expect(csv, contains('Generated at'));
    expect(csv,
        contains('Day,Start,End,Title,Code,Room,Instructor,Enabled,Source'));
    expect(
        csv,
        contains(
            'Monday,08:00,09:30,"Advanced, Calculus",CALC-101,"Lab 2\nWing",Instructor,Yes,Linked'));
    expect(csv,
        contains('Tuesday,13:00,15:15,History,,Room,"Doe, Jane",No,Custom'));
    final dataLines = csv.split('\n').where(
        (line) => line.startsWith('Monday') || line.startsWith('Tuesday'));
    for (final line in dataLines) {
      expect(line.contains('AM'), isFalse);
      expect(line.contains('PM'), isFalse);
    }
  });

  testWidgets('buildSchedulePdf generates bytes', (tester) async {
    final grouped = groupClassesByDay([
      serviceItem(
          id: 1, day: 1, title: 'Calculus', start: '08:00', end: '09:30'),
    ]);
    final bytes = await buildSchedulePdf(grouped, now: DateTime(2025, 10, 22));
    expect(bytes, isNotEmpty);
  });

  testWidgets('export PDF ignores rapid double tap while busy', (tester) async {
    final api = FakeScheduleApi(
      cached: [
        serviceItem(id: 1, day: 1, title: 'Calculus'),
      ],
      fetcher: (_) async => [
        serviceItem(id: 1, day: 1, title: 'Calculus'),
      ],
    );

    final delayingShare = DelayingShareRecorder();
    ShareService.overrideForTests(delayingShare.share);

    await _pumpPage(tester, api);
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('schedule-actions-menu')));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const ValueKey('schedule-export-pdf-item')).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(delayingShare.callCount, 1);

    await tester.tap(find.byKey(const ValueKey('schedule-actions-menu')));
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('schedule-export-pdf-item')).first,
      warnIfMissed: false,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(delayingShare.callCount, 1);

    delayingShare.complete();
    await tester.pumpAndSettle();

    ShareService.overrideForTests(_recordingShare.share);
  });

  testWidgets('export failure surfaces retry error', (tester) async {
    final events = <String>[];
    TelemetryService.overrideForTests((name, _) => events.add(name));
    final api = FakeScheduleApi(
      cached: [
        serviceItem(id: 1, day: 1, title: 'Calculus'),
      ],
      fetcher: (_) async => [
        serviceItem(id: 1, day: 1, title: 'Calculus'),
      ],
    );
    final flakyShare = FlakyShareRecorder();
    ShareService.overrideForTests(flakyShare.share);

    await _pumpPage(tester, api);
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('schedule-actions-menu')));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const ValueKey('schedule-export-pdf-item')).first);
    await tester.pumpAndSettle();

    expect(find.text('Export unavailable'), findsOneWidget);
    expect(events.contains('schedule_export_failed'), isTrue);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Export unavailable'), findsNothing);
    expect(flakyShare.callCount, 2);
    ShareService.overrideForTests(_recordingShare.share);
    TelemetryService.reset();
  });

  testWidgets('export PDF generates files', (tester) async {
    final api = FakeScheduleApi(
      cached: [
        serviceItem(
            id: 1, day: 1, title: 'Calculus', start: '08:00', end: '09:30'),
      ],
      fetcher: (_) async => [
        serviceItem(
            id: 1, day: 1, title: 'Calculus', start: '08:00', end: '09:30'),
      ],
    );

    await _pumpPage(tester, api);
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('schedule-actions-menu')));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const ValueKey('schedule-export-pdf-item')).first);
    await tester.pumpAndSettle();

    expect(_recordingShare.calls, isNotEmpty);
    final params = _recordingShare.calls.last;
    final files = params.files!;
    expect(files, hasLength(2));

    XFile? pdfFile;
    XFile? textFile;
    for (final file in files) {
      final bytes = await file.readAsBytes();
      final header = String.fromCharCodes(bytes.take(4));
      if (header == '%PDF') {
        pdfFile = file;
        continue;
      }
      try {
        final content = utf8.decode(bytes);
        if (content.contains('Calculus')) {
          textFile = file;
        }
      } catch (_) {
        // not UTF-8 text
      }
    }

    expect(pdfFile, isNotNull);
    expect(textFile, isNotNull);

    final textContent = utf8.decode(await textFile!.readAsBytes());
    expect(textContent, contains('Calculus'));
    expect(textContent, contains('Monday'));
  });

  testWidgets('export CSV generates file', (tester) async {
    final api = FakeScheduleApi(
      cached: [
        serviceItem(
            id: 3, day: 3, title: 'Physics', start: '12:00', end: '13:30'),
      ],
      fetcher: (_) async => [
        serviceItem(
            id: 3, day: 3, title: 'Physics', start: '12:00', end: '13:30'),
      ],
    );

    await _pumpPage(tester, api);
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('schedule-actions-menu')));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const ValueKey('schedule-export-csv-item')).first);
    await tester.pumpAndSettle();

    expect(_recordingShare.calls, isNotEmpty);
    final params = _recordingShare.calls.last;
    final files = params.files!;
    expect(files, hasLength(1));
    final csvText = utf8.decode(await files.first.readAsBytes());
    expect(csvText, contains('Generated at'));
    expect(csvText, contains('Wednesday'));
    expect(csvText, contains('Physics'));
    expect(params.fileNameOverrides, contains('mysched-timetable.csv'));
  });
}
