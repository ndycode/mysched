// coverage:ignore-file
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/routes.dart';
import '../../services/admin_service.dart';
import '../../services/notif_scheduler.dart';
import '../../services/profile_cache.dart';
import '../../services/theme_controller.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';
import '../../utils/local_notifs.dart';
import '../about_sheet.dart';
import '../admin_issue_reports_page.dart';
import '../privacy_sheet.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ThemeController _themeController = ThemeController.instance;
  static const double _kBottomNavSafePadding = 120;

  bool _loading = true;
  bool _saving = false;
  bool _classAlarms = true;
  bool _appNotifs = true;
  bool _quietWeek = false;
  bool _verboseLogging = false;
  int _leadMinutes = 10;
  int _snoozeMinutes = 5;
  String? _studentName;
  String? _studentEmail;
  String? _avatarUrl;
  bool _profileHydrated = false;
  bool _adminLoaded = false;
  bool _isAdmin = false;
  String? _adminError;
  bool _adminSnackShown = false;
  ThemeMode _themeMode = ThemeMode.system;

  VoidCallback? _profileListener;
  VoidCallback? _adminRoleListener;
  VoidCallback? _adminCountListener;
  void Function(int classId, int minutes)? _snoozeListener;

  final List<int> _leadOptions = const [5, 10, 15, 20, 30, 45, 60];
  final List<int> _snoozeOptions = const [5, 10, 15, 20];

  @override
  void initState() {
    super.initState();
    _themeMode = _themeController.currentMode;
    _themeController.mode.addListener(_handleThemeChanged);
    _restorePreferences();
    _listenToProfile();
    _bootstrapAdminState();
    _installSnoozeListener();
  }

  @override
  void dispose() {
    _themeController.mode.removeListener(_handleThemeChanged);
    if (_profileListener != null) {
      ProfileCache.notifier.removeListener(_profileListener!);
    }
    if (_adminRoleListener != null) {
      AdminService.instance.role.removeListener(_adminRoleListener!);
    }
    if (_adminCountListener != null) {
      AdminService.instance.newReportCount.removeListener(_adminCountListener!);
    }
    _removeSnoozeListener();
    super.dispose();
  }

  Future<void> _restorePreferences() async {
    final sp = await SharedPreferences.getInstance();
    await NotifScheduler.ensurePreferenceMigration(prefs: sp);
    setState(() {
      _classAlarms = sp.getBool('class_alarms') ?? true;
      _appNotifs = sp.getBool('app_notifs') ?? true;
      _quietWeek = sp.getBool('quiet_week_enabled') ?? false;
      _verboseLogging = sp.getBool('alarm_verbose_logging') ?? false;
      _leadMinutes = sp.getInt('notifLeadMinutes') ?? 10;
      _snoozeMinutes = sp.getInt('snoozeMinutes') ?? 5;
    });
    setState(() => _loading = false);
  }

  void _listenToProfile() {
    _profileListener = () {
      final summary = ProfileCache.notifier.value;
      _applyProfile(summary);
    };
    ProfileCache.notifier.addListener(_profileListener!);
    _applyProfile(ProfileCache.notifier.value);
    ProfileCache.load();
  }

  void _applyProfile(ProfileSummary? profile) {
    if (!mounted) return;
    if (profile == null) {
      if (_profileHydrated) return;
      setState(() => _profileHydrated = true);
      return;
    }
    setState(() {
      _studentName = profile.name;
      _studentEmail = profile.email;
      _avatarUrl = profile.avatarUrl;
      _profileHydrated = true;
    });
  }

  void _bootstrapAdminState() {
    _adminRoleListener = () {
      if (!mounted) return;
      final state = AdminService.instance.role.value;
      setState(() {
        _adminLoaded = state != AdminRoleState.unknown;
        _isAdmin = state == AdminRoleState.admin;
        _adminError = state == AdminRoleState.error
            ? 'Unable to verify admin access.'
            : null;
      });
      if (state == AdminRoleState.admin) {
        AdminService.instance.refreshNewReportCount();
      }
    };
    AdminService.instance.role.addListener(_adminRoleListener!);

    _adminCountListener = () {
      if (!mounted) return;
      final count = AdminService.instance.newReportCount.value;
      if (count > 0 && !_adminSnackShown) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _adminSnackShown) return;
          showAppSnackBar(
            context,
            count == 1
                ? 'You have 1 new class report to review.'
                : 'You have $count new class reports to review.',
            actionLabel: 'View',
            onAction: _openClassIssueReports,
          );
          _adminSnackShown = true;
        });
      }
      if (count == 0) {
        _adminSnackShown = false;
      }
    };
    AdminService.instance.newReportCount.addListener(_adminCountListener!);
    AdminService.instance.refreshRole().ignore();
  }

  void _handleThemeChanged() {
    if (!mounted) return;
    setState(() => _themeMode = _themeController.currentMode);
  }

  Future<void> _openClassIssueReports() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ClassIssueReportsPage()),
    );
    if (!mounted) return;
    AdminService.instance.refreshNewReportCount();
  }

  void _installSnoozeListener() {
    _snoozeListener = (classId, minutes) {
      if (!mounted) return;
      _showSnack('Reminder snoozed for $minutes minutes.');
    };
    NotifScheduler.onSnoozed = _snoozeListener;
  }

  void _removeSnoozeListener() {
    if (NotifScheduler.onSnoozed == _snoozeListener) {
      NotifScheduler.onSnoozed = null;
    }
    _snoozeListener = null;
  }

  Future<void> _sendTestNotification() async {
    if (!Platform.isAndroid) {
      _showSnack('Heads-up notifications are Android only.');
      return;
    }
    final success = await LocalNotifs.showHeadsUp(
      id: DateTime.now().millisecondsSinceEpoch & 0x7fffffff,
      title: 'Heads-up test',
      body: 'This is how reminder alerts will look.',
    );
    if (success) {
      _showSnack('Heads-up sent.');
    } else {
      _showSupportError(
        'Unable to show notification. Check alarm permissions.',
        onRetry: _sendTestNotification,
      );
    }
  }

  Future<void> _triggerAlarmTest() async {
    if (!Platform.isAndroid) {
      _showSnack('Full-screen alarm preview is Android only.');
      return;
    }
    final ok = await LocalNotifs.scheduleTestAlarm(
      seconds: 1,
      title: 'Alarm preview',
      body: 'Swipe to snooze or stop.',
    );
    if (ok) {
      _showSnack('Launching alarm preview…');
    } else {
      _showSupportError(
        'Unable to start the alarm preview. Check alarm permissions.',
        onRetry: _triggerAlarmTest,
      );
    }
  }

  Future<void> _toggleClassAlarms(bool value) async {
    setState(() => _classAlarms = value);
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('class_alarms', value);
    await NotifScheduler.resync();
  }

  Future<void> _toggleAppNotifs(bool value) async {
    setState(() => _appNotifs = value);
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('app_notifs', value);
    await NotifScheduler.resync();
  }

  Future<void> _toggleQuietWeek(bool value) async {
    setState(() => _quietWeek = value);
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('quiet_week_enabled', value);
    await NotifScheduler.resync();
    _showSnack(
      value
          ? 'Quiet week enabled. Alarms paused.'
          : 'Quiet week disabled. Alarms resuming.',
    );
  }

  Future<void> _toggleVerboseLogging(bool value) async {
    setState(() => _verboseLogging = value);
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('alarm_verbose_logging', value);
    LocalNotifs.debugLogExactAlarms = value;
  }

  Future<void> _pickLeadMinutes() async {
    final value = await _pickOption(
      title: 'Heads-up before class',
      options: _leadOptions,
      selected: _leadMinutes,
      suffix: 'minutes',
    );
    if (value == null) return;
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('notifLeadMinutes', value);
    setState(() => _leadMinutes = value);
    await NotifScheduler.resync();
  }

  Future<void> _pickSnoozeMinutes() async {
    final value = await _pickOption(
      title: 'Snooze length',
      options: _snoozeOptions,
      selected: _snoozeMinutes,
      suffix: 'minutes',
    );
    if (value == null) return;
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('snoozeMinutes', value);
    setState(() => _snoozeMinutes = value);
  }

  Future<int?> _pickOption({
    required String title,
    required List<int> options,
    required int selected,
    required String suffix,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        final media = MediaQuery.of(context);
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: media.viewInsets.bottom + media.padding.bottom + 16,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: AppTokens.radius.xl,
              ),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  ...options.map(
                    (value) => ListTile(
                      title: Text('$value $suffix'),
                      trailing: value == selected
                          ? Icon(Icons.check_rounded,
                              color: theme.colorScheme.primary)
                          : null,
                      onTap: () => Navigator.of(context).pop(value),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    showAppSnackBar(context, message);
  }

  void _showSupportError(
    String message, {
    VoidCallback? onRetry,
  }) {
    if (!mounted) return;
    setState(() {
      _saving = false;
    });
    showAppSnackBar(
      context,
      message,
      type: AppSnackBarType.error,
      actionLabel: onRetry == null ? null : 'Retry',
      onAction: onRetry,
    );
  }

  Future<void> _openAccount() async {
    await context.push(AppRoutes.account);
    await ProfileCache.load(forceRefresh: true);
  }

  Future<void> _openPrivacy() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PrivacySheet()),
    );
  }

  Future<void> _openAbout() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AboutSheet()),
    );
  }

  Future<void> _openExactAlarmSettings() async {
    await LocalNotifs.openExactAlarmSettings();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = AppTokens.spacing;
    final media = MediaQuery.of(context);

    if (_loading) {
      return ScreenShell(
        screenName: 'settings',
        hero: const ScreenHeroCard(
          title: 'Settings',
          subtitle: 'Loading your preferences…',
        ),
        sections: const [
          ScreenSection(
            decorated: false,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    final hero = ScreenBrandHeader(
      name: _studentName,
      email: _studentEmail,
      avatarUrl: _avatarUrl,
      onAccountTap: _openAccount,
      showChevron: false,
      loading: !_profileHydrated,
    );

    final sections = <Widget>[
      const ScreenSection(
        decorated: false,
        child: ScreenHeroCard(
          title: 'Settings',
          subtitle: 'Control alarms, notifications, and app styling in one place.',
        ),
      ),
      ScreenSection(
        title: 'Notifications',
        subtitle: 'Control alarms, quiet weeks, and push alerts.',
        decorated: false,
        child: _buildNotificationCard(theme),
      ),
      ScreenSection(
        title: 'Schedule preferences',
        subtitle: 'Heads-up timing and snooze length.',
        decorated: false,
        child: _buildScheduleCard(theme),
      ),
      ScreenSection(
        title: 'Appearance',
        subtitle: 'Choose light, dark, or match system.',
        decorated: false,
        child: _buildAppearanceCard(theme),
      ),
    ];

    if (Platform.isAndroid) {
      sections.add(
        ScreenSection(
          title: 'Android tools',
          subtitle: 'Exact alarms and diagnostics.',
          decorated: false,
          child: _buildAndroidToolsCard(theme),
        ),
      );
    }

    if (_adminLoaded && _isAdmin) {
      sections.add(
        ScreenSection(
          title: 'Admin tools',
          subtitle: 'Manage reports and send tests.',
          decorated: false,
          child: _buildAdminCard(theme),
        ),
      );
    } else if (_adminError != null) {
      sections.add(
        ScreenSection(
          decorated: false,
          child: ErrorState(
            title: 'Admin tools unavailable',
            message: _adminError!,
            onRetry: () => AdminService.instance.refreshRole(force: true),
          ),
        ),
      );
    }

    sections.add(
      ScreenSection(
        title: 'Support',
        subtitle: 'Resync alarms or review policies.',
        decorated: false,
        child: _buildSupportCard(theme),
      ),
    );

    final shell = ScreenShell(
      screenName: 'settings',
      hero: hero,
      sections: sections,
      padding: EdgeInsets.fromLTRB(
        20,
        media.padding.top + spacing.xxxl,
        20,
        spacing.quad + _kBottomNavSafePadding,
      ),
      safeArea: false,
    );

    return AbsorbPointer(
      absorbing: _saving,
      child: shell,
    );
  }

  Widget _buildNotificationCard(ThemeData theme) {
    final spacing = AppTokens.spacing;
    final colors = theme.colorScheme;

    return CardX(
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToggleRow(
            theme: theme,
            icon: Icons.alarm_rounded,
            title: 'Class reminders',
            description: 'Alarm-style alerts before classes begin.',
            value: _classAlarms,
            onChanged: _toggleClassAlarms,
          ),
          SizedBox(height: spacing.lg),
          _buildToggleRow(
            theme: theme,
            icon: Icons.notifications_active_outlined,
            title: 'App notifications',
            description: 'Allow MySched to send notifications.',
            value: _appNotifs,
            onChanged: _toggleAppNotifs,
          ),
          SizedBox(height: spacing.lg),
          _buildToggleRow(
            theme: theme,
            icon: Icons.nightlight_rounded,
            title: 'Quiet week',
            description: 'Pause alarm scheduling for one week.',
            value: _quietWeek,
            onChanged: _toggleQuietWeek,
          ),
          if (_quietWeek) ...[
            SizedBox(height: spacing.md),
            Container(
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: AppTokens.radius.lg,
              ),
              padding: const EdgeInsets.all(12),
              child: Text(
                'Quiet week is on. Alarm reminders are paused until you turn it off.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleCard(ThemeData theme) {
    final spacing = AppTokens.spacing;

    return CardX(
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNavigationRow(
            theme: theme,
            icon: Icons.snooze_outlined,
            title: 'Heads-up before class',
            description: '$_leadMinutes minutes before class',
            onTap: _pickLeadMinutes,
          ),
          SizedBox(height: spacing.lg),
          _buildNavigationRow(
            theme: theme,
            icon: Icons.schedule_rounded,
            title: 'Snooze length',
            description: '$_snoozeMinutes minutes',
            onTap: _pickSnoozeMinutes,
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard(ThemeData theme) {
    final spacing = AppTokens.spacing;

    return CardX(
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appearance',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: spacing.md),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.wb_sunny_outlined),
                label: Text('Light'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.nightlight_round),
                label: Text('Dark'),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.auto_mode_rounded),
                label: Text('System'),
              ),
            ],
            selected: <ThemeMode>{_themeMode},
            onSelectionChanged: (value) {
              final next = value.single;
              setState(() => _themeMode = next);
              _themeController.setThemeMode(next);
            },
          ),
          SizedBox(height: spacing.md),
          Text(
            'Switch between light, dark, or follow your device settings. Changes animate instantly.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAndroidToolsCard(ThemeData theme) {
    final spacing = AppTokens.spacing;
    final colors = theme.colorScheme;

    return CardX(
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: _buildNavigationRow(
        theme: theme,
        icon: Icons.alarm_on_rounded,
        title: 'Open exact alarm settings',
        description: 'Manage Android exact alarm permission.',
        accentColor: colors.primary,
        trailing: Icon(Icons.open_in_new_rounded, color: colors.primary),
        onTap: _openExactAlarmSettings,
      ),
    );
  }

  Widget _buildAdminCard(ThemeData theme) {
    final spacing = AppTokens.spacing;
    final colors = theme.colorScheme;

    return CardX(
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNavigationRow(
            theme: theme,
            icon: Icons.flag_outlined,
            title: 'Class issue reports',
            description: 'Review flagged classes and keep details accurate.',
            trailing: Icon(
              Icons.flag_outlined,
              color: colors.primary,
            ),
            onTap: _openClassIssueReports,
          ),
          SizedBox(height: spacing.lg),
          _buildNavigationRow(
            theme: theme,
            icon: Icons.notification_important_outlined,
            title: 'Send test heads-up',
            description: 'Preview the quick heads-up alert.',
            accentColor: colors.primary,
            trailing: Icon(Icons.play_arrow_rounded, color: colors.primary),
            onTap: _sendTestNotification,
          ),
          SizedBox(height: spacing.lg),
          _buildToggleRow(
            theme: theme,
            icon: Icons.bug_report_outlined,
            title: 'Verbose alarm logging (debug)',
            description: 'Print exact alarm scheduling details.',
            value: _verboseLogging,
            onChanged: _toggleVerboseLogging,
          ),
          SizedBox(height: spacing.lg),
          PrimaryButton(
            label: 'Launch alarm preview',
            leading: const Icon(Icons.play_circle_outline_rounded),
            onPressed: _triggerAlarmTest,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(ThemeData theme) {
    final spacing = AppTokens.spacing;

    return CardX(
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNavigationRow(
            theme: theme,
            icon: Icons.refresh_rounded,
            title: 'Resync class reminders',
            description: 'Regenerate alarms after schedule changes.',
            onTap: () async {
              setState(() => _saving = true);
              await NotifScheduler.resync();
              if (!mounted) return;
              setState(() => _saving = false);
              _showSnack('Resync in progress.');
            },
          ),
          SizedBox(height: spacing.lg),
          _buildNavigationRow(
            theme: theme,
            icon: Icons.info_outline_rounded,
            title: 'About',
            onTap: _openAbout,
          ),
          SizedBox(height: spacing.lg),
          _buildNavigationRow(
            theme: theme,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy policy',
            onTap: _openPrivacy,
          ),
          SizedBox(height: spacing.lg),
          PrimaryButton(
            label: 'Sign out',
            onPressed: () {
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final spacing = AppTokens.spacing;
    final colors = theme.colorScheme;
    final accent = colors.primary;

    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: spacing.edgeInsetsAll(spacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: AppTokens.radius.xl,
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            _buildIconBadge(theme, icon, accent),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTokens.typography.subtitle.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing.md),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              thumbColor: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.selected) ? accent : null,
              ),
              trackColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? accent.withValues(alpha: 0.35)
                    : null,
              ),
              splashRadius: 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRow({
    required ThemeData theme,
    required IconData icon,
    required String title,
    String? description,
    VoidCallback? onTap,
    Color? accentColor,
    Widget? trailing,
  }) {
    final spacing = AppTokens.spacing;
    final colors = theme.colorScheme;
    final accent = accentColor ?? colors.primary;

    final row = Row(
      children: [
        _buildIconBadge(theme, icon, accent),
        SizedBox(width: spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTokens.typography.subtitle.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (description != null) ...[
                SizedBox(height: spacing.xs),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: spacing.md),
        trailing ??
            Icon(
              Icons.chevron_right_rounded,
              color: colors.onSurfaceVariant,
            ),
      ],
    );

    if (onTap == null) {
      return Container(
        padding: spacing.edgeInsetsAll(spacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: AppTokens.radius.xl,
          border: Border.all(color: colors.outline.withValues(alpha: 0.12)),
        ),
        child: row,
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: spacing.edgeInsetsAll(spacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: AppTokens.radius.xl,
          border: Border.all(color: colors.outline.withValues(alpha: 0.12)),
        ),
        child: row,
      ),
    );
  }

  Widget _buildIconBadge(ThemeData theme, IconData icon, Color accent) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.22 : 0.14),
        borderRadius: AppTokens.radius.md,
      ),
      child: Icon(icon, color: accent),
    );
  }
}
