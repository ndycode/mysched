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
  bool _adminSnackShown = false;
  List<AlarmSound> _deviceRingtones = [];
  bool _ringtonesLoading = true;

  final List<int> _leadOptions = const [5, 10, 15, 20, 30, 45, 60];
  final List<int> _snoozeOptions = const [5, 10, 15, 20];


  @override
  void initState() {
    super.initState();
    _controller = SettingsController();
    _bindControllerEvents();
    ConnectionMonitor.instance.startMonitoring();
    OfflineQueue.instance.init();
    _loadDeviceRingtones();
  }

  Future<void> _loadDeviceRingtones() async {
    final sounds = await LocalNotifs.getAlarmSounds();
    if (!mounted) return;
    setState(() {
      // Add default option at the start
      _deviceRingtones = [
        const AlarmSound(title: 'Default System Alarm', uri: 'default'),
        ...sounds,
      ];
      _ringtonesLoading = false;
    });
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

  Future<void> _pickReminderLeadMinutes() async {
    final value = await _pickOption(
      title: 'Reminder lead time',
      options: const [0, 5, 10, 15, 30, 60],
      selected: _controller.reminderLeadMinutes,
      suffix: 'minutes before',
    );
    if (value == null) return;
    _controller.setReminderLeadMinutes(value);
  }

  String _getRingtoneLabel(String uri) {
    if (_deviceRingtones.isEmpty) return 'Default';
    final found = _deviceRingtones.firstWhere(
      (e) => e.uri == uri,
      orElse: () => const AlarmSound(title: 'Default', uri: 'default'),
    );
    return found.title;
  }

  Future<void> _pickRingtone() async {
    if (_ringtonesLoading || _deviceRingtones.isEmpty) {
      showAppSnackBar(context, 'Loading ringtones...');
      return;
    }
    
    final currentUri = _controller.alarmRingtone;
    final selected = await showSmoothDialog<AlarmSound>(
      context: context,
      builder: (context) => _RingtonePicker(
        ringtones: _deviceRingtones,
        selectedUri: currentUri,
        onPreview: (uri) => LocalNotifs.playRingtonePreview(uri),
      ),
    );
    
    if (selected != null) {
      _controller.setAlarmRingtone(selected.uri);
    }
  }

  Future<int?> _pickOption({
    required String title,
    required List<int> options,
    required int selected,
    required String suffix,
  }) {
    return showSmoothDialog<int>(
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
                    ? theme.colorScheme.outline.withValues(alpha: AppOpacity.overlay)
                    : theme.colorScheme.outline,
                width: theme.brightness == Brightness.dark ? AppTokens.componentSize.divider : AppTokens.componentSize.dividerThin,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: AppOpacity.statusBg),
                  blurRadius: AppTokens.shadow.xxl,
                  offset: AppShadowOffset.modal,
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
                      style: AppTokens.typography.headline.copyWith(
                        fontWeight: AppTokens.fontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: options.map((value) {
                          final displayLabel = '$value $suffix';
                          final isSelected = value == selected;

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
                                      style: AppTokens.typography.body.copyWith(
                                        fontWeight: isSelected ? AppTokens.fontWeight.semiBold : AppTokens.fontWeight.regular,
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
                          minHeight: AppTokens.componentSize.buttonMd,
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
                  height: AppTokens.componentSize.avatarXl,
                  width: AppTokens.componentSize.avatarXl,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primary.withValues(alpha: AppOpacity.statusBg),
                        colors.primary.withValues(alpha: AppOpacity.overlay),
                      ],
                    ),
                    borderRadius: AppTokens.radius.md,
                    border: Border.all(
                      color: colors.primary.withValues(alpha: AppOpacity.ghost),
                      width: AppTokens.componentSize.dividerThick,
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
                          fontWeight: AppTokens.fontWeight.bold,
                          letterSpacing: AppLetterSpacing.tight,
                          color: colors.onSurface,
                        ),
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        'Control alarms, notifications, and app styling.',
                        style: AppTokens.typography.body.copyWith(
                          height: AppLineHeight.body,
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
                  color: isDark ? colors.outline.withValues(alpha: AppOpacity.overlay) : colors.outline,
                  width: isDark ? AppTokens.componentSize.divider : AppTokens.componentSize.dividerThin,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: AppOpacity.faint),
                          blurRadius: AppTokens.shadow.lg,
                          offset: AppShadowOffset.sm,
                        ),
                      ],
              ),
              child: _buildNotificationCard(theme),
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
                  color: isDark ? colors.outline.withValues(alpha: AppOpacity.overlay) : colors.outline,
                  width: isDark ? AppTokens.componentSize.divider : AppTokens.componentSize.dividerThin,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: AppOpacity.faint),
                          blurRadius: AppTokens.shadow.lg,
                          offset: AppShadowOffset.sm,
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
                    color: isDark ? colors.outline.withValues(alpha: AppOpacity.overlay) : colors.outline,
                    width: isDark ? AppTokens.componentSize.divider : AppTokens.componentSize.dividerThin,
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: AppOpacity.faint),
                            blurRadius: AppTokens.shadow.md,
                            offset: AppShadowOffset.sm,
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
                    color: isDark ? colors.outline.withValues(alpha: AppOpacity.overlay) : colors.outline,
                    width: isDark ? AppTokens.componentSize.divider : AppTokens.componentSize.dividerThin,
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: AppOpacity.faint),
                            blurRadius: AppTokens.shadow.md,
                            offset: AppShadowOffset.sm,
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
                  color: isDark ? colors.outline.withValues(alpha: AppOpacity.overlay) : colors.outline,
                  width: isDark ? AppTokens.componentSize.divider : AppTokens.componentSize.dividerThin,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: AppOpacity.faint),
                          blurRadius: AppTokens.shadow.lg,
                          offset: AppShadowOffset.sm,
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
                  color: isDark ? colors.outline.withValues(alpha: AppOpacity.overlay) : colors.outline,
                  width: isDark ? AppTokens.componentSize.divider : AppTokens.componentSize.dividerThin,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: AppOpacity.faint),
                          blurRadius: AppTokens.shadow.lg,
                          offset: AppShadowOffset.sm,
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
            bottom: spacing.quad + AppLayout.bottomNavSafePadding,
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
          ToggleRow(
            icon: Icons.alarm_rounded,
            title: 'Class reminders',
            description: 'Alarm-style alerts before classes begin.',
            value: _controller.classAlarms,
            onChanged: _controller.toggleClassAlarms,
          ),
          SizedBox(height: spacing.lg),
          ToggleRow(
            icon: Icons.notifications_active_outlined,
            title: 'App notifications',
            description: 'Allow MySched to send notifications.',
            value: _controller.appNotifs,
            onChanged: _controller.toggleAppNotifs,
          ),
          SizedBox(height: spacing.lg),
          ToggleRow(
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
              color: colors.primary.withValues(alpha: AppOpacity.overlay),
                borderRadius: AppTokens.radius.md,
              ),
              padding: spacing.edgeInsetsAll(spacing.md),
              child: Text(
                'Quiet week is on. Alarm reminders are paused until you turn it off.',
                style: AppTokens.typography.caption.copyWith(
                  color: colors.primary,
                  fontWeight: AppTokens.fontWeight.semiBold,
                ),
              ),
            ),
          ],
          SizedBox(height: spacing.xl),
          // Do Not Disturb toggle
          ToggleRow(
            icon: Icons.do_not_disturb_on_rounded,
            title: 'Do Not Disturb',
            description: 'Delay alarms during quiet hours.',
            value: _controller.dndEnabled,
            onChanged: _controller.toggleDndEnabled,
          ),
          if (_controller.dndEnabled) ...[
            SizedBox(height: spacing.md),
            Row(
              children: [
                SizedBox(width: spacing.xl + AppTokens.iconSize.lg),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _DndTimePicker(
                          label: 'Start',
                          value: _controller.dndStartTime,
                          onChanged: _controller.setDndStartTime,
                          theme: theme,
                        ),
                      ),
                      SizedBox(width: spacing.md),
                      Expanded(
                        child: _DndTimePicker(
                          label: 'End',
                          value: _controller.dndEndTime,
                          onChanged: _controller.setDndEndTime,
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: spacing.xl),
          // Reminder lead time
          GestureDetector(
            onTap: _pickReminderLeadMinutes,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: spacing.edgeInsetsSymmetric(vertical: spacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: AppTokens.iconSize.md,
                    color: colors.primary,
                  ),
                  SizedBox(width: spacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reminder lead time',
                          style: AppTokens.typography.subtitle.copyWith(
                            color: colors.onSurface,
                            fontWeight: AppTokens.fontWeight.semiBold,
                          ),
                        ),
                        SizedBox(height: spacing.xs),
                        Text(
                          _controller.reminderLeadMinutes == 0
                              ? 'Alert at due time'
                              : '${_controller.reminderLeadMinutes} min before',
                          style: AppTokens.typography.bodySecondary.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          // ────────────────────────────────────────────────────────────────
          // Schedule Preferences Section
          // ────────────────────────────────────────────────────────────────
          SizedBox(height: spacing.xl),
          Divider(color: colors.outlineVariant),
          SizedBox(height: spacing.lg),
          Text(
            'Timing',
            style: AppTokens.typography.label.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: AppTokens.fontWeight.semiBold,
            ),
          ),
          SizedBox(height: spacing.lg),
          NavigationRow(
            icon: Icons.snooze_outlined,
            title: 'Heads-up before class',
            description: '${_controller.leadMinutes} minutes before class',
            onTap: _pickLeadMinutes,
          ),
          SizedBox(height: spacing.lg),
          NavigationRow(
            icon: Icons.schedule_rounded,
            title: 'Snooze length',
            description: '${_controller.snoozeMinutes} minutes',
            onTap: _pickSnoozeMinutes,
          ),
          // ────────────────────────────────────────────────────────────────
          // Alarm Settings Section
          // ────────────────────────────────────────────────────────────────
          SizedBox(height: spacing.xl),
          Divider(color: colors.outlineVariant),
          SizedBox(height: spacing.lg),
          Text(
            'Alarm',
            style: AppTokens.typography.label.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: AppTokens.fontWeight.semiBold,
            ),
          ),
          SizedBox(height: spacing.lg),
          // Volume slider
          Row(
            children: [
              Icon(
                Icons.volume_up_rounded,
                size: AppTokens.iconSize.md,
                color: colors.primary,
              ),
              SizedBox(width: spacing.lg),
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
                            fontWeight: AppTokens.fontWeight.semiBold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_controller.alarmVolume}%',
                          style: AppTokens.typography.body.copyWith(
                            color: colors.primary,
                            fontWeight: AppTokens.fontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.xs),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: AppSlider.trackHeight,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: AppSlider.thumbRadius),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: AppSlider.overlayRadius),
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
          ToggleRow(
            icon: Icons.vibration_rounded,
            title: 'Use vibration',
            description: 'Vibrate when alarm rings.',
            value: _controller.alarmVibration,
            onChanged: _controller.toggleAlarmVibration,
          ),
          SizedBox(height: spacing.lg),
          // Ringtone selection
          NavigationRow(
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
                  color: AppSemanticColor.white,
                  onColor: AppSemanticColor.black,
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
                  color: AppTokens.darkColors.surface,
                  onColor: AppSemanticColor.white,
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: _ThemeOption(
                  selected: _controller.themeMode == AppThemeMode.voidMode,
                  onTap: () => _controller.setMode(AppThemeMode.voidMode),
                  label: 'Void',
                  icon: Icons.brightness_2_rounded,
                  color: AppTokens.voidColors.background,
                  onColor: AppSemanticColor.white,
                  borderColor: AppTokens.darkColors.outline,
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
            style: AppTokens.typography.caption.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.xl),
          // Time format toggle
          ToggleRow(
            icon: Icons.schedule_rounded,
            title: 'Use 24-hour format',
            description: _controller.use24HourFormat ? '08:00 - 17:30' : '8:00 AM - 5:30 PM',
            value: _controller.use24HourFormat,
            onChanged: _controller.toggle24HourFormat,
          ),
          SizedBox(height: spacing.lg),
          // Haptic feedback toggle
          ToggleRow(
            icon: Icons.vibration_rounded,
            title: 'Haptic feedback',
            description: 'Vibrate on button taps',
            value: _controller.hapticFeedback,
            onChanged: _controller.toggleHapticFeedback,
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
          NavigationRow(
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
          NavigationRow(
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
          NavigationRow(
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
                      width: AppTokens.componentSize.badgeMd,
                      height: AppTokens.componentSize.badgeMd,
                      child: CircularProgressIndicator(
                        strokeWidth: AppTokens.spacing.micro,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                      ),
                    )
                  : const Icon(Icons.refresh_rounded),
              label: _controller.readinessLoading ? 'Checking…' : 'Refresh status',
              onPressed: _controller.readinessLoading
                  ? null
                  : _controller.refreshAlarmReadiness,
              expanded: false,
              minHeight: AppTokens.componentSize.buttonSm,
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
          NavigationRow(
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
          NavigationRow(
            icon: Icons.notification_important_outlined,
            title: 'Send test heads-up',
            description: 'Preview the quick heads-up alert.',
            accentColor: colors.primary,
            trailing: Icon(Icons.play_arrow_rounded, color: colors.primary),
            onTap: _controller.sendTestNotification,
          ),
          SizedBox(height: spacing.lg),
          ToggleRow(
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
          NavigationRow(
            icon: Icons.refresh_rounded,
            title: 'Resync class reminders',
            description: 'Regenerate alarms after schedule changes.',
            onTap: _controller.resyncReminders,
          ),
          SizedBox(height: spacing.lg),
          NavigationRow(
            icon: Icons.info_outline_rounded,
            title: 'About',
            onTap: _openAbout,
          ),
          SizedBox(height: spacing.lg),
          NavigationRow(
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
            ? colors.primary.withValues(alpha: AppOpacity.statusBg)
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
        style: AppTokens.typography.caption.copyWith(
          color: fg,
          fontWeight: AppTokens.fontWeight.bold,
        ),
      ),
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
                          style: AppTokens.typography.caption.copyWith(
                            color: colors.onSurface,
                            fontWeight: AppTokens.fontWeight.semiBold,
                          ),
                        ),
                        if (pending >= 100) ...[
                          SizedBox(width: spacing.sm),
                          Container(
                            padding: AppTokens.spacing.edgeInsetsSymmetric(horizontal: spacing.sm, vertical: spacing.xs),
                            decoration: BoxDecoration(
                              color: colors.error.withValues(alpha: AppOpacity.overlay),
                              borderRadius: AppTokens.radius.pill,
                            ),
                            child: Text(
                              'Queue full',
                              style: AppTokens.typography.caption.copyWith(
                                color: colors.error,
                                fontWeight: AppTokens.fontWeight.bold,
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
                      minHeight: AppTokens.componentSize.buttonMd,
                      expanded: true,
                  ),
                ),
                SizedBox(width: AppTokens.spacing.sm),
                SecondaryButton(
                  label: 'Clear',
                  onPressed: pending > 0 ? () => OfflineQueue.instance.clear() : null,
                  minHeight: AppTokens.componentSize.buttonMd,
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
            height: AppTokens.componentSize.avatarLg,
            width: AppTokens.componentSize.avatarLg,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: AppOpacity.medium),
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
              fontWeight: AppTokens.fontWeight.semiBold,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTokens.typography.bodySecondary.copyWith(
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
            height: AppTokens.componentSize.avatarXxl,
            decoration: BoxDecoration(
              color: isOutline ? Colors.transparent : color,
              borderRadius: AppTokens.radius.lg,
              border: Border.all(
                color: selected
                    ? colors.primary
                    : (isOutline
                        ? colors.outline.withValues(alpha: AppOpacity.ghost)
                        : (showBorder
                            ? colors.outline.withValues(alpha: AppOpacity.dim)
                            : (borderColor ?? Colors.transparent))),
                width: selected ? AppTokens.spacing.micro : AppTokens.componentSize.divider,
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
                    top: AppTokens.spacing.xs,
                    right: AppTokens.spacing.xs,
                    child: Container(
                      padding: EdgeInsets.all(spacing.micro),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isOutline ? colors.surface : color,
                          width: AppTokens.componentSize.dividerThick,
                        ),
                      ),
                      child: Icon(
                        Icons.check,
                        size: AppTokens.iconSize.check,
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
            style: AppTokens.typography.caption.copyWith(
              fontWeight: selected ? AppTokens.fontWeight.bold : AppTokens.fontWeight.medium,
              color: selected ? colors.primary : colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingtonePicker extends StatefulWidget {
  const _RingtonePicker({
    required this.ringtones,
    required this.selectedUri,
    required this.onPreview,
  });

  final List<AlarmSound> ringtones;
  final String selectedUri;
  final void Function(String uri) onPreview;

  @override
  State<_RingtonePicker> createState() => _RingtonePickerState();
}

class _RingtonePickerState extends State<_RingtonePicker> {
  String? _playingUri;

  @override
  void dispose() {
    // Stop any playing preview when dialog closes
    LocalNotifs.stopRingtonePreview();
    super.dispose();
  }

  void _preview(String uri) {
    setState(() => _playingUri = uri);
    widget.onPreview(uri);
    // Clear playing state after ~2.5 seconds (sound plays for ~2 seconds)
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && _playingUri == uri) {
        setState(() => _playingUri = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: spacing.edgeInsetsAll(spacing.lg),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: isDark ? colors.surfaceContainerHigh : colors.surface,
          borderRadius: AppTokens.radius.xxl,
          border: Border.all(
            color: isDark
                ? colors.outline.withValues(alpha: AppOpacity.overlay)
                : colors.outline,
            width: isDark
                ? AppTokens.componentSize.divider
                : AppTokens.componentSize.dividerThin,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: AppOpacity.statusBg),
              blurRadius: AppTokens.shadow.xxl,
              offset: AppShadowOffset.modal,
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
                child: Row(
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      color: colors.primary,
                      size: AppTokens.iconSize.lg,
                    ),
                    SizedBox(width: spacing.md),
                    Text(
                      'Select Ringtone',
                      style: AppTokens.typography.headline.copyWith(
                        fontWeight: AppTokens.fontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.ringtones.length,
                  itemBuilder: (context, index) {
                    final ringtone = widget.ringtones[index];
                    final isSelected = ringtone.uri == widget.selectedUri;
                    final isPlaying = ringtone.uri == _playingUri;

                    return InkWell(
                      onTap: () => Navigator.of(context).pop(ringtone),
                      child: Container(
                        color: isPlaying
                            ? colors.primary.withValues(alpha: AppOpacity.overlay)
                            : null,
                        padding: spacing.edgeInsetsSymmetric(
                          horizontal: spacing.xl,
                          vertical: spacing.md,
                        ),
                        child: Row(
                          children: [
                            // Preview button
                            GestureDetector(
                              onTap: () => _preview(ringtone.uri),
                              child: Container(
                                width: AppTokens.componentSize.avatarMd,
                                height: AppTokens.componentSize.avatarMd,
                                decoration: BoxDecoration(
                                  color: isPlaying
                                      ? colors.primary
                                      : colors.primary.withValues(alpha: AppOpacity.overlay),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPlaying
                                      ? Icons.volume_up_rounded
                                      : Icons.play_arrow_rounded,
                                  size: AppTokens.iconSize.sm,
                                  color: isPlaying
                                      ? colors.onPrimary
                                      : colors.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: spacing.md),
                            Expanded(
                              child: Text(
                                ringtone.title,
                                style: AppTokens.typography.body.copyWith(
                                  fontWeight: isSelected || isPlaying
                                      ? AppTokens.fontWeight.semiBold
                                      : AppTokens.fontWeight.regular,
                                  color: isSelected
                                      ? colors.primary
                                      : colors.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isPlaying)
                              Text(
                                'Playing...',
                                style: AppTokens.typography.caption.copyWith(
                                  color: colors.primary,
                                  fontWeight: AppTokens.fontWeight.medium,
                                ),
                              )
                            else if (isSelected)
                              Icon(
                                Icons.check_rounded,
                                color: colors.primary,
                                size: AppTokens.iconSize.md,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
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
                      minHeight: AppTokens.componentSize.buttonMd,
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
  }
}

/// Time picker for DND start/end times.
class _DndTimePicker extends StatelessWidget {
  const _DndTimePicker({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.theme,
  });

  final String label;
  final String value; // "HH:mm" format
  final ValueChanged<String> onChanged;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final colors = theme.colorScheme;
    
    // Parse value
    final parts = value.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final timeOfDay = TimeOfDay(hour: hour, minute: minute);
    
    // Format for display
    final displayTime = timeOfDay.format(context);

    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: timeOfDay,
          helpText: '$label time',
          builder: (context, child) {
            return Theme(
              data: theme.copyWith(
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: colors.surface,
                  hourMinuteShape: RoundedRectangleBorder(
                    borderRadius: AppTokens.radius.md,
                  ),
                  dayPeriodShape: RoundedRectangleBorder(
                    borderRadius: AppTokens.radius.sm,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          onChanged(formatted);
        }
      },
      borderRadius: AppTokens.radius.sm,
      child: Container(
        padding: spacing.edgeInsetsSymmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: AppTokens.radius.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTokens.typography.caption.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            Text(
              displayTime,
              style: AppTokens.typography.subtitle.copyWith(
                color: colors.onSurface,
                fontWeight: AppTokens.fontWeight.semiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
