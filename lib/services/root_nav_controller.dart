import 'dart:async';

abstract class RootNavHandle {
  int get currentIndex;
  bool get hasQuickAction;
  bool get quickActionOpen;
  Future<void> goToTab(int index);
  Future<void> showQuickActions();
}

/// Global coordinator that lets leaf screens communicate with the root nav.
class RootNavController {
  RootNavController._();

  static RootNavHandle? _handle;

  static void attach(RootNavHandle handle) {
    _handle = handle;
  }

  static void detach(RootNavHandle handle) {
    if (identical(_handle, handle)) {
      _handle = null;
    }
  }

  static RootNavHandle? get handle => _handle;

  static int? get currentIndex => _handle?.currentIndex;

  static bool get hasQuickAction => _handle?.hasQuickAction ?? false;

  static bool get quickActionOpen => _handle?.quickActionOpen ?? false;

  static Future<void> goToTab(int index) async {
    final handle = _handle;
    if (handle == null) return;
    await handle.goToTab(index);
  }

  static Future<void> showQuickActions() async {
    final handle = _handle;
    if (handle == null) return;
    await handle.showQuickActions();
  }
}
