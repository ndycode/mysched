// coverage:ignore-file
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../services/admin_service.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';
import '../../utils/local_notifs.dart';
import '../about_sheet.dart';
import '../admin_issue_reports_page.dart';
import '../privacy_sheet.dart';
import 'settings_controller.dart';
import '../../services/theme_controller.dart';
import '../../services/data_sync.dart';
import '../../services/offline_queue.dart';
import '../../services/connection_monitor.dart';

import 'package:intl/intl.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsController _controller;
  static const double _kBottomNavSafePadding = 120;
  bool _adminSnackShown = false;

  final List<int> _leadOptions = const [5, 10, 15, 20, 30, 45, 60];
  final List<int> _snoozeOptions = const [5, 10, 15, 20];


  @override
  void initState() {
    super.initState();
    _controller = SettingsController();
    _bindControllerEvents();
    ConnectionMonitor.instance.startMonitoring();
    OfflineQueue.instance.init();

  }

  @override
  void dispose() {
    ConnectionMonitor.instance.stopMonitoring();
    _controller.dispose();
    super.dispose();
  }

  void _bindControllerEvents() {
    _controller.onSnack = (message) {
      if (!mounted) return;
      showAppSnackBar(context, message);
    };

    _controller.onSupportError = (message, onRetry) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        message,
        type: AppSnackBarType.error,
        actionLabel: onRetry == null ? null : 'Retry',
        onAction: onRetry,
      );
    };

    _controller.onNewAdminReports = (count) {
      if (!mounted) return;
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
  }

  Future<void> _openClassIssueReports() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ClassIssueReportsPage()),
    );
    if (!mounted) return;
    AdminService.instance.refreshNewReportCount();
  }

  Future<void> _pickLeadMinutes() async {
    final value = await _pickOption(
      title: 'Heads-up before class',
      options: _leadOptions,
      selected: _controller.leadMinutes,
      suffix: 'minutes',
    );
    if (value == null) return;
    _controller.setLeadMinutes(value);
  }

  Future<void> _pickSnoozeMinutes() async {
    final value = await _pickOption(
      title: 'Snooze length',
      options: _snoozeOptions,
      selected: _controller.snoozeMinutes,
      suffix: 'minutes',
    );
    if (value == null) return;
    _controller.setSnoozeMinutes(value);
  }

  final List<Map<String, String>> _availableRingtones = const [
    {'uri': 'default', 'title': 'Default System Ringtone'},
    {'uri': 'content://settings/system/alarm_alert', 'title': 'Classic Alarm'},
    {'uri': 'content://media/internal/audio/media/123', 'title': 'Digital Beep'},
  ];

  String _getRingtoneLabel(String uri) {
    final found = _availableRingtones.firstWhere(
      (e) => e['uri'] == uri,
      orElse: () => {'title': 'Default'},
    );
    return found['title'] ?? 'Default';
  }

  Future<void> _pickRingtone() async {
    final selected = await _pickOption(
      title: 'Select Ringtone',
      options: List.generate(_availableRingtones.length, (i) => i),
      selected: _availableRingtones.indexWhere((e) => e['uri'] == _controller.alarmRingtone),
      suffix: '',
    );
    
    if (selected != null && selected >= 0 && selected < _availableRingtones.length) {
      _controller.setAlarmRingtone(_availableRingtones[selected]['uri']!);
    }
  }

  Future<int?> _pickOption({
    required String title,
    required List<int> options,
    required int selected,
    required String suffix,
  }) {
    return showDialog<int>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final spacing = AppTokens.spacing;
        
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: spacing.edgeInsetsAll(spacing.lg),
          child: Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.surfaceContainerHigh
                  : theme.colorScheme.surface,
              borderRadius: AppTokens.radius.xxl,
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? theme.colorScheme.outline.withValues(alpha: 0.12)
                    : theme.colorScheme.outline,
                width: theme.brightness == Brightness.dark ? 1 : 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: AppTokens.radius.xxl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                    padding: spacing.edgeInsetsAll(spacing.xl),
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: options.map((value) {
                          // Handle both int options (minutes) and index options (ringtones)
                          final isRingtone = suffix.isEmpty;
                          
                          final displayLabel = isRingtone 
                              ? _availableRingtones[value]['title']!
                              : '$value $suffix';
                          
                          final isSelected = isRingtone 
                              ? _availableRingtones[value]['uri'] == _controller.alarmRingtone
                              : value == selected;

                          return InkWell(
                            onTap: () => Navigator.of(context).pop(value),
                            child: Padding(
                              padding: spacing.edgeInsetsSymmetric(
                                horizontal: spacing.xl,
                                vertical: spacing.md,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      displayLabel,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        color: isSelected 
                                            ? theme.colorScheme.primary 
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_rounded,
                                      color: theme.colorScheme.primary,
                                      size: AppTokens.iconSize.md,
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.md),
                  Padding(
                    padding: spacing.edgeInsetsAll(spacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SecondaryButton(
                          label: 'Cancel',
                          onPressed: () => Navigator.of(context).pop(),
                          minHeight: 40,
                          expanded: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openAccount() async {
    await context.push(AppRoutes.account);
    await _controller.refreshProfile();
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
    await _controller.refreshAlarmReadiness();
  }

  Future<void> _openNotificationSettings() async {
    await LocalNotifs.openNotificationSettings();
    await _controller.refreshAlarmReadiness();
  }

  Future<void> _openBatteryOptimizationSettings() async {
    await LocalNotifs.openBatteryOptimizationDialog(context);
    await _controller.refreshAlarmReadiness();
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = AppTokens.spacing;
    final media = MediaQuery.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.loading) {
          return ScreenShell(
            screenName: 'settings',
            hero: const ScreenHeroCard(
              title: 'Settings',
              subtitle: 'Loading your preferences…',
            ),
            sections: [
              ScreenSection(
                decorated: false,
                child: Column(
                  children: [
                    const SkeletonCard(showAvatar: false, lineCount: 4),
                    SizedBox(height: spacing.lg),
                    const SkeletonCard(showAvatar: false, lineCount: 3),
                  ],
                ),
              ),
            ],
          );
        }

        final hero = ScreenBrandHeader(
          name: _controller.studentName,
          email: _controller.studentEmail,
          avatarUrl: _controller.avatarUrl,
          onAccountTap: _openAccount,
          showChevron: false,
          loading: !_controller.profileHydrated,
        );

        final sections = <Widget>[
          // Premium Header
          ScreenSection(
            decorated: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primary.withValues(alpha: 0.15),
                        colors.primary.withValues(alpha: 0.10),
                      ],
                    ),
                    borderRadius: AppTokens.radius.md,
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.settings_rounded,
                    color: colors.primary,
                    size: AppTokens.iconSize.xl,
                  ),
                ),
                SizedBox(width: spacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: AppTokens.typography.headline.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: colors.onSurface,
                        ),
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        'Control alarms, notifications, and app styling.',
                        style: AppTokens.typography.body.copyWith(
                          height: 1.4,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ScreenSection(
            title: 'Notifications',
            subtitle: 'Control alarms, quiet weeks, and push alerts.',
            decorated: false,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? colors.surfaceContainerHigh : colors.surface,
                borderRadius: AppTokens.radius.xl,
                border: Border.all(
                  color: isDark ? colors.outline.withValues(alpha: 0.12) : colors.outline,
                  width: isDark ? 1 : 0.5,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: _buildNotificationCard(theme),
            ),
          ),
          ScreenSection(
            title: 'Schedule preferences',
            subtitle: 'Heads-up timing and snooze length.',
            decorated: false,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? colors.surfaceContainerHigh : colors.surface,
                borderRadius: AppTokens.radius.xl,
                border: Border.all(
                  color: isDark ? colors.outline.withValues(alpha: 0.12) : colors.outline,
                  width: isDark ? 1 : 0.5,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: _buildScheduleCard(theme),
            ),
          ),
          ScreenSection(
            title: 'Alarm settings',
            subtitle: 'Volume, vibration, and ringtone.',
            decorated: false,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? colors.surfaceContainerHigh : colors.surface,
                borderRadius: AppTokens.radius.xl,
                border: Border.all(
                  color: isDark ? colors.outline.withValues(alpha: 0.12) : colors.outline,
                  width: isDark ? 1 : 0.5,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: _buildAlarmSettingsCard(theme),
            ),
          ),
          ScreenSection(
            title: 'Appearance',
            subtitle: 'Choose light, dark, or match system.',
            decorated: false,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? colors.surfaceContainerHigh : colors.surface,
                borderRadius: AppTokens.radius.xl,
                border: Border.all(
                  color: isDark ? colors.outline.withValues(alpha: 0.12) : colors.outline,
                  width: isDark ? 1 : 0.5,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: _buildAppearanceCard(theme),
            ),
          ),
        ];

        if (Platform.isAndroid) {
          sections.add(
            ScreenSection(
              title: 'Android tools',
              subtitle: 'Exact alarms and diagnostics.',
              decorated: false,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? colors.surfaceContainerHigh : colors.surface,
                  borderRadius: AppTokens.radius.xl,
                  border: Border.all(
                    color: isDark ? colors.outline.withValues(alpha: 0.12) : colors.outline,
                    width: isDark ? 1 : 0.5,
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: _buildAndroidToolsCard(theme),
              ),
            ),
          );
        }

        if (_controller.adminLoaded && _controller.isAdmin) {
          sections.add(
            ScreenSection(
              title: 'Admin tools',
              subtitle: 'Manage reports and send tests.',
              decorated: false,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? colors.surfaceContainerHigh : colors.surface,
                  borderRadius: AppTokens.radius.xl,
                  border: Border.all(
                    color: isDark ? colors.outline.withValues(alpha: 0.12) : colors.outline,
                    width: isDark ? 1 : 0.5,
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: _buildAdminCard(theme),
              ),
            ),
          );
        } else if (_controller.adminError != null) {
          sections.add(
            ScreenSection(
              decorated: false,
              child: StateDisplay(
                variant: StateVariant.error,
                title: 'Admin tools unavailable',
                message: _controller.adminError!,
                primaryActionLabel: 'Retry',
                onPrimaryAction: () => AdminService.instance.refreshRole(force: true),
                compact: true,
              ),
            ),
          );
        }

        sections.add(
          ScreenSection(
            title: 'Sync & offline',
            subtitle: 'View cached data status and retry queued changes.',
            decorated: false,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? colors.surfaceContainerHigh : colors.surface,
                borderRadius: AppTokens.radius.lg,
                border: Border.all(
                  color: isDark ? colors.outline.withValues(alpha: 0.12) : colors.outline,
                  width: isDark ? 1 : 0.5,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: _buildSyncCard(theme),
            ),
          ),
        );

        sections.add(
          ScreenSection(
            title: 'Support',
            subtitle: 'Resync alarms or review policies.',
            decorated: false,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? colors.surfaceContainerHigh : colors.surface,
                borderRadius: AppTokens.radius.lg,
                border: Border.all(
                  color: isDark ? colors.outline.withValues(alpha: 0.12) : colors.outline,
                  width: isDark ? 1 : 0.5,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: _buildSupportCard(theme),
            ),
          ),
        );

        final shell = ScreenShell(
          screenName: 'settings',
          hero: hero,
          sections: sections,
          padding: spacing.edgeInsetsOnly(
            left: spacing.xl,
            right: spacing.xl,
            top: media.padding.top + spacing.xxxl,
            bottom: spacing.quad + _kBottomNavSafePadding,
          ),
          safeArea: false,
        );

        return AbsorbPointer(
          absorbing: _controller.saving,
          child: shell,
        );
      },
    );
  }

  Widget _buildNotificationCard(ThemeData theme) {
    final spacing = AppTokens.spacing;
    final colors = theme.colorScheme;

    return Padding(
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToggleRow(
            theme: theme,
            icon: Icons.alarm_rounded,
            title: 'Class reminders',
            description: 'Alarm-style alerts before classes begin.',
            value: _controller.classAlarms,
            onChanged: _controller.toggleClassAlarms,
          ),
          SizedBox(height: spacing.lg),
          _buildToggleRow(
            theme: theme,
            icon: Icons.notifications_active_outlined,
            title: 'App notifications',
            description: 'Allow MySched to send notifications.',
            value: _controller.appNotifs,
            onChanged: _controller.toggleAppNotifs,
          ),
          SizedBox(height: spacing.lg),
          _buildToggleRow(
            theme: theme,
            icon: Icons.nightlight_rounded,
            title: 'Quiet week',
            description: 'Pause alarm scheduling for one week.',
            value: _controller.quietWeek,
            onChanged: _controller.toggleQuietWeek,
          ),
          if (_controller.quietWeek) ...[
            SizedBox(height: spacing.md),
            Container(
              decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
                borderRadius: AppTokens.radius.md,
              ),
              padding: spacing.edgeInsetsAll(spacing.md),
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

    return Padding(
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNavigationRow(
            theme: theme,
            icon: Icons.snooze_outlined,
            title: 'Heads-up before class',
            description: '${_controller.leadMinutes} minutes before class',
            onTap: _pickLeadMinutes,
          ),
          SizedBox(height: spacing.lg),
          _buildNavigationRow(
            theme: theme,
            icon: Icons.schedule_rounded,
            title: 'Snooze length',
            description: '${_controller.snoozeMinutes} minutes',
            onTap: _pickSnoozeMinutes,
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmSettingsCard(ThemeData theme) {
    final spacing = AppTokens.spacing;
    final colors = theme.colorScheme;

    return Padding(
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Volume slider
          Row(
            children: [
              _buildIconBadge(theme, Icons.volume_up_rounded, colors.primary),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Alarm volume',
                          style: AppTokens.typography.subtitle.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_controller.alarmVolume}%',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.xs),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                      ),
                      child: Slider(
                        value: _controller.alarmVolume.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 20,
                        activeColor: colors.primary,
                        inactiveColor: colors.surfaceContainerHighest,
                        onChanged: (value) {
                          _controller.setAlarmVolume(value.round());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          // Vibration toggle
          _buildToggleRow(
            theme: theme,
            icon: Icons.vibration_rounded,
            title: 'Use vibration',
            description: 'Vibrate when alarm rings.',
            value: _controller.alarmVibration,
            onChanged: _controller.toggleAlarmVibration,
          ),
          SizedBox(height: spacing.lg),
          // Ringtone selection
          _buildNavigationRow(
            theme: theme,
            icon: Icons.music_note_rounded,
            title: 'Ringtone',
            description: _getRingtoneLabel(_controller.alarmRingtone),
            onTap: _pickRingtone,
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard(ThemeData theme) {
    final spacing = AppTokens.spacing;

    return Padding(
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _ThemeOption(
                  selected: _controller.themeMode == AppThemeMode.light,
                  onTap: () => _controller.setMode(AppThemeMode.light),
                  label: 'Light',
                  icon: Icons.wb_sunny_rounded,
                  color: Colors.white,
                  onColor: Colors.black,
                  showBorder: true,
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: _ThemeOption(
                  selected: _controller.themeMode == AppThemeMode.dark,
                  onTap: () => _controller.setMode(AppThemeMode.dark),
                  label: 'Dark',
                  icon: Icons.nightlight_round,
                  color: const Color(0xFF303030),
                  onColor: Colors.white,
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: _ThemeOption(
                  selected: _controller.themeMode == AppThemeMode.voidMode,
                  onTap: () => _controller.setMode(AppThemeMode.voidMode),
                  label: 'Void',
                  icon: Icons.brightness_2_rounded,
                  color: const Color(0xFF000000),
                  onColor: Colors.white,
                  borderColor: const Color(0xFF333333),
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: _ThemeOption(
                  selected: _controller.themeMode == AppThemeMode.system,
                  onTap: () => _controller.setMode(AppThemeMode.system),
                  label: 'Auto',
                  icon: Icons.brightness_auto_rounded,
                  color: Colors.transparent,
                  onColor: theme.colorScheme.onSurface,
                  isOutline: true,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          Text(
            'Switch between light, dark, or void mode (ultra dark). Changes animate instantly.',
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

    return Padding(
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNavigationRow(
            theme: theme,
            icon: Icons.alarm_on_rounded,
            title: 'Exact alarms',
            description: 'Required for on-time class reminders.',
            accentColor: colors.primary,
            trailing: _buildStatusPill(
              theme: theme,
              ok: _controller.exactAlarmAllowed,
              okLabel: 'Allowed',
              badLabel: 'Action needed',
            ),
            onTap: _openExactAlarmSettings,
          ),
          SizedBox(height: spacing.lg),
          _buildNavigationRow(
            theme: theme,
            icon: Icons.notifications_active_outlined,
            title: 'Notifications',
            description: 'Backup banner if full-screen alarms are blocked.',
            accentColor: colors.primary,
            trailing: _buildStatusPill(
              theme: theme,
              ok: _controller.notificationsAllowed,
              okLabel: 'On',
              badLabel: 'Blocked',
            ),
            onTap: _openNotificationSettings,
          ),
          SizedBox(height: spacing.lg),
          _buildNavigationRow(
            theme: theme,
            icon: Icons.battery_alert_rounded,
            title: 'Battery optimization',
            description: 'Allow background delivery so alarms are not killed.',
            accentColor: colors.primary,
            trailing: _buildStatusPill(
              theme: theme,
              ok: _controller.ignoringBatteryOptimizations,
              okLabel: 'Unrestricted',
              badLabel: 'Optimized',
            ),
            onTap: _openBatteryOptimizationSettings,
          ),
          SizedBox(height: spacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: SecondaryButton(
              leading: _controller.readinessLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                      ),
                    )
                  : const Icon(Icons.refresh_rounded),
              label: _controller.readinessLoading ? 'Checking…' : 'Refresh status',
              onPressed: _controller.readinessLoading
                  ? null
                  : _controller.refreshAlarmReadiness,
              expanded: false,
              minHeight: 44,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(ThemeData theme) {
    final spacing = AppTokens.spacing;
    final colors = theme.colorScheme;

    return Padding(
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
            onTap: _controller.sendTestNotification,
          ),
          SizedBox(height: spacing.lg),
          _buildToggleRow(
            theme: theme,
            icon: Icons.bug_report_outlined,
            title: 'Verbose alarm logging (debug)',
            description: 'Print exact alarm scheduling details.',
            value: _controller.verboseLogging,
            onChanged: _controller.toggleVerboseLogging,
          ),
          SizedBox(height: spacing.lg),
          PrimaryButton(
            label: 'Launch alarm preview',
            leading: const Icon(Icons.play_circle_outline_rounded),
            onPressed: () =>
                _controller.triggerAlarmTest(_openExactAlarmSettings),
          ),

        ],
      ),
    );
  }

  Widget _buildSupportCard(ThemeData theme) {
    final spacing = AppTokens.spacing;

    return Padding(
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNavigationRow(
            theme: theme,
            icon: Icons.refresh_rounded,
            title: 'Resync class reminders',
            description: 'Regenerate alarms after schedule changes.',
            onTap: _controller.resyncReminders,
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
      child: Padding(
        padding: spacing.edgeInsetsSymmetric(vertical: spacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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

  Widget _buildStatusPill({
    required ThemeData theme,
    required bool? ok,
    String okLabel = 'Allowed',
    String badLabel = 'Blocked',
  }) {
    final colors = theme.colorScheme;
    final isOk = ok == true;
    final isUnknown = ok == null;
    final label = isUnknown ? 'Unknown' : (isOk ? okLabel : badLabel);
    final bg = isUnknown
        ? colors.surfaceContainerHighest
        : isOk
            ? colors.primary.withValues(alpha: 0.16)
            : colors.errorContainer;
    final fg = isUnknown
        ? colors.onSurfaceVariant
        : isOk
            ? colors.primary
            : colors.error;
    return Container(
      padding: AppTokens.spacing.edgeInsetsSymmetric(horizontal: AppTokens.spacing.md, vertical: AppTokens.spacing.sm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppTokens.radius.pill,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
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
      crossAxisAlignment: CrossAxisAlignment.center,
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
      return Padding(
        padding: spacing.edgeInsetsSymmetric(vertical: spacing.sm),
        child: row,
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: spacing.edgeInsetsSymmetric(vertical: spacing.sm),
        child: row,
      ),
    );
  }

  Widget _buildIconBadge(ThemeData theme, IconData icon, Color accent) {

    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: AppTokens.radius.sm,
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: accent, size: AppTokens.iconSize.lg),
    );
  }

  Widget _buildSyncCard(ThemeData theme) {
    final spacing = AppTokens.spacing;
    final colors = theme.colorScheme;

    String formatSync(DateTime? value) {
      if (value == null) return 'Never';
      final now = DateTime.now();
      final diff = now.difference(value);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return DateFormat('MMM d, h:mm a').format(value);
    }

    return Padding(
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<DateTime?>(
            valueListenable: DataSync.instance.lastScheduleSync,
            builder: (context, lastSchedule, _) {
              return ValueListenableBuilder<DateTime?>(
                valueListenable: DataSync.instance.lastRemindersSync,
                builder: (context, lastReminders, __) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SyncRow(
                        icon: Icons.schedule_rounded,
                        label: 'Schedules',
                        value: formatSync(lastSchedule),
                      ),
                      SizedBox(height: spacing.sm),
                      _SyncRow(
                        icon: Icons.notifications_active_outlined,
                        label: 'Reminders',
                        value: formatSync(lastReminders),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          SizedBox(height: spacing.md),
          ValueListenableBuilder<int>(
            valueListenable: OfflineQueue.instance.pendingCount,
            builder: (context, pending, _) {
              return Row(
                children: [
                  Container(
                    padding: AppTokens.spacing.edgeInsetsSymmetric(horizontal: AppTokens.spacing.md, vertical: AppTokens.spacing.sm),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: AppTokens.radius.pill,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          pending > 0 ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                          size: AppTokens.iconSize.sm,
                          color: pending > 0 ? colors.secondary : colors.primary,
                        ),
                        SizedBox(width: spacing.sm),
                        Text(
                          pending > 0
                              ? '$pending change${pending == 1 ? '' : 's'} queued'
                              : 'No queued changes',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (pending >= 100) ...[
                          SizedBox(width: spacing.sm),
                          Container(
                            padding: AppTokens.spacing.edgeInsetsSymmetric(horizontal: spacing.sm, vertical: spacing.xs),
                            decoration: BoxDecoration(
                              color: colors.error.withValues(alpha: 0.12),
                              borderRadius: AppTokens.radius.pill,
                            ),
                            child: Text(
                              'Queue full',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  Flexible(
                    child: SecondaryButton(
                      label: 'Process queue',
                      onPressed: () => OfflineQueue.instance.processQueue(),
                      minHeight: 40,
                      expanded: true,
                  ),
                ),
                SizedBox(width: AppTokens.spacing.sm),
                SecondaryButton(
                  label: 'Clear',
                  onPressed: pending > 0 ? () => OfflineQueue.instance.clear() : null,
                  minHeight: 40,
                  expanded: false,
                ),
              ],
            );
          },
        ),
          SizedBox(height: spacing.md),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Sync now',
                  onPressed: () {
                    DataSync.instance.requestFullRefresh();
                    _controller.onSnack?.call('Sync requested.');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SyncRow extends StatelessWidget {
  const _SyncRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;

    final accent = colors.primary;

    return Padding(
      padding: spacing.edgeInsetsSymmetric(vertical: spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: AppTokens.radius.md,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: accent, size: AppTokens.iconSize.lg),
          ),
          SizedBox(width: spacing.md),
          Text(
            label,
            style: AppTokens.typography.subtitle.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.selected,
    required this.onTap,
    required this.label,
    required this.icon,
    required this.color,
    required this.onColor,
    this.borderColor,
    this.showBorder = false,
    this.isOutline = false,
  });

  final bool selected;
  final VoidCallback onTap;
  final String label;
  final IconData icon;
  final Color color;
  final Color onColor;
  final Color? borderColor;
  final bool showBorder;
  final bool isOutline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: isOutline ? Colors.transparent : color,
              borderRadius: AppTokens.radius.lg,
              border: Border.all(
                color: selected
                    ? colors.primary
                    : (isOutline
                        ? colors.outline.withValues(alpha: 0.3)
                        : (showBorder
                            ? colors.outline.withValues(alpha: 0.1)
                            : (borderColor ?? Colors.transparent))),
                width: selected ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    color: isOutline ? colors.onSurface : onColor,
                    size: AppTokens.iconSize.lg,
                  ),
                ),
                if (selected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: EdgeInsets.all(spacing.xs / 2),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isOutline ? colors.surface : color,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.check,
                        size: AppTokens.iconSize.xs - 4,
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? colors.primary : colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
