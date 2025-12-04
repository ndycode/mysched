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

      final croppedBytes = await showDialog<Uint8List>(
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
          size: 18,
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
    return Container(
      padding: spacing.edgeInsetsAll(spacing.xl),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colors.surfaceContainerHigh
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? colors.outline.withValues(alpha: 0.12)
              : const Color(0xFFE5E5E5),
          width: theme.brightness == Brightness.dark ? 1 : 0.5,
        ),
        boxShadow: theme.brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
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
                        size: 48,
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
                            width: 18,
                            height: 18,
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
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          if (_sid.isNotEmpty || _email.isNotEmpty) ...[
            const SizedBox(height: 6),
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colors.surfaceContainerHigh
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? colors.outline.withValues(alpha: 0.12)
              : const Color(0xFFE5E5E5),
          width: theme.brightness == Brightness.dark ? 1 : 0.5,
        ),
        boxShadow: theme.brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.mail_outline,
            title: 'Change email',
            color: colors.primary,
            onTap: () async {
              await context.push<bool>(
                AppRoutes.changeEmail,
                extra: ChangeEmailPageArgs(currentEmail: _email),
              );
              await _load();
            },
          ),
          SizedBox(height: AppTokens.spacing.lg),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Change password',
            color: colors.primary,
            onTap: () async {
              await context.push<bool>(AppRoutes.changePassword);
              await _load();
            },
          ),
          SizedBox(height: AppTokens.spacing.lg),
          _SettingsTile(
            icon: Icons.delete_forever_outlined,
            title: 'Delete account',
            color: colors.error,
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
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You\'ll return to the login screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      await _auth.logout();
      if (!context.mounted) return;
      if (!mounted) return;
      context.go(AppRoutes.login);
    }
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = AppTokens.spacing;
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: spacing.edgeInsetsSymmetric(vertical: spacing.sm),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 22),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: Text(
                title,
                style: AppTokens.typography.subtitle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
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
      title: const Text('Crop profile photo'),
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
          const SizedBox(height: 12),
          Text(
            'Pinch to zoom and position yourself inside the square frame.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving
              ? null
              : () {
                  setState(() {
                    _saving = true;
                  });
                  _controller.crop();
                },
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
