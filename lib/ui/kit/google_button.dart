
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../app/constants.dart';
import '../theme/tokens.dart';

class GoogleButton extends StatelessWidget {
  const GoogleButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final scale = MediaQuery.of(context).textScaler.scale(1.0); 

    return Material(
      color: isDark ? palette.surfaceVariant : Colors.white,
      borderRadius: AppTokens.radius.pill,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppTokens.radius.pill,
        splashColor: palette.primary.withValues(alpha: AppOpacity.overlay),
        highlightColor: palette.primary.withValues(alpha: AppOpacity.faint),
        child: Container(
          width: double.infinity,
          height: AppTokens.componentSize.buttonLg,
          decoration: BoxDecoration(
            borderRadius: AppTokens.radius.pill,
            border: Border.all(
              color: palette.outline,
              width: AppTokens.componentSize.divider,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20 * scale,
                height: 20 * scale,
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.google,
                    size: 18 * scale,
                    color: palette.onSurface,
                  ),
                ),
              ),
              SizedBox(width: AppTokens.spacing.sm),
              Text(
                AppConstants.continueWithGoogleLabel,
                style: AppTokens.typography.bodyScaled(scale).copyWith(
                      fontWeight: AppTokens.fontWeight.semiBold,
                      color: palette.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
