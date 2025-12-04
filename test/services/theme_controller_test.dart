import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mysched/services/theme_controller.dart';

void main() {
  group('AppThemeMode', () {
    test('label returns correct strings', () {
      expect(AppThemeMode.light.label, 'Light');
      expect(AppThemeMode.dark.label, 'Dark');
      expect(AppThemeMode.voidMode.label, 'Void');
      expect(AppThemeMode.system.label, 'System');
    });

    test('has all expected values', () {
      expect(AppThemeMode.values.length, 4);
      expect(AppThemeMode.values.contains(AppThemeMode.light), true);
      expect(AppThemeMode.values.contains(AppThemeMode.dark), true);
      expect(AppThemeMode.values.contains(AppThemeMode.voidMode), true);
      expect(AppThemeMode.values.contains(AppThemeMode.system), true);
    });
  });

  group('ThemeController', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      ThemeController.resetForTesting();
    });

    tearDown(() {
      ThemeController.resetForTesting();
    });

    test('singleton returns same instance', () {
      final instance1 = ThemeController.instance;
      final instance2 = ThemeController.instance;
      expect(identical(instance1, instance2), true);
    });

    test('initial mode is system', () {
      final controller = ThemeController.instance;
      expect(controller.mode.value, AppThemeMode.system);
      expect(controller.currentMode, AppThemeMode.system);
    });

    test('init loads persisted theme', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ui_theme_mode_v2', 'dark');

      ThemeController.resetForTesting();
      final controller = ThemeController.instance;
      await controller.init();

      expect(controller.mode.value, AppThemeMode.dark);
    });

    test('setMode updates mode and persists', () async {
      final controller = ThemeController.instance;
      await controller.init();

      await controller.setMode(AppThemeMode.light);

      expect(controller.mode.value, AppThemeMode.light);
      expect(controller.currentMode, AppThemeMode.light);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('ui_theme_mode_v2'), 'light');
    });

    test('setMode tracks previous mode', () async {
      final controller = ThemeController.instance;
      await controller.init();

      expect(controller.previousMode, AppThemeMode.system);

      await controller.setMode(AppThemeMode.dark);
      expect(controller.previousMode, AppThemeMode.system);

      await controller.setMode(AppThemeMode.light);
      expect(controller.previousMode, AppThemeMode.dark);
    });

    test('setMode triggers transitioning state', () async {
      final controller = ThemeController.instance;
      await controller.init();

      expect(controller.transitioning.value, false);

      await controller.setMode(AppThemeMode.voidMode);

      // Transitioning should be true immediately
      expect(controller.transitioning.value, true);

      // Wait for transition to complete
      await Future.delayed(const Duration(milliseconds: 300));
      expect(controller.transitioning.value, false);
    });

    test('setMode with same value does nothing', () async {
      final controller = ThemeController.instance;
      await controller.init();

      final previousMode = controller.previousMode;
      await controller.setMode(AppThemeMode.system); // Same as initial

      expect(controller.previousMode, previousMode);
      expect(controller.transitioning.value, false);
    });

    test('all theme modes can be set and retrieved', () async {
      final controller = ThemeController.instance;
      await controller.init();

      for (final mode in AppThemeMode.values) {
        await controller.setMode(mode);
        expect(controller.currentMode, mode);
        await Future.delayed(const Duration(milliseconds: 10));
      }
    });
  });
}
