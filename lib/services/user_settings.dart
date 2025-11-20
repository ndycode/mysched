import 'dart:async';

/// Minimal user settings wrapper to allow code to compile.
class UserSettings {
  const UserSettings();

  Future<void> refresh() async {
    // No persisted settings yet.
  }
}
