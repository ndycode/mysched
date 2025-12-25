
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../app/constants.dart';
import '../theme/tokens.dart';

/// Custom Google "G" logo painter - replaces font_awesome_flutter dependency
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 18});
  
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final center = Offset(s / 2, s / 2);
    final radius = s / 2 * 0.85;
    final strokeWidth = s * 0.18;
    
    // Google brand colors
    const blue = Color(0xFF4285F4);
    const red = Color(0xFFEA4335);
    const yellow = Color(0xFFFBBC05);
    const green = Color(0xFF34A853);
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    
    // Blue arc (right side, going up)
    paint.color = blue;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 4,  // start angle
      -math.pi / 2,  // sweep angle
      false,
      paint,
    );
    
    // Red arc (top)
    paint.color = red;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 3 / 4,
      -math.pi / 2,
      false,
      paint,
    );
    
    // Yellow arc (bottom left)
    paint.color = yellow;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 3 / 4,
      -math.pi / 2,
      false,
      paint,
    );
    
    // Green arc (bottom)
    paint.color = green;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi / 4,
      -math.pi / 2,
      false,
      paint,
    );
    
    // Blue horizontal bar
    final barPaint = Paint()
      ..color = blue
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - strokeWidth / 4,
        center.dy - strokeWidth / 2,
        radius + strokeWidth / 2,
        strokeWidth,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
                  child: GoogleLogo(size: 18 * scale),
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
