import 'package:flutter/material.dart';

import '../../env.dart';
import '../../models/schedule_class.dart';
import '../../models/section.dart' as model;
import '../../services/semester_service.dart';
import '../../ui/kit/kit.dart';
import '../../ui/theme/tokens.dart';
import '../../utils/app_log.dart';

const _scope = 'ManualSectionEntry';

/// Result from manual section entry.
class ManualEntryResult {
  const ManualEntryResult({
    required this.section,
    required this.classes,
  });

  final model.Section section;
  final List<ScheduleClass> classes;
}

/// A bottom sheet for manually entering a section code when OCR fails.
class ManualSectionEntrySheet extends StatefulWidget {
  const ManualSectionEntrySheet({super.key});

  /// Shows the sheet and returns the result, or null if cancelled.
  static Future<ManualEntryResult?> show(BuildContext context) {
    return AppModal.sheet<ManualEntryResult>(
      context: context,
      builder: (_) => const ManualSectionEntrySheet(),
    );
  }

  @override
  State<ManualSectionEntrySheet> createState() => _ManualSectionEntrySheetState();
}

class _ManualSectionEntrySheetState extends State<ManualSectionEntrySheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  
  List<model.Section> _suggestions = [];
  bool _loading = false;
  String? _error;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _loadPopularSections();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadPopularSections() async {
    try {
      final semesterId = await SemesterService.instance.getActiveSemesterId();
      if (semesterId == null) return;

      final rows = await Env.supa
          .from('sections')
          .select('id, code')
          .eq('semester_id', semesterId)
          .order('code')
          .limit(20);

      if (!mounted) return;
      setState(() {
        _suggestions = (rows as List)
            .map((r) => model.Section.fromMap(r as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      AppLog.error(_scope, 'Failed to load sections', error: e);
    }
  }

  Future<void> _search(String query) async {
    if (query.length < 2) {
      _loadPopularSections();
      return;
    }

    setState(() => _searching = true);

    try {
      final semesterId = await SemesterService.instance.getActiveSemesterId();
      if (semesterId == null) return;

      final escaped = query.replaceAll("'", "''").toUpperCase();
      final rows = await Env.supa
          .from('sections')
          .select('id, code')
          .eq('semester_id', semesterId)
          .ilike('code', '%$escaped%')
          .order('code')
          .limit(20);

      if (!mounted) return;
      setState(() {
        _suggestions = (rows as List)
            .map((r) => model.Section.fromMap(r as Map<String, dynamic>))
            .toList();
        _searching = false;
      });
    } catch (e) {
      AppLog.error(_scope, 'Search failed', error: e);
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _selectSection(model.Section section) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Load classes for the selected section
      final rows = await Env.supa
          .from('classes')
          .select('''
id, section_id, day, start, end, code, title, room, units, instructor_id, instructors(full_name, avatar_url)
''')
          .eq('section_id', section.id)
          .order('day')
          .order('start');

      final classes = (rows as List)
          .map((r) => ScheduleClass.fromMap(r as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      Navigator.of(context).pop(ManualEntryResult(
        section: section,
        classes: classes,
      ));
    } catch (e) {
      AppLog.error(_scope, 'Failed to load classes', error: e);
      if (mounted) {
        setState(() {
          _error = 'Failed to load classes. Try again.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: AppTokens.componentSize.sheetMaxHeight),
        padding: spacing.edgeInsetsAll(spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.edit_outlined, color: colors.primary),
                SizedBox(width: spacing.sm),
                Text(
                  'Enter Section Code',
                  style: AppTokens.typography.title.copyWith(
                    fontWeight: AppTokens.fontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: spacing.md),

            // Search field
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'e.g., BSCS 3-1 or BS IT 4-2',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searching
                    ? Padding(
                        padding: spacing.edgeInsetsAll(spacing.sm),
                        child: SizedBox(
                          width: AppTokens.componentSize.spinnerSm,
                          height: AppTokens.componentSize.spinnerSm,
                          child: CircularProgressIndicator(
                            strokeWidth:
                                AppTokens.componentSize.progressStroke,
                          ),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: AppTokens.radius.sm,
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: _search,
            ),
            SizedBox(height: spacing.md),

            // Error message
            if (_error != null)
              Padding(
                padding: EdgeInsets.only(bottom: spacing.sm),
                child: Text(
                  _error!,
                  style: AppTokens.typography.caption.copyWith(
                    color: colors.error,
                  ),
                ),
              ),

            // Loading indicator
            if (_loading)
              Center(
                child: Padding(
                  padding: spacing.edgeInsetsAll(spacing.lg),
                  child: const CircularProgressIndicator(),
                ),
              )
            else ...[
              // Section list header
              Text(
                _controller.text.isEmpty ? 'Available Sections' : 'Matching Sections',
                style: AppTokens.typography.caption.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: spacing.sm),

              // Section list
              Flexible(
                child: _suggestions.isEmpty
                    ? Center(
                        child: Padding(
                          padding: spacing.edgeInsetsAll(spacing.lg),
                          child: Text(
                            'No sections found',
                            style: AppTokens.typography.body.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final section = _suggestions[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colors.primaryContainer,
                              child: Text(
                                section.code.substring(0, 1),
                                style: AppTokens.typography.caption.copyWith(
                                  color: colors.onPrimaryContainer,
                                  fontWeight: AppTokens.fontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(section.code),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _selectSection(section),
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
