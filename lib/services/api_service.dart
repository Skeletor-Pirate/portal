import 'dart:convert';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG
// ─────────────────────────────────────────────────────────────────────────────

const String kBaseUrl = 'http://187.127.139.208:8081';

// ─────────────────────────────────────────────────────────────────────────────
// TOKEN STORE  (in-memory; swap for flutter_secure_storage in production)
// ─────────────────────────────────────────────────────────────────────────────

class TokenStore {
  static String? _access;
  static String? _refresh;

  static String? get access  => _access;
  static String? get refresh => _refresh;
  static bool   get hasTokens => _access != null;

  static void save({required String access, required String refresh}) {
    _access  = access;
    _refresh = refresh;
  }

  static void clear() {
    _access  = null;
    _refresh = null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXCEPTION
// ─────────────────────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final int?   statusCode;
  final String message;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

// ─────────────────────────────────────────────────────────────────────────────
// CORE HTTP CLIENT
// ─────────────────────────────────────────────────────────────────────────────

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _client = http.Client();

  // ── Headers ────────────────────────────────────────────────────────────────

  Map<String, String> _headers({bool auth = true}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (auth && TokenStore.access != null) {
      h['Authorization'] = 'Bearer ${TokenStore.access}';
    }
    return h;
  }

  // ── URI builder ────────────────────────────────────────────────────────────

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse('$kBaseUrl$path');
    if (query != null && query.isNotEmpty) {
      return base.replace(
          queryParameters: query.map((k, v) => MapEntry(k, v.toString())));
    }
    return base;
  }

  // ── Response parser ────────────────────────────────────────────────────────

  Future<dynamic> _parse(http.Response res) async {
    if (res.statusCode == 401) {
      final ok = await _tryRefresh();
      if (!ok) {
        TokenStore.clear();
        throw ApiException('Session expired. Please log in again.', statusCode: 401);
      }
      // Caller should retry — throw with 401 so callers know to retry once
      throw ApiException('token_refreshed', statusCode: 401);
    }
    if (res.statusCode >= 400) {
      String msg = 'Error ${res.statusCode}';
      try {
        final b = jsonDecode(res.body);
        if (b is Map) {
          // DRF often returns {"field": ["error"]} or {"detail": "..."}
          if (b.containsKey('detail'))        msg = b['detail'].toString();
          else if (b.containsKey('message'))  msg = b['message'].toString();
          else if (b.containsKey('non_field_errors'))
            msg = (b['non_field_errors'] as List).join(' ');
          else {
            final firstVal = b.values.first;
            msg = firstVal is List ? firstVal.first.toString() : firstVal.toString();
          }
        }
      } catch (_) {}
      throw ApiException(msg, statusCode: res.statusCode);
    }
    if (res.body.isEmpty || res.statusCode == 204) return null;
    return jsonDecode(res.body);
  }

  // ── Token refresh ──────────────────────────────────────────────────────────

