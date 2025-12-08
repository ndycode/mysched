// ignore_for_file: unused_local_variable
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../env.dart';
import '../../models/schedule_class.dart';
import '../../models/section.dart' as model;
import '../../ui/kit/kit.dart';
import '../../ui/theme/card_styles.dart';
import '../../ui/theme/motion.dart';
import '../../ui/theme/tokens.dart';
import '../../utils/app_log.dart';
import '../../utils/errors.dart';
import '../../utils/formatters.dart';
import '../../utils/supabase_client.dart';

const _scope = 'ScanPreview';

class ScanPreviewOutcome {
  const ScanPreviewOutcome._({
    this.section,
    this.classes = const [],
    this.imagePath,
    this.retake = false,
  });

  const ScanPreviewOutcome.success({
    required Map<String, dynamic> section,
    required List<Map<String, dynamic>> classes,
    required String imagePath,
  }) : this._(
          section: section,
          classes: classes,
          imagePath: imagePath,
        );

  const ScanPreviewOutcome.retake() : this._(retake: true);

  final Map<String, dynamic>? section;
  final List<Map<String, dynamic>> classes;
  final String? imagePath;
  final bool retake;

  bool get isSuccess => section != null && imagePath != null;
}

class ScanPreviewSheet extends StatefulWidget {
  const ScanPreviewSheet({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<ScanPreviewSheet> createState() => _ScanPreviewSheetState();
}

class _ScanPreviewSheetState extends State<ScanPreviewSheet> {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  final Random _random = Random();

  bool _processing = false;
  String? _error;
  bool _imageReady = false;

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ScanPreviewSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _imageReady = false;
    }
  }

