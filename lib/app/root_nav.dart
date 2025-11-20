import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reminder_scope.dart';
import '../screens/add_class_page.dart';
import '../screens/add_reminder_page.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/reminders_page.dart';
import '../screens/schedules_page.dart';
import '../screens/scan_options_sheet.dart';
import '../screens/scan_preview_sheet.dart';
import '../screens/schedules_preview_sheet.dart';
import '../screens/settings_page.dart';
import '../services/reminder_scope_store.dart';
import '../services/reminders_api.dart';
import '../services/root_nav_controller.dart';
import '../services/schedule_api.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';

class RootNav extends StatefulWidget {
  const RootNav({
    super.key,
    this.initialTab,
    this.fromScan = false,
    this.reminderScopeOverride,
  });

  final int? initialTab;
  final bool fromScan;
  final ReminderScope? reminderScopeOverride;

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav>
    with SingleTickerProviderStateMixin
    implements RootNavHandle {
  static const _fabHintPrefKey = 'dashboard.fab_hint_seen';
  static const double _kNavHeight = 10;
  int _idx = 0;

  // Single shared API instances for the tabs that need them
  late final ScheduleApi _api = ScheduleApi();
  late final RemindersApi _remindersApi = RemindersApi();

  final GlobalKey<DashboardScreenState> _dashboardKey =
      GlobalKey<DashboardScreenState>();
  final GlobalKey<SchedulesPageState> _schedulesKey =
      GlobalKey<SchedulesPageState>();
  final GlobalKey<RemindersPageState> _remindersKey =
      GlobalKey<RemindersPageState>();

  late final AnimationController _quickSheetController;
  bool _quickActionOpen = false;
  bool _fabHintVisible = false;

  @override
  void initState() {
    super.initState();
    _quickSheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    RootNavController.attach(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFabHint();
      _handleInitialArgs();
    });
  }

  @override
  void dispose() {
    RootNavController.detach(this);
    _quickSheetController.dispose();
    super.dispose();
  }

  Future<void> _handleInitialArgs() async {
    final tab = widget.initialTab;
    if (tab != null) {
      final clamped = tab.clamp(0, 3);
      await _switchTab(clamped, forceRefresh: true);
    }
    if (widget.fromScan) {
      await _schedulesKey.currentState?.reload();
    }
    if (widget.reminderScopeOverride != null) {
      ReminderScopeStore.instance.update(widget.reminderScopeOverride!);
    }
  }

  @override
  int get currentIndex => _idx;

  @override
  bool get hasQuickAction => true;

  @override
  bool get quickActionOpen => _quickActionOpen;

  Future<void> _switchTab(int index, {bool forceRefresh = false}) async {
    if (_idx != index) {
      setState(() => _idx = index);
      await _refreshTab(index);
      return;
    }
    if (forceRefresh) {
      await _refreshTab(index);
    }
  }

  @override
  Future<void> goToTab(int index) => _switchTab(index);

