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
    final borderWidth = elevatedCardBorderWidth(theme);
    final isDark = theme.brightness == Brightness.dark;
    final maxHeight = media.size.height * AppLayout.sheetMaxHeightRatio;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: spacing.xl,
          right: spacing.xl,
          bottom: media.viewInsets.bottom + spacing.xl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppLayout.sheetMaxWidth,
              maxHeight: maxHeight,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: AppTokens.radius.xl,
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        AppTokens.shadow.modal(
                          colors.shadow.withValues(alpha: AppOpacity.border),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: AppTokens.radius.xl,
                child: Material(
                  type: MaterialType.transparency,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Padding(
                        padding: spacing.edgeInsetsOnly(
                          left: spacing.xl,
                          right: spacing.xl,
                          top: spacing.xl,
                          bottom: spacing.md,
                        ),
                        child: SheetHeaderRow(
                          title: 'Scan student card',
                          subtitle:
                              'Choose how you want to capture your student account card',
                          icon: Icons.credit_card_rounded,
                          onClose: () => Navigator.of(context).pop(),
                        ),
                      ),
                      // Content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: spacing.edgeInsetsOnly(
                            left: spacing.xl,
                            right: spacing.xl,
                            bottom: spacing.md,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Student card preview mockup
                              _StudentCardPreview(),
                            ],
                          ),
                        ),
                      ),
                      // Action buttons
                      Container(
                        padding: spacing.edgeInsetsOnly(
                          left: spacing.xl,
                          right: spacing.xl,
                          top: spacing.md,
                          bottom: spacing.xl,
                        ),
                        decoration: BoxDecoration(
                          color: cardBackground,
                          border: Border(
                            top: BorderSide(
                              color: isDark
                                  ? colors.outline
                                      .withValues(alpha: AppOpacity.overlay)
                                  : colors.outlineVariant
                                      .withValues(alpha: AppOpacity.ghost),
                              width: AppTokens.componentSize.dividerThin,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                onPressed: _busy
                                    ? null
                                    : () => _pick(ImageSource.camera),
                                label: _busy ? 'Opening...' : 'Take photo',
                                icon: Icons.camera_alt_outlined,
                                minHeight: AppTokens.componentSize.buttonMd,
                              ),
                            ),
                            SizedBox(width: spacing.md),
                            Expanded(
                              child: SecondaryButton(
                                onPressed: _busy
                                    ? null
                                    : () => _pick(ImageSource.gallery),
                                label: 'Upload',
                                icon: Icons.photo_library_outlined,
                                minHeight: AppTokens.componentSize.buttonMd,
                              ),
                            ),
                          ],
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

/// A stylized preview of a student enrollment card to guide users
class _StudentCardPreview extends StatelessWidget {
  const _StudentCardPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;

    // Match the empty state card styling from dashboard
    final backgroundColor = isDark
        ? colors.surfaceContainerHighest.withValues(alpha: AppOpacity.divider)
        : colors.primary.withValues(alpha: AppOpacity.micro);
    final borderColor = isDark
        ? colors.outline.withValues(alpha: AppOpacity.overlay)
        : colors.primary.withValues(alpha: AppOpacity.dim);

    return Container(
      padding: spacing.edgeInsetsAll(spacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppTokens.radius.lg,
        border: Border.all(
          color: borderColor,
          width: AppTokens.componentSize.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student info section
          Row(
            children: [
              _FieldColumn(label: 'STUDENT NO.', width: 80),
              SizedBox(width: spacing.xl),
              Expanded(child: _FieldColumn(label: 'STUDENT NAME')),
            ],
          ),
          SizedBox(height: spacing.lg),
          Row(
            children: [
              _FieldColumn(label: 'COURSE', width: 80),
              SizedBox(width: spacing.xl),
              _FieldColumn(label: 'SECTION', width: 72),
              SizedBox(width: spacing.xl),
              _FieldColumn(label: 'YR LVL', width: 48),
            ],
          ),
          SizedBox(height: spacing.xl),
          // Divider
          Container(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: AppOpacity.ghost),
          ),
          SizedBox(height: spacing.lg),
          // Schedule table header
          Row(
            children: const [
              _TableLabel(label: 'CODE', width: 56),
              Expanded(child: _TableLabel(label: 'SUBJECT')),
              _TableLabel(label: 'UNITS', width: 40, align: TextAlign.end),
            ],
          ),
          SizedBox(height: spacing.sm),
          // Schedule rows
          ...List.generate(3, (i) => _ScheduleRow(index: i)),
        ],
      ),
    );
  }
}

class _FieldColumn extends StatelessWidget {
  const _FieldColumn({required this.label, this.width});

  final String label;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: AppTokens.fontWeight.medium,
            color: palette.muted.withValues(alpha: AppOpacity.soft),
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: spacing.xs),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: colors.outlineVariant.withValues(alpha: AppOpacity.accent),
            borderRadius: AppTokens.radius.micro,
          ),
        ),
      ],
    );

    if (width != null) {
      return SizedBox(width: width, child: content);
    }
    return content;
  }
}

class _TableLabel extends StatelessWidget {
  const _TableLabel({
    required this.label,
    this.width,
    this.align = TextAlign.start,
  });

  final String label;
  final double? width;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;

    final text = Text(
      label,
      textAlign: align,
      style: TextStyle(
        fontSize: 8,
        fontWeight: AppTokens.fontWeight.semiBold,
        color: palette.muted.withValues(alpha: AppOpacity.soft),
        letterSpacing: 0.2,
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: text);
    }
    return text;
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spacing = AppTokens.spacing;
    final barColor = colors.outlineVariant.withValues(alpha: AppOpacity.accent);

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: Row(
        children: [
          // Code
          SizedBox(
            width: 56,
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: AppTokens.radius.micro,
              ),
            ),
          ),
          SizedBox(width: spacing.md),
          // Subject
          Expanded(
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: AppTokens.radius.micro,
              ),
            ),
          ),
          SizedBox(width: spacing.md),
          // Units
          SizedBox(
            width: 40,
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: AppTokens.radius.micro,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
