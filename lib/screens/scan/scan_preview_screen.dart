import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../env.dart';
import '../../models/schedule_class.dart';
import '../../models/section.dart' as model;
import '../../services/semester_service.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/motion.dart';
import '../../ui/theme/tokens.dart';
import '../../utils/app_log.dart';
import '../../utils/errors.dart';
import '../../utils/formatters.dart';
import '../../utils/image_preprocessing.dart';
import '../../utils/section_matching.dart';
import '../../utils/supabase_client.dart';
import 'scan_error_modal.dart';

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
  bool _imageReady = false;
  String? _error;
  String? _enhancedImagePath;

  @override
  void dispose() {
    _textRecognizer.close();
    // Cleanup enhanced image if exists
    if (_enhancedImagePath != null) {
      ImagePreprocessor.cleanup(_enhancedImagePath!);
    }
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
      // Show error modal for missing image
      final action = await ScanErrorModal.show(
        context,
        errorMessage: 'Image unavailable. Retake to continue.',
      );
      if (!mounted) return;
      if (action == ScanErrorAction.retake) {
        Navigator.of(context).pop(const ScanPreviewOutcome.retake());
      }
      return;
    }

    setState(() {
      _processing = true;
      _error = null; // Clear previous error
    });

    try {
      await Future.delayed(_randomProcessingDelay());

      // Check for low-light conditions
      final isLowLight = await ImagePreprocessor.detectLowLight(widget.imagePath);

      // Preprocess image for better OCR (especially in low-light)
      File imageToProcess = file;
      final enhancedPath = await ImagePreprocessor.enhanceForOcr(widget.imagePath);
      if (enhancedPath != null) {
        _enhancedImagePath = enhancedPath;
        imageToProcess = File(enhancedPath);
        AppLog.debug(_scope, 'Using enhanced image for OCR');
      }

      final input = InputImage.fromFile(imageToProcess);
      final result = await _textRecognizer.processImage(input);
      
      // Try to extract section from enhanced image first
      var sectionCode = extractSection(result.text);
      
      // If enhanced image failed and we have original, try original
      if (sectionCode == null && enhancedPath != null) {
        AppLog.debug(_scope, 'Enhanced OCR failed, trying original image');
        final originalInput = InputImage.fromFile(file);
        final originalResult = await _textRecognizer.processImage(originalInput);
        sectionCode = extractSection(originalResult.text);
      }
      
      if (sectionCode == null) {
        throw Exception(
          isLowLight
            ? 'Section not found. Try better lighting.'
            : 'Section not found. Please retake.',
        );
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
      setState(() {
        _processing = false;
        _error = friendlyError(error.toString());
      });
    }
  }

  Duration _randomProcessingDelay() {
    final millis = 2000 + _random.nextInt(2000);
    return Duration(milliseconds: millis);
  }

  Future<model.Section?> _findSection(String rawCode) async {
    // Try to get multiple matches and pick the best one
    final matches = await _findSectionMatches(rawCode);
    if (matches.isEmpty) return null;
    
    // Return the best match
    final best = matches.first;
    AppLog.debug(_scope, 'Best match: ${best.code} (${(best.similarity * 100).toInt()}% similarity)');
    
    return model.Section(id: best.id, code: best.code);
  }

  /// Finds all section matches in the database with similarity scoring.
  /// Returns matches sorted by similarity (best first).
  Future<List<SectionMatch>> _findSectionMatches(String rawCode) async {
    String normalize(String value) =>
        value.toUpperCase().replaceAll(RegExp(r'\s+'), ' ').trim();

    final normalized = normalize(rawCode);
    final compact = normalized.replaceAll(' ', '');

    // Get active semester ID to filter sections
    final semesterId = await SemesterService.instance.getActiveSemesterId();
    if (semesterId == null) {
      AppLog.warn(_scope, 'No active semester found for section lookup');
      return [];
    }

    // Direct match with semester filter (exact match - highest priority)
    final direct = await Env.supa
        .from('sections')
        .select('id, code')
        .eq('code', normalized)
        .eq('semester_id', semesterId)
        .maybeSingle();
    if (direct is Map<String, dynamic>) {
      return [SectionMatch(
        id: (direct['id'] as num).toInt(),
        code: direct['code'].toString(),
        similarity: 1.0,
        isExactMatch: true,
      )];
    }

    String escape(String value) => value.replaceAll("'", "''");

    // Build broader search patterns for fuzzy matching
    final patterns = <String>[
      '%${escape(normalized)}%',
      if (normalized.contains(' ')) '%${escape(normalized.replaceAll(' ', '%'))}%',
      if (compact != normalized) '%${escape(compact)}%',
    ];
    
    // Also search for just the course code prefix (for partial matches)
    final courseMatch = RegExp(r'^([A-Z]+(?:\s+[A-Z]+)?)').firstMatch(normalized);
    if (courseMatch != null) {
      final courseCode = courseMatch.group(1)!;
      if (courseCode.length >= 2) {
        patterns.add('%${escape(courseCode)}%');
      }
    }

    // Fuzzy match with semester filter
    final builder = Env.supa
        .from('sections')
        .select('id, code')
        .eq('semester_id', semesterId)
        .or(patterns.map((p) => 'code.ilike.$p').join(','));

    final response = await builder.limit(50);
    final rows = asMapList(response);
    
    if (rows.isEmpty) return [];
    
    // Rank matches using Levenshtein distance
    final matches = rankSectionMatches(normalized, rows);
    
    AppLog.debug(_scope, 'Found ${matches.length} section matches for "$rawCode"');
    return matches;
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
    final spacing = AppTokens.spacing;
    final file = File(widget.imagePath);
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final cardBackground =
        isDark ? colors.surfaceContainerHigh : colors.surface;

    return ModalShell(
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
              subtitle:
                  'Make sure the card details are readable before scanning.',
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
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Background or image
                                      if (file.existsSync()) ...[
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
                                      ] else
                                        Container(
                                          alignment: Alignment.center,
                                          color: colors.surfaceContainerHigh,
                                          child: Text(
                                            'Image unavailable. Retake to continue.',
                                            textAlign: TextAlign.center,
                                            style: AppTokens.typography.body.copyWith(
                                              color: palette.danger,
                                            ),
                                          ),
                                        ),
                                      // Error overlay - compact with animation
                                      if (_error != null)
                                        Positioned.fill(
                                          child: TweenAnimationBuilder<double>(
                                            duration: AppMotionSystem.standard,
                                            curve: AppMotionSystem.easeOut,
                                            tween: Tween(begin: 0.0, end: 1.0),
                                            builder: (context, value, child) {
                                              return Opacity(
                                                opacity: value,
                                                child: Transform.scale(
                                                  scale: 0.95 + (0.05 * value),
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: cardBackground,
                                              ),
                                              child: Padding(
                                                padding: spacing.edgeInsetsSymmetric(
                                                  horizontal: spacing.lg,
                                                  vertical: spacing.md,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    // Compact error icon
                                                    Container(
                                                      width: AppTokens.componentSize.stateIconCompact,
                                                      height: AppTokens.componentSize.stateIconCompact,
                                                      decoration: BoxDecoration(
                                                        color: palette.danger.withValues(alpha: AppOpacity.ghost),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.error_outline_rounded,
                                                        size: AppTokens.componentSize.stateIconInnerCompact,
                                                        color: palette.danger,
                                                      ),
                                                    ),
                                                    SizedBox(height: spacing.md),
                                                    // Title
                                                    Text(
                                                      'Scan failed',
                                                      style: AppTokens.typography.subtitle.copyWith(
                                                        fontWeight: AppTokens.fontWeight.semiBold,
                                                        color: colors.onSurface,
                                                      ),
                                                    ),
                                                    SizedBox(height: spacing.xs),
                                                    // Message
                                                    Text(
                                                      _error!,
                                                      textAlign: TextAlign.center,
                                                      style: AppTokens.typography.caption.copyWith(
                                                        color: colors.onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
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
                                label: _processing 
                                    ? 'Scanning...' 
                                    : _error != null 
                                        ? 'Retry' 
                                        : 'Scan',
                                icon: _processing
                                    ? null
                                    : _error != null
                                        ? Icons.refresh_rounded
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
    );
  }
}
