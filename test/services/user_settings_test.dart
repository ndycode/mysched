import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mysched/app/constants.dart';
import 'package:mysched/services/user_settings.dart';

void main() {
  group('UserSettings', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      UserSettings.resetInstance();
    });

    tearDown(() {
      UserSettings.resetInstance();
    });

    test('singleton returns same instance', () {
      final instance1 = UserSettings.instance;
      final instance2 = UserSettings.instance;
      expect(identical(instance1, instance2), true);
    });

    test('initial values use defaults', () async {
      final settings = UserSettings.instance;
      await settings.init();

      expect(settings.appNotifsEnabled.value, true);
      expect(settings.classAlarmsEnabled.value, true);
      expect(settings.quietWeekEnabled.value, false);
      expect(settings.leadMinutes.value, AppConstants.defaultLeadMinutes);
      expect(settings.snoozeMinutes.value, AppConstants.defaultSnoozeMinutes);
      expect(settings.verboseLogging.value, false);
    });

    test('init loads persisted values', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.keyAppNotifs: false,
        AppConstants.keyClassAlarms: false,
        AppConstants.keyQuietWeek: true,
        AppConstants.keyLeadMinutes: 15,
        AppConstants.keySnoozeMinutes: 10,
        AppConstants.keyVerboseLogging: true,
        // Mark migration as complete to prevent ensurePreferenceMigration from
        // treating snoozeMinutes=10 as a legacy default that needs rebasing.
        'lead_minutes_rebased_v2': true,
        'snooze_minutes_rebased_v2': true,
      });

      UserSettings.resetInstance();
      final settings = UserSettings.instance;
      await settings.init();

      expect(settings.appNotifsEnabled.value, false);
      expect(settings.classAlarmsEnabled.value, false);
      expect(settings.quietWeekEnabled.value, true);
      expect(settings.leadMinutes.value, 15);
      expect(settings.snoozeMinutes.value, 10);
      expect(settings.verboseLogging.value, true);
    });

    group('setAppNotifsEnabled', () {
      test('updates value and persists', () async {
        final settings = UserSettings.instance;
        await settings.init();

        await settings.setAppNotifsEnabled(false);

        expect(settings.appNotifsEnabled.value, false);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(AppConstants.keyAppNotifs), false);
      });
    });

    group('setClassAlarmsEnabled', () {
      test('updates value and persists', () async {
        final settings = UserSettings.instance;
        await settings.init();

        await settings.setClassAlarmsEnabled(false);

        expect(settings.classAlarmsEnabled.value, false);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(AppConstants.keyClassAlarms), false);
      });
    });

    group('setQuietWeekEnabled', () {
      test('updates value and persists', () async {
        final settings = UserSettings.instance;
        await settings.init();

        await settings.setQuietWeekEnabled(true);

        expect(settings.quietWeekEnabled.value, true);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(AppConstants.keyQuietWeek), true);
      });
    });

    group('setLeadMinutes', () {
      test('updates value and persists', () async {
        final settings = UserSettings.instance;
        await settings.init();

        await settings.setLeadMinutes(30);

        expect(settings.leadMinutes.value, 30);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt(AppConstants.keyLeadMinutes), 30);
      });

      test('clamps value to minimum 1', () async {
        final settings = UserSettings.instance;
        await settings.init();

        await settings.setLeadMinutes(0);

        expect(settings.leadMinutes.value, 1);
      });

      test('clamps value to maximum 120', () async {
        final settings = UserSettings.instance;
        await settings.init();

        await settings.setLeadMinutes(200);

        expect(settings.leadMinutes.value, 120);
      });
    });

    group('setSnoozeMinutes', () {
      test('updates value and persists', () async {
        final settings = UserSettings.instance;
        await settings.init();

        await settings.setSnoozeMinutes(10);

        expect(settings.snoozeMinutes.value, 10);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt(AppConstants.keySnoozeMinutes), 10);
      });
    });

    test('refresh reloads values from storage', () async {
      final settings = UserSettings.instance;
      await settings.init();

      // Manually update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyAppNotifs, false);
      await prefs.setInt(AppConstants.keyLeadMinutes, 45);

      // Refresh should pick up the changes
      await settings.refresh();

      expect(settings.appNotifsEnabled.value, false);
      expect(settings.leadMinutes.value, 45);
    });
  });
}