  Future<bool> _tryRefresh() async {
    if (TokenStore.refresh == null) return false;
    try {
      final res = await _client.post(
        _uri('/api/v1/auth/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': TokenStore.refresh}),
      );
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        TokenStore.save(access: d['access'], refresh: TokenStore.refresh!);
        return true;
      }
    } catch (_) {}
    return false;
  }

  // ── HTTP verbs ─────────────────────────────────────────────────────────────

  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool auth = true}) async {
    final res = await _client.get(_uri(path, query), headers: _headers(auth: auth));
    return _parse(res);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    final res = await _client.post(
      _uri(path),
      headers: _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _parse(res);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final res = await _client.put(_uri(path), headers: _headers(), body: jsonEncode(body));
    return _parse(res);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final res = await _client.patch(_uri(path), headers: _headers(), body: jsonEncode(body));
    return _parse(res);
  }

  Future<void> delete(String path) async {
    final res = await _client.delete(_uri(path), headers: _headers());
    await _parse(res);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AUTH  (/api/v1/auth/)
  // ─────────────────────────────────────────────────────────────────────────

  /// POST /api/v1/auth/login/   → TokenObtainPair
  Future<AuthResult> login(String username, String password) async {
    final d = await post(
      '/api/v1/auth/login/',
      {'username': username, 'password': password},
      auth: false,
    );
    final r = AuthResult.fromJson(d);
    TokenStore.save(access: r.access, refresh: r.refresh);
    return r;
  }

  /// POST /api/v1/auth/refresh/  → TokenRefresh
  Future<void> refreshToken() async {
    await _tryRefresh();
  }

  /// GET /api/v1/auth/me/   → User
  Future<AuthMe> getMe() async {
    final d = await get('/api/v1/auth/me/');
    return AuthMe.fromJson(d);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PROFILES  (/api/v1/profiles/)
  // ─────────────────────────────────────────────────────────────────────────

  /// GET /api/v1/profiles/me/
  Future<ProfileMe> getMyProfile() async {
    final d = await get('/api/v1/profiles/me/');
    return ProfileMe.fromJson(d);
  }

  // ── Students ───────────────────────────────────────────────────────────────

  /// GET /api/v1/profiles/students/
  Future<PaginatedResult<StudentProfile>> getStudents({
    int page = 1, String? search,
  }) async {
    final q = <String, dynamic>{'page': page};
    if (search != null && search.isNotEmpty) q['search'] = search;
    final d = await get('/api/v1/profiles/students/', query: q);
    return PaginatedResult.fromJson(d, StudentProfile.fromJson);
  }

  /// POST /api/v1/profiles/students/
  Future<StudentProfile> createStudent(Map<String, dynamic> body) async {
    final d = await post('/api/v1/profiles/students/', body);
    return StudentProfile.fromJson(d);
  }

  /// GET /api/v1/profiles/students/{id}/
  Future<StudentProfile> getStudent(int id) async {
    final d = await get('/api/v1/profiles/students/$id/');
    return StudentProfile.fromJson(d);
  }

  /// PATCH /api/v1/profiles/students/{id}/
  Future<StudentProfile> patchStudent(int id, Map<String, dynamic> body) async {
    final d = await patch('/api/v1/profiles/students/$id/', body);
    return StudentProfile.fromJson(d);
  }

  /// DELETE /api/v1/profiles/students/{id}/
  Future<void> deleteStudent(int id) => delete('/api/v1/profiles/students/$id/');

  // ── Teachers ───────────────────────────────────────────────────────────────

  /// GET /api/v1/profiles/teachers/
  Future<PaginatedResult<TeacherProfile>> getTeachers({int page = 1}) async {
    final d = await get('/api/v1/profiles/teachers/', query: {'page': page});
    return PaginatedResult.fromJson(d, TeacherProfile.fromJson);
  }

  /// POST /api/v1/profiles/teachers/
  Future<TeacherProfile> createTeacher(Map<String, dynamic> body) async {
    final d = await post('/api/v1/profiles/teachers/', body);
    return TeacherProfile.fromJson(d);
  }

  /// PATCH /api/v1/profiles/teachers/{id}/
  Future<TeacherProfile> patchTeacher(int id, Map<String, dynamic> body) async {
    final d = await patch('/api/v1/profiles/teachers/$id/', body);
    return TeacherProfile.fromJson(d);
  }

  /// DELETE /api/v1/profiles/teachers/{id}/
  Future<void> deleteTeacher(int id) => delete('/api/v1/profiles/teachers/$id/');

  // ── Parents ────────────────────────────────────────────────────────────────

  /// GET /api/v1/profiles/parents/
  Future<PaginatedResult<ParentProfile>> getParents({int page = 1}) async {
    final d = await get('/api/v1/profiles/parents/', query: {'page': page});
    return PaginatedResult.fromJson(d, ParentProfile.fromJson);
  }

  /// POST /api/v1/profiles/parents/
  Future<ParentProfile> createParent(Map<String, dynamic> body) async {
    final d = await post('/api/v1/profiles/parents/', body);
    return ParentProfile.fromJson(d);
  }

  /// PATCH /api/v1/profiles/parents/{id}/
  Future<ParentProfile> patchParent(int id, Map<String, dynamic> body) async {
    final d = await patch('/api/v1/profiles/parents/$id/', body);
    return ParentProfile.fromJson(d);
  }

  /// DELETE /api/v1/profiles/parents/{id}/
  Future<void> deleteParent(int id) => delete('/api/v1/profiles/parents/$id/');

  // ── Parent-Student Mappings ────────────────────────────────────────────────

  /// GET /api/v1/profiles/parent-student-mappings/
  Future<PaginatedResult<ParentStudentMapping>> getParentStudentMappings({
    int page = 1,
  }) async {
    final d = await get('/api/v1/profiles/parent-student-mappings/', query: {'page': page});
    return PaginatedResult.fromJson(d, ParentStudentMapping.fromJson);
  }

  /// POST /api/v1/profiles/parent-student-mappings/
  Future<ParentStudentMapping> createMapping(int parentId, int studentId) async {
    final d = await post('/api/v1/profiles/parent-student-mappings/', {
      'parent': parentId,
      'student': studentId,
    });
    return ParentStudentMapping.fromJson(d);
  }

  /// DELETE /api/v1/profiles/parent-student-mappings/{id}/
  Future<void> deleteMapping(int id) =>
      delete('/api/v1/profiles/parent-student-mappings/$id/');

  // ─────────────────────────────────────────────────────────────────────────
  // ACADEMICS  (/api/v1/academics/)
  // ─────────────────────────────────────────────────────────────────────────

  // ── Enrollments ────────────────────────────────────────────────────────────

  /// GET /api/v1/academics/enrollments/
  Future<PaginatedResult<Enrollment>> getEnrollments({
    int page = 1, String? classId,
  }) async {
    final q = <String, dynamic>{'page': page};
    if (classId != null) q['class_id'] = classId;
    final d = await get('/api/v1/academics/enrollments/', query: q);
    return PaginatedResult.fromJson(d, Enrollment.fromJson);
  }

  /// POST /api/v1/academics/enrollments/
  Future<Enrollment> createEnrollment(Map<String, dynamic> body) async {
    final d = await post('/api/v1/academics/enrollments/', body);
    return Enrollment.fromJson(d);
  }

  /// POST /api/v1/academics/enrollments/bulk-promote/
  Future<void> bulkPromote(Map<String, dynamic> body) async {
    await post('/api/v1/academics/enrollments/bulk-promote/', body);
  }

  // ── Teacher Assignments ────────────────────────────────────────────────────

  /// GET /api/v1/academics/teacher-assignments/
  Future<PaginatedResult<TeacherAssignment>> getTeacherAssignments({
    int page = 1,
  }) async {
    final d = await get('/api/v1/academics/teacher-assignments/', query: {'page': page});
    return PaginatedResult.fromJson(d, TeacherAssignment.fromJson);
  }

  /// POST /api/v1/academics/teacher-assignments/
  Future<TeacherAssignment> createTeacherAssignment(Map<String, dynamic> body) async {
    final d = await post('/api/v1/academics/teacher-assignments/', body);
    return TeacherAssignment.fromJson(d);
  }

  /// DELETE /api/v1/academics/teacher-assignments/{id}/
  Future<void> deleteTeacherAssignment(int id) =>
      delete('/api/v1/academics/teacher-assignments/$id/');

  // ─────────────────────────────────────────────────────────────────────────
  // OPERATIONS  (/api/v1/operations/)
  // ─────────────────────────────────────────────────────────────────────────

  // ── Attendance ─────────────────────────────────────────────────────────────

  /// GET /api/v1/operations/attendance/
  Future<PaginatedResult<AttendanceRecord>> getAttendance({
    int page = 1, String? studentId, String? date,
  }) async {
    final q = <String, dynamic>{'page': page};
    if (studentId != null) q['student'] = studentId;
    if (date != null)      q['date']    = date;
    final d = await get('/api/v1/operations/attendance/', query: q);
    return PaginatedResult.fromJson(d, AttendanceRecord.fromJson);
  }

  /// POST /api/v1/operations/attendance/bulk-record/
  Future<void> bulkRecordAttendance(List<Map<String, dynamic>> records) async {
    await post('/api/v1/operations/attendance/bulk-record/', {'records': records});
  }

  // ── Exams ──────────────────────────────────────────────────────────────────

  /// GET /api/v1/operations/exams/
  Future<PaginatedResult<Exam>> getExams({int page = 1}) async {
    final d = await get('/api/v1/operations/exams/', query: {'page': page});
    return PaginatedResult.fromJson(d, Exam.fromJson);
  }

  /// POST /api/v1/operations/exams/
  Future<Exam> createExam(Map<String, dynamic> body) async {
    final d = await post('/api/v1/operations/exams/', body);
    return Exam.fromJson(d);
  }

  /// PATCH /api/v1/operations/exams/{id}/
  Future<Exam> patchExam(int id, Map<String, dynamic> body) async {
    final d = await patch('/api/v1/operations/exams/$id/', body);
    return Exam.fromJson(d);
  }

  /// DELETE /api/v1/operations/exams/{id}/
  Future<void> deleteExam(int id) => delete('/api/v1/operations/exams/$id/');

  // ── Grades ─────────────────────────────────────────────────────────────────

  /// GET /api/v1/operations/grades/
  Future<PaginatedResult<StudentGrade>> getGrades({
    int page = 1, String? studentId, String? examId,
  }) async {
    final q = <String, dynamic>{'page': page};
    if (studentId != null) q['student'] = studentId;
    if (examId != null)    q['exam']    = examId;
    final d = await get('/api/v1/operations/grades/', query: q);
    return PaginatedResult.fromJson(d, StudentGrade.fromJson);
  }

  /// POST /api/v1/operations/grades/bulk-submit/
  Future<void> bulkSubmitGrades(List<Map<String, dynamic>> grades) async {
    await post('/api/v1/operations/grades/bulk-submit/', {'grades': grades});
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ACCOUNTS  (/api/v1/accounts/)
  // ─────────────────────────────────────────────────────────────────────────

  /// GET /api/v1/accounts/permissions/
  Future<PaginatedResult<AppPermission>> getPermissions({int page = 1}) async {
    final d = await get('/api/v1/accounts/permissions/', query: {'page': page});
    return PaginatedResult.fromJson(d, AppPermission.fromJson);
  }

  /// GET /api/v1/accounts/roles/
  Future<PaginatedResult<AppRole>> getRoles({int page = 1}) async {
    final d = await get('/api/v1/accounts/roles/', query: {'page': page});
    return PaginatedResult.fromJson(d, AppRole.fromJson);
  }

  /// POST /api/v1/accounts/roles/
  Future<AppRole> createRole(Map<String, dynamic> body) async {
    final d = await post('/api/v1/accounts/roles/', body);
    return AppRole.fromJson(d);
  }

  /// DELETE /api/v1/accounts/roles/{id}/
  Future<void> deleteRole(int id) => delete('/api/v1/accounts/roles/$id/');

  /// GET /api/v1/accounts/user-roles/
  Future<PaginatedResult<UserRoleAssignment>> getUserRoles({int page = 1}) async {
    final d = await get('/api/v1/accounts/user-roles/', query: {'page': page});
    return PaginatedResult.fromJson(d, UserRoleAssignment.fromJson);
  }

  /// POST /api/v1/accounts/user-roles/
  Future<UserRoleAssignment> assignUserRole(int userId, int roleId) async {
    final d = await post('/api/v1/accounts/user-roles/', {
      'user': userId,
      'role': roleId,
    });
    return UserRoleAssignment.fromJson(d);
  }

  /// DELETE /api/v1/accounts/user-roles/{id}/
  Future<void> removeUserRole(int id) => delete('/api/v1/accounts/user-roles/$id/');
}

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────

// ── Auth ───────────────────────────────────────────────────────────────────

class AuthResult {
  final String access;
  final String refresh;
  AuthResult({required this.access, required this.refresh});
  factory AuthResult.fromJson(Map<String, dynamic> j) =>
      AuthResult(access: j['access'] ?? '', refresh: j['refresh'] ?? '');
}

class AuthMe {
  final int    id;
  final String username;
  final String email;
  final String role;
  final String? firstName;
  final String? lastName;

  AuthMe({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.firstName,
    this.lastName,
  });

  String get fullName =>
      [firstName, lastName].where((s) => s != null && s!.isNotEmpty).join(' ');

  factory AuthMe.fromJson(Map<String, dynamic> j) => AuthMe(
        id:        j['id'] ?? 0,
        username:  j['username'] ?? '',
        email:     j['email'] ?? '',
        role:      (j['role'] ?? j['user_type'] ?? '').toString().toLowerCase(),
        firstName: j['first_name'],
        lastName:  j['last_name'],
      );
}

// ── Profiles ───────────────────────────────────────────────────────────────

class ProfileMe {
  final int    id;
  final String displayName;
  final String role;
  final String? schoolName;
  final String? idLabel;
  final Map<String, dynamic> raw;

  ProfileMe({
    required this.id,
    required this.displayName,
    required this.role,
    this.schoolName,
    this.idLabel,
    required this.raw,
  });

  factory ProfileMe.fromJson(Map<String, dynamic> j) {
    final u     = j['user'] as Map<String, dynamic>? ?? j;
    final first = (u['first_name'] ?? '').toString();
    final last  = (u['last_name']  ?? '').toString();
    final name  = '$first $last'.trim();
    return ProfileMe(
      id:          j['id'] ?? 0,
      displayName: name.isNotEmpty ? name : (u['username'] ?? 'User').toString(),
      role:        (j['role'] ?? j['user_type'] ?? u['role'] ?? '').toString(),
      schoolName:  j['school']?['name'] ?? j['school_name'],
      idLabel:     (j['employee_id'] ?? j['student_id'] ?? j['staff_id'])?.toString(),
      raw:         j,
    );
  }
}

// ── Pagination ─────────────────────────────────────────────────────────────

class PaginatedResult<T> {
  final int     count;
  final String? next;
  final String? previous;
  final List<T> results;

  PaginatedResult({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  bool get hasMore => next != null;

  factory PaginatedResult.fromJson(
      Map<String, dynamic> j, T Function(Map<String, dynamic>) fromJson) {
    final list = (j['results'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList();
    return PaginatedResult(
      count:    j['count'] ?? list.length,
      next:     j['next'],
      previous: j['previous'],
      results:  list,
    );
  }
}

// ── StudentProfile ─────────────────────────────────────────────────────────

class StudentProfile {
  final int    id;
  final String fullName;
  final String? gradeClass;
  final String? rollNumber;
  final String? attendancePct;
  final String? email;
  final Map<String, dynamic> raw;

  StudentProfile({
    required this.id,
    required this.fullName,
    this.gradeClass,
    this.rollNumber,
    this.attendancePct,
    this.email,
    required this.raw,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> j) {
    final u     = j['user'] as Map<String, dynamic>? ?? j;
    final first = (u['first_name'] ?? '').toString();
    final last  = (u['last_name']  ?? '').toString();
    final name  = '$first $last'.trim();
    return StudentProfile(
      id:            j['id'] ?? 0,
      fullName:      name.isNotEmpty ? name : (u['username'] ?? 'Student').toString(),
      gradeClass:    (j['grade'] ?? j['class_name'] ?? j['current_class'])?.toString(),
      rollNumber:    (j['roll_number'] ?? j['student_id'])?.toString(),
      attendancePct: j['attendance_percentage']?.toString(),
      email:         (u['email'] ?? j['email'])?.toString(),
      raw:           j,
    );
  }
}

// ── TeacherProfile ─────────────────────────────────────────────────────────

class TeacherProfile {
  final int    id;
  final String fullName;
  final String? subject;
  final String? employeeId;
  final String? email;
  final Map<String, dynamic> raw;

  TeacherProfile({
    required this.id,
    required this.fullName,
    this.subject,
    this.employeeId,
    this.email,
    required this.raw,
  });

  factory TeacherProfile.fromJson(Map<String, dynamic> j) {
    final u     = j['user'] as Map<String, dynamic>? ?? j;
    final first = (u['first_name'] ?? '').toString();
    final last  = (u['last_name']  ?? '').toString();
    final name  = '$first $last'.trim();
    return TeacherProfile(
      id:         j['id'] ?? 0,
      fullName:   name.isNotEmpty ? name : (u['username'] ?? 'Teacher').toString(),
      subject:    (j['subject'] ?? j['subjects'])?.toString(),
      employeeId: j['employee_id']?.toString(),
      email:      (u['email'] ?? j['email'])?.toString(),
      raw:        j,
    );
  }
}

// ── ParentProfile ──────────────────────────────────────────────────────────

class ParentProfile {
  final int    id;
  final String fullName;
  final String? linkedStudent;
  final String? email;
  final Map<String, dynamic> raw;

  ParentProfile({
    required this.id,
    required this.fullName,
    this.linkedStudent,
    this.email,
    required this.raw,
  });

  factory ParentProfile.fromJson(Map<String, dynamic> j) {
    final u     = j['user'] as Map<String, dynamic>? ?? j;
    final first = (u['first_name'] ?? '').toString();
    final last  = (u['last_name']  ?? '').toString();
    final name  = '$first $last'.trim();
    return ParentProfile(
      id:            j['id'] ?? 0,
      fullName:      name.isNotEmpty ? name : (u['username'] ?? 'Parent').toString(),
      linkedStudent: (j['student_name'] ?? j['child_name'])?.toString(),
      email:         (u['email'] ?? j['email'])?.toString(),
      raw:           j,
    );
  }
}

// ── ParentStudentMapping ───────────────────────────────────────────────────

class ParentStudentMapping {
  final int    id;
  final int    parentId;
  final int    studentId;
  final String? parentName;
  final String? studentName;

  ParentStudentMapping({
    required this.id,
    required this.parentId,
    required this.studentId,
    this.parentName,
    this.studentName,
  });

  factory ParentStudentMapping.fromJson(Map<String, dynamic> j) =>
      ParentStudentMapping(
        id:          j['id'] ?? 0,
        parentId:    j['parent'] is int ? j['parent'] : (j['parent']?['id'] ?? 0),
        studentId:   j['student'] is int ? j['student'] : (j['student']?['id'] ?? 0),
        parentName:  j['parent_name']  ?? j['parent']?['name'],
        studentName: j['student_name'] ?? j['student']?['name'],
      );
}

// ── Enrollment ─────────────────────────────────────────────────────────────

class Enrollment {
  final int    id;
  final String studentName;
  final String? className;
  final String? status;
  final Map<String, dynamic> raw;

  Enrollment({
    required this.id,
    required this.studentName,
    this.className,
    this.status,
    required this.raw,
  });

  factory Enrollment.fromJson(Map<String, dynamic> j) => Enrollment(
        id:          j['id'] ?? 0,
        studentName: (j['student_name'] ?? j['student']?['name'] ?? 'Student').toString(),
        className:   (j['class_name'] ?? j['class'])?.toString(),
        status:      j['status']?.toString(),
        raw:         j,
      );
}

// ── TeacherAssignment ──────────────────────────────────────────────────────

class TeacherAssignment {
  final int    id;
  final String teacherName;
  final String? subject;
  final String? className;
  final Map<String, dynamic> raw;

  TeacherAssignment({
    required this.id,
    required this.teacherName,
    this.subject,
    this.className,
    required this.raw,
  });

  factory TeacherAssignment.fromJson(Map<String, dynamic> j) => TeacherAssignment(
        id:          j['id'] ?? 0,
        teacherName: (j['teacher_name'] ?? j['teacher']?['name'] ?? 'Teacher').toString(),
        subject:     j['subject']?.toString(),
        className:   (j['class_name'] ?? j['class'])?.toString(),
        raw:         j,
      );
}

// ── AttendanceRecord ───────────────────────────────────────────────────────

class AttendanceRecord {
  final int    id;
  final String studentName;
  final String status;   // present / absent / late
  final String? date;

  AttendanceRecord({
    required this.id,
    required this.studentName,
    required this.status,
    this.date,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> j) => AttendanceRecord(
        id:          j['id'] ?? 0,
        studentName: (j['student_name'] ?? j['student']?['name'] ?? 'Student').toString(),
        status:      (j['status'] ?? 'present').toString().toLowerCase(),
        date:        j['date']?.toString(),
      );
}

// ── Exam ───────────────────────────────────────────────────────────────────

class Exam {
  final int    id;
  final String name;
  final String? date;
  final String? subject;
  final Map<String, dynamic> raw;

  Exam({required this.id, required this.name, this.date, this.subject, required this.raw});

  factory Exam.fromJson(Map<String, dynamic> j) => Exam(
        id:      j['id'] ?? 0,
        name:    (j['name'] ?? j['title'] ?? 'Exam').toString(),
        date:    (j['date'] ?? j['exam_date'])?.toString(),
        subject: j['subject']?.toString(),
        raw:     j,
      );
}

// ── StudentGrade ───────────────────────────────────────────────────────────

class StudentGrade {
  final int    id;
  final String studentName;
  final String? examName;
  final String? score;
  final String? grade;

  StudentGrade({
    required this.id,
    required this.studentName,
    this.examName,
    this.score,
    this.grade,
  });

  factory StudentGrade.fromJson(Map<String, dynamic> j) => StudentGrade(
        id:          j['id'] ?? 0,
        studentName: (j['student_name'] ?? j['student']?['name'] ?? 'Student').toString(),
        examName:    (j['exam_name']    ?? j['exam']?['name'])?.toString(),
        score:       j['score']?.toString(),
        grade:       j['grade']?.toString(),
      );
}

// ── AppPermission ──────────────────────────────────────────────────────────

class AppPermission {
  final int    id;
  final String name;
  final String? codename;

  AppPermission({required this.id, required this.name, this.codename});

  factory AppPermission.fromJson(Map<String, dynamic> j) => AppPermission(
        id:       j['id'] ?? 0,
        name:     (j['name'] ?? '').toString(),
        codename: j['codename']?.toString(),
      );
}

// ── AppRole ────────────────────────────────────────────────────────────────

class AppRole {
  final int    id;
  final String name;
  final List<int> permissions;

  AppRole({required this.id, required this.name, required this.permissions});

  factory AppRole.fromJson(Map<String, dynamic> j) => AppRole(
        id:          j['id'] ?? 0,
        name:        (j['name'] ?? '').toString(),
        permissions: (j['permissions'] as List? ?? []).map((e) => e is int ? e : (e['id'] ?? 0) as int).toList(),
      );
}

// ── UserRoleAssignment ─────────────────────────────────────────────────────

class UserRoleAssignment {
  final int id;
  final int userId;
  final int roleId;
  final String? roleName;

  UserRoleAssignment({
    required this.id,
    required this.userId,
    required this.roleId,
    this.roleName,
  });

  factory UserRoleAssignment.fromJson(Map<String, dynamic> j) => UserRoleAssignment(
        id:       j['id'] ?? 0,
        userId:   j['user'] is int ? j['user'] : (j['user']?['id'] ?? 0),
        roleId:   j['role'] is int ? j['role'] : (j['role']?['id'] ?? 0),
        roleName: j['role_name'] ?? j['role']?['name'],
      );
}
