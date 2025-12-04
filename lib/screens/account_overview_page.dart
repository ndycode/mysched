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

import '../app/routes.dart';
import '../env.dart';
import '../services/auth_service.dart';
import '../services/telemetry_service.dart';
import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';
import '../utils/nav.dart';
import 'change_email_page.dart';

class AccountOverviewPage extends StatefulWidget {
  const AccountOverviewPage({super.key});
  @override
  State<AccountOverviewPage> createState() => _AccountOverviewPageState();
}

class _AccountOverviewPageState extends State<AccountOverviewPage>
    with RouteAware {
  final _auth = AuthService.instance;
  static const double _kBottomNavSafePadding = 120;

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
      TelemetryService.instance.logError('account_load_profile', error: e, stack: stack);
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
        maxWidth: 1200,
        imageQuality: 85,
      );

      if (picked == null) {
        setState(() => _busy = false);
        return;
      }

      final originalBytes = await picked.readAsBytes();
      if (!mounted) return;

      final croppedBytes = await showSmoothDialog<Uint8List>(
        context: context,
        barrierDismissible: false,
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
    final spacing = AppTokens.spacing;
    final media = MediaQuery.of(context);

    final backButton = IconButton(
      splashRadius: 22,
      onPressed: _busy
          ? null
          : () {
              if (context.canPop()) {
                context.pop();
              }
            },
      icon: CircleAvatar(
        radius: 16,
        backgroundColor: colors.primary.withValues(alpha: 0.12),
        child: Icon(
          Icons.arrow_back_rounded,
          color: colors.primary,
          size: AppTokens.iconSize.sm,
        ),
      ),
    );

    final heroContent = ScreenBrandHeader(
      leading: backButton,
      showChevron: false,
      loading: !_profileHydrated,
    );

    return ScreenShell(
      screenName: 'account_overview',
      hero: heroContent,
      sections: [
        const ScreenSection(
          decorated: false,
          child: ScreenHeroCard(
            title: 'Account overview',
            subtitle: 'Manage your profile and security preferences.',
          ),
        ),
        ScreenSection(
          title: 'Profile',
          subtitle: 'Update your avatar, name, and student ID.',
          decorated: false,
          child: _buildProfileCard(theme, colors),
        ),
        ScreenSection(
          title: 'Security actions',
          subtitle: 'Keep your login details up to date.',
          decorated: false,
          child: _buildSecurityCard(theme, colors),
        ),
        ScreenSection(
          decorated: false,
          child: SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              onPressed: _busy ? null : () => _confirmSignOut(context),
              label: 'Sign out',
              icon: Icons.logout_rounded,
            ),
          ),
        ),
      ],
      padding: EdgeInsets.fromLTRB(
        spacing.xl,
        media.padding.top + spacing.xxxl,
        spacing.xl,
        spacing.quad + _kBottomNavSafePadding,
      ),
      safeArea: false,
    );
  }

  Widget _buildProfileCard(ThemeData theme, ColorScheme colors) {
    final spacing = AppTokens.spacing;
    return CardX(
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: colors.primary.withValues(alpha: 0.12),
                backgroundImage:
                    _avatar == null ? null : NetworkImage(_avatar!),
                child: _avatar == null
                    ? Icon(
                        Icons.person_rounded,
                        size: AppTokens.iconSize.xxl + 8,
                        color: colors.onSurface.withValues(alpha: 0.5),
                      )
                    : null,
              ),
              Positioned(
                right: -6,
                bottom: -6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: AppTokens.radius.xxxl,
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: 0.2),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _busy ? null : _pickAndUpload,
                    icon: _busy
                        ? SizedBox(
                width: AppTokens.componentSize.badgeMd + 2,
                height: AppTokens.componentSize.badgeMd + 2,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.primary,
                            ),
                          )
                        : Icon(Icons.photo_camera_outlined,
                            color: colors.primary),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          Text(
            _name.isEmpty ? 'Student' : _name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: AppTokens.typography.title.fontSize,
            ),
            textAlign: TextAlign.center,
          ),
          if (_sid.isNotEmpty || _email.isNotEmpty) ...[
            SizedBox(height: spacing.xs + 2),
            Column(
              children: [
                if (_sid.isNotEmpty)
                  Text(
                    _sid,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (_email.isNotEmpty)
                  Text(
                    _email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSecurityCard(ThemeData theme, ColorScheme colors) {
    final spacing = AppTokens.spacing;
    return CardX(
      padding: spacing.edgeInsetsAll(spacing.xl),
      child: Column(
        children: [
          InfoTile(
            icon: Icons.mail_outline,
            title: 'Change email',
            tint: colors.primary,
            iconInContainer: true,
            showChevron: true,
            onTap: () async {
              await context.push<bool>(
                AppRoutes.changeEmail,
                extra: ChangeEmailPageArgs(currentEmail: _email),
              );
              await _load();
            },
          ),
          SizedBox(height: AppTokens.spacing.lg),
          InfoTile(
            icon: Icons.lock_outline,
            title: 'Change password',
            tint: colors.primary,
            iconInContainer: true,
            showChevron: true,
            onTap: () async {
              await context.push<bool>(AppRoutes.changePassword);
              await _load();
            },
          ),
          SizedBox(height: AppTokens.spacing.lg),
          InfoTile(
            icon: Icons.delete_forever_outlined,
            title: 'Delete account',
            tint: colors.error,
            iconInContainer: true,
            showChevron: true,
            onTap: () async {
              await context.push<bool>(AppRoutes.deleteAccount);
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
    final shouldSignOut = await AppModal.showConfirmDialog(
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
    final cropDimension = (screenWidth * 0.8).clamp(220.0, 360.0);

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
          fontWeight: FontWeight.w700,
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
              ? const SizedBox(
                  width: 80,
                  height: 44,
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
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
