import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's preferred theme and exposes transition hints so we can
/// mask palette swaps with a soft overlay.
enum AppThemeMode {
  light,
  dark,
  voidMode,
  system;

  String get label {
    switch (this) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.voidMode:
        return 'Void';
      case AppThemeMode.system:
        return 'System';
    }
  }
}

class ThemeController {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  static const String _storageKey = 'ui_theme_mode_v2';
  static const Duration _overlayDuration = Duration(milliseconds: 260);

  final ValueNotifier<AppThemeMode> mode =
      ValueNotifier<AppThemeMode>(AppThemeMode.system);
  final ValueNotifier<bool> transitioning = ValueNotifier<bool>(false);

  AppThemeMode _previousMode = AppThemeMode.system;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored != null) {
      mode.value = _decode(stored);
      _previousMode = mode.value;
    }
    _initialized = true;
  }

  AppThemeMode get currentMode => mode.value;
  AppThemeMode get previousMode => _previousMode;

  Future<void> setMode(AppThemeMode value) async {
    if (mode.value == value) return;
    _previousMode = mode.value;
    transitioning.value = true;
    mode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, _encode(value));
    Future.delayed(_overlayDuration, () {
      if (mode.value == value) {
        transitioning.value = false;
      }
    });
  }

  String _encode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.voidMode:
        return 'void';
      case AppThemeMode.system:
        return 'system';
    }
  }

  AppThemeMode _decode(String raw) {
    switch (raw) {
      case 'dark':
        return AppThemeMode.dark;
      case 'light':
        return AppThemeMode.light;
      case 'void':
        return AppThemeMode.voidMode;
      case 'system':
        return AppThemeMode.system;
      default:
        return AppThemeMode.system;
    }
  }
}