  Future<void> _loadFabHint() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_fabHintPrefKey) ?? false;
    if (!seen && mounted) {
      setState(() => _fabHintVisible = true);
    }
  }

  Future<void> _dismissFabHint() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_fabHintPrefKey, true);
    if (mounted) {
      setState(() => _fabHintVisible = false);
    }
  }

  Future<void> _refreshTab(int index) async {
    switch (index) {
      case 0:
        await _dashboardKey.currentState?.refreshOnTabVisit();
        break;
      case 1:
        await _schedulesKey.currentState?.refreshOnTabVisit();
        break;
      case 2:
        await _remindersKey.currentState?.refreshOnTabVisit();
        break;
      case 3:
        // settings page handles its own refresh
        break;
    }
  }

  void _openQuickActions() {
    if (_quickActionOpen) return;
    setState(() => _quickActionOpen = true);
    RootNavController.attach(this);
    _quickSheetController.forward();
  }

  void _closeQuickActions() {
    if (!_quickActionOpen) return;
    _quickSheetController.reverse().whenComplete(() {
      if (mounted) {
        setState(() => _quickActionOpen = false);
      }
    });
  }

  @override
  Future<void> showQuickActions() async {
    if (_quickActionOpen) {
      _closeQuickActions();
    } else {
      _openQuickActions();
    }
  }

  Future<void> _openAddClass() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    _closeQuickActions();
    final created = await showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddClassSheet(api: _api),
    );
    if (created == true) {
      await _schedulesKey.currentState?.reload();
      await _dashboardKey.currentState?.refreshOnTabVisit();
    }
  }

  Future<void> _openAddReminder() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    _closeQuickActions();
    final result = await showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddReminderSheet(api: _remindersApi),
    );
    if (result == true) {
      await _remindersKey.currentState?.refreshOnTabVisit();
      await _dashboardKey.currentState?.refreshOnTabVisit();
    }
  }

  Future<void> _openScanOptions() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    _closeQuickActions();
    while (mounted) {
      if (!mounted) return;
      final path = await showModalBottomSheet<String?>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const ScanOptionsSheet(),
      );
      if (path == null || !mounted) return;
      final preview = await showModalBottomSheet<ScanPreviewOutcome?>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ScanPreviewSheet(imagePath: path),
      );
      if (!mounted) return;
      if (preview == null) return;
      if (preview.retake) {
        // User wants to recapture; restart flow.
        continue;
      }
      if (!preview.isSuccess) return;

      final outcome = await showModalBottomSheet<ScheduleImportOutcome?>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => SchedulesPreviewSheet(
          imagePath: preview.imagePath!,
          section: preview.section!,
          classes: preview.classes,
        ),
      );
      if (!mounted) return;
      if (outcome == null) return;
      if (outcome.retake) {
        // Restart the capture flow.
        continue;
      }
      if (outcome.imported) {
        await _schedulesKey.currentState?.reload();
        await _dashboardKey.currentState?.refreshOnTabVisit();
        await _switchTab(RootNavTabs.schedules, forceRefresh: true);
        if (!mounted) return;
        showAppSnackBar(
          context,
          'Schedule imported successfully.',
          type: AppSnackBarType.success,
        );
      }
      return;
    }
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppTokens.radius.xl,
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Quick actions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _closeQuickActions,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _QuickActionButton(
                icon: Icons.library_add_outlined,
                label: 'Add custom class',
                description: 'Create a class manually.',
                onTap: _openAddClass,
              ),
              const SizedBox(height: 12),
              _QuickActionButton(
                icon: Icons.alarm_add_outlined,
                label: 'Add reminder',
                description: 'Plan an assignment or task.',
                onTap: _openAddReminder,
              ),
              const SizedBox(height: 12),
              _QuickActionButton(
                icon: Icons.camera_alt_outlined,
                label: 'Scan schedule',
                description: 'Import from your student card.',
                onTap: _openScanOptions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final content = IndexedStack(
      index: _idx,
      children: [
        DashboardScreen(
          key: _dashboardKey,
          api: _api,
          remindersApi: _remindersApi,
        ),
        SchedulesPage(key: _schedulesKey),
        RemindersPage(
          key: _remindersKey,
          api: _remindersApi,
          initialScope: widget.reminderScopeOverride,
        ),
        const SettingsPage(),
      ],
    );

    return Scaffold(
      extendBody: false,
      body: Stack(
        children: [
          content,
          if (_quickActionOpen)
            AnimatedBuilder(
              animation: _quickSheetController,
              builder: (context, child) {
                final viewPadding = MediaQuery.of(context).padding.bottom;
                final bottomInset = viewPadding + _kNavHeight;
                final isDark = Theme.of(context).brightness == Brightness.dark;
                const scrimColor = Colors.transparent;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _closeQuickActions,
                        child: Container(
                          color: scrimColor,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: bottomInset,
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _quickSheetController,
                          curve: Curves.easeInOut,
                        ),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.08),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _quickSheetController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ],
                );
              },
              child: _buildQuickActions(context),
            ),
        ],
      ),
      bottomNavigationBar: GlassNavigationBar(
        selectedIndex: _idx,
        destinations: rootNavDestinations,
        onDestinationSelected: _switchTab,
        onQuickAction: showQuickActions,
        quickActionOpen: _quickActionOpen,
        quickActionLabel: 'Quick actions',
        inlineQuickAction: true,
        solid: true,
        solidBackground: colors.surface,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_fabHintVisible)
            _FabHintBubble(
              onDismiss: _dismissFabHint,
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: AppTokens.radius.lg,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: AppTokens.radius.lg,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: colors.primary.withValues(alpha: 0.16),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: colors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _FabHintBubble extends StatelessWidget {
  const _FabHintBubble({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: isDark ? 0.9 : 0.96),
          borderRadius: AppTokens.radius.lg,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.16),
              blurRadius: 28,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Need something fast? Use the plus button to add reminders, classes, or scan schedules.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onDismiss,
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
