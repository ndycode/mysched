import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'schedule_repository.dart';

/// Service for exporting schedule data as PDF or images.
class ScheduleExportService {
  static const _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// Generates a PDF document from the schedule and returns the file path.
  static Future<String> generateSchedulePdf({
    required List<ClassItem> classes,
    required String userName,
    String? semester,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateGenerated = DateFormat('MMM d, yyyy').format(now);
    
    // Group classes by day
    final classesByDay = <int, List<ClassItem>>{};
    for (final cls in classes) {
      if (!cls.enabled) continue;
      classesByDay.putIfAbsent(cls.day, () => []).add(cls);
    }
    
    // Sort class within each day by start time
    for (final dayClasses in classesByDay.values) {
      dayClasses.sort((a, b) => _timeToMinutes(a.start).compareTo(_timeToMinutes(b.start)));
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 20),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Weekly Class Schedule',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      userName,
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey600,
                      ),
                    ),
                    if (semester != null)
                      pw.Text(
                        semester,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey500,
                        ),
                      ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Generated on',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey400,
                      ),
                    ),
                    pw.Text(
                      dateGenerated,
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          
          // Schedule content by day
          ...List.generate(7, (dayIndex) {
            final day = dayIndex + 1; // 1-7
            final dayClasses = classesByDay[day] ?? [];
            
            if (dayClasses.isEmpty) {
              return pw.Container(); // Skip empty days
            }
            
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Day header
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Text(
                          _dayNames[dayIndex],
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.Spacer(),
                        pw.Text(
                          '${dayClasses.length} class${dayClasses.length == 1 ? '' : 'es'}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.blue600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  
                  // Classes for this day
                  ...dayClasses.map((cls) => pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 8),
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey200),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Time column
                        pw.Container(
                          width: 80,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                _formatTime(cls.start),
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.Text(
                                _formatTime(cls.end),
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 12),
                        
                        // Class details
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                cls.title ?? cls.code ?? 'Untitled Class',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey800,
                                ),
                              ),
                              if (cls.code != null && cls.title != null)
                                pw.Text(
                                  cls.code!,
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.grey500,
                                  ),
                                ),
                              if (cls.instructor != null)
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(top: 4),
                                  child: pw.Text(
                                    cls.instructor!,
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      color: PdfColors.grey600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        // Room
                        if (cls.room != null)
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.grey100,
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            child: pw.Text(
                              cls.room!,
                              style: pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )),
                ],
              ),
            );
          }),
          
          // Footer
          pw.Spacer(),
          pw.Container(
            padding: const pw.EdgeInsets.only(top: 20),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey200, width: 1),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generated by MySched',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey400,
                  ),
                ),
                pw.Text(
                  'Total: ${classes.where((c) => c.enabled).length} classes',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Save PDF to temporary directory
    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(now);
    final fileName = 'schedule_$timestamp.pdf';
    final filePath = '${directory.path}/$fileName';
    
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    
    return filePath;
  }

  /// Shares the generated PDF file using the system share dialog.
  static Future<void> sharePdf(String filePath) async {
    final file = XFile(filePath, mimeType: 'application/pdf');
    await SharePlus.instance.share(
      ShareParams(
        files: [file],
        subject: 'My Class Schedule',
        text: 'Here is my weekly class schedule.',
      ),
    );
  }
  
  /// Generates and immediately shares a PDF schedule.
  static Future<void> exportAndShare({
    required List<ClassItem> classes,
    required String userName,
    String? semester,
  }) async {
    final filePath = await generateSchedulePdf(
      classes: classes,
      userName: userName,
      semester: semester,
    );
    await sharePdf(filePath);
  }

  /// Converts time string "HH:MM" to minutes for sorting.
  static int _timeToMinutes(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return hour * 60 + minute;
  }

  /// Formats time for display (12-hour format).
  static String _formatTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2024, 1, 1, hour, minute);
      return DateFormat.jm().format(dt);
    } catch (_) {
      return time;
    }
  }
}