  Future<void> _scan() async {
    if (_processing) return;
    final file = File(widget.imagePath);
    if (!file.existsSync()) {
      setState(() {
        _error = 'Image unavailable. Retake to continue.';
      });
      return;
    }

    setState(() {
      _processing = true;
      _error = null;
    });

    try {
      await Future.delayed(_randomProcessingDelay());
      final input = InputImage.fromFile(file);
      final result = await _textRecognizer.processImage(input);
      final sectionCode = extractSection(result.text);
      if (sectionCode == null) {
        throw Exception('Could not read your section code.');
      }

      final section = await _findSection(sectionCode);
      if (section == null) {
        throw Exception('No section found for "$sectionCode".');
      }

      final classes = await _loadClassesForSection(section.id);
      if (!mounted) return;
      Navigator.of(context).pop(
        ScanPreviewOutcome.success(
          section: section.toMap(),
          classes: classes.map((c) => c.toMap()).toList(),
          imagePath: widget.imagePath,
        ),
      );
    } catch (error, stack) {
      AppLog.error(_scope, 'OCR failed', error: error, stack: stack);
      if (!mounted) return;
      setState(() => _error = friendlyError(error.toString()));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Duration _randomProcessingDelay() {
    final millis = 2000 + _random.nextInt(2000);
    return Duration(milliseconds: millis);
  }

  Future<model.Section?> _findSection(String rawCode) async {
    String normalize(String value) =>
        value.toUpperCase().replaceAll(RegExp(r'\s+'), ' ').trim();

    final normalized = normalize(rawCode);
    final compact = normalized.replaceAll(' ', '');

    final direct = await Env.supa
        .from('sections')
        .select('id, code')
        .eq('code', normalized)
        .maybeSingle();
    if (direct is Map<String, dynamic>) {
      return model.Section.fromMap(direct);
    }

    String escape(String value) => value.replaceAll("'", "''");

    final patterns = <String>[
      normalized,
      if (normalized.contains(' ')) normalized.replaceAll(' ', '%'),
      if (compact != normalized) compact,
    ];

    final builder = patterns.length == 1
        ? Env.supa
            .from('sections')
            .select('id, code')
            .ilike('code', '%${escape(patterns.first)}%')
        : Env.supa.from('sections').select('id, code').or(
              patterns
                  .map((pattern) => 'code.ilike.%${escape(pattern)}%')
                  .join(','),
            );

    final response = await builder.limit(25);
    for (final row in asMapList(response)) {
      final dbCode = (row['code'] ?? '').toString();
      final dbNormalized = normalize(dbCode);
      if (dbNormalized.replaceAll(' ', '') == compact) {
        return model.Section.fromMap(row);
      }
    }

    return null;
  }

  Future<List<ScheduleClass>> _loadClassesForSection(int sectionId) async {
    final rows = await Env.supa
        .from('classes')
        .select(
          '''
id, section_id, day, start, end, code, title, room, units, instructor_id, instructors(full_name, avatar_url)
''',
        )
        .eq('section_id', sectionId)
        .order('day')
        .order('start');
    return (rows as List)
        .map((row) => ScheduleClass.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final media = MediaQuery.of(context);
    final spacing = AppTokens.spacing;
    final file = File(widget.imagePath);
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final cardBackground = elevatedCardBackground(theme, solid: true);
    final borderColor = elevatedCardBorder(theme, solid: true);
    final borderWidth = elevatedCardBorderWidth(theme);
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
                          title: 'Check your capture',
                          subtitle: 'Make sure the card details are readable before scanning.',
                          icon: Icons.qr_code_scanner_rounded,
                          onClose: () => Navigator.of(context).pop(),
                        ),
                      ),
                      // Preview content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: spacing.edgeInsetsOnly(
                            left: spacing.xl,
                            right: spacing.xl,
                            bottom: spacing.md,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Use standard ID card aspect ratio (85.6mm × 53.98mm ≈ 1.586:1)
                              AspectRatio(
                                aspectRatio: 1.586,
                                child: ClipRRect(
                                  borderRadius: AppTokens.radius.lg,
                                  child: file.existsSync()
                                      ? Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            if (!_imageReady)
                                              Center(
                                                child: CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<Color>(
                                                    colors.primary,
                                                  ),
                                                ),
                                              ),
                                            Positioned.fill(
                                              child: Image.file(
                                                file,
                                                fit: BoxFit.cover,
                                                gaplessPlayback: true,
                                                frameBuilder: (context, child, frame,
                                                    wasSynchronouslyLoaded) {
                                                  if (frame != null &&
                                                      !_imageReady &&
                                                      mounted) {
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback((_) {
                                                      if (mounted) {
                                                        setState(() => _imageReady = true);
                                                      }
                                                    });
                                                  }
                                                  return AnimatedOpacity(
                                                    opacity: frame == null ? 0 : 1,
                                                    duration: AppMotionSystem.standard,
                                                    curve: AppMotionSystem.easeInOut,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(
                                          alignment: Alignment.center,
                                          color: colors.surfaceContainerHigh,
                                          child: Text(
                                            'Image unavailable. Retake to continue.',
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: palette.danger,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              if (_error != null) ...[
                                SizedBox(height: spacing.lg),
                                StateDisplay(
                                  variant: StateVariant.error,
                                  title: 'Scan failed',
                                  message: _error!,
                                  primaryActionLabel: 'Retry',
                                  onPrimaryAction: _processing ? null : _scan,
                                  secondaryActionLabel: 'Retake',
                                  onSecondaryAction: _processing
                                      ? null
                                      : () => Navigator.of(context)
                                          .pop(const ScanPreviewOutcome.retake()),
                                  compact: true,
                                ),
                              ],
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
                                  ? colors.outline.withValues(alpha: AppOpacity.overlay)
                                  : colors.outlineVariant.withValues(alpha: AppOpacity.ghost),
                              width: AppTokens.componentSize.dividerThin,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                onPressed:
                                    _processing || !file.existsSync() ? null : _scan,
                                label: _processing ? 'Scanning...' : 'Scan',
                                icon: _processing
                                    ? null
                                    : Icons.qr_code_scanner_rounded,
                                leading: _processing
                                    ? SizedBox(
                                        width: AppTokens.componentSize.badgeMd,
                                        height: AppTokens.componentSize.badgeMd,
                                        child: CircularProgressIndicator(
                                          strokeWidth: AppTokens.componentSize.progressStroke,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            colors.onPrimary,
                                          ),
                                        ),
                                      )
                                    : null,
                                minHeight: AppTokens.componentSize.buttonMd,
                              ),
                            ),
                            SizedBox(width: spacing.md),
                            Expanded(
                              child: SecondaryButton(
                                onPressed: _processing
                                    ? null
                                    : () => Navigator.of(context)
                                        .pop(const ScanPreviewOutcome.retake()),
                                label: 'Retake',
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
