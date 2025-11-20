import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's preferred theme and exposes transition hints so we can
/// mask palette swaps with a soft overlay.
class ThemeController {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  static const String _storageKey = 'ui_theme_mode';
  static const Duration _overlayDuration = Duration(milliseconds: 260);

  final ValueNotifier<ThemeMode> mode =
      ValueNotifier<ThemeMode>(ThemeMode.system);
  final ValueNotifier<bool> transitioning = ValueNotifier<bool>(false);

  ThemeMode _previousMode = ThemeMode.system;
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

  ThemeMode get currentMode => mode.value;
  ThemeMode get previousMode => _previousMode;

  Future<void> setThemeMode(ThemeMode value) async {
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

  String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _decode(String raw) {
    switch (raw) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }
}
