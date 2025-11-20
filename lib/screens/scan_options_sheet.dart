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
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final spacing = AppTokens.spacing;
    final cardBackground = elevatedCardBackground(theme, solid: true);
    final borderColor = elevatedCardBorder(theme, solid: true);

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            spacing.xl,
            20,
            media.padding.bottom + viewInsets.bottom + spacing.xl,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: media.size.height * 0.78,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: AppTokens.radius.xl,
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(
                        alpha:
                            theme.brightness == Brightness.dark ? 0.32 : 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: spacing.edgeInsetsOnly(
                    left: spacing.xl + 8,
                    right: spacing.xl + 8,
                    top: spacing.xl + 4,
                    bottom: spacing.xl,
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
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
                          const SizedBox(width: 48),
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
                        height: 180,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: AppTokens.radius.lg,
                          border: Border.all(
                            color:
                                colors.outlineVariant.withValues(alpha: 0.38),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.credit_card,
                          size: 64,
                          color:
                              colors.onSurfaceVariant.withValues(alpha: 0.78),
                        ),
                      ),
                      SizedBox(height: spacing.xxl),
                      FilledButton.icon(
                        onPressed:
                            _busy ? null : () => _pick(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: Text(_busy ? 'Opening camera…' : 'Take photo'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppTokens.radius.xl,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing.md),
                      OutlinedButton.icon(
                        onPressed:
                            _busy ? null : () => _pick(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Upload from photos'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppTokens.radius.xl,
                          ),
                        ),
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
