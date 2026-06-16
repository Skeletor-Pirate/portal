import 'dart:io';
import 'package:postgres/postgres.dart';

class SchoolAssignment {
  final String id;
  final String title;
  final String? description;
  final String? dueDate;
  final String? subjectId;
  final String? subjectName;
  final String? sectionId;
  final String? sectionName;
  final double? maxMarks;
  final String? status;

  SchoolAssignment({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.subjectId,
    this.subjectName,
    this.sectionId,
    this.sectionName,
    this.maxMarks,
    this.status,
  });

  factory SchoolAssignment.fromJson(Map<String, dynamic> j) => SchoolAssignment(
        id:          j['id']?.toString() ?? '',
        title:       j['title'] ?? '',
        description: j['description']?.toString(),
        dueDate:     j['due_date']?.toString(),
        subjectId:   j['subject']?.toString(),
        subjectName: j['subject_name']?.toString() ?? j['subject']?.toString() ?? 'Unknown Subject',
        sectionId:   j['section']?.toString(),
        sectionName: j['section_name']?.toString(),
        maxMarks:    (j['max_marks'] as num?)?.toDouble(),
        status:      j['status']?.toString() ?? 'Pending',
      );
}

void main() async {
  const dbUrl = 'postgresql://neondb_owner:npg_V2Bnuz5xFpYe@ep-nameless-bird-a1pl9bnj-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require';
  
  final uri = Uri.parse(dbUrl);
  final endpoint = Endpoint(
    host: uri.host,
    database: uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : 'postgres',
    username: uri.userInfo.split(':')[0],
    password: uri.userInfo.split(':')[1],
    port: uri.hasPort ? uri.port : 5432,
  );

  final conn = await Connection.open(
    endpoint,
    settings: const ConnectionSettings(sslMode: SslMode.require),
  );

  final result = await conn.execute('SELECT id, title, description, subject_id, section_id, teacher_id, due_date, created_at FROM operations_assignment');
  
  final mapped = result.map((row) {
    return {
      'id': row[0].toString(),
      'title': row[1].toString(),
      'description': row[2].toString(),
      'subject': row[3].toString(),
      'section': row[4].toString(),
      'teacher': row[5].toString(),
      'due_date': (row[6] as DateTime).toIso8601String(),
      'created_at': (row[7] as DateTime).toIso8601String(),
    };
  }).toList();
  
  try {
    for (var m in mapped) {
      final a = SchoolAssignment.fromJson(m);
      print('Parsed successfully: \${a.title}');
    }
  } catch (e) {
    print('Parse error: \$e');
  }

  await conn.close();
}
