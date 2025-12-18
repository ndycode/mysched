import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'layout.dart';
import 'responsive_provider.dart';

/// Modern auth layout with branded header and card-style form area.
///
/// Features a vibrant branded header section with app logo and title,
/// followed by a clean white/surface card area containing the form content.
class AuthShell extends StatefulWidget {
  const AuthShell({
    super.key,
    required this.screenName,
    required this.title,
    required this.subtitle,
    required this.child,
    this.bottom,
    this.headerAction,
    this.showBackButton = true,
    this.heroIcon,
  });

  final String screenName;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? bottom;
  final Widget? headerAction;
  final bool showBackButton;
  final IconData? heroIcon;

  @override
  State<AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends State<AuthShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: AppTokens.motion.slow,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppTokens.spacing;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    final physics = theme.platform == TargetPlatform.iOS
        ? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
        : const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

    final canPop = widget.showBackButton && Navigator.canPop(context);

    // Branded header height - responsive
    final headerHeight =
        keyboardVisible ? screenHeight * 0.15 : screenHeight * 0.32;

    // Branded header with gradient and logo
    final brandedHeader = Container(
      height: headerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  palette.primary.withValues(alpha: 0.9),
                  palette.primary.withValues(alpha: 0.7),
                ]
              : [
                  palette.primary,
                  palette.primary.withValues(alpha: 0.85),
                ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Back button
            if (canPop)
              Positioned(
                top: spacing.sm,
                left: spacing.sm,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: palette.onPrimary,
                  ),
                ),
              ),
            // Header action
            if (widget.headerAction != null)
              Positioned(
                top: spacing.sm,
                right: spacing.md,
                child: widget.headerAction!,
              ),
            // Logo and title
            Center(
              child: AnimatedOpacity(
                duration: AppTokens.motion.medium,
                opacity: keyboardVisible ? 0.0 : 1.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App icon/logo
                    Container(
                      width: 64 * scale,
                      height: 64 * scale,
                      decoration: BoxDecoration(
                        color: palette.onPrimary.withValues(alpha: 0.15),
                        borderRadius: AppTokens.radius.xl,
                      ),
                      child: Icon(
                        widget.heroIcon ?? Icons.calendar_month_rounded,
                        size: 36 * scale,
                        color: palette.onPrimary,
                      ),
                    ),
                    SizedBox(height: spacing.lg * spacingScale),
                    // Title
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style:
                          AppTokens.typography.headlineScaled(scale).copyWith(
                                fontWeight: AppTokens.fontWeight.bold,
                                color: palette.onPrimary,
                                letterSpacing: AppLetterSpacing.tight,
                              ),
                    ),
                    SizedBox(height: spacing.xs * spacingScale),
                    // Subtitle
                    Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: AppTokens.typography.bodyScaled(scale).copyWith(
                            color: palette.onPrimary.withValues(alpha: 0.85),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Form card content
    final formCard = Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: AppLayout.sheetMaxWidth),
      decoration: BoxDecoration(
        color: isDark ? palette.surface : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(spacing.xl)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.xl,
          vertical: spacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Form content
            widget.child,
            // Bottom actions
            if (widget.bottom != null) ...[
              SizedBox(height: spacing.lg * spacingScale),
              widget.bottom!,
            ],
            SizedBox(height: spacing.md),
          ],
        ),
      ),
    );

    return AppScaffold(
      screenName: widget.screenName,
      safeArea: false,
      body: Container(
        color: isDark ? palette.background : palette.primary,
        child: SingleChildScrollView(
          physics: physics,
          child: Column(
            children: [
              // Branded header
              brandedHeader,
              // Form card with slide animation
              SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    color: isDark ? palette.surface : Colors.white,
                    child: Center(child: formCard),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Divider with text.
class AuthDividerOr extends StatelessWidget {
  const AuthDividerOr({super.key, this.text = 'or'});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final scale = ResponsiveProvider.scale(context);

    return Padding(
      padding: spacing.edgeInsetsSymmetric(vertical: spacing.md),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: AppTokens.componentSize.dividerThin,
              color: colors.outline.withValues(alpha: AppOpacity.ghost),
            ),
          ),
          Padding(
            padding: spacing.edgeInsetsSymmetric(horizontal: spacing.lg),
            child: Text(
              text.toUpperCase(),
              style: AppTokens.typography.captionScaled(scale).copyWith(
                    color: palette.muted,
                    letterSpacing: 1.2,
                    fontWeight: AppTokens.fontWeight.medium,
                  ),
            ),
          ),
          Expanded(
            child: Container(
              height: AppTokens.componentSize.dividerThin,
              color: colors.outline.withValues(alpha: AppOpacity.ghost),
            ),
          ),
        ],
      ),
    );
  }
}

