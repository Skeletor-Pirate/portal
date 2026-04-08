import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ── Constants ─────────────────────────────────
const String kBaseUrl = 'http://187.127.139.208:8081';

// ── Token Store (in-memory; swap for secure_storage in production) ────────
class TokenStore {
  static String? _access;
  static String? _refresh;

  static String? get access => _access;
  static String? get refresh => _refresh;

  static void save({required String access, required String refresh}) {
    _access = access;
    _refresh = refresh;
  }

  static void clear() {
    _access = null;
    _refresh = null;
  }

  static bool get hasTokens => _access != null;
}

// ── API Exception ─────────────────────────────
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

// ── Core HTTP Client ──────────────────────────
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _client = http.Client();

  // ── Helpers ─────────────────────────────────

  Map<String, String> _headers({bool auth = true}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (auth && TokenStore.access != null) {
      h['Authorization'] = 'Bearer ${TokenStore.access}';
    }
    return h;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('$kBaseUrl$path');
    if (query != null && query.isNotEmpty) {
      return uri.replace(
          queryParameters: query.map((k, v) => MapEntry(k, v.toString())));
    }
    return uri;
  }

  Future<dynamic> _parseResponse(http.Response res) async {
    if (res.statusCode == 401) {
      // Try refresh
      final refreshed = await _refreshToken();
      if (!refreshed) {
        TokenStore.clear();
        throw ApiException('Session expired. Please log in again.',
            statusCode: 401);
      }
      throw ApiException('Retry', statusCode: 401);
    }
    if (res.statusCode >= 400) {
      String msg = 'Request failed (${res.statusCode})';
      try {
        final body = jsonDecode(res.body);
        if (body is Map) {
          msg = body['detail'] ?? body['message'] ?? body.values.first?.toString() ?? msg;
        }
      } catch (_) {}
      throw ApiException(msg, statusCode: res.statusCode);
    }
    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = TokenStore.refresh;
    if (refreshToken == null) return false;
    try {
      final res = await _client.post(
        _uri('/api/v1/auth/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        TokenStore.save(
          access: data['access'],
          refresh: refreshToken,
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool auth = true}) async {
    final res =
        await _client.get(_uri(path, query), headers: _headers(auth: auth));
    return _parseResponse(res);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    final res = await _client.post(
      _uri(path),
      headers: _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _parseResponse(res);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final res = await _client.put(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _parseResponse(res);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final res = await _client.patch(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _parseResponse(res);
  }

  Future<dynamic> delete(String path) async {
    final res =
        await _client.delete(_uri(path), headers: _headers());
    return _parseResponse(res);
  }

  // ── Auth ─────────────────────────────────────

  /// POST /api/v1/auth/login/
  Future<AuthResult> login(String username, String password) async {
    final data = await post(
      '/api/v1/auth/login/',
      {'username': username, 'password': password},
      auth: false,
    );
    final result = AuthResult.fromJson(data);
    TokenStore.save(access: result.access, refresh: result.refresh);
    return result;
  }

  /// GET /api/v1/auth/me/
  Future<AuthMe> getMe() async {
    final data = await get('/api/v1/auth/me/');
    return AuthMe.fromJson(data);
  }

  /// GET /api/v1/profiles/me/
  Future<ProfileMe> getMyProfile() async {
    final data = await get('/api/v1/profiles/me/');
    return ProfileMe.fromJson(data);
  }

  // ── Students ─────────────────────────────────

  /// GET /api/v1/profiles/students/
  Future<PaginatedResult<StudentProfile>> getStudents({
    int page = 1,
    String? search,
  }) async {
    final q = <String, dynamic>{'page': page};
    if (search != null && search.isNotEmpty) q['search'] = search;
    final data = await get('/api/v1/profiles/students/', query: q);
    return PaginatedResult.fromJson(data, StudentProfile.fromJson);
  }

  // ── Teachers ─────────────────────────────────

  /// GET /api/v1/profiles/teachers/
  Future<PaginatedResult<TeacherProfile>> getTeachers({int page = 1}) async {
    final data =
        await get('/api/v1/profiles/teachers/', query: {'page': page});
    return PaginatedResult.fromJson(data, TeacherProfile.fromJson);
  }

  // ── Parents ──────────────────────────────────

  /// GET /api/v1/profiles/parents/
  Future<PaginatedResult<ParentProfile>> getParents({int page = 1}) async {
    final data =
        await get('/api/v1/profiles/parents/', query: {'page': page});
    return PaginatedResult.fromJson(data, ParentProfile.fromJson);
  }

  // ── Enrollments ──────────────────────────────

  /// GET /academics/enrollments/
  Future<PaginatedResult<Enrollment>> getEnrollments({
    int page = 1,
    String? classId,
  }) async {
    final q = <String, dynamic>{'page': page};
    if (classId != null) q['class_id'] = classId;
    final data = await get('/academics/enrollments/', query: q);
    return PaginatedResult.fromJson(data, Enrollment.fromJson);
  }

  // ── Teacher Assignments ───────────────────────

  /// GET /academics/teacher-assignments/
  Future<PaginatedResult<TeacherAssignment>> getTeacherAssignments(
      {int page = 1}) async {
    final data = await get('/academics/teacher-assignments/',
        query: {'page': page});
    return PaginatedResult.fromJson(data, TeacherAssignment.fromJson);
  }

  // ── Attendance ───────────────────────────────

  /// POST /operations/attendance/bulk-record/
  Future<void> bulkRecordAttendance(
      List<Map<String, dynamic>> records) async {
    await post('/operations/attendance/bulk-record/', {'records': records});
  }

  // ── Exams ────────────────────────────────────

  /// GET /api/v1/operations/exams/
  Future<PaginatedResult<Exam>> getExams({int page = 1}) async {
    final data =
        await get('/api/v1/operations/exams/', query: {'page': page});
    return PaginatedResult.fromJson(data, Exam.fromJson);
  }

  // ── Grades ───────────────────────────────────

  /// POST /api/v1/operations/grades/bulk-submit/
  Future<void> bulkSubmitGrades(List<Map<String, dynamic>> grades) async {
    await post('/api/v1/operations/grades/bulk-submit/', {'grades': grades});
  }

  // ── RBAC ─────────────────────────────────────

  /// GET /api/v1/accounts/
  Future<dynamic> getAccounts() async {
    return get('/api/v1/accounts/');
  }
}

// ── Models ────────────────────────────────────

class AuthResult {
  final String access;
  final String refresh;
  AuthResult({required this.access, required this.refresh});
  factory AuthResult.fromJson(Map<String, dynamic> j) =>
      AuthResult(access: j['access'] ?? '', refresh: j['refresh'] ?? '');
}

class AuthMe {
  final int id;
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
      [firstName, lastName].where((s) => s != null && s.isNotEmpty).join(' ');

  factory AuthMe.fromJson(Map<String, dynamic> j) => AuthMe(
        id: j['id'] ?? 0,
        username: j['username'] ?? '',
        email: j['email'] ?? '',
        role: (j['role'] ?? j['user_type'] ?? '').toString().toLowerCase(),
        firstName: j['first_name'],
        lastName: j['last_name'],
      );
}

class ProfileMe {
  final int id;
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
    final firstName = j['first_name'] ?? j['user']?['first_name'] ?? '';
    final lastName = j['last_name'] ?? j['user']?['last_name'] ?? '';
    final name = '$firstName $lastName'.trim();
    return ProfileMe(
      id: j['id'] ?? 0,
      displayName: name.isNotEmpty ? name : j['username'] ?? 'User',
      role: (j['role'] ?? j['user_type'] ?? '').toString(),
      schoolName: j['school']?['name'] ?? j['school_name'],
      idLabel: j['employee_id'] ?? j['student_id'] ?? j['staff_id'],
      raw: j,
    );
  }
}

class PaginatedResult<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  PaginatedResult({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedResult.fromJson(
      Map<String, dynamic> j, T Function(Map<String, dynamic>) fromJson) {
    final list = (j['results'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList();
    return PaginatedResult(
      count: j['count'] ?? list.length,
      next: j['next'],
      previous: j['previous'],
      results: list,
    );
  }
}

class StudentProfile {
  final int id;
  final String fullName;
  final String? gradeClass;
  final String? rollNumber;
  final String? attendancePct;

  StudentProfile({
    required this.id,
    required this.fullName,
    this.gradeClass,
    this.rollNumber,
    this.attendancePct,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> j) {
    final u = j['user'] ?? j;
    final first = u['first_name'] ?? '';
    final last = u['last_name'] ?? '';
    final name = '$first $last'.trim();
    return StudentProfile(
      id: j['id'] ?? 0,
      fullName: name.isNotEmpty ? name : u['username'] ?? 'Student',
      gradeClass: j['grade'] ?? j['class_name'] ?? j['current_class'],
      rollNumber: j['roll_number']?.toString() ?? j['student_id']?.toString(),
      attendancePct: j['attendance_percentage']?.toString(),
    );
  }
}

class TeacherProfile {
  final int id;
  final String fullName;
  final String? subject;
  final String? employeeId;

  TeacherProfile({
    required this.id,
    required this.fullName,
    this.subject,
    this.employeeId,
  });

  factory TeacherProfile.fromJson(Map<String, dynamic> j) {
    final u = j['user'] ?? j;
    final first = u['first_name'] ?? '';
    final last = u['last_name'] ?? '';
    final name = '$first $last'.trim();
    return TeacherProfile(
      id: j['id'] ?? 0,
      fullName: name.isNotEmpty ? name : u['username'] ?? 'Teacher',
      subject: j['subject'] ?? j['subjects']?.toString(),
      employeeId: j['employee_id']?.toString(),
    );
  }
}

class ParentProfile {
  final int id;
  final String fullName;
  final String? linkedStudent;

  ParentProfile({
    required this.id,
    required this.fullName,
    this.linkedStudent,
  });

  factory ParentProfile.fromJson(Map<String, dynamic> j) {
    final u = j['user'] ?? j;
    final first = u['first_name'] ?? '';
    final last = u['last_name'] ?? '';
    final name = '$first $last'.trim();
    return ParentProfile(
      id: j['id'] ?? 0,
      fullName: name.isNotEmpty ? name : u['username'] ?? 'Parent',
      linkedStudent: j['student_name'] ?? j['child_name'],
    );
  }
}

class Enrollment {
  final int id;
  final String studentName;
  final String? className;
  final String? status;

  Enrollment({
    required this.id,
    required this.studentName,
    this.className,
    this.status,
  });

  factory Enrollment.fromJson(Map<String, dynamic> j) => Enrollment(
        id: j['id'] ?? 0,
        studentName: j['student_name'] ?? j['student']?['name'] ?? 'Student',
        className: j['class_name'] ?? j['class'],
        status: j['status'],
      );
}

class TeacherAssignment {
  final int id;
  final String teacherName;
  final String? subject;
  final String? className;

  TeacherAssignment({
    required this.id,
    required this.teacherName,
    this.subject,
    this.className,
  });

  factory TeacherAssignment.fromJson(Map<String, dynamic> j) =>
      TeacherAssignment(
        id: j['id'] ?? 0,
        teacherName: j['teacher_name'] ?? j['teacher']?['name'] ?? 'Teacher',
        subject: j['subject'],
        className: j['class_name'] ?? j['class'],
      );
}

class Exam {
  final int id;
  final String name;
  final String? date;
  final String? subject;

  Exam({required this.id, required this.name, this.date, this.subject});

  factory Exam.fromJson(Map<String, dynamic> j) => Exam(
        id: j['id'] ?? 0,
        name: j['name'] ?? j['title'] ?? 'Exam',
        date: j['date'] ?? j['exam_date'],
        subject: j['subject'],
      );
}
