import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ── Constants ─────────────────────────────────
const String kBaseUrl = 'http://187.127.139.208:8081';

// ── Token Store ───────────────────────────────
class TokenStore {
  static String? _access;
  static String? _refresh;
  static String? get access => _access;
  static String? get refresh => _refresh;

  // This was missing and caused most of your build errors
  static bool get hasTokens => _access != null && _access!.isNotEmpty;

  static void save({required String access, required String refresh}) {
    _access = access;
    _refresh = refresh;
  }

  static void clear() {
    _access = null;
    _refresh = null;
  }
}

// ── API Exception ─────────────────────────────
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

// ── Api Service ───────────────────────────────
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _client = http.Client();

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
      final refreshed = await _refreshToken();
      if (!refreshed) {
        TokenStore.clear();
        throw ApiException('Session expired.', statusCode: 401);
      }
      throw ApiException('Retry', statusCode: 401);
    }
    if (res.statusCode >= 400) {
      String msg = 'Request failed';
      try {
        final body = jsonDecode(res.body);
        msg = body['detail'] ?? body['message'] ?? msg;
      } catch (_) {}
      throw ApiException(msg, statusCode: res.statusCode);
    }
    return res.body.isEmpty ? null : jsonDecode(res.body);
  }

  Future<bool> _refreshToken() async {
    if (TokenStore.refresh == null) return false;
    try {
      final res = await _client.post(_uri('/api/v1/auth/refresh/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh': TokenStore.refresh}));
      if (res.statusCode == 200) {
        TokenStore.save(access: jsonDecode(res.body)['access'], refresh: TokenStore.refresh!);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query, bool auth = true}) async {
    final res = await _client.get(_uri(path, query), headers: _headers(auth: auth));
    return _parseResponse(res);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final res = await _client.post(_uri(path), headers: _headers(auth: auth), body: jsonEncode(body));
    return _parseResponse(res);
  }

  // ── Auth & Registration ───────────────────────
  Future<AuthRegister> register(String username, String email, String password, String role) async {
    final data = await post('/api/v1/auth/register/', {
      'username': username,
      'email': email,
      'password': password,
      'user_type': role.toLowerCase(),
    }, auth: false);
    return AuthRegister.fromJson(data);
  }

  Future<AuthResult> login(String username, String password) async {
    final data = await post('/api/v1/auth/login/', {'username': username, 'password': password}, auth: false);
    final result = AuthResult.fromJson(data);
    TokenStore.save(access: result.access, refresh: result.refresh);
    return result;
  }

  // ── Dashboard Data Methods ───────────────────
  Future<ProfileMe> getMyProfile() async {
    final data = await get('/api/v1/profiles/me/');
    return ProfileMe.fromJson(data);
  }

  Future<PaginatedResult<StudentProfile>> getStudents({int page = 1, String? search}) async {
    // FIX: Using Map<String, dynamic> to allow both int and String
    final Map<String, dynamic> q = {'page': page};
    if (search != null) q['search'] = search;
    final data = await get('/api/v1/profiles/students/', query: q);
    return PaginatedResult.fromJson(data, StudentProfile.fromJson);
  }

  Future<PaginatedResult<TeacherProfile>> getTeachers({int page = 1}) async {
    final data = await get('/api/v1/profiles/teachers/', query: {'page': page});
    return PaginatedResult.fromJson(data, TeacherProfile.fromJson);
  }

  Future<PaginatedResult<ParentProfile>> getParents({int page = 1}) async {
    final data = await get('/api/v1/profiles/parents/', query: {'page': page});
    return PaginatedResult.fromJson(data, ParentProfile.fromJson);
  }
}

// ── Models ────────────────────────────────────

class AuthRegister {
  final int id;
  final String username, email;
  AuthRegister({required this.id, required this.username, required this.email});
  factory AuthRegister.fromJson(Map<String, dynamic> j) => AuthRegister(id: j['id'] ?? 0, username: j['username'] ?? '', email: j['email'] ?? '');
}

class AuthResult {
  final String access, refresh;
  AuthResult({required this.access, required this.refresh});
  factory AuthResult.fromJson(Map<String, dynamic> j) => AuthResult(access: j['access'] ?? '', refresh: j['refresh'] ?? '');
}

class ProfileMe {
  final int id;
  final String displayName, role;
  final String? schoolName;
  ProfileMe({required this.id, required this.displayName, required this.role, this.schoolName});
  factory ProfileMe.fromJson(Map<String, dynamic> j) {
    final first = j['first_name'] ?? j['user']?['first_name'] ?? '';
    final last = j['last_name'] ?? j['user']?['last_name'] ?? '';
    return ProfileMe(
      id: j['id'] ?? 0,
      displayName: '$first $last'.trim().isNotEmpty ? '$first $last'.trim() : j['username'] ?? 'User',
      role: (j['role'] ?? j['user_type'] ?? '').toString(),
      schoolName: j['school']?['name'] ?? j['school_name'],
    );
  }
}

class PaginatedResult<T> {
  final int count;
  final List<T> results;
  PaginatedResult({required this.count, required this.results});
  factory PaginatedResult.fromJson(Map<String, dynamic> j, T Function(Map<String, dynamic>) fromJson) {
    final list = (j['results'] as List? ?? []).whereType<Map<String, dynamic>>().map(fromJson).toList();
    return PaginatedResult(count: j['count'] ?? list.length, results: list);
  }
}

class StudentProfile {
  final int id;
  final String fullName;
  final String? attendancePct, gradeClass, rollNumber;
  StudentProfile({required this.id, required this.fullName, this.attendancePct, this.gradeClass, this.rollNumber});
  factory StudentProfile.fromJson(Map<String, dynamic> j) => StudentProfile(
    id: j['id'] ?? 0,
    fullName: '${j['first_name'] ?? ''} ${j['last_name'] ?? ''}'.trim(),
    attendancePct: j['attendance_percentage']?.toString(),
    gradeClass: j['grade'] ?? j['class_name'],
    rollNumber: j['roll_number']?.toString(),
  );
}

class TeacherProfile {
  final int id;
  final String fullName;
  final String? subject;
  TeacherProfile({required this.id, required this.fullName, this.subject});
  factory TeacherProfile.fromJson(Map<String, dynamic> j) => TeacherProfile(
    id: j['id'] ?? 0,
    fullName: '${j['first_name'] ?? ''} ${j['last_name'] ?? ''}'.trim(),
    subject: j['subject']?.toString(),
  );
}

class ParentProfile {
  final int id;
  final String fullName;
  final String? linkedStudent;
  ParentProfile({required this.id, required this.fullName, this.linkedStudent});
  factory ParentProfile.fromJson(Map<String, dynamic> j) => ParentProfile(
    id: j['id'] ?? 0,
    fullName: '${j['first_name'] ?? ''} ${j['last_name'] ?? ''}'.trim(),
    linkedStudent: j['student_name'] ?? j['child_name'],
  );
}

class Exam {
  final int id;
  final String name;
  Exam({required this.id, required this.name});
  factory Exam.fromJson(Map<String, dynamic> j) => Exam(id: j['id'] ?? 0, name: j['name'] ?? j['title'] ?? 'Exam');
}