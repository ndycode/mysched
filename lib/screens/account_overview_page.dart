// coverage:ignore-file
// lib/screens/account_overview_page.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/constants.dart';
import '../app/routes.dart';
import '../env.dart';
import '../services/auth_service.dart';
import '../services/telemetry_service.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';
import '../utils/nav.dart';
import 'change_email_page.dart';
import 'change_password_page.dart';
import 'delete_account_page.dart';

class AccountOverviewPage extends StatefulWidget {
  const AccountOverviewPage({super.key});
  @override
  State<AccountOverviewPage> createState() => _AccountOverviewPageState();
}

class _AccountOverviewPageState extends State<AccountOverviewPage>
    with RouteAware {
  final _auth = AuthService.instance;

  String _name = '';
  String _sid = '';
  String _email = '';
  String? _avatar;
  bool _profileHydrated = false;
  bool _busy = false;
  PageRoute<dynamic>? _routeSubscription;

  @override
  void initState() {
    super.initState();
    _load();
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

  @override
  void dispose() {
    if (_routeSubscription != null) {
      routeObserver.unsubscribe(this);
      _routeSubscription = null;
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    // Returning from a child page (e.g., change email/password)
    if (mounted) {
      // ignore: discarded_futures
      _load();
    }
  }

  Future<void> refreshOnTabVisit() => _load();

  Future<void> _load() async {
    try {
      final me = await _auth.me();
      final sp = await SharedPreferences.getInstance();
      final supaEmail = Env.supa.auth.currentUser?.email ?? '';

      setState(() {
        _name = (me?['full_name'] ?? me?['fullName'] ?? '').toString();
        _sid = (me?['student_id'] ?? me?['studentId'] ?? '').toString();
        _email = supaEmail;
        _avatar = (me?['avatar_url'] as String?) ?? sp.getString('avatar_url');
        _profileHydrated = true;
      });
    } catch (e, stack) {
      TelemetryService.instance
          .logError('account_load_profile', error: e, stack: stack);
      if (!mounted) return;
      if (!_profileHydrated) {
        setState(() => _profileHydrated = true);
      }
    }
  }

  Future<void> _pickAndUpload() async {
    if (_busy) return;
    setState(() => _busy = true);
    File? tmpFile;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppConstants.imageMaxWidth,
        imageQuality: AppConstants.imageQuality,
      );

      if (picked == null) {
        setState(() => _busy = false);
        return;
      }

      final originalBytes = await picked.readAsBytes();
      if (!mounted) return;

      final croppedBytes = await AppModal.alert<Uint8List>(
        context: context,
        dismissible: false,
        builder: (context) => _AvatarCropDialog(imageBytes: originalBytes),
      );

      if (croppedBytes == null) {
        setState(() => _busy = false);
        return;
      }

      final tmpDir = await getTemporaryDirectory();
      final tmpPath =
          '${tmpDir.path}/avatar-${DateTime.now().millisecondsSinceEpoch}.jpg';
      tmpFile = File(tmpPath);
      await tmpFile.writeAsBytes(croppedBytes, flush: true);

      final url = await _auth.uploadAvatar(tmpFile.path);

      if (!mounted) return;
      setState(() => _avatar = url);
      showAppSnackBar(
        context,
        'Profile photo updated',
        type: AppSnackBarType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Upload failed: $e',
        type: AppSnackBarType.error,
      );
    } finally {
      if (tmpFile != null && await tmpFile.exists()) {
        try {
          await tmpFile.delete();
        } catch (_) {
          // ignore temp file deletion failure
        }
      }
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final media = MediaQuery.of(context);

    final backButton = PressableScale(
      onTap: _busy
          ? null
          : () {
              if (context.canPop()) {
                context.pop();
              }
            },
      child: Container(
        padding: EdgeInsets.all(spacing.sm),
        decoration: BoxDecoration(
          color: colors.onSurface.withValues(alpha: AppOpacity.faint),
          borderRadius: AppTokens.radius.md,
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          size: AppTokens.iconSize.md,
          color: palette.muted,
        ),
      ),
    );

    final heroContent = ScreenBrandHeader(
      leading: backButton,
      showChevron: false,
      loading: !_profileHydrated,
    );

    final shellPadding = EdgeInsets.fromLTRB(
      spacing.xl,
      media.padding.top + spacing.xxxl,
      spacing.xl,
      spacing.quad + AppLayout.bottomNavSafePadding,
    );

    // Show skeleton loading state
    if (!_profileHydrated) {
      return ScreenShell(
        screenName: 'account_overview',
        hero: heroContent,
        sections: [
          ScreenSection(
            decorated: false,
            child: const SkeletonAccountOverview(),
          ),
        ],
        padding: shellPadding,
        safeArea: false,
      );
    }

    return ScreenShell(
      screenName: 'account_overview',
      hero: heroContent,
      sections: [
        ScreenSection(
          decorated: false,
          child: _buildAccountSummaryCard(colors, isDark, palette),
        ),
        ScreenSection(
          decorated: false,
          child: _buildSecurityCard(colors, isDark, palette),
        ),
        ScreenSection(
          decorated: false,
          child: SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              onPressed: _busy ? null : () => _confirmSignOut(context),
              label: 'Sign out',
              icon: Icons.logout_rounded,
              minHeight: AppTokens.componentSize.buttonMd,
            ),
          ),
        ),
      ],
      padding: shellPadding,
      safeArea: false,
    );
  }

  Widget _buildAccountSummaryCard(
      ColorScheme colors, bool isDark, ColorPalette palette) {
    final spacing = AppTokens.spacing;

    return CardX(
      variant: CardVariant.elevated,
      padding: spacing.edgeInsetsAll(spacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Text(
            'Account overview',
            style: AppTokens.typography.title.copyWith(
              fontWeight: AppTokens.fontWeight.bold,
              letterSpacing: AppLetterSpacing.snug,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Manage your profile and security preferences.',
            style: AppTokens.typography.body.copyWith(
              color: palette.muted,
            ),
          ),
          SizedBox(height: spacing.xl),
          // Profile section header
          Text(
            'Profile',
            style: AppTokens.typography.subtitle.copyWith(
              fontWeight: AppTokens.fontWeight.semiBold,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Update your avatar, name, and student ID.',
            style: AppTokens.typography.bodySecondary.copyWith(
              color: palette.muted,
            ),
          ),
          SizedBox(height: spacing.lg),
          // Profile content
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: AppTokens.componentSize.avatarXl,
                    backgroundColor:
                        colors.primary.withValues(alpha: AppOpacity.overlay),
                    backgroundImage:
                        _avatar == null ? null : NetworkImage(_avatar!),
                    child: _avatar == null
                        ? Icon(
                            Icons.person_rounded,
                            size: AppTokens.iconSize.xl,
                            color: colors.onSurface
                                .withValues(alpha: AppOpacity.subtle),
                          )
                        : null,
                  ),
                  Positioned(
                    right: -spacing.xs,
                    bottom: -spacing.xs,
                    child: GestureDetector(
                      onTap: _busy ? null : _pickAndUpload,
                      child: Container(
                        padding: spacing.edgeInsetsAll(spacing.sm),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: AppTokens.radius.xxxl,
                          border: Border.all(
                            color: isDark
                                ? colors.surfaceContainerHigh
                                : colors.surface,
                            width: AppTokens.componentSize.dividerThick,
                          ),
                        ),
                        child: _busy
                            ? SizedBox(
                                width: AppTokens.iconSize.sm,
                                height: AppTokens.iconSize.sm,
                                child: CircularProgressIndicator(
                                  strokeWidth: AppTokens.spacing.micro,
                                  color: colors.onPrimary,
                                ),
                              )
                            : Icon(
                                Icons.photo_camera_outlined,
                                size: AppTokens.iconSize.sm,
                                color: colors.onPrimary,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name.isEmpty ? 'Student' : _name,
                      style: AppTokens.typography.subtitle.copyWith(
                        fontWeight: AppTokens.fontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    if (_sid.isNotEmpty || _email.isNotEmpty) ...[
                      SizedBox(height: spacing.xs),
                      if (_sid.isNotEmpty)
                        Text(
                          _sid,
                          style: AppTokens.typography.bodySecondary.copyWith(
                            color: palette.muted,
                            fontWeight: AppTokens.fontWeight.medium,
                          ),
                        ),
                      if (_email.isNotEmpty)
                        Text(
                          _email,
                          style: AppTokens.typography.bodySecondary.copyWith(
                            color: palette.muted,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(
      ColorScheme colors, bool isDark, ColorPalette palette) {
    final spacing = AppTokens.spacing;
    return CardX(
      variant: CardVariant.elevated,
      padding: spacing.edgeInsetsAll(spacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security actions',
            style: AppTokens.typography.subtitle.copyWith(
              fontWeight: AppTokens.fontWeight.semiBold,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Keep your login details up to date.',
            style: AppTokens.typography.bodySecondary.copyWith(
              color: palette.muted,
            ),
          ),
          SizedBox(height: spacing.lg),
          InfoTile(
            icon: Icons.mail_outline,
            title: 'Change email',
            tint: colors.primary,
            iconInContainer: true,
            showChevron: true,
            onTap: () async {
              await ChangeEmailPage.show(
                context,
                currentEmail: _email,
              );
              await _load();
            },
          ),
          SizedBox(height: spacing.md),
          InfoTile(
            icon: Icons.lock_outline,
            title: 'Change password',
            tint: colors.primary,
            iconInContainer: true,
            showChevron: true,
            onTap: () async {
              await ChangePasswordPage.show(context);
              await _load();
            },
          ),
          SizedBox(height: spacing.md),
          InfoTile(
            icon: Icons.delete_forever_outlined,
            title: 'Delete account',
            tint: palette.danger,
            iconInContainer: true,
            showChevron: true,
            onTap: () async {
              await DeleteAccountPage.show(context);
              if (mounted) {
                await _load();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldSignOut = await AppModal.confirm(
      context: context,
      title: 'Sign out?',
      message: 'You\'ll return to the login screen.',
      confirmLabel: 'Sign out',
    );

    if (shouldSignOut == true) {
      await _auth.logout();
      if (!context.mounted) return;
      if (!mounted) return;
      context.go(AppRoutes.login);
    }
  }
}

class _AvatarCropDialog extends StatefulWidget {
  const _AvatarCropDialog({required this.imageBytes});

  final Uint8List imageBytes;

  @override
  State<_AvatarCropDialog> createState() => _AvatarCropDialogState();
}

class _AvatarCropDialogState extends State<_AvatarCropDialog> {
  final CropController _controller = CropController();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final cropDimension = (screenWidth * AppScale.cropDialogRatio).clamp(
        AppTokens.componentSize.cropDialogMin,
        AppTokens.componentSize.cropDialogMax);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppTokens.radius.sheet),
      titlePadding: AppTokens.spacing.edgeInsetsOnly(
        left: AppTokens.spacing.xl,
        right: AppTokens.spacing.xl,
        top: AppTokens.spacing.xl,
        bottom: AppTokens.spacing.sm,
      ),
      contentPadding: AppTokens.spacing.edgeInsetsOnly(
        left: AppTokens.spacing.xl,
        right: AppTokens.spacing.xl,
        bottom: AppTokens.spacing.lg,
      ),
      actionsPadding: AppTokens.spacing.edgeInsetsAll(AppTokens.spacing.lg),
      title: Text(
        'Crop profile photo',
        style: AppTokens.typography.title.copyWith(
          fontWeight: AppTokens.fontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: cropDimension,
            height: cropDimension,
            child: ClipRRect(
              borderRadius: AppTokens.radius.lg,
              child: Crop(
                controller: _controller,
                image: widget.imageBytes,
                aspectRatio: 1,
                onCropped: (bytes) {
                  Navigator.of(context).pop(bytes);
                },
              ),
            ),
          ),
          SizedBox(height: AppTokens.spacing.md),
          Text(
            'Pinch to zoom and position yourself inside the square frame.',
            style: AppTokens.typography.bodySecondary.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        SecondaryButton(
          label: 'Cancel',
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          minHeight: AppTokens.componentSize.buttonSm,
          expanded: false,
        ),
        _saving
            ? SizedBox(
                width: AppTokens.componentSize.buttonLg + AppTokens.spacing.xxl,
                height: AppTokens.componentSize.buttonSm,
                child: Center(
                  child: SizedBox(
                    width: AppTokens.componentSize.badgeMd +
                        AppTokens.spacing.micro,
                    height: AppTokens.componentSize.badgeMd +
                        AppTokens.spacing.micro,
                    child: CircularProgressIndicator(
                        strokeWidth: AppTokens.spacing.micro),
                  ),
                ),
              )
            : PrimaryButton(
                label: 'Save',
                onPressed: () {
                  setState(() {
                    _saving = true;
                  });
                  _controller.crop();
                },
                minHeight: AppTokens.componentSize.buttonSm,
                expanded: false,
              ),
      ],
    );
  }
}
