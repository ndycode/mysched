import 'package:flutter/material.dart';

import '../../services/schedule_export_service.dart';
import '../../services/schedule_repository.dart';
import '../../services/profile_cache.dart';
import '../../services/semester_service.dart';
import '../kit/kit.dart';
import '../theme/tokens.dart';

/// Shows the export options sheet.
Future<void> showExportOptionsSheet({
  required BuildContext context,
  required ScheduleApi api,
}) async {
  await AppModal.sheet(
    context: context,
    builder: (context) => _ExportOptionsSheet(api: api),
  );
}

class _ExportOptionsSheet extends StatefulWidget {
  const _ExportOptionsSheet({required this.api});

  final ScheduleApi api;

  @override
  State<_ExportOptionsSheet> createState() => _ExportOptionsSheetState();
}

class _ExportOptionsSheetState extends State<_ExportOptionsSheet> {
  bool _exporting = false;
  String? _error;

  Future<void> _exportPdf() async {
    setState(() {
      _exporting = true;
      _error = null;
    });

    try {
      // Get current classes
      final classes = await widget.api.getMyClasses();
      if (classes.isEmpty) {
        setState(() {
          _error = 'No classes to export. Add some classes first.';
          _exporting = false;
        });
        return;
      }

      // Get user name
      final profile = await ProfileCache.load();
      final userName = profile.name ?? profile.email ?? 'Student';

      // Get semester info
      final semester = await SemesterService.instance.getActiveSemester();
      final semesterLabel = semester?.name;

      // Generate and share
      await ScheduleExportService.exportAndShare(
        classes: classes,
        userName: userName,
        semester: semesterLabel,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Export failed: $e';
          _exporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return ModalShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: spacing.edgeInsetsAll(spacing.xl * spacingScale),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colors.outline.withValues(alpha: AppOpacity.faint),
                  width: AppTokens.componentSize.dividerThin,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: spacing.edgeInsetsAll(spacing.sm * spacingScale),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: AppOpacity.overlay),
                    borderRadius: AppTokens.radius.sm,
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    color: colors.primary,
                    size: AppTokens.iconSize.md * scale,
                  ),
                ),
                SizedBox(width: spacing.md * spacingScale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export Schedule',
                        style: AppTokens.typography.subtitleScaled(scale).copyWith(
                          fontWeight: AppTokens.fontWeight.semiBold,
                          color: colors.onSurface,
                        ),
                      ),
                      SizedBox(height: spacing.micro * spacingScale),
                      Text(
                        'Share your schedule as a PDF',
                        style: AppTokens.typography.captionScaled(scale).copyWith(
                          color: palette.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: palette.muted,
                  ),
                  onPressed: _exporting ? null : () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: spacing.edgeInsetsAll(spacing.xl * spacingScale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Error message
                if (_error != null) ...[
                  ErrorBanner(message: _error!),
                  SizedBox(height: spacing.lg * spacingScale),
                ],

                // Export option: PDF
                _ExportOption(
                  icon: Icons.picture_as_pdf_rounded,
                  iconColor: Colors.red,
                  title: 'Export as PDF',
                  subtitle: 'Weekly schedule with all class details',
                  onTap: _exporting ? null : _exportPdf,
                  loading: _exporting,
                ),

                SizedBox(height: spacing.lg * spacingScale),

                // Info text
                Container(
                  padding: spacing.edgeInsetsAll(spacing.md * spacingScale),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(alpha: AppOpacity.subtle),
                    borderRadius: AppTokens.radius.md,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: AppTokens.iconSize.sm * scale,
                        color: palette.muted,
                      ),
                      SizedBox(width: spacing.sm * spacingScale),
                      Expanded(
                        child: Text(
                          'Only enabled classes will be included in the export.',
                          style: AppTokens.typography.captionScaled(scale).copyWith(
                            color: palette.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  const _ExportOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.loading = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return InkWell(
      onTap: onTap,
      borderRadius: AppTokens.radius.lg,
      child: Container(
        padding: spacing.edgeInsetsAll(spacing.lg * spacingScale),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: AppTokens.radius.lg,
          border: Border.all(
            color: colors.outline.withValues(alpha: AppOpacity.faint),
            width: AppTokens.componentSize.dividerThin,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: spacing.edgeInsetsAll(spacing.md * spacingScale),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: AppOpacity.overlay),
                borderRadius: AppTokens.radius.md,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: AppTokens.iconSize.lg * scale,
              ),
            ),
            SizedBox(width: spacing.md * spacingScale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTokens.typography.label.copyWith(
                      color: colors.onSurface,
                      fontWeight: AppTokens.fontWeight.semiBold,
                    ),
                  ),
                  SizedBox(height: spacing.micro * spacingScale),
                  Text(
                    subtitle,
                    style: AppTokens.typography.captionScaled(scale).copyWith(
                      color: palette.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (loading)
              SizedBox(
                width: AppTokens.componentSize.spinnerSm,
                height: AppTokens.componentSize.spinnerSm,
                child: CircularProgressIndicator(
                  strokeWidth: AppTokens.componentSize.progressStroke,
                  valueColor: AlwaysStoppedAnimation(colors.primary),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: AppTokens.iconSize.sm * scale,
                color: palette.muted,
              ),
          ],
        ),
      ),
    );
  }
}
