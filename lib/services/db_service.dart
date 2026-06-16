import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

class DbService {
  static const String _dbUrl = 'postgresql://neondb_owner:npg_V2Bnuz5xFpYe@ep-nameless-bird-a1pl9bnj-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require';

  static Connection? _connection;

  static Future<Connection> _getConnection() async {
    if (_connection != null && _connection!.isOpen) {
      return _connection!;
    }
    
    // Parse the URL
    // Format: postgresql://user:password@host:port/database
    final uri = Uri.parse(_dbUrl);
    final endpoint = Endpoint(
      host: uri.host,
      database: uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : 'postgres',
      username: uri.userInfo.split(':')[0],
      password: uri.userInfo.split(':')[1],
      port: uri.hasPort ? uri.port : 5432,
    );

    _connection = await Connection.open(
      endpoint,
      settings: const ConnectionSettings(sslMode: SslMode.require),
    );
    return _connection!;
  }

  static Future<void> createAssignment({
    required String title,
    required String description,
    required String subjectId,
    required String sectionId,
    required String teacherId, // actually user_id
    required String schoolId,
    required DateTime dueDate,
  }) async {
    try {
      final conn = await _getConnection();
      
      // Lookup real teacher profile ID
      final teacherRes = await conn.execute(
        Sql.named('SELECT id FROM profiles_teacherprofile WHERE user_id = @user_id AND school_id = @school_id LIMIT 1'),
        parameters: {'user_id': teacherId, 'school_id': schoolId},
      );
      if (teacherRes.isEmpty) {
        throw Exception('Teacher profile not found for user.');
      }
      final realTeacherId = teacherRes[0][0].toString();

      final id = const Uuid().v4();
      final now = DateTime.now().toUtc();
      
      await conn.execute(
        Sql.named('INSERT INTO operations_assignment (id, title, description, subject_id, section_id, teacher_id, due_date, created_at, school_id) VALUES (@id, @title, @description, @subject_id, @section_id, @teacher_id, @due_date, @created_at, @school_id)'),
        parameters: {
          'id': id,
          'title': title,
          'description': description,
          'subject_id': subjectId,
          'section_id': sectionId,
          'teacher_id': realTeacherId,
          'due_date': dueDate.toUtc(),
          'created_at': now,
          'school_id': schoolId,
        },
      );
    } catch (e) {
      print('Database Error: \$e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getAssignments(String schoolId) async {
    try {
      final conn = await _getConnection();
      final result = await conn.execute(
        Sql.named('SELECT id, title, description, subject_id, section_id, teacher_id, due_date, created_at FROM operations_assignment WHERE school_id = @school_id ORDER BY due_date DESC'),
        parameters: {'school_id': schoolId},
      );
      
      return result.map((row) {
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
    } catch (e) {
      print('Database Error: \$e');
      return [];
    }
  }
}
