import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/schedule_api.dart' as sched;
import 'package:mysched/services/telemetry_service.dart';
import 'package:mysched/ui/kit/class_details_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_helpers/supabase_stub.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await SupabaseTestBootstrap.ensureInitialized();
  });

  tearDown(TelemetryService.reset);

  sched.ClassItem buildCustomItem({bool enabled = true}) {
    return sched.ClassItem(
      id: 1,
      day: 1,
      start: '08:00',
      end: '09:00',
      title: 'Calculus',
      code: 'MATH101',
      room: 'R1',
      instructor: 'Prof. Ada',
      instructorAvatar: null,
      enabled: enabled,
      isCustom: true,
    );
  }

  sched.ClassDetails buildCustomDetails({bool enabled = true}) {
    final now = DateTime(2024, 1, 1);
    return sched.ClassDetails(
      id: 1,
      isCustom: true,
      title: 'Calculus',
      day: 1,
      start: '08:00',
      end: '09:00',
      enabled: enabled,
      code: 'MATH101',
      room: 'R1',
      units: 3,
      sectionId: null,
      sectionCode: null,
      sectionName: null,
      sectionNumber: null,
      sectionStatus: null,
      instructorName: 'Prof. Ada',
      instructorEmail: 'ada@example.com',
      instructorTitle: 'Lecturer',
      instructorDepartment: 'Mathematics',
      instructorAvatar: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  sched.ClassItem buildLinkedItem({bool enabled = true}) {
    return sched.ClassItem(
      id: 2,
      day: 2,
      start: '10:00',
      end: '11:00',
      title: 'Physics',
      code: 'PHYS101',
      room: 'Lab 1',
      instructor: 'Dr. Faraday',
      instructorAvatar: null,
      enabled: enabled,
      isCustom: false,
    );
  }

  sched.ClassDetails buildLinkedDetails({bool enabled = true}) {
    final now = DateTime(2024, 1, 2);
    return sched.ClassDetails(
      id: 2,
      isCustom: false,
      title: 'Physics',
      day: 2,
      start: '10:00',
      end: '11:00',
      enabled: enabled,
      code: 'PHYS101',
      room: 'Lab 1',
      units: 3,
      sectionId: 200,
      sectionCode: 'PHY2A',
      sectionName: 'Physics II',
      sectionNumber: '2A',
      sectionStatus: 'Active',
      instructorName: 'Dr. Faraday',
      instructorEmail: 'faraday@example.com',
      instructorTitle: 'Professor',
      instructorDepartment: 'Physics',
      instructorAvatar: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('ClassDetailsSheet', () {
    Future<void> pumpWithViewport(WidgetTester tester, Widget child) async {
      final view = tester.view;
      view.physicalSize = const Size(1200, 2000);
      view.devicePixelRatio = 1.0;
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: child),
        ),
      );
    }

    testWidgets('toggles a custom class and updates UI', (tester) async {
      final api = _FakeScheduleApi(details: buildCustomDetails(enabled: true));
      final recorded = <sched.ClassDetails>[];

      await pumpWithViewport(
        tester,
        ClassDetailsSheet(
          api: api,
          item: buildCustomItem(enabled: true),
          initial: buildCustomDetails(enabled: true),
          onLoaded: recorded.add,
          onDetailsChanged: recorded.add,
          onEditCustom: (_) async {},
          onDeleteCustom: (_) async {},
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      await tester.ensureVisible(find.text('Disable class'));
      await tester.tap(find.text('Disable class'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(api.toggleInvocations, <bool>[false]);
      expect(recorded.isNotEmpty, isTrue);
      expect(recorded.last.enabled, isFalse);
      expect(find.text('Enable class'), findsOneWidget);
    });

    testWidgets('deletes a custom class after confirmation', (tester) async {
      final api = _FakeScheduleApi(details: buildCustomDetails(enabled: true));
      var deleteCallbackCalled = false;

      await pumpWithViewport(
        tester,
        ClassDetailsSheet(
          api: api,
          item: buildCustomItem(),
          initial: buildCustomDetails(enabled: true),
          onLoaded: (_) {},
          onDetailsChanged: (_) {},
          onEditCustom: (_) async {},
          onDeleteCustom: (_) async {
            deleteCallbackCalled = true;
          },
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      await tester.ensureVisible(find.text('Delete class'));
      await tester.tap(find.text('Delete class'));
      await tester.pumpAndSettle();

      // AppModal.confirm uses a custom Dialog widget, not AlertDialog
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Delete custom class?'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(api.deleteCalled, isTrue);
      expect(deleteCallbackCalled, isTrue);
    });
    testWidgets('reports issue for linked class', (tester) async {
      String? recordedEvent;
      Map<String, dynamic>? recordedData;
      TelemetryService.overrideForTests((name, data) {
        recordedEvent = name;
        recordedData = data;
      });

      final api = _FakeScheduleApi(details: buildLinkedDetails(enabled: true));

      await pumpWithViewport(
        tester,
        ClassDetailsSheet(
          api: api,
          item: buildLinkedItem(),
          initial: buildLinkedDetails(enabled: true),
          onLoaded: (_) {},
          onDetailsChanged: (_) {},
          onEditCustom: (_) async {},
          onDeleteCustom: (_) async {},
        ),
      );

      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Report schedule issue'));
      await tester.tap(find.text('Report schedule issue'));
      await tester.pumpAndSettle();

      expect(find.text('Report a schedule issue'), findsOneWidget);

      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'Time conflict with the lab section.',
      );
      await tester.pump();

      await tester.tap(find.text('Send report'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(api.reportCalled, isTrue);
      expect(api.reportedNote, 'Time conflict with the lab section.');

      await tester.pumpAndSettle();

      expect(
        find.text("Thanks! We'll review this class shortly."),
        findsOneWidget,
      );
      expect(recordedEvent, 'class_issue_reported');
      expect(recordedData, isNotNull);
      expect(recordedData!['class_id'], 2);
      expect(
        recordedData!['note_length'],
        'Time conflict with the lab section.'.length,
      );
    });

  });
}

class _FakeScheduleApi extends sched.ScheduleApi {
  _FakeScheduleApi({required this.details})
      : super(client: Supabase.instance.client);

  sched.ClassDetails details;
  final List<bool> toggleInvocations = <bool>[];
  bool deleteCalled = false;
  bool reportCalled = false;
  String? reportedNote;

  @override
  Future<sched.ClassDetails> fetchClassDetails(sched.ClassItem item) async {
    return details;
  }

  @override
  Future<void> setCustomClassEnabled(int id, bool enable) async {
    toggleInvocations.add(enable);
    details = details.copyWith(enabled: enable);
  }

  @override
  Future<void> deleteCustomClass(int id) async {
    deleteCalled = true;
  }

  @override
  Future<void> reportClassIssue(
    sched.ClassDetails details, {
    String? note,
  }) async {
    reportCalled = true;
    reportedNote = note;
  }
}
