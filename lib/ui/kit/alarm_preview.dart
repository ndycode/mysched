import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Visual mock of the native fullscreen alarm so design tweaks stay in sync.
class AlarmPreviewMock extends StatelessWidget {
  const AlarmPreviewMock({super.key, this.expanded = false});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final sizes = AppTokens.componentSize;
    final maxWidth = expanded ? sizes.alarmPreviewMaxWidth : sizes.alarmPreviewMinWidth;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: expanded ? sizes.alarmPreviewMaxHeight : sizes.alarmPreviewMinHeight,
        maxWidth: maxWidth,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.xl,
          vertical: spacing.xlHalf,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppAlarmColors.bgTop, AppAlarmColors.bgBottom],
          ),
          borderRadius: AppTokens.radius.xxxl,
          boxShadow: [
            BoxShadow(
              color: AppSemanticColor.black.withValues(alpha: AppOpacity.barrier),
              blurRadius: AppTokens.shadow.hero,
              spreadRadius: AppTokens.shadow.spreadLg,
              offset: AppShadowOffset.alarm,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.05),
                    radius: 1.1,
                    colors: [AppAlarmColors.glow, Colors.transparent],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  accent: AppAlarmColors.accent,
                  textSecondary: AppAlarmColors.textSecondary,
                  textMuted: AppAlarmColors.textMuted,
                ),
                SizedBox(height: spacing.xlHalf),
                _ClockBlock(
                  expanded: expanded,
                  textPrimary: AppSemanticColor.white,
                  textSecondary: AppAlarmColors.textSecondary,
                  accent: AppAlarmColors.accent,
                ),
                SizedBox(height: spacing.lg),
                _ContextCard(
                  textPrimary: AppSemanticColor.white,
                  textSecondary: AppAlarmColors.textSecondary,
                ),
                const Spacer(),
                _Actions(
                  accent: AppAlarmColors.accent,
                  accentDim: AppAlarmColors.accentDim,
                  stopAccent: AppAlarmColors.stopAccent,
                  textPrimary: AppSemanticColor.white,
                  textSecondary: AppAlarmColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.accent,
    required this.textSecondary,
    required this.textMuted,
  });

  final Color accent;
  final Color textSecondary;
  final Color textMuted;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    return Row(
      children: [
        Container(
          padding: spacing.edgeInsetsSymmetric(horizontal: spacing.mdLg, vertical: spacing.smMd),
          decoration: BoxDecoration(
            borderRadius: AppTokens.radius.pill,
            border: Border.all(color: AppSemanticColor.white.withValues(alpha: AppOpacity.overlay)),
            gradient: LinearGradient(
              colors: [
                AppSemanticColor.white.withValues(alpha: AppOpacity.faint),
                AppSemanticColor.white.withValues(alpha: AppOpacity.faint),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: AppOpacity.border),
                blurRadius: AppTokens.shadow.glow,
                spreadRadius: AppTokens.shadow.spreadMd,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.alarm_rounded, size: AppTokens.iconSize.sm, color: accent),
              SizedBox(width: spacing.sm),
              Text(
                'Class reminder',
                style: AppTokens.typography.body.copyWith(
                  color: textSecondary,
                  fontWeight: AppTokens.fontWeight.bold,
                  letterSpacing: AppLetterSpacing.wide,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Ringing',
              style: AppTokens.typography.body.copyWith(
                color: accent,
                fontWeight: AppTokens.fontWeight.bold,
                letterSpacing: AppLetterSpacing.widest,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              '07:15 AM',
              style: AppTokens.typography.caption.copyWith(
                color: textMuted,
                fontWeight: AppTokens.fontWeight.semiBold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ClockBlock extends StatelessWidget {
  const _ClockBlock({
    required this.expanded,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
  });

  final bool expanded;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final displayBase = AppTokens.typography.display;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.md),
      decoration: BoxDecoration(
        borderRadius: AppTokens.radius.lg,
        border: Border.all(color: AppSemanticColor.white.withValues(alpha: AppOpacity.faint)),
        color: AppSemanticColor.white.withValues(alpha: AppOpacity.faint),
      ),
      child: Column(
        children: [
          Text(
            '3:04',
            style: displayBase.copyWith(
              color: textPrimary,
              fontWeight: AppTokens.fontWeight.extraBold,
              fontSize: (displayBase.fontSize ?? 32) * (expanded ? 3.25 : 3.06),
              height: AppLineHeight.single,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Alarm stops in 08:00',
            style: AppTokens.typography.body.copyWith(
              color: accent,
              fontWeight: AppTokens.fontWeight.bold,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Tue, Apr 23',
            style: AppTokens.typography.caption.copyWith(
              color: textSecondary,
              fontWeight: AppTokens.fontWeight.semiBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        borderRadius: AppTokens.radius.xl,
        border: Border.all(color: AppSemanticColor.white.withValues(alpha: AppOpacity.faint)),
        color: AppSemanticColor.white.withValues(alpha: AppOpacity.faint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event, size: AppTokens.iconSize.sm, color: textSecondary),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  'Next: Math class at 3:30 PM',
                  style: AppTokens.typography.body.copyWith(
                    color: textPrimary,
                    fontWeight: AppTokens.fontWeight.bold,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: AppTokens.iconSize.md, color: textSecondary),
            ],
          ),
          SizedBox(height: spacing.md),
          Row(
            children: [
              _StatusPill(
                icon: Icons.volume_up_rounded,
                label: 'Sound on',
                textSecondary: textSecondary,
              ),
              SizedBox(width: AppTokens.spacing.md),
              _StatusPill(
                icon: Icons.vibration_rounded,
                label: 'Vibrate',
                textSecondary: textSecondary,
              ),
              SizedBox(width: AppTokens.spacing.md),
              _StatusPill(
                icon: Icons.snooze_rounded,
                label: 'Snooze 5 min',
                textSecondary: textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.textSecondary,
  });

  final IconData icon;
  final String label;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: AppTokens.componentSize.alarmPillHeight,
        padding: AppTokens.spacing.edgeInsetsSymmetric(horizontal: AppTokens.spacing.smMd),
        decoration: BoxDecoration(
          color: AppSemanticColor.white.withValues(alpha: AppOpacity.faint),
          borderRadius: AppTokens.radius.lg,
          border: Border.all(color: AppSemanticColor.white.withValues(alpha: AppOpacity.faint)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppTokens.iconSize.sm, color: textSecondary),
            SizedBox(width: AppTokens.spacing.xs),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTokens.typography.caption.copyWith(
                  color: textSecondary,
                  fontWeight: AppTokens.fontWeight.semiBold,
                  letterSpacing: AppLetterSpacing.relaxed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.accent,
    required this.accentDim,
    required this.stopAccent,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color accent;
  final Color accentDim;
  final Color stopAccent;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ActionButton(
          label: 'Stop',
          icon: Icons.pause_circle_filled_rounded,
          fillColor: stopAccent,
          textColor: textPrimary,
        ),
        SizedBox(height: spacing.sm),
        _ActionButton(
          label: 'Snooze 5 min',
          icon: Icons.snooze_rounded,
          fillColor: accent.withValues(alpha: AppOpacity.border),
          textColor: textPrimary,
          borderColor: accentDim.withValues(alpha: AppOpacity.subtle),
          secondaryLabel: '3 of 5 left',
        ),
        SizedBox(height: spacing.sm),
        _ActionButton(
          label: 'View reminders',
          icon: Icons.event_note_rounded,
          fillColor: AppSemanticColor.white.withValues(alpha: AppOpacity.faint),
          textColor: textSecondary,
          borderColor: AppSemanticColor.white.withValues(alpha: AppOpacity.faint),
          trailing: Icon(Icons.chevron_right_rounded,
              color: textSecondary, size: AppTokens.iconSize.md),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.fillColor,
    required this.textColor,
    this.borderColor,
    this.secondaryLabel,
    this.trailing,
  });

  final String label;
  final IconData icon;
  final Color fillColor;
  final Color textColor;
  final Color? borderColor;
  final String? secondaryLabel;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    return Container(
      height: AppTokens.componentSize.alarmActionHeight,
      padding: EdgeInsets.symmetric(horizontal: spacing.lg),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: AppTokens.radius.xxl,
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: AppTokens.componentSize.dividerMedium,
        ),
        boxShadow: [
          BoxShadow(
            color: AppSemanticColor.black.withValues(alpha: AppOpacity.border),
            blurRadius: AppTokens.shadow.action,
            offset: AppShadowOffset.modal,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: AppTokens.iconSize.lg),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTokens.typography.subtitle.copyWith(
                    color: textColor,
                    fontWeight: AppTokens.fontWeight.extraBold,
                  ),
                ),
                if (secondaryLabel != null) ...[
                  SizedBox(height: AppTokens.spacing.xs),
                  Text(
                    secondaryLabel!,
                    style: AppTokens.typography.caption.copyWith(
                      color: textColor.withValues(alpha: AppOpacity.muted),
                      fontWeight: AppTokens.fontWeight.semiBold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
