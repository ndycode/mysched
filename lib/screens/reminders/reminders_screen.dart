import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/reminder_scope.dart';
import '../../services/reminder_scope_store.dart';
import '../../services/reminders_api.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';
import '../../utils/nav.dart';
import '../../app/routes.dart';
import '../add_reminder_page.dart';
import 'reminders_controller.dart';
import 'reminders_data.dart';
import 'reminders_cards.dart';
import 'reminders_messages.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({
    super.key,
    RemindersApi? api,
    this.initialScope,
  }) : _apiOverride = api;

  final RemindersApi? _apiOverride;
  final ReminderScope? initialScope;

  @override
  RemindersPageState createState() => RemindersPageState();
}

class RemindersPageState extends State<RemindersPage> with RouteAware {
  late final RemindersController _controller;
  PageRoute<dynamic>? _routeSubscription;

  final DateFormat _timeFormat = DateFormat('h:mm a');
  final DateFormat _dateLine = DateFormat('EEEE, MMM d');

  @override
  void initState() {
    super.initState();
    _controller = RemindersController(
      api: widget._apiOverride,
      initialScope: widget.initialScope,
    );
    _dismissKeyboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_routeSubscription != null) {
      routeObserver.unsubscribe(this);
      _routeSubscription = null;
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute && route != _routeSubscription) {
      if (_routeSubscription != null) {
        routeObserver.unsubscribe(this);
      }
      _routeSubscription = route;
      routeObserver.subscribe(this, route);
    }
  }

  void _dismissKeyboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  Future<void> refreshOnTabVisit() {
    return _controller.refreshOnRouteFocus();
  }

  @override
  void didPopNext() {
    // ignore: discarded_futures
    _controller.refreshOnRouteFocus();
  }

  Future<void> _openAddPage([ReminderEntry? editing]) async {
    final media = MediaQuery.of(context);
    final spacing = AppTokens.spacing;
    final changed = await showOverlaySheet<bool>(
      context: context,
      alignment: Alignment.center,
      padding: spacing.edgeInsetsOnly(
        left: spacing.xl,
        right: spacing.xl,
        top: media.padding.top + spacing.xxl,
        bottom: media.padding.bottom + spacing.xxl,
      ),
      builder: (_) => AddReminderSheet(
        api: widget._apiOverride ?? RemindersApi(),
        editing: editing,
      ),
    );
    if (changed == true) {
      _controller.notifyDirty();
      await _controller.load(silent: false);
    }
  }

  Future<void> _openAccount() async {
    await context.push(AppRoutes.account);
    if (!mounted) return;
    await _controller.loadProfile(refresh: true);
  }



  Future<void> _deleteReminder(ReminderEntry entry) async {
    final ok = await AppModal.showConfirmDialog(
      context: context,
      title: 'Delete reminder?',
      message: 'This reminder will be removed and any scheduled notifications will be cancelled.',
      confirmLabel: 'Delete',
      isDanger: true,
    );
    if (ok != true) return;
    
    await _controller.deleteReminder(
      entry,
      onMessage: (msg) => _toast(msg, isError: msg.contains('wrong')),
    );
  }

  Future<void> _snoozeReminder(ReminderEntry entry) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final duration = await showModalBottomSheet<Duration>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ReminderSnoozeSheet(
        entry: entry,
        formatDue: _formatDue,
      ),
    );
    if (duration == null) return;

    await _controller.snoozeReminder(
      entry,
      duration,
      onMessage: (msg) => _toast(msg, isError: msg.contains('wrong')),
      formatDue: _formatDue,
    );
  }

  String _formatDue(DateTime due) {
    final local = due.toLocal();
    return '${_dateLine.format(local)} at ${_timeFormat.format(local)}';
  }

  void _toast(String message, {bool isError = false}) {
    if (!mounted) return;
    showAppSnackBar(
      context,
      message,
      type: isError ? AppSnackBarType.error : AppSnackBarType.success,
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final spacing = AppTokens.spacing;

    return PopupMenuButton<_ReminderSummaryMenu>(
      onSelected: (action) {
        switch (action) {
          case _ReminderSummaryMenu.newReminder:
            _openAddPage();
            break;
          case _ReminderSummaryMenu.toggleCompleted:
            _controller.showCompleted = !_controller.showCompleted;
            break;
          case _ReminderSummaryMenu.resetReminders:
            _controller.resetReminders().then((_) {
              _toast('Reminders reset');
              _controller.refresh();
            });
            break;
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: AppTokens.radius.lg,
      ),
      elevation: isDark ? AppTokens.shadow.elevationDark : AppTokens.shadow.elevationLight,
      color: isDark ? colors.surfaceContainerHigh : colors.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: colors.shadow.withValues(alpha: isDark ? AppOpacity.divider : AppOpacity.medium),
      padding: EdgeInsets.zero,
      icon: SizedBox(
        width: AppTokens.componentSize.buttonXs,
        height: AppTokens.componentSize.buttonXs,
        child: Center(
          child: Icon(
            Icons.more_vert_rounded,
            size: AppTokens.iconSize.md,
            color: colors.onSurfaceVariant,
          ),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<_ReminderSummaryMenu>(
          value: _ReminderSummaryMenu.newReminder,
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context, _ReminderSummaryMenu.newReminder),
              splashColor: colors.primary.withValues(alpha: AppOpacity.highlight),
              highlightColor: colors.primary.withValues(alpha: AppOpacity.micro),
              child: Padding(
                padding: spacing.edgeInsetsSymmetric(
                  horizontal: spacing.lg,
                  vertical: spacing.md,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: spacing.edgeInsetsAll(spacing.sm),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: AppOpacity.overlay),
                        borderRadius: AppTokens.radius.sm,
                      ),
                      child: Icon(
                        Icons.add_alarm_rounded,
                        size: AppTokens.iconSize.md,
                        color: colors.primary,
                      ),
                    ),
                    SizedBox(width: spacing.md + spacing.micro),
                    Flexible(
                      child: Text(
                        'New reminder',
                        style: AppTokens.typography.bodySecondary.copyWith(
                          fontWeight: AppTokens.fontWeight.medium,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        PopupMenuItem<_ReminderSummaryMenu>(
          value: _ReminderSummaryMenu.toggleCompleted,
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context, _ReminderSummaryMenu.toggleCompleted),
              splashColor: colors.primary.withValues(alpha: AppOpacity.highlight),
              highlightColor: colors.primary.withValues(alpha: AppOpacity.micro),
              child: Padding(
                padding: spacing.edgeInsetsSymmetric(
                  horizontal: spacing.lg,
                  vertical: spacing.md,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: spacing.edgeInsetsAll(spacing.sm),
                      decoration: BoxDecoration(
                        color: colors.secondary.withValues(alpha: AppOpacity.overlay),
                        borderRadius: AppTokens.radius.sm,
                      ),
                      child: Icon(
                        _controller.showCompleted
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: AppTokens.iconSize.md,
                        color: colors.secondary,
                      ),
                    ),
                    SizedBox(width: spacing.md + spacing.micro),
                    Flexible(
                      child: Text(
                        _controller.showCompleted ? 'Hide completed' : 'Show completed',
                        style: AppTokens.typography.bodySecondary.copyWith(
                          fontWeight: AppTokens.fontWeight.medium,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        PopupMenuItem<_ReminderSummaryMenu>(
          enabled: false,
          height: AppTokens.componentSize.divider,
          padding: spacing.edgeInsetsSymmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          child: Container(
            height: AppTokens.componentSize.divider,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.outline.withValues(alpha: AppOpacity.transparent),
                  colors.outline.withValues(alpha: isDark ? AppOpacity.accent : AppOpacity.divider),
                  colors.outline.withValues(alpha: AppOpacity.transparent),
                ],
              ),
            ),
          ),
        ),
        PopupMenuItem<_ReminderSummaryMenu>(
          value: _ReminderSummaryMenu.resetReminders,
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context, _ReminderSummaryMenu.resetReminders),
              splashColor: colors.primary.withValues(alpha: AppOpacity.highlight),
              highlightColor: colors.primary.withValues(alpha: AppOpacity.micro),
              child: Padding(
                padding: spacing.edgeInsetsSymmetric(
                  horizontal: spacing.lg,
                  vertical: spacing.md,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: spacing.edgeInsetsAll(spacing.sm),
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: AppOpacity.overlay),
                        borderRadius: AppTokens.radius.sm,
                      ),
                      child: Icon(
                        Icons.restart_alt_rounded,
                        size: AppTokens.iconSize.md,
                        color: colors.error,
                      ),
                    ),
                    SizedBox(width: spacing.md + spacing.micro),
                    Flexible(
                      child: Text(
                        'Reset reminders',
                        style: AppTokens.typography.bodySecondary.copyWith(
                          fontWeight: AppTokens.fontWeight.medium,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final now = DateTime.now();
        final scopedEntries = _controller.entriesForScope(now);
        final summary = ReminderSummary.resolve(scopedEntries, now);
        final groups = _controller.groupedEntries(scopedEntries);
        final queuedIds = _controller.queuedIds;
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final media = MediaQuery.of(context);
        final isDark = theme.brightness == Brightness.dark;

        final spacing = AppTokens.spacing;
        final hero = ScreenBrandHeader(
          name: _controller.studentName,
          email: _controller.studentEmail,
          avatarUrl: _controller.avatarUrl,
          onAccountTap: _openAccount,
          showChevron: false,
          loading: !_controller.profileHydrated,
        );
        final shellPadding = spacing.edgeInsetsOnly(
          left: spacing.xl,
          right: spacing.xl,
          top: media.padding.top + spacing.xxxl,
          bottom: spacing.quad + AppLayout.bottomNavSafePadding,
        );

        if (_controller.loading) {
          return ScreenShell(
            screenName: 'reminders',
            hero: hero,
            sections: [
              ScreenSection(
                decorated: false,
                child: Column(
                  children: [
                    const SkeletonCard(showAvatar: false, lineCount: 2),
                    SizedBox(height: spacing.lg),
                    const SkeletonList(itemCount: 3, showHeader: true),
                  ],
                ),
              ),
            ],
            padding: shellPadding,
            onRefresh: () => _controller.refresh(),
            refreshColor: colors.primary,
            safeArea: false,
            cacheExtent: AppLayout.listCacheExtent,
          );
        }

        final menuButton = _buildMenuButton(context);

        final sections = <Widget>[];

        if (_controller.error != null) {
          sections.add(
            ScreenSection(
              decorated: false,
              child: StateDisplay(
                variant: StateVariant.error,
                title: 'Reminders not refreshed',
                message: _controller.error!,
                primaryActionLabel: 'Retry',
                onPrimaryAction: () => _controller.load(silent: false),
                compact: true,
              ),
            ),
          );
        }

        sections.add(
          ScreenSection(
            decorated: false,
            child: ReminderSummaryCard(
              summary: summary,
              now: now,
              onCreate: () => _openAddPage(),
              onToggleCompleted: () {
                _controller.showCompleted = !_controller.showCompleted;
              },
              showCompleted: _controller.showCompleted,
              menuButton: menuButton,
              scope: _controller.scope,
              onScopeChanged: (scope) {
                if (scope == _controller.scope) return;
                ReminderScopeStore.instance.update(scope);
              },
            ),
          ),
        );



        if (groups.isEmpty) {
          sections.add(
            ScreenSection(
              decorated: false,
              child: Container(
                padding: spacing.edgeInsetsSymmetric(
                  horizontal: spacing.xxl,
                  vertical: spacing.quad,
                ),
                decoration: BoxDecoration(
                  color: isDark ? colors.surfaceContainerHigh : colors.surface,
                  borderRadius: AppTokens.radius.xl,
                  border: Border.all(
                    color: isDark ? colors.outline.withValues(alpha: AppOpacity.overlay) : colors.outline.withValues(alpha: AppOpacity.divider),
                    width: isDark ? AppTokens.componentSize.divider : AppTokens.componentSize.dividerThin,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: spacing.emptyStateSize,
                      height: spacing.emptyStateSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colors.primary.withValues(alpha: AppOpacity.medium),
                            colors.primary.withValues(alpha: AppOpacity.highlight),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.primary.withValues(alpha: AppOpacity.accent),
                          width: AppTokens.componentSize.dividerThick,
                        ),
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: spacing.quad,
                        color: colors.primary,
                      ),
                    ),
                    SizedBox(height: spacing.xxlPlus),
                    Text(
                      'No reminders yet',
                      style: AppTokens.typography.headline.copyWith(
                        fontWeight: AppTokens.fontWeight.bold,
                        letterSpacing: AppLetterSpacing.tight,
                        color: colors.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing.md),
                    Text(
                      'Tap "New reminder" to create one. We\'ll keep it in sync across devices.',
                      style: AppTokens.typography.bodySecondary.copyWith(
                        height: AppLineHeight.body,
                        color: colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          sections.add(
            ScreenSection(
              decorated: false,
              child: ReminderListCard(
                groups: groups,
                timeFormat: _timeFormat,
                onToggle: (entry, isActive) => _controller.toggleCompleted(
                    entry, !isActive,
                    onMessage: (msg) =>
                        _toast(msg, isError: msg.contains('wrong'))),
                onEdit: (entry) => _openAddPage(entry),
                onDelete: _deleteReminder,
                onSnooze: _snoozeReminder,
                queuedIds: queuedIds,
              ),
            ),
          );
          sections.add(
            SizedBox(
              height: spacing.quad + media.padding.bottom + spacing.xl,
            ),
          );
        }

        if (sections.isEmpty) {
          sections.add(const SizedBox.shrink());
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            Navigator.of(context).pop(_controller.dirty);
          },
          child: ScreenShell(
            screenName: 'reminders',
            hero: hero,
            sections: sections,
            padding: shellPadding,
            onRefresh: () => _controller.refresh(),
            refreshColor: colors.primary,
            safeArea: false,
            cacheExtent: AppLayout.listCacheExtent,
            useSlivers: false,
          ),
        );
      },
    );
  }
}

enum _ReminderSummaryMenu { newReminder, toggleCompleted, resetReminders }
