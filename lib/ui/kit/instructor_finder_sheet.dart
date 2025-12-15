// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../env.dart';
import '../../widgets/instructor_avatar.dart';
import '../kit/kit.dart';
import '../theme/tokens.dart';

/// A modal sheet for finding an instructor and viewing their current schedule.
/// 
/// Students can use this to locate professors by seeing their current class and room.
class InstructorFinderSheet extends StatefulWidget {
  const InstructorFinderSheet({super.key});

  @override
  State<InstructorFinderSheet> createState() => _InstructorFinderSheetState();
}

class _InstructorFinderSheetState extends State<InstructorFinderSheet> {
  late Future<List<_InstructorInfo>> _instructorsFuture;
  _InstructorInfo? _selectedInstructor;
  List<_ScheduleItem>? _selectedSchedule;
  bool _loadingSchedule = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _instructorsFuture = _loadInstructors();
  }

  Future<List<_InstructorInfo>> _loadInstructors() async {
    try {
      final userId = Env.supa.auth.currentUser?.id;
      if (userId == null) return [];

      // Get user's section codes (e.g., "BSCS", "BSIT", etc.)
      final sectionRows = await Env.supa
          .from('user_sections')
          .select('sections(code)')
          .eq('user_id', userId);
      
      final sectionCodes = (sectionRows as List)
          .map((r) => (r['sections'] as Map?)?['code'] as String?)
          .where((code) => code != null && code.isNotEmpty)
          .toSet()
          .toList();
      
      if (sectionCodes.isEmpty) return [];

      // Map section codes to departments
      // BSCS, BSIT, BSIS, ACT -> CSIT
      // Add more mappings as needed
      final departments = <String>{};
      for (final code in sectionCodes) {
        final dept = _sectionToDepartment(code!);
        if (dept != null) departments.add(dept);
      }
      
      if (departments.isEmpty) return [];

      // Get all instructors from matching departments
      final rows = await Env.supa
          .from('instructors')
          .select('id, full_name, email, avatar_url, department')
          .inFilter('department', departments.toList())
          .order('full_name');
      
      final list = (rows as List).cast<Map<String, dynamic>>();
      return list.map((json) => _InstructorInfo(
        id: json['id'] as String,
        fullName: json['full_name'] as String? ?? 'Unknown',
        email: json['email'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        department: json['department'] as String?,
      )).toList();
    } catch (e) {
      return [];
    }
  }

  /// Maps section code to department name
  String? _sectionToDepartment(String sectionCode) {
    final code = sectionCode.toUpperCase();
    // CSIT department
    if (code.startsWith('BSCS') || 
        code.startsWith('BSIT') || 
        code.startsWith('BSIS') || 
        code.startsWith('ACT')) {
      return 'CSIT';
    }
    // Add more department mappings as needed
    // Example:
    // if (code.startsWith('BSA') || code.startsWith('BSMA')) return 'Accountancy';
    // if (code.startsWith('BSCRIM')) return 'Criminology';
    return null;
  }

  Future<void> _selectInstructor(_InstructorInfo instructor) async {
    setState(() {
      _selectedInstructor = instructor;
      _loadingSchedule = true;
      _selectedSchedule = null;
    });

    try {
      // Get day of week - database uses 'Mon', 'Tue', etc.
      final now = DateTime.now();
      final dayName = DateFormat('E').format(now); // 'Mon', 'Tue', etc.

      final rows = await Env.supa
          .from('instructor_schedule')
          .select()
          .eq('instructor_id', instructor.id)
          .eq('semester_active', true)
          .eq('day', dayName)
          .order('start', ascending: true);

      final list = (rows as List).cast<Map<String, dynamic>>();
      final schedule = list.map((json) {
        final startStr = json['start'] as String? ?? '00:00';
        final endStr = json['end'] as String? ?? '00:00';
        
        return _ScheduleItem(
          subject: json['title'] as String? ?? 'Unknown',
          code: json['code'] as String? ?? '',
          room: json['room'] as String? ?? '',
          startTime: _parseTime(startStr),
          endTime: _parseTime(endStr),
          sectionCode: json['section_code'] as String?,
          sectionNumber: json['section_number'] as String?,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _selectedSchedule = schedule;
          _loadingSchedule = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _selectedSchedule = [];
          _loadingSchedule = false;
        });
      }
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
  }

  /// Format remaining time until class ends (e.g., "ends in 30m")
  String _formatTimeRemaining(TimeOfDay endTime, DateTime now) {
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final nowMinutes = now.hour * 60 + now.minute;
    final remaining = endMinutes - nowMinutes;
    
    if (remaining <= 0) return 'ending';
    if (remaining < 60) return 'ends in ${remaining}m';
    final hours = remaining ~/ 60;
    final mins = remaining % 60;
    if (mins == 0) return 'ends in ${hours}h';
    return 'ends in ${hours}h ${mins}m';
  }

  void _goBack() {
    setState(() {
      _selectedInstructor = null;
      _selectedSchedule = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DetailShell(
      useBubbleShadow: true,
      child: _selectedInstructor == null
          ? _buildInstructorList(context)
          : _buildScheduleView(context),
    );
  }

  /// Skeleton loading for instructor list - matches _InstructorTile structure
  Widget _buildInstructorListSkeleton(BuildContext context) {
    final spacing = AppTokens.spacing;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    Widget buildTileSkeleton() {
      return Container(
        padding: spacing.edgeInsetsAll(spacing.md * spacingScale),
        decoration: BoxDecoration(
          color: isDark ? colors.surfaceContainerHigh : colors.surfaceContainerLow,
          borderRadius: AppTokens.radius.md,
        ),
        child: Row(
          children: [
            SkeletonCircle(size: AppTokens.componentSize.avatarMd * scale),
            SizedBox(width: spacing.md * spacingScale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBlock(
                    height: AppTokens.componentSize.skeletonTextMd * scale,
                    width: AppTokens.componentSize.skeletonWidthXl * scale,
                    borderRadius: AppTokens.radius.sm,
                  ),
                  SizedBox(height: spacing.xs * spacingScale),
                  SkeletonBlock(
                    height: AppTokens.componentSize.skeletonTextSm * scale,
                    width: AppTokens.componentSize.skeletonWidthMd * scale,
                    borderRadius: AppTokens.radius.sm,
                  ),
                ],
              ),
            ),
            SkeletonBlock(
              height: AppTokens.iconSize.md * scale,
              width: AppTokens.iconSize.md * scale,
              borderRadius: AppTokens.radius.sm,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < 5; i++) ...[
          buildTileSkeleton(),
          if (i < 4) SizedBox(height: spacing.sm * spacingScale),
        ],
      ],
    );
  }

  /// Skeleton loading for schedule view - matches schedule structure
  Widget _buildScheduleSkeleton(BuildContext context) {
    final spacing = AppTokens.spacing;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status card skeleton
        Container(
          padding: spacing.edgeInsetsAll(spacing.lg * spacingScale),
          decoration: BoxDecoration(
            color: palette.muted.withValues(alpha: AppOpacity.dim),
            borderRadius: AppTokens.radius.md,
          ),
          child: Row(
            children: [
              SkeletonBlock(
                height: AppTokens.componentSize.badgeLg * scale,
                width: AppTokens.componentSize.badgeLg * scale,
                borderRadius: AppTokens.radius.sm,
              ),
              SizedBox(width: spacing.md * spacingScale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBlock(
                      height: AppTokens.componentSize.skeletonTextSm * scale,
                      width: AppTokens.componentSize.skeletonWidthMd * scale,
                      borderRadius: AppTokens.radius.pill,
                    ),
                    SizedBox(height: spacing.sm * spacingScale),
                    SkeletonBlock(
                      height: AppTokens.componentSize.skeletonTextMd * scale,
                      width: AppTokens.componentSize.skeletonWidthXl * scale,
                      borderRadius: AppTokens.radius.sm,
                    ),
                    SizedBox(height: spacing.xs * spacingScale),
                    SkeletonBlock(
                      height: AppTokens.componentSize.skeletonTextSm * scale,
                      width: AppTokens.componentSize.skeletonWidthLg * scale,
                      borderRadius: AppTokens.radius.sm,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.xl * spacingScale),

        // Date header skeleton
        Row(
          children: [
            SkeletonBlock(
              height: AppTokens.iconSize.sm * scale,
              width: AppTokens.iconSize.sm * scale,
              borderRadius: AppTokens.radius.sm,
            ),
            SizedBox(width: spacing.sm * spacingScale),
            SkeletonBlock(
              height: AppTokens.componentSize.skeletonTextSm * scale,
              width: AppTokens.componentSize.skeletonWidthLg * scale,
              borderRadius: AppTokens.radius.sm,
            ),
          ],
        ),
        SizedBox(height: spacing.lg * spacingScale),

        // Schedule items skeleton
        for (int i = 0; i < 4; i++) ...[
          Container(
            padding: spacing.edgeInsetsAll(spacing.md * spacingScale),
            decoration: BoxDecoration(
              color: isDark ? colors.surfaceContainerHigh : colors.surfaceContainerLow,
              borderRadius: AppTokens.radius.md,
            ),
            child: Row(
              children: [
                SkeletonCircle(size: AppTokens.componentSize.badgeSm * scale),
                SizedBox(width: spacing.md * spacingScale),
                SkeletonBlock(
                  height: AppTokens.componentSize.skeletonTextSm * scale,
                  width: AppTokens.componentSize.skeletonWidthMd * scale,
                  borderRadius: AppTokens.radius.sm,
                ),
                SizedBox(width: spacing.sm * spacingScale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBlock(
                        height: AppTokens.componentSize.skeletonTextMd * scale,
                        width: AppTokens.componentSize.skeletonWidthXl * scale,
                        borderRadius: AppTokens.radius.sm,
                      ),
                      SizedBox(height: spacing.xs * spacingScale),
                      SkeletonBlock(
                        height: AppTokens.componentSize.skeletonTextSm * scale,
                        width: AppTokens.componentSize.skeletonWidthMd * scale,
                        borderRadius: AppTokens.radius.sm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (i < 3) SizedBox(height: spacing.sm * spacingScale),
        ],
      ],
    );
  }

  Widget _buildInstructorList(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        SheetHeaderRow(
          icon: Icons.search_rounded,
          title: 'Find Instructor',
          subtitle: 'See where a professor is right now',
          onClose: () => Navigator.of(context).pop(),
        ),
        SizedBox(height: spacing.lg * spacingScale),
        
        // Search bar
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search instructors...',
            prefixIcon: Icon(Icons.search, size: AppTokens.iconSize.md * scale),
            filled: true,
            fillColor: isDark 
                ? colors.surfaceContainerHighest 
                : colors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: AppTokens.radius.md,
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: spacing.lg * spacingScale,
              vertical: spacing.md * spacingScale,
            ),
          ),
        ),
        SizedBox(height: spacing.lg * spacingScale),
        
        // Instructor list
        Flexible(
          child: FutureBuilder<List<_InstructorInfo>>(
            future: _instructorsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return _buildInstructorListSkeleton(context);
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No instructors found',
                    style: AppTokens.typography.bodyScaled(scale).copyWith(color: palette.muted),
                  ),
                );
              }

              final instructors = snapshot.data!
                  .where((i) => _searchQuery.isEmpty || 
                      i.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (i.department?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
                  .toList();

              if (instructors.isEmpty) {
                return Center(
                  child: Text(
                    'No matching instructors',
                    style: AppTokens.typography.bodyScaled(scale).copyWith(color: palette.muted),
                  ),
                );
              }

              // Group by department
              final grouped = <String, List<_InstructorInfo>>{};
              for (final instructor in instructors) {
                final dept = instructor.department ?? 'Other';
                grouped.putIfAbsent(dept, () => []).add(instructor);
              }
              final departments = grouped.keys.toList()..sort();

              return ListView.builder(
                shrinkWrap: true,
                itemCount: departments.length,
                itemBuilder: (context, deptIndex) {
                  final dept = departments[deptIndex];
                  final deptInstructors = grouped[dept]!;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (deptIndex > 0) SizedBox(height: spacing.lg * spacingScale),
                      // Department header
                      Padding(
                        padding: EdgeInsets.only(bottom: spacing.sm * spacingScale),
                        child: Text(
                          dept.toUpperCase(),
                          style: AppTokens.typography.captionScaled(scale).copyWith(
                            fontWeight: AppTokens.fontWeight.bold,
                            color: palette.muted,
                          ),
                        ),
                      ),
                      // Instructors in department
                      ...deptInstructors.map((instructor) => Padding(
                        padding: EdgeInsets.only(bottom: spacing.sm * spacingScale),
                        child: _InstructorTile(
                          instructor: instructor,
                          onTap: () => _selectInstructor(instructor),
                        ),
                      )),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleView(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);
    final instructor = _selectedInstructor!;
    final now = DateTime.now();
    final todayLabel = DateFormat('EEEE, MMMM d').format(now);

    // Find current class
    _ScheduleItem? currentClass;
    if (_selectedSchedule != null) {
      final nowMinutes = now.hour * 60 + now.minute;
      for (final item in _selectedSchedule!) {
        final startMinutes = item.startTime.hour * 60 + item.startTime.minute;
        final endMinutes = item.endTime.hour * 60 + item.endTime.minute;
        if (nowMinutes >= startMinutes && nowMinutes < endMinutes) {
          currentClass = item;
          break;
        }
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with back button and instructor info
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back button - matching SheetHeaderRow close button style
            PressableScale(
              onTap: _goBack,
              child: Container(
                padding: EdgeInsets.all(spacing.sm * spacingScale),
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: AppOpacity.faint),
                  borderRadius: AppTokens.radius.md,
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: AppTokens.iconSize.md * scale,
                  color: palette.muted,
                ),
              ),
            ),
            SizedBox(width: spacing.md * spacingScale),
            // Avatar
            InstructorAvatar(
              name: instructor.fullName,
              avatarUrl: instructor.avatarUrl,
              tint: colors.primary,
              size: AppTokens.componentSize.avatarMd * scale,
            ),
            SizedBox(width: spacing.md * spacingScale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    instructor.fullName,
                    style: AppTokens.typography.subtitleScaled(scale).copyWith(
                      fontWeight: AppTokens.fontWeight.bold,
                      color: colors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (instructor.department != null)
                    Text(
                      instructor.department!,
                      style: AppTokens.typography.captionScaled(scale).copyWith(
                        color: palette.muted,
                      ),
                    ),
                ],
              ),
            ),
            // Close button - matching SheetHeaderRow exactly
            PressableScale(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.all(spacing.sm * spacingScale),
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: AppOpacity.faint),
                  borderRadius: AppTokens.radius.md,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: AppTokens.iconSize.md * scale,
                  color: palette.muted,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.xl * spacingScale),

        // Loading state
        if (_loadingSchedule) ...[
          _buildScheduleSkeleton(context),
        ] else ...[
          // Current status
          Container(
            padding: spacing.edgeInsetsAll(spacing.lg * spacingScale),
            decoration: BoxDecoration(
              color: currentClass != null
                  ? colors.primary.withValues(alpha: AppOpacity.medium)
                  : palette.muted.withValues(alpha: AppOpacity.dim),
              borderRadius: AppTokens.radius.md,
            ),
            child: Row(
              children: [
                Container(
                  width: AppTokens.componentSize.badgeLg * scale,
                  height: AppTokens.componentSize.badgeLg * scale,
                  decoration: BoxDecoration(
                    color: currentClass != null
                        ? colors.primary
                        : palette.muted.withValues(alpha: AppOpacity.dim),
                    borderRadius: AppTokens.radius.sm,
                  ),
                  child: Icon(
                    currentClass != null
                        ? Icons.class_outlined
                        : Icons.event_busy_outlined,
                    size: AppTokens.iconSize.sm * scale,
                    color: currentClass != null
                        ? colors.onPrimary
                        : palette.muted,
                  ),
                ),
                SizedBox(width: spacing.md * spacingScale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            currentClass != null ? 'TEACHING NOW' : 'NOT IN CLASS',
                            style: AppTokens.typography.captionScaled(scale).copyWith(
                              fontWeight: AppTokens.fontWeight.bold,
                              color: currentClass != null
                                  ? colors.primary
                                  : palette.muted,
                            ),
                          ),
                          if (currentClass != null) ...[
                            const Spacer(),
                            // Countdown badge - positioned on right
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing.sm * spacingScale,
                                vertical: spacing.xs * spacingScale,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: AppOpacity.dim),
                                borderRadius: AppTokens.radius.pill,
                              ),
                              child: Text(
                                _formatTimeRemaining(currentClass.endTime, now),
                                style: AppTokens.typography.captionScaled(scale).copyWith(
                                  fontWeight: AppTokens.fontWeight.semiBold,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (currentClass != null) ...[
                        SizedBox(height: spacing.xs * spacingScale),
                        Text(
                          currentClass.subject,
                          style: AppTokens.typography.subtitleScaled(scale).copyWith(
                            fontWeight: AppTokens.fontWeight.semiBold,
                            color: colors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: AppTokens.iconSize.xs * scale,
                              color: colors.primary,
                            ),
                            SizedBox(width: spacing.xs * spacingScale),
                            Text(
                              currentClass.room,
                              style: AppTokens.typography.bodyScaled(scale).copyWith(
                                color: palette.muted,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        SizedBox(height: spacing.xs * spacingScale),
                        Text(
                          'No class at this time',
                          style: AppTokens.typography.bodyScaled(scale).copyWith(
                            color: palette.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.xl * spacingScale),

          // Today's schedule header
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: AppTokens.iconSize.sm * scale,
                color: palette.muted,
              ),
              SizedBox(width: spacing.sm * spacingScale),
              Text(
                todayLabel,
                style: AppTokens.typography.captionScaled(scale).copyWith(
                  fontWeight: AppTokens.fontWeight.semiBold,
                  color: palette.muted,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md * spacingScale),

          // Schedule list
          if (_selectedSchedule == null || _selectedSchedule!.isEmpty) ...[
            Container(
              padding: spacing.edgeInsetsAll(spacing.xxl * spacingScale),
              decoration: BoxDecoration(
                color: isDark 
                    ? colors.surfaceContainerHighest 
                    : colors.surfaceContainerLow,
                borderRadius: AppTokens.radius.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppTokens.componentSize.avatarXl * scale,
                    height: AppTokens.componentSize.avatarXl * scale,
                    decoration: BoxDecoration(
                      color: palette.muted.withValues(alpha: AppOpacity.dim),
                      borderRadius: AppTokens.radius.md,
                    ),
                    child: Icon(
                      Icons.event_busy_outlined,
                      size: AppTokens.iconSize.lg * scale,
                      color: palette.muted,
                    ),
                  ),
                  SizedBox(height: spacing.md * spacingScale),
                  Text(
                    'No classes scheduled today',
                    style: AppTokens.typography.bodyScaled(scale).copyWith(
                      fontWeight: AppTokens.fontWeight.medium,
                      color: colors.onSurface,
                    ),
                  ),
                  SizedBox(height: spacing.xs * spacingScale),
                  Text(
                    'This instructor has no classes on $todayLabel',
                    style: AppTokens.typography.captionScaled(scale).copyWith(
                      color: palette.muted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _selectedSchedule!.length,
                separatorBuilder: (_, __) => SizedBox(height: spacing.sm * spacingScale),
                itemBuilder: (context, index) {
                  final item = _selectedSchedule![index];
                  final isCurrent = item == currentClass;
                  final nowMinutes = now.hour * 60 + now.minute;
                  final endMinutes = item.endTime.hour * 60 + item.endTime.minute;
                  final isPast = nowMinutes >= endMinutes;

                  return _ScheduleTile(
                    item: item,
                    isCurrent: isCurrent,
                    isPast: isPast,
                  );
                },
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _InstructorInfo {
  final String id;
  final String fullName;
  final String? email;
  final String? avatarUrl;
  final String? department;

  _InstructorInfo({
    required this.id,
    required this.fullName,
    this.email,
    this.avatarUrl,
    this.department,
  });
}

class _ScheduleItem {
  final String subject;
  final String code;
  final String room;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? sectionCode;
  final String? sectionNumber;

  _ScheduleItem({
    required this.subject,
    required this.code,
    required this.room,
    required this.startTime,
    required this.endTime,
    this.sectionCode,
    this.sectionNumber,
  });

  String get timeRange {
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String get section {
    if (sectionCode != null && sectionNumber != null) {
      return '$sectionCode $sectionNumber';
    }
    return sectionCode ?? '';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String get startTimeFormatted => _formatTime(startTime);
  String get endTimeFormatted => _formatTime(endTime);
}

class _InstructorTile extends StatelessWidget {
  const _InstructorTile({
    required this.instructor,
    required this.onTap,
  });

  final _InstructorInfo instructor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return Material(
      color: isDark ? colors.surfaceContainerHigh : colors.surfaceContainerLow,
      borderRadius: AppTokens.radius.md,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTokens.radius.md,
        child: Padding(
          padding: spacing.edgeInsetsAll(spacing.md * spacingScale),
          child: Row(
            children: [
              InstructorAvatar(
                name: instructor.fullName,
                avatarUrl: instructor.avatarUrl,
                tint: colors.primary,
                size: AppTokens.componentSize.avatarMd * scale,
              ),
              SizedBox(width: spacing.md * spacingScale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instructor.fullName,
                      style: AppTokens.typography.subtitleScaled(scale).copyWith(
                        fontWeight: AppTokens.fontWeight.semiBold,
                        color: colors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (instructor.department != null)
                      Text(
                        instructor.department!,
                        style: AppTokens.typography.captionScaled(scale).copyWith(
                          color: palette.muted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: AppTokens.iconSize.md * scale,
                color: palette.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.item,
    required this.isCurrent,
    required this.isPast,
  });

  final _ScheduleItem item;
  final bool isCurrent;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final spacing = AppTokens.spacing;
    final isDark = theme.brightness == Brightness.dark;
    final palette = isDark ? AppTokens.darkColors : AppTokens.lightColors;
    final scale = ResponsiveProvider.scale(context);
    final spacingScale = ResponsiveProvider.spacing(context);

    return Container(
      padding: spacing.edgeInsetsAll(spacing.md * spacingScale),
      decoration: BoxDecoration(
        color: isCurrent
            ? colors.primary.withValues(alpha: AppOpacity.dim)
            : isDark
                ? colors.surfaceContainerHigh
                : colors.surfaceContainerLow,
        borderRadius: AppTokens.radius.md,
        border: isCurrent
            ? Border.all(
                color: colors.primary.withValues(alpha: AppOpacity.subtle),
                width: AppTokens.componentSize.dividerThick,
              )
            : null,
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: AppTokens.componentSize.badgeSm * scale,
            height: AppTokens.componentSize.badgeSm * scale,
            decoration: BoxDecoration(
              color: isCurrent
                  ? colors.primary
                  : isPast
                      ? palette.positive
                      : palette.muted.withValues(alpha: AppOpacity.subtle),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: spacing.md * spacingScale),
          // Time - vertical layout (start above end)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.startTimeFormatted,
                style: AppTokens.typography.captionScaled(scale).copyWith(
                  fontWeight: AppTokens.fontWeight.medium,
                  color: isPast && !isCurrent ? palette.muted : colors.onSurface,
                ),
              ),
              SizedBox(height: spacing.micro * spacingScale),
              Text(
                item.endTimeFormatted,
                style: AppTokens.typography.captionScaled(scale).copyWith(
                  fontWeight: AppTokens.fontWeight.medium,
                  color: isPast && !isCurrent ? palette.muted : colors.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(width: spacing.xl * spacingScale),
          // Subject and room
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.subject,
                  style: AppTokens.typography.bodyScaled(scale).copyWith(
                    fontWeight: AppTokens.fontWeight.medium,
                    color: isPast && !isCurrent ? palette.muted : null,
                    decoration: isPast && !isCurrent
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: AppTokens.iconSize.xs * scale,
                      color: palette.muted,
                    ),
                    SizedBox(width: spacing.xs * spacingScale),
                    Text(
                      item.room,
                      style: AppTokens.typography.captionScaled(scale).copyWith(
                        color: palette.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
