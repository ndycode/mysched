import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/app/constants.dart';

void main() {
  group('AppConstants', () {
    test('appName is MySched', () {
      expect(AppConstants.appName, 'MySched');
    });

    test('defaultLeadMinutes is 5', () {
      expect(AppConstants.defaultLeadMinutes, 5);
    });

    test('defaultSnoozeMinutes is 5', () {
      expect(AppConstants.defaultSnoozeMinutes, 5);
    });

    group('SharedPreferences keys', () {
      test('keyClassAlarms is defined', () {
        expect(AppConstants.keyClassAlarms, 'class_alarms');
      });

      test('keyAppNotifs is defined', () {
        expect(AppConstants.keyAppNotifs, 'app_notifs');
      });

      test('keyQuietWeek is defined', () {
        expect(AppConstants.keyQuietWeek, 'quiet_week_enabled');
      });

      test('keyVerboseLogging is defined', () {
        expect(AppConstants.keyVerboseLogging, 'alarm_verbose_logging');
      });

      test('keyLeadMinutes is defined', () {
        expect(AppConstants.keyLeadMinutes, 'notifLeadMinutes');
      });

      test('keySnoozeMinutes is defined', () {
        expect(AppConstants.keySnoozeMinutes, 'snoozeMinutes');
      });

      test('keyAlarmVolume is defined', () {
        expect(AppConstants.keyAlarmVolume, 'alarm_volume');
      });

      test('keyAlarmVibration is defined', () {
        expect(AppConstants.keyAlarmVibration, 'alarm_vibration');
      });

      test('keyAlarmRingtone is defined', () {
        expect(AppConstants.keyAlarmRingtone, 'alarm_ringtone');
      });
    });

    group('Default alarm settings', () {
      test('defaultAlarmVolume is 80', () {
        expect(AppConstants.defaultAlarmVolume, 80);
      });

      test('defaultAlarmVibration is true', () {
        expect(AppConstants.defaultAlarmVibration, true);
      });

      test('defaultAlarmRingtone is default', () {
        expect(AppConstants.defaultAlarmRingtone, 'default');
      });
    });
  });
}
