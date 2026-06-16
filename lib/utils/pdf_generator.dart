import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<Uint8List> generateToolPdf(String toolName, dynamic data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          if (data is String) {
            // Raw text fallback
            return [
              pw.Header(level: 0, child: pw.Text(toolName)),
              pw.Paragraph(text: data),
            ];
          }

          if (data is Map<String, dynamic>) {
            return _buildMapContent(toolName, data);
          }

          return [pw.Text('Invalid data format.')];
        },
      ),
    );

    return await pdf.save();
  }

  static Future<void> sharePdf(String toolName, dynamic data) async {
    final bytes = await generateToolPdf(toolName, data);
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${toolName.replaceAll(' ', '_').toLowerCase()}_output.pdf',
    );
  }

  static List<pw.Widget> _buildMapContent(String toolName, Map<String, dynamic> data) {
    List<pw.Widget> widgets = [];

    // Title
    final title = data['title'] ?? data['lesson_title'] ?? toolName;
    widgets.add(
      pw.Header(
        level: 0,
        child: pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple)),
      ),
    );

    // Metadata Tags
    List<String> tags = [];
    if (data['subject'] != null) tags.add('Subject: ${data['subject']}');
    if (data['class_name'] != null) tags.add('Class: ${data['class_name']}');
    if (data['topic'] != null) tags.add('Topic: ${data['topic']}');

    if (tags.isNotEmpty) {
      widgets.add(pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 16),
        child: pw.Text(tags.join(' | '), style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
      ));
    }

    // Specific Tool Rendering
    if (toolName == 'Quiz') {
      _buildQuiz(widgets, data);
    } else if (toolName == 'Lesson Plan') {
      _buildLessonPlan(widgets, data);
    } else {
      // Generic Map Fallback
      data.forEach((key, value) {
        if (key != 'title' && key != 'subject' && key != 'class_name' && key != 'topic') {
          widgets.add(pw.Header(level: 1, text: _capitalize(key)));
          if (value is List) {
            for (var item in value) {
              widgets.add(pw.Paragraph(text: item.toString()));
            }
          } else {
            widgets.add(pw.Paragraph(text: value.toString()));
          }
          widgets.add(pw.SizedBox(height: 10));
        }
      });
    }

    return widgets;
  }

  static void _buildQuiz(List<pw.Widget> widgets, Map<String, dynamic> data) {
    if (data['mcqs'] != null && (data['mcqs'] as List).isNotEmpty) {
      widgets.add(pw.Header(level: 1, text: 'Multiple Choice Questions'));
      int i = 1;
      for (var mcq in data['mcqs']) {
        widgets.add(pw.Paragraph(text: '$i. ${mcq['question']}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
        if (mcq['options'] != null) {
          int optIdx = 0;
          for (var opt in mcq['options']) {
            String letter = String.fromCharCode(65 + optIdx);
            bool isCorrect = mcq['correct_answer'] == opt;
            widgets.add(
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 20, bottom: 4),
                child: pw.Text('$letter) $opt' + (isCorrect ? ' (Correct)' : ''),
                  style: pw.TextStyle(color: isCorrect ? PdfColors.green700 : PdfColors.black)),
              ),
            );
            optIdx++;
          }
        }
        widgets.add(pw.SizedBox(height: 10));
        i++;
      }
    }

    if (data['short_answers'] != null && (data['short_answers'] as List).isNotEmpty) {
      widgets.add(pw.Header(level: 1, text: 'Short Answer Questions'));
      int i = 1;
      for (var sa in data['short_answers']) {
        widgets.add(pw.Paragraph(text: '$i. ${sa['question']}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
        widgets.add(
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            margin: const pw.EdgeInsets.only(left: 10, bottom: 10, top: 4),
            decoration: pw.BoxDecoration(color: PdfColors.grey100, border: pw.Border.all(color: PdfColors.grey300)),
            child: pw.Text('Answer Key: \n${sa['answer_key']}', style: const pw.TextStyle(fontSize: 10)),
          ),
        );
        i++;
      }
    }
  }

  static void _buildLessonPlan(List<pw.Widget> widgets, Map<String, dynamic> data) {
    if (data['curriculum_alignment'] != null) {
      widgets.add(pw.Header(level: 1, text: 'Curriculum Alignment'));
      widgets.add(pw.Paragraph(text: data['curriculum_alignment']));
    }

    if (data['learning_objectives'] != null) {
      widgets.add(pw.Header(level: 1, text: 'Learning Objectives'));
      for (var obj in data['learning_objectives']) {
        widgets.add(pw.Bullet(text: obj['objective'] ?? obj.toString()));
      }
      widgets.add(pw.SizedBox(height: 10));
    }

    if (data['materials_needed'] != null) {
      widgets.add(pw.Header(level: 1, text: 'Materials Needed'));
      for (var mat in data['materials_needed']) {
        widgets.add(pw.Bullet(text: mat.toString()));
      }
      widgets.add(pw.SizedBox(height: 10));
    }

    if (data['introduction'] != null) {
      widgets.add(pw.Header(level: 1, text: 'Introduction'));
      widgets.add(pw.Paragraph(text: data['introduction']));
    }

    if (data['activities'] != null) {
      widgets.add(pw.Header(level: 1, text: 'Activities'));
      for (var act in data['activities']) {
        widgets.add(pw.Paragraph(text: '${act['duration']} - ${act['activity_title']}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
        widgets.add(pw.Paragraph(text: act['description'] ?? ''));
        widgets.add(pw.SizedBox(height: 8));
      }
    }

    if (data['conclusion'] != null) {
      widgets.add(pw.Header(level: 1, text: 'Conclusion'));
      widgets.add(pw.Paragraph(text: data['conclusion']));
    }

    if (data['assessments'] != null) {
      widgets.add(pw.Header(level: 1, text: 'Assessments'));
      for (var asmt in data['assessments']) {
        widgets.add(pw.Paragraph(text: asmt['assessment_type'] ?? 'Assessment', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
        widgets.add(pw.Paragraph(text: asmt['description'] ?? ''));
        widgets.add(pw.SizedBox(height: 8));
      }
    }
  }

  static String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).replaceAll('_', ' ');
}
