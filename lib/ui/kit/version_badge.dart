import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import '../theme/tokens.dart';

/// Displays a compact version badge (e.g., "1.0.0+1 P5")
class VersionBadge extends StatefulWidget {
  const VersionBadge({super.key});

  @override
  State<VersionBadge> createState() => _VersionBadgeState();
}

class _VersionBadgeState extends State<VersionBadge> {
  String? _versionText;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    String base = 'ver';
    try {
      final info = await PackageInfo.fromPlatform();
      base = '${info.version}+${info.buildNumber}';
    } catch (_) {}

    int? patch;
    try {
      final updater = ShorebirdUpdater();
      final p = await updater.readCurrentPatch();
      patch = p?.number;
    } catch (_) {}

    if (mounted) {
      setState(() {
        _versionText = patch != null ? '$base P$patch' : base;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_versionText == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;

    return Container(
      padding: spacing.edgeInsetsSymmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: AppTokens.radius.sm,
      ),
      child: Text(
        _versionText!,
        style: AppTokens.typography.caption.copyWith(
          fontWeight: AppTokens.fontWeight.semiBold,
          color: colors.onSurfaceVariant,
          fontSize: 10,
        ),
      ),
    );
  }
}
