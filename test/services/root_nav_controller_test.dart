import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/root_nav_controller.dart';

class _MockHandle implements RootNavHandle {
  int currentTabIndex = 0;
  bool quickAction = false;
  bool isQuickActionOpen = false;
  
  final List<int> goToTabCalls = [];
  final List<String> calls = [];
  
  @override
  int get currentIndex => currentTabIndex;
  
  @override
  bool get hasQuickAction => quickAction;
  
  @override
  bool get quickActionOpen => isQuickActionOpen;
  
  @override
  Future<void> goToTab(int index) async {
    goToTabCalls.add(index);
    currentTabIndex = index;
  }
  
  @override
  Future<void> showQuickActions() async {
    calls.add('showQuickActions');
    isQuickActionOpen = true;
  }
}

void main() {
  setUp(() {
    // Clear any existing handle before each test
    final handle = RootNavController.handle;
    if (handle != null) {
      RootNavController.detach(handle);
    }
  });
  
  tearDown(() {
    final handle = RootNavController.handle;
    if (handle != null) {
      RootNavController.detach(handle);
    }
  });
  
  group('RootNavController', () {
    test('attach sets handle', () {
      final handle = _MockHandle();
      RootNavController.attach(handle);
      expect(RootNavController.handle, same(handle));
    });
    
    test('detach clears matching handle', () {
      final handle = _MockHandle();
      RootNavController.attach(handle);
      RootNavController.detach(handle);
      expect(RootNavController.handle, isNull);
    });
    
    test('detach ignores non-matching handle', () {
      final handle1 = _MockHandle();
      final handle2 = _MockHandle();
      RootNavController.attach(handle1);
      RootNavController.detach(handle2);
      expect(RootNavController.handle, same(handle1));
    });
    
    test('currentIndex returns null without handle', () {
      expect(RootNavController.currentIndex, isNull);
    });
    
    test('currentIndex returns handle value', () {
      final handle = _MockHandle()..currentTabIndex = 2;
      RootNavController.attach(handle);
      expect(RootNavController.currentIndex, 2);
    });
    
    test('hasQuickAction returns false without handle', () {
      expect(RootNavController.hasQuickAction, isFalse);
    });
    
    test('hasQuickAction returns handle value', () {
      final handle = _MockHandle()..quickAction = true;
      RootNavController.attach(handle);
      expect(RootNavController.hasQuickAction, isTrue);
    });
    
    test('quickActionOpen returns false without handle', () {
      expect(RootNavController.quickActionOpen, isFalse);
    });
    
    test('quickActionOpen returns handle value', () {
      final handle = _MockHandle()..isQuickActionOpen = true;
      RootNavController.attach(handle);
      expect(RootNavController.quickActionOpen, isTrue);
    });
    
    test('goToTab does nothing without handle', () async {
      await RootNavController.goToTab(1);
      // No error should be thrown
    });
    
    test('goToTab calls handle', () async {
      final handle = _MockHandle();
      RootNavController.attach(handle);
      await RootNavController.goToTab(3);
      expect(handle.goToTabCalls, [3]);
      expect(RootNavController.currentIndex, 3);
    });
    
    test('showQuickActions does nothing without handle', () async {
      await RootNavController.showQuickActions();
      // No error should be thrown
    });
    
    test('showQuickActions calls handle', () async {
      final handle = _MockHandle();
      RootNavController.attach(handle);
      await RootNavController.showQuickActions();
      expect(handle.calls, ['showQuickActions']);
      expect(RootNavController.quickActionOpen, isTrue);
    });
  });
}
