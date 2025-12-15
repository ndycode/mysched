import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/theme/motion.dart';

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

  static ThemeController? _instance;
  static ThemeController get instance {
    _instance ??= ThemeController._();
    return _instance!;
  }

  static const String _storageKey = 'ui_theme_mode_v2';
  static const String _accentKey = 'ui_accent_color_v1';
  static final Duration _overlayDuration = AppMotionSystem.standard + AppMotionSystem.staggerSlow - AppMotionSystem.staggerFast; // ~250ms

  final ValueNotifier<AppThemeMode> mode =
      ValueNotifier<AppThemeMode>(AppThemeMode.system);
  final ValueNotifier<bool> transitioning = ValueNotifier<bool>(false);
  
  /// Custom accent color (null = default blue).
  final ValueNotifier<Color?> accentColor = ValueNotifier<Color?>(null);

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
    // Load custom accent color
    final accentHex = prefs.getString(_accentKey);
    if (accentHex != null) {
      accentColor.value = _hexToColor(accentHex);
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

  /// Sets custom accent color (null to reset to default).
  Future<void> setAccentColor(Color? color) async {
    if (accentColor.value == color) return;
    transitioning.value = true;
    accentColor.value = color;
    final prefs = await SharedPreferences.getInstance();
    if (color == null) {
      await prefs.remove(_accentKey);
    } else {
      await prefs.setString(_accentKey, _colorToHex(color));
    }
    Future.delayed(_overlayDuration, () {
      transitioning.value = false;
    });
  }

  String _colorToHex(Color color) {
    return color.toARGB32().toRadixString(16).padLeft(8, '0');
  }

  Color? _hexToColor(String hex) {
    try {
      final value = int.parse(hex, radix: 16);
      return Color(value);
    } catch (_) {
      return null;
    }
  }

  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
  }
}