/// Social login button for Google authentication.
class AuthSocialButton extends StatelessWidget {
  const AuthSocialButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.enabled = true,
    this.loading = false,
  });

  /// Creates a Google sign-in button.
  factory AuthSocialButton.google({
    Key? key,
    VoidCallback? onPressed,
    bool enabled = true,
    bool loading = false,
  }) {
    return AuthSocialButton(
      key: key,
      label: 'Continue with Google',
      icon: const _GoogleIcon(),
      onPressed: onPressed,
      enabled: enabled,
      loading: loading,
    );
  }

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final scale = ResponsiveProvider.scale(context);

    final isDisabled = onPressed == null || !enabled || loading;

    return AnimatedOpacity(
      duration: AppTokens.motion.fast,
      opacity: isDisabled ? AppOpacity.soft : 1.0,
      child: Material(
        color: isDark ? palette.surfaceVariant : Colors.white,
        borderRadius: AppTokens.radius.xl,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: AppTokens.radius.xl,
          splashColor: colors.primary.withValues(alpha: AppOpacity.highlight),
          highlightColor: colors.primary.withValues(alpha: AppOpacity.micro),
          child: Container(
            height: AppTokens.componentSize.buttonLg,
            padding: spacing.edgeInsetsSymmetric(horizontal: spacing.lg),
            decoration: BoxDecoration(
              borderRadius: AppTokens.radius.xl,
              border: Border.all(
                color: isDark
                    ? colors.outline.withValues(alpha: AppOpacity.soft)
                    : colors.outline,
                width: AppTokens.componentSize.divider,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  SizedBox(
                    width: AppInteraction.loaderSize,
                    height: AppInteraction.loaderSize,
                    child: CircularProgressIndicator(
                      strokeWidth: AppInteraction.progressStrokeWidthLarge,
                      valueColor: AlwaysStoppedAnimation<Color>(palette.muted),
                    ),
                  )
                else
                  SizedBox(width: 20 * scale, height: 20 * scale, child: icon),
                SizedBox(width: spacing.md),
                Text(
                  label,
                  style: AppTokens.typography.bodyScaled(scale).copyWith(
                        color: colors.onSurface,
                        fontWeight: AppTokens.fontWeight.medium,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Google "G" logo icon.
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Google colors
    const blue = Color(0xFF4285F4);
    const red = Color(0xFFEA4335);
    const yellow = Color(0xFFFBBC05);
    const green = Color(0xFF34A853);

    final paint = Paint()..style = PaintingStyle.fill;

    // Blue arc (right side)
    paint.color = blue;
    final blueRect = Rect.fromLTWH(0, 0, w, h);
    canvas.drawArc(blueRect, -0.5, 1.8, true, paint);

    // Green arc (bottom right)
    paint.color = green;
    canvas.drawArc(blueRect, 1.3, 1.0, true, paint);

    // Yellow arc (bottom left)
    paint.color = yellow;
    canvas.drawArc(blueRect, 2.3, 1.0, true, paint);

    // Red arc (top)
    paint.color = red;
    canvas.drawArc(blueRect, 3.3, 1.5, true, paint);

    // White center circle
    paint.color = Colors.white;
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.35, paint);

    // Blue rectangle for the "G" bar
    paint.color = blue;
    final barRect = Rect.fromLTWH(w * 0.48, h * 0.42, w * 0.52, h * 0.16);
    canvas.drawRect(barRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Security indicator.
class AuthTrustIndicator extends StatelessWidget {
  const AuthTrustIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final scale = ResponsiveProvider.scale(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: AppTokens.iconSize.xs * scale,
          color: palette.muted.withValues(alpha: AppOpacity.muted),
        ),
        SizedBox(width: spacing.xs),
        Text(
          'Your data is encrypted',
          style: AppTokens.typography.microScaled(scale).copyWith(
                color: palette.muted.withValues(alpha: AppOpacity.muted),
              ),
        ),
      ],
    );
  }
}
