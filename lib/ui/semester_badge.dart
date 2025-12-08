import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/semester.dart';
import '../services/semester_service.dart';
import '../services/user_scope.dart';
import 'theme/tokens.dart';

/// A widget that displays the user's section and active semester as separate badges.
class SemesterBadge extends StatefulWidget {
  const SemesterBadge({
    super.key,
    this.compact = false,
  });

  /// If true, uses smaller text and padding.
  final bool compact;

  @override
  State<SemesterBadge> createState() => _SemesterBadgeState();
}

class _SemesterBadgeState extends State<SemesterBadge> {
  Semester? _semester;
  String? _sectionCode;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final semester = await SemesterService.instance.getActiveSemester();
    final sectionCode = await _fetchUserSectionCode();
    if (mounted) {
      setState(() {
        _semester = semester;
        _sectionCode = sectionCode;
        _loading = false;
      });
    }
  }

  Future<String?> _fetchUserSectionCode() async {
    final uid = UserScope.currentUserId();
    if (uid == null) return null;

    try {
      final res = await Supabase.instance.client
          .from('user_sections')
          .select('sections(code)')
          .eq('user_id', uid)
          .order('added_at', ascending: false)
          .limit(1);

      final list = (res as List?) ?? const [];
      if (list.isEmpty) return null;

      final row = Map<String, dynamic>.from(list.first as Map);
      final sectionsData = row['sections'];
      if (sectionsData is Map) {
        return sectionsData['code'] as String?;
      } else if (sectionsData is List && sectionsData.isNotEmpty) {
        return (sectionsData.first as Map)['code'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final spacing = AppTokens.spacing;

    if (_loading) {
      return SizedBox(
        height: widget.compact
            ? AppTokens.componentSize.badgeMd
            : AppTokens.componentSize.badgeLg,
        child: Center(
          child: SizedBox(
            width: AppTokens.iconSize.sm,
            height: AppTokens.iconSize.sm,
            child: CircularProgressIndicator(
              strokeWidth: AppTokens.componentSize.dividerMedium,
              color: palette.muted,
            ),
          ),
        ),
      );
    }

    final hasSection = _sectionCode != null && _sectionCode!.isNotEmpty;
    final hasSemester = _semester != null;

    if (!hasSection && !hasSemester) {
      return const SizedBox.shrink();
    }

    final textStyle = widget.compact
        ? AppTokens.typography.caption
        : AppTokens.typography.bodySecondary;

    Widget buildBadge({
      required String text,
      required IconData icon,
      required Color color,
    }) {
      return Container(
        padding: spacing.edgeInsetsSymmetric(
          horizontal: widget.compact ? spacing.sm : spacing.md,
          vertical: widget.compact ? spacing.xs : spacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: AppOpacity.statusBg),
          borderRadius: AppTokens.radius.sm,
          border: Border.all(
            color: color.withValues(alpha: AppOpacity.overlay),
            width: AppTokens.componentSize.dividerThin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: widget.compact
                  ? AppTokens.iconSize.xs
                  : AppTokens.iconSize.sm,
              color: color,
            ),
            SizedBox(width: spacing.xs),
            Text(
              text,
              style: textStyle.copyWith(
                color: color,
                fontWeight: AppTokens.fontWeight.semiBold,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        if (hasSection)
          buildBadge(
            text: _sectionCode!,
            icon: Icons.groups_rounded,
            color: colors.primary,
          ),
        if (hasSection && hasSemester) SizedBox(width: spacing.sm),
        if (hasSemester)
          buildBadge(
            text: _semester!.name,
            icon: Icons.calendar_today_rounded,
            color: palette.info,
          ),
      ],
    );
  }
}

