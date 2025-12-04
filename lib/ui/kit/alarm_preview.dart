import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Visual mock of the native fullscreen alarm so design tweaks stay in sync.
class AlarmPreviewMock extends StatelessWidget {
  const AlarmPreviewMock({super.key, this.expanded = false});

  final bool expanded;

  static const Color _bgTop = Color(0xFF0B0D11);
  static const Color _bgBottom = Color(0xFF080A10);
  static const Color _glow = Color(0xFF161B2C);
  static const Color _accent = Color(0xFF7B61FF);
  static const Color _accentDim = Color(0xFF684FE0);
  static const Color _stopAccent = Color(0xFFFF6B6B);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFC7CCDA);
  static const Color _textMuted = Color(0xFF7E869A);

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final maxWidth = expanded ? 460.0 : 420.0;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: expanded ? 560 : 460,
        maxWidth: maxWidth,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.xl,
          vertical: spacing.xl + 2,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
          borderRadius: AppTokens.radius.xxxl,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.46),
              blurRadius: 26,
              spreadRadius: 10,
              offset: const Offset(0, 22),
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
                    colors: [_glow, Colors.transparent],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  accent: _accent,
                  textSecondary: _textSecondary,
                  textMuted: _textMuted,
                ),
                SizedBox(height: spacing.xl + 2),
                _ClockBlock(
                  expanded: expanded,
                  textPrimary: _textPrimary,
                  textSecondary: _textSecondary,
                  accent: _accent,
                ),
                SizedBox(height: spacing.lg),
                _ContextCard(
                  textPrimary: _textPrimary,
                  textSecondary: _textSecondary,
                ),
                const Spacer(),
                _Actions(
                  accent: _accent,
                  accentDim: _accentDim,
                  stopAccent: _stopAccent,
                  textPrimary: _textPrimary,
                  textSecondary: _textSecondary,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: AppTokens.radius.pill,
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.04),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.18),
                blurRadius: 22,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.alarm_rounded, size: 16, color: accent),
              SizedBox(width: spacing.sm),
              Text(
                'Class reminder',
                style: TextStyle(
                  color: textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
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
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              '07:15 AM',
              style: TextStyle(
                color: textMuted,
                fontWeight: FontWeight.w600,
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.md),
      decoration: BoxDecoration(
        borderRadius: AppTokens.radius.lg,
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        color: Colors.white.withValues(alpha: 0.02),
      ),
      child: Column(
        children: [
          Text(
            '3:04',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: expanded ? 104 : 98,
                      height: 1.0,
                    ) ??
                TextStyle(
                  color: textPrimary,
                  fontSize: expanded ? 104 : 98,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Alarm stops in 08:00',
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Tue, Apr 23',
            style: TextStyle(
              color: textSecondary,
              fontWeight: FontWeight.w600,
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event, size: 18, color: textSecondary),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  'Next: Math class at 3:30 PM',
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: textSecondary),
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
              const SizedBox(width: 10),
              _StatusPill(
                icon: Icons.vibration_rounded,
                label: 'Vibrate',
                textSecondary: textSecondary,
              ),
              const SizedBox(width: 10),
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
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: AppTokens.radius.lg,
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.1,
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
          fillColor: accent.withValues(alpha: 0.18),
          textColor: textPrimary,
          borderColor: accentDim.withValues(alpha: 0.55),
          secondaryLabel: '3 of 5 left',
        ),
        SizedBox(height: spacing.sm),
        _ActionButton(
          label: 'View reminders',
          icon: Icons.event_note_rounded,
          fillColor: Colors.white.withValues(alpha: 0.04),
          textColor: textSecondary,
          borderColor: Colors.white.withValues(alpha: 0.06),
          trailing: Icon(Icons.chevron_right_rounded,
              color: textSecondary, size: 20),
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
      height: 62,
      padding: EdgeInsets.symmetric(horizontal: spacing.lg),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: AppTokens.radius.xxl,
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 22),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                if (secondaryLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    secondaryLabel!,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.76),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
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
