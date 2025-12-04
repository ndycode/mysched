// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../ui/kit/kit.dart';
import '../ui/theme/tokens.dart';
import '../ui/theme/card_styles.dart';

class ScanOptionsSheet extends StatefulWidget {
  const ScanOptionsSheet({super.key});

  @override
  State<ScanOptionsSheet> createState() => _ScanOptionsSheetState();
}

class _ScanOptionsSheetState extends State<ScanOptionsSheet> {
  final ImagePicker _picker = ImagePicker();
  bool _busy = false;

  Future<void> _pick(ImageSource source) async {
    if (_busy) return;
    final consentGranted = await ensureScanConsent(context);
    if (!consentGranted) return;
    setState(() => _busy = true);
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 92);
      if (!mounted) return;
      if (picked != null) {
        Navigator.of(context).pop(picked.path);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final media = MediaQuery.of(context);
    final spacing = AppTokens.spacing;
    final cardBackground = elevatedCardBackground(theme, solid: true);
    final borderColor = elevatedCardBorder(theme, solid: true);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: media.size.height * 0.78,
          ),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: spacing.xl),
            child: CardX(
              padding: EdgeInsets.zero,
              backgroundColor: theme.brightness == Brightness.dark
                  ? theme.colorScheme.surfaceContainerHigh
                  : theme.colorScheme.surface,
              borderColor: theme.colorScheme.outline.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.12 : 0.4),
              borderRadius: AppTokens.radius.xl,
              elevation: 12,
              child: ClipRRect(
                borderRadius: AppTokens.radius.xl,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    spacing.xl,
                    spacing.xl,
                    spacing.xl,
                    media.viewInsets.bottom + spacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          PressableScale(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: spacing.edgeInsetsAll(spacing.sm),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.08),
                                borderRadius: AppTokens.radius.xl,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: AppTokens.iconSize.sm,
                                color: colors.primary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Scan student card',
                              textAlign: TextAlign.center,
                              style: AppTokens.typography.title.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          SizedBox(width: AppTokens.spacing.quad),
                        ],
                      ),
                      SizedBox(height: spacing.sm),
                      Text(
                        'Choose how you want to capture your student account card.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: spacing.xl + 4),
                      Container(
                        height: AppTokens.componentSize.previewLg,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: AppTokens.radius.lg,
                          border: Border.all(
                            color: colors.outlineVariant.withValues(alpha: 0.2),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.credit_card,
                          size: AppTokens.iconSize.display,
                          color:
                              colors.onSurfaceVariant.withValues(alpha: 0.78),
                        ),
                      ),
                      SizedBox(height: spacing.xxl),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              onPressed:
                                  _busy ? null : () => _pick(ImageSource.camera),
                              label: _busy ? 'Opening...' : 'Take photo',
                              icon: Icons.camera_alt_outlined,
                              minHeight: 48,
                            ),
                          ),
                          SizedBox(width: spacing.md),
                          Expanded(
                            child: SecondaryButton(
                              onPressed:
                                  _busy ? null : () => _pick(ImageSource.gallery),
                              label: 'Upload',
                              icon: Icons.photo_library_outlined,
                              minHeight: 48,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
