import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Small pill badge to indicate queued/offline items.
class QueuedBadge extends StatelessWidget {
  const QueuedBadge({super.key, this.label = 'Queued'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.secondary.withValues(alpha: 0.14),
        borderRadius: AppTokens.radius.pill,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.secondary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
