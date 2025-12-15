import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A token-driven delete action for slidable items.
///
/// Used as the delete action content inside Slidable widgets.
class SlideDeleteAction extends StatelessWidget {
  const SlideDeleteAction({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    return Container(
      margin: EdgeInsets.only(left: AppTokens.spacing.sm),
      decoration: BoxDecoration(
        color: palette.danger,
        borderRadius: AppTokens.radius.lg,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.delete_outline_rounded, color: colors.onError),
          SizedBox(height: AppTokens.spacing.xs),
          Text(
            'Delete',
            textAlign: TextAlign.center,
            style: AppTokens.typography.label.copyWith(
              color: colors.onError,
              fontWeight: AppTokens.fontWeight.semiBold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
