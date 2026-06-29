import 'dart:convert';
import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'db_service.dart';
import 'ai_service.dart';
import 'config_service.dart';
import 'app_store.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG
// ─────────────────────────────────────────────────────────────────────────────

String get kBaseUrl {
  return ConfigService.serverUrl;
}

String get kAiBaseUrl {
  return ConfigService.aiUrl;
}

// ─────────────────────────────────────────────────────────────────────────────
// TOKEN STORE
// ─────────────────────────────────────────────────────────────────────────────

class TokenStore {
  static String? _access;
  static String? _refresh;

  static const String _keyAccess  = 'auth_access_token';
  static const String _keyRefresh = 'auth_refresh_token';

  static String? get access  => _access;
  static String? get refresh => _refresh;
  static bool   get hasTokens => _access != null;

  /// Load persisted tokens from SharedPreferences (call once at startup)
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _access  = prefs.getString(_keyAccess);
    _refresh = prefs.getString(_keyRefresh);
  }

  /// Save tokens in memory AND persist to disk
  static Future<void> save({required String access, required String refresh}) async {
    _access  = access;
    _refresh = refresh;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccess, access);
    await prefs.setString(_keyRefresh, refresh);
  }

  /// Clear tokens from memory AND disk
  static Future<void> clear() async {
    _access  = null;
    _refresh = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccess);
    await prefs.remove(_keyRefresh);
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

/// Internal sentinel thrown when a token refresh succeeds mid-request.
/// The HTTP layer catches this and retries the original request.
class _TokenRefreshedException implements Exception {}

// ─────────────────────────────────────────────────────────────────────────────
// CORE HTTP CLIENT
// ─────────────────────────────────────────────────────────────────────────────

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
    String base = kBaseUrl;
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    final baseUri = Uri.parse('$base$path');
    if (query != null && query.isNotEmpty) {
      return baseUri.replace(
          queryParameters: query.map((k, v) => MapEntry(k, v.toString())));
    }
    return baseUri;
  }

  Future<dynamic> _parse(http.Response res, {bool auth = true}) async {
    if (res.statusCode == 401 && auth) {
      final ok = await _tryRefresh();
      if (!ok) {
        await TokenStore.clear();
        throw ApiException('Session expired. Please log in again.', statusCode: 401);
      }
      // Token refreshed — caller should retry. Throw a typed sentinel.
      throw _TokenRefreshedException();
    }
    if (res.statusCode == 401 && !auth) {
      // Login endpoint 401 — wrong credentials
      String msg = 'Invalid email or password.';
      try {
        final b = jsonDecode(res.body);
        if (b is Map && b['detail'] != null) msg = b['detail'].toString();
      } catch (_) {}
      throw ApiException(msg, statusCode: 401);
    }
    if (res.statusCode >= 400) {
      String msg = 'Error ${res.statusCode}';
      try {
        final b = jsonDecode(res.body);
        if (b is Map) {
          if (b.containsKey('detail'))             msg = b['detail'].toString();
          else if (b.containsKey('message'))        msg = b['message'].toString();
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
        await TokenStore.save(access: d['access'], refresh: TokenStore.refresh!);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool auth = true}) async {
    try {
      final res = await _client.get(_uri(path, query), headers: _headers(auth: auth));
      return _parse(res, auth: auth);
    } on _TokenRefreshedException {
      // Retry once with new token
      final res = await _client.get(_uri(path, query), headers: _headers(auth: auth));
      return _parse(res, auth: auth);
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    try {
      final res = await _client.post(_uri(path), headers: _headers(auth: auth), body: jsonEncode(body));
      return _parse(res, auth: auth);
    } on _TokenRefreshedException {
      final res = await _client.post(_uri(path), headers: _headers(auth: auth), body: jsonEncode(body));
      return _parse(res, auth: auth);
    }
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    try {
      final res = await _client.put(_uri(path), headers: _headers(), body: jsonEncode(body));
      return _parse(res);
    } on _TokenRefreshedException {
      final res = await _client.put(_uri(path), headers: _headers(), body: jsonEncode(body));
      return _parse(res);
    }
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    try {
      final res = await _client.patch(_uri(path), headers: _headers(), body: jsonEncode(body));
      return _parse(res);
    } on _TokenRefreshedException {
      final res = await _client.patch(_uri(path), headers: _headers(), body: jsonEncode(body));
      return _parse(res);
    }
  }

  Future<void> delete(String path) async {
    try {
      final res = await _client.delete(_uri(path), headers: _headers());
      await _parse(res);
    } on _TokenRefreshedException {
      final res = await _client.delete(_uri(path), headers: _headers());
      await _parse(res);
    }
  }

  // ── FALLBACK HELPERS ─────────────────────────────────────────────────────

  Future<dynamic> _getWithFallback(String path, {String? fallback, Map<String, dynamic>? query, bool auth = true}) async {
    try {
      return await get(path, query: query, auth: auth);
    } on ApiException catch (e) {
      if (e.statusCode == 404 && fallback != null) return await get(fallback, query: query, auth: auth);
      rethrow;
    }
  }

  Future<dynamic> _postWithFallback(String path, Map<String, dynamic> body, {String? fallback, bool auth = true}) async {
    try {
      return await post(path, body, auth: auth);
    } on ApiException catch (e) {
      if (e.statusCode == 404 && fallback != null) return await post(fallback, body, auth: auth);
      rethrow;
    }
  }

  Future<dynamic> _patchWithFallback(String path, Map<String, dynamic> body, {String? fallback}) async {
    try {
      return await patch(path, body);
    } on ApiException catch (e) {
      if (e.statusCode == 404 && fallback != null) return await patch(fallback, body);
      rethrow;
    }
  }

  Future<void> _deleteWithFallback(String path, {String? fallback}) async {
    try {
      await delete(path);
    } on ApiException catch (e) {
      if (e.statusCode == 404 && fallback != null) {
        await delete(fallback);
        return;
      }
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AUTH
  // ─────────────────────────────────────────────────────────────────────────

  Future<AuthResult> login(String email, String password) async {
    // Backend uses EMAIL as USERNAME_FIELD (simplejwt TokenObtainPairView)
    final d = await post(
      '/api/v1/auth/login/',
      {'email': email, 'password': password},
      auth: false,
    );
    final r = AuthResult.fromJson(d);
    await TokenStore.save(access: r.access, refresh: r.refresh);
    return r;
  }

  /// GET /api/v1/auth/me/
  Future<AuthMe> getMe() async {
    final d = await get('/api/v1/auth/me/');
    return AuthMe.fromJson(d);
  }

  /// GET /api/v1/profiles/me/
  Future<ProfileContext> getProfileContext() async {
    final d = await _getWithFallback('/api/v1/profiles/me/', fallback: '/api/v1/users/me/');
    return ProfileContext.fromJson(d);
  }

  /// Legacy alias
  Future<ProfileMe> getMyProfile() async {
    try {
      final ctx = await getProfileContext();
      return ProfileMe(
        id: ctx.identity.id,
        displayName: ctx.identity.fullName,
        role: ctx.roles.isNotEmpty ? ctx.roles.first : '',
        schoolName: null,
        idLabel: null,
        raw: {},
      );
    } catch (_) {
      final me = await getMe();
      return ProfileMe(
        id: me.id,
        displayName: me.fullName,
        role: me.email,
        schoolName: me.schoolName,
        idLabel: null,
        raw: {},
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // USERS  /api/v1/accounts/users/
  // ─────────────────────────────────────────────────────────────────────────

  Future<PaginatedResult<TenantUser>> getUsers({int page = 1}) async {
    final d = await _getWithFallback('/api/v1/users/', fallback: '/api/v1/accounts/users/', query: {'page': page});
    return PaginatedResult.fromJson(d, TenantUser.fromJson);
  }

  Future<TenantUser> createUser(Map<String, dynamic> body) async {
    final d = await _postWithFallback(
      '/api/v1/users/', 
      body,
      fallback: '/api/v1/accounts/users/',
    );
    return TenantUser.fromJson(d);
  }

  Future<TenantUser> patchUser(String id, Map<String, dynamic> body) async {
    final d = await _patchWithFallback('/api/v1/users/$id/', body, fallback: '/api/v1/accounts/users/$id/');
    return TenantUser.fromJson(d);
  }

  Future<void> deleteUser(String id) => _deleteWithFallback('/api/v1/users/$id/', fallback: '/api/v1/accounts/users/$id/');

  // ─────────────────────────────────────────────────────────────────────────
  // PROFILES  /api/v1/profiles/
  // ─────────────────────────────────────────────────────────────────────────

  Future<PaginatedResult<StudentProfile>> getStudents({int page = 1, String? search}) async {
    final q = <String, dynamic>{'page': page};
    if (search != null && search.isNotEmpty) q['search'] = search;
    final d = await _getWithFallback('/api/v1/profiles/students/', fallback: '/api/v1/students/', query: q);
    return PaginatedResult.fromJson(d, StudentProfile.fromJson);
  }

  Future<StudentProfile> createStudent(Map<String, dynamic> body) async {
    final d = await _postWithFallback('/api/v1/profiles/students/', body, fallback: '/api/v1/students/');
    return StudentProfile.fromJson(d);
  }

  Future<StudentProfile> patchStudent(String id, Map<String, dynamic> body) async {
    final d = await _patchWithFallback('/api/v1/profiles/students/$id/', body, fallback: '/api/v1/students/$id/');
    return StudentProfile.fromJson(d);
  }

  Future<void> deleteStudent(String id) => _deleteWithFallback('/api/v1/profiles/students/$id/', fallback: '/api/v1/students/$id/');

  Future<PaginatedResult<TeacherProfile>> getTeachers({int page = 1}) async {
    final d = await get('/api/v1/profiles/teachers/', query: {'page': page});
    return PaginatedResult.fromJson(d, TeacherProfile.fromJson);
  }

  Future<TeacherProfile> createTeacher(Map<String, dynamic> body) async {
    final d = await _postWithFallback('/api/v1/profiles/teachers/', body, fallback: '/api/v1/teachers/');
    return TeacherProfile.fromJson(d);
  }

  Future<TeacherProfile> patchTeacher(String id, Map<String, dynamic> body) async {
    final d = await _patchWithFallback('/api/v1/profiles/teachers/$id/', body, fallback: '/api/v1/teachers/$id/');
    return TeacherProfile.fromJson(d);
  }

  Future<void> deleteTeacher(String id) => _deleteWithFallback('/api/v1/profiles/teachers/$id/', fallback: '/api/v1/teachers/$id/');

  Future<PaginatedResult<ParentProfile>> getParents({int page = 1}) async {
    final d = await _getWithFallback('/api/v1/profiles/parents/', fallback: '/api/v1/parents/', query: {'page': page});
    return PaginatedResult.fromJson(d, ParentProfile.fromJson);
  }

  Future<ParentProfile> createParent(Map<String, dynamic> body) async {
    final d = await _postWithFallback('/api/v1/profiles/parents/', body, fallback: '/api/v1/parents/');
    return ParentProfile.fromJson(d);
  }

  Future<ParentProfile> patchParent(String id, Map<String, dynamic> body) async {
    final d = await _patchWithFallback('/api/v1/profiles/parents/$id/', body, fallback: '/api/v1/parents/$id/');
    return ParentProfile.fromJson(d);
  }

  Future<void> deleteParent(String id) => _deleteWithFallback('/api/v1/profiles/parents/$id/', fallback: '/api/v1/parents/$id/');

  Future<PaginatedResult<ParentStudentMapping>> getParentStudentMappings({int page = 1}) async {
    final d = await _getWithFallback('/api/v1/profiles/parent-student-mappings/', fallback: '/api/v1/parent-student-mappings/', query: {'page': page});
    return PaginatedResult.fromJson(d, ParentStudentMapping.fromJson);
  }

  Future<ParentStudentMapping> createMapping(
    String parentId, String studentId, String relationship,
  ) async {
    final d = await _postWithFallback('/api/v1/profiles/parent-student-mappings/', {
      'parent': parentId,
      'student': studentId,
      'relationship': relationship,
    }, fallback: '/api/v1/parent-student-mappings/');
    return ParentStudentMapping.fromJson(d);
  }

  Future<void> deleteMapping(String id) =>
      _deleteWithFallback('/api/v1/profiles/parent-student-mappings/$id/', fallback: '/api/v1/parent-student-mappings/$id/');

  // ─────────────────────────────────────────────────────────────────────────
  // ACADEMICS  /api/v1/academics/
  // ─────────────────────────────────────────────────────────────────────────

  Future<PaginatedResult<AcademicYear>> getAcademicYears({int page = 1}) async {
    final d = await _getWithFallback('/api/v1/academics/academic-years/', fallback: '/api/v1/academic-years/', query: {'page': page});
    return PaginatedResult.fromJson(d, AcademicYear.fromJson);
  }

  Future<AcademicYear> createAcademicYear(Map<String, dynamic> body) async {
    final d = await _postWithFallback('/api/v1/academics/academic-years/', body, fallback: '/api/v1/academic-years/');
    return AcademicYear.fromJson(d);
  }

  Future<AcademicYear> patchAcademicYear(String id, Map<String, dynamic> body) async {
    final d = await _patchWithFallback('/api/v1/academics/academic-years/$id/', body, fallback: '/api/v1/academic-years/$id/');
    return AcademicYear.fromJson(d);
  }

  Future<void> deleteAcademicYear(String id) => _deleteWithFallback('/api/v1/academics/academic-years/$id/', fallback: '/api/v1/academic-years/$id/');

  Future<PaginatedResult<ClassLevel>> getClassLevels({int page = 1}) async {
    final d = await _getWithFallback('/api/v1/academics/class-levels/', fallback: '/api/v1/class-levels/', query: {'page': page});
    return PaginatedResult.fromJson(d, ClassLevel.fromJson);
  }

  Future<ClassLevel> createClassLevel(Map<String, dynamic> body) async {
    final d = await _postWithFallback('/api/v1/academics/class-levels/', body, fallback: '/api/v1/class-levels/');
    return ClassLevel.fromJson(d);
  }

  Future<void> deleteClassLevel(String id) => _deleteWithFallback('/api/v1/academics/class-levels/$id/', fallback: '/api/v1/class-levels/$id/');

  Future<PaginatedResult<Section>> getSections({int page = 1, String? classLevelId}) async {
    final q = <String, dynamic>{'page': page};
    if (classLevelId != null) q['class_level'] = classLevelId;
    final d = await _getWithFallback('/api/v1/academics/sections/', fallback: '/api/v1/sections/', query: q);
    return PaginatedResult.fromJson(d, Section.fromJson);
  }

  Future<Section> createSection(Map<String, dynamic> body) async {
    final d = await _postWithFallback('/api/v1/academics/sections/', body, fallback: '/api/v1/sections/');
    return Section.fromJson(d);
  }

  Future<void> deleteSection(String id) => _deleteWithFallback('/api/v1/academics/sections/$id/', fallback: '/api/v1/sections/$id/');

  Future<PaginatedResult<Subject>> getSubjects({int page = 1}) async {
    final d = await _getWithFallback('/api/v1/academics/subjects/', fallback: '/api/v1/subjects/', query: {'page': page});
    return PaginatedResult.fromJson(d, Subject.fromJson);
  }

  Future<Subject> createSubject(Map<String, dynamic> body) async {
    final d = await _postWithFallback('/api/v1/academics/subjects/', body, fallback: '/api/v1/subjects/');
    return Subject.fromJson(d);
  }

  Future<void> deleteSubject(String id) => _deleteWithFallback('/api/v1/academics/subjects/$id/', fallback: '/api/v1/subjects/$id/');

  Future<PaginatedResult<Enrollment>> getEnrollments({
    int page = 1, String? studentId, String? status, String? sectionId,
  }) async {
    final isTeacher = AppStore.instance.detectedProfileType == 'teacher';
    final q = <String, dynamic>{'page': page};
    if (studentId != null) q['student'] = studentId;
    if (status != null)    q['status']  = status;
    if (sectionId != null) q['section_id'] = sectionId;
    
    final endpoint = isTeacher 
        ? '/api/v1/academics/teacher-assignments/my-students/' 
        : '/api/v1/academics/enrollments/';
        
    final d = await _getWithFallback(endpoint, fallback: '/api/v1/enrollments/', query: q);
    return PaginatedResult.fromJson(d, Enrollment.fromJson);
  }

  Future<Enrollment> createEnrollment(Map<String, dynamic> body) async {
    final d = await _postWithFallback('/api/v1/academics/enrollments/', body, fallback: '/api/v1/enrollments/');
    return Enrollment.fromJson(d);
  }

  Future<void> deleteEnrollment(String id) => _deleteWithFallback('/api/v1/academics/enrollments/$id/', fallback: '/api/v1/enrollments/$id/');

  Future<String> bulkPromote({
    required List<String> studentIds,
    required String targetAcademicYearId,
    required String targetClassLevelId,
    required String targetSectionId,
  }) async {
    final d = await _postWithFallback('/api/v1/academics/enrollments/bulk-promote/', {
      'student_ids': studentIds,
      'target_academic_year_id': targetAcademicYearId,
      'target_class_level_id': targetClassLevelId,
      'target_section_id': targetSectionId,
    }, fallback: '/api/v1/enrollments/bulk-promote/');
    return d?['detail'] ?? 'Promoted successfully';
  }

  Future<PaginatedResult<TeacherAssignment>> getTeacherAssignments({
    int page = 1, String? teacherId, String? status,
  }) async {
    final q = <String, dynamic>{'page': page};
    if (teacherId != null) q['teacher'] = teacherId;
    if (status != null)    q['status']  = status;
    final d = await _getWithFallback('/api/v1/academics/teacher-assignments/', fallback: '/api/v1/teacher-assignments/', query: q);
    return PaginatedResult.fromJson(d, TeacherAssignment.fromJson);
  }

  Future<TeacherAssignment> createTeacherAssignment(Map<String, dynamic> body) async {
    final d = await _postWithFallback('/api/v1/academics/teacher-assignments/', body, fallback: '/api/v1/teacher-assignments/');
    return TeacherAssignment.fromJson(d);
  }

  Future<void> deleteTeacherAssignment(String id) =>
      _deleteWithFallback('/api/v1/academics/teacher-assignments/$id/', fallback: '/api/v1/teacher-assignments/$id/');

  // ─────────────────────────────────────────────────────────────────────────
  // OPERATIONS  /api/v1/operations/
  // ─────────────────────────────────────────────────────────────────────────

  Future<PaginatedResult<SchoolAssignment>> getAssignments({
    int page = 1, String? sectionId,
  }) async {
    try {
      final isTeacher = AppStore.instance.detectedProfileType == 'teacher';
      final endpoint = isTeacher
          ? '/api/v1/operations/assignments/me/teacher/'
          : '/api/v1/operations/assignments/';
          
      final d = await _getWithFallback(endpoint, fallback: endpoint, query: {'page': page});
      final result = PaginatedResult.fromJson(d, SchoolAssignment.fromJson);
      
      if (sectionId != null) {
        final filtered = result.results.where((a) => a.sectionId == sectionId).toList();
        return PaginatedResult(count: filtered.length, next: result.next, previous: result.previous, results: filtered);
      }
      return result;
    } catch (e) {
      return PaginatedResult(count: 0, next: null, previous: null, results: []);
    }
  }

  Future<SchoolAssignment> createAssignment(Map<String, dynamic> body) async {
    final d = await _postWithFallback('/api/v1/operations/assignments/', body, fallback: '/api/v1/assignments/');
    return SchoolAssignment.fromJson(d);
  }

  Future<PaginatedResult<AssignmentSubmission>> getSubmissions({
    int page = 1, String? studentId, String? assignmentId,
  }) async {
    final q = <String, dynamic>{'page': page};
    if (studentId != null) q['student'] = studentId;
    if (assignmentId != null) q['assignment'] = assignmentId;
    try {
      final d = await _getWithFallback('/api/v1/operations/submissions/', fallback: '/api/v1/submissions/', query: q);
      return PaginatedResult.fromJson(d, AssignmentSubmission.fromJson);
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        return PaginatedResult(count: 0, next: null, previous: null, results: []);
      }
      rethrow;
    }
  }

  Future<PaginatedResult<AssignmentSubmission>> getStudentSubmissions({int page = 1}) async {
    try {
      final d = await get('/api/v1/operations/submissions/me/', query: {'page': page});
      return PaginatedResult.fromJson(d, AssignmentSubmission.fromJson);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        final studentId = AppStore.instance.studentProfileId;
        if (studentId == null) {
          return PaginatedResult(count: 0, next: null, previous: null, results: []);
        }
        return getSubmissions(page: page, studentId: studentId);
      }
      rethrow;
    }
  }

  Future<AssignmentSubmission> submitAssignment(Map<String, dynamic> body) async {
    final d = await _postWithFallback('/api/v1/operations/submissions/', body, fallback: '/api/v1/submissions/');
    return AssignmentSubmission.fromJson(d);
  }

  Future<Map<String, dynamic>> requestSubmissionUploadUrl(
    String assignmentId,
    String fileName,
    String contentType,
  ) async {
    return await post('/api/v1/operations/submissions/request-upload/', {
      'assignment_id': assignmentId,
      'file_name': fileName,
      'content_type': contentType,
    });
  }

  Future<void> uploadBytesToSignedUrl(String uploadUrl, List<int> bytes, String contentType) async {
    final uri = Uri.parse(uploadUrl);
    final res = await http.put(uri, headers: {'Content-Type': contentType}, body: bytes);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('Upload failed with status ${res.statusCode}', statusCode: res.statusCode);
    }
  }

  String _extractFilePathFromUploadUrl(String uploadUrl) {
    final uri = Uri.parse(uploadUrl);
    var path = uri.path;
    if (path.startsWith('/')) path = path.substring(1);
    final segments = path.split('/');
    if (segments.length <= 1) return path;
    return segments.sublist(1).join('/');
  }

  Future<AssignmentSubmission> confirmSubmission(String assignmentId, String filePath) async {
    final d = await post('/api/v1/operations/submissions/confirm/', {
      'assignment_id': assignmentId,
      'file_path': filePath,
    });
    return AssignmentSubmission.fromJson(d);
  }

  Future<AssignmentSubmission> submitAssignmentFile({
    required String assignmentId,
    required String studentId,
    required String fileName,
    required List<int> bytes,
    required String contentType,
  }) async {
    try {
      final uploadData = await requestSubmissionUploadUrl(assignmentId, fileName, contentType);
      final uploadUrl = uploadData['upload_url']?.toString();
      if (uploadUrl == null) {
        throw ApiException('Missing upload URL from backend');
      }
      await uploadBytesToSignedUrl(uploadUrl, bytes, contentType);
      final filePath = _extractFilePathFromUploadUrl(uploadUrl);
      return await confirmSubmission(assignmentId, filePath);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        // Fallback to direct multipart upload for older backend versions.
        final url = _uri('/api/v1/operations/submissions/');
        final request = http.MultipartRequest('POST', url);
        final headers = _headers();
        headers.remove('Content-Type');
        request.headers.addAll(headers);
        request.fields['assignment'] = assignmentId;
        request.fields['student'] = studentId;
        request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));
        final streamed = await request.send();
        final response = await http.Response.fromStream(streamed);
        final parsed = await _parse(response);
        return AssignmentSubmission.fromJson(parsed);
      }
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STUDENT SPECIFIC
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getStudentDashboard() async {
    return await get('/api/v1/profiles/students/dashboard/');
  }

  Future<PaginatedResult<Subject>> getStudentSubjects() async {
    try {
      final d = await get('/api/v1/profiles/students/me/subjects/');
      if (d is Map<String, dynamic> && d.containsKey('results')) {
        return PaginatedResult.fromJson(d, Subject.fromJson);
      }
      return PaginatedResult(count: 0, next: null, previous: null, results: []);
    } catch (e) {
      return PaginatedResult(count: 0, next: null, previous: null, results: []);
    }
  }

  Future<AttendanceSummaryData> getAttendanceSummary() async {
    try {
      final d = await get('/api/v1/operations/attendance/me/summary/');
      return AttendanceSummaryData.fromJson(d);
    } catch (e) {
      return AttendanceSummaryData();
    }
  }

  Future<PaginatedResult<AttendanceRecord>> getStudentAttendanceRecords({int page = 1}) async {
    try {
      final d = await get('/api/v1/operations/attendance/me/', query: {'page': page});
      return PaginatedResult.fromJson(d, AttendanceRecord.fromJson);
    } catch (e) {
      return PaginatedResult(count: 0, next: null, previous: null, results: []);
    }
  }

  Future<PaginatedResult<StudentGrade>> getStudentGrades({int page = 1}) async {
    try {
      final d = await get('/api/v1/operations/grades/me/', query: {'page': page});
      return PaginatedResult.fromJson(d, StudentGrade.fromJson);
    } catch (e) {
      return PaginatedResult(count: 0, next: null, previous: null, results: []);
    }
  }

  Future<ReportCardData> getReportCard() async {
    try {
      final d = await get('/api/v1/operations/grades/me/report-card/');
      return ReportCardData.fromJson(d);
    } catch (e) {
      return ReportCardData();
    }
  }

  Future<PaginatedResult<SchoolAssignment>> getStudentAssignments({int page = 1}) async {
    try {
      final d = await get('/api/v1/operations/assignments/me/', query: {'page': page});
      return PaginatedResult.fromJson(d, SchoolAssignment.fromJson);
    } catch (e) {
      return PaginatedResult(count: 0, next: null, previous: null, results: []);
    }
  }

  Future<PaginatedResult<SchoolAssignment>> getUpcomingAssignments() async {
    try {
      final d = await get('/api/v1/operations/assignments/me/upcoming/');
      return PaginatedResult.fromJson(d, SchoolAssignment.fromJson);
    } catch (e) {
      return PaginatedResult(count: 0, next: null, previous: null, results: []);
    }
  }


  Future<PaginatedResult<AttendanceRecord>> getAttendance({
    int page = 1, String? studentId, String? date, String? sectionId,
  }) async {
    final q = <String, dynamic>{'page': page};
    if (studentId != null) q['student'] = studentId;
    if (date != null)      q['date']    = date;
    if (sectionId != null) q['section'] = sectionId;
    final d = await _getWithFallback('/api/v1/operations/attendance/', fallback: '/api/v1/attendance/', query: q);
    return PaginatedResult.fromJson(d, AttendanceRecord.fromJson);
  }

  /// Bulk record attendance — exactly matches BulkAttendanceSerializer
  Future<String> bulkRecordAttendance({
    required String academicYearId,
    required String classLevelId,
    required String sectionId,
    required String date,
    required List<Map<String, dynamic>> records,
  }) async {
    final d = await _postWithFallback('/api/v1/operations/attendance/bulk-record/', {
      'academic_year_id': academicYearId,
      'class_level_id':   classLevelId,
      'section_id':       sectionId,
      'date':             date,
      'records':          records,
    }, fallback: '/api/v1/attendance/bulk-record/');
    return d?['detail'] ?? 'Attendance recorded';
  }

  Future<PaginatedResult<Exam>> getExams({int page = 1}) async {
    final d = await _getWithFallback('/api/v1/operations/exams/', fallback: '/api/v1/exams/', query: {'page': page});
    return PaginatedResult.fromJson(d, Exam.fromJson);
  }

  Future<Exam> createExam(Map<String, dynamic> body) async {
    final d = await _postWithFallback('/api/v1/operations/exams/', body, fallback: '/api/v1/exams/');
    return Exam.fromJson(d);
  }

  Future<Exam> patchExam(String id, Map<String, dynamic> body) async {
    final d = await _patchWithFallback('/api/v1/operations/exams/$id/', body, fallback: '/api/v1/exams/$id/');
    return Exam.fromJson(d);
  }

  Future<void> deleteExam(String id) => _deleteWithFallback('/api/v1/operations/exams/$id/', fallback: '/api/v1/exams/$id/');

  Future<PaginatedResult<StudentGrade>> getGrades({
    int page = 1, String? studentId, String? examId, String? subjectId,
  }) async {
    final q = <String, dynamic>{'page': page};
    if (studentId != null) q['student'] = studentId;
    if (examId != null)    q['exam']    = examId;
    if (subjectId != null) q['subject'] = subjectId;
    final d = await _getWithFallback('/api/v1/operations/grades/', fallback: '/api/v1/grades/', query: q);
    return PaginatedResult.fromJson(d, StudentGrade.fromJson);
  }

  /// Bulk submit grades — exactly matches BulkGradeSubmitSerializer
  Future<String> bulkSubmitGrades({
    required String examId,
    required String subjectId,
    required String sectionId,
    required List<Map<String, dynamic>> records,
  }) async {
    final d = await post('/api/v1/operations/grades/bulk-submit/', {
      'exam_id':    examId,
      'subject_id': subjectId,
      'section_id': sectionId,
      'records':    records,
    });
    return d?['detail'] ?? 'Grades submitted';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ACCOUNTS  /api/v1/accounts/
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<AppPermission>> getPermissions() async {
    final d = await _getWithFallback('/api/v1/accounts/permissions/', fallback: '/api/v1/permissions/');
    if (d is List) return d.whereType<Map<String, dynamic>>().map(AppPermission.fromJson).toList();
    return PaginatedResult.fromJson(d, AppPermission.fromJson).results;
  }

  Future<PaginatedResult<AppRole>> getRoles({int page = 1}) async {
    final d = await _getWithFallback('/api/v1/accounts/roles/', fallback: '/api/v1/roles/', query: {'page': page});
    return PaginatedResult.fromJson(d, AppRole.fromJson);
  }

  Future<AppRole> createRole(Map<String, dynamic> body) async {
    final d = await _postWithFallback('/api/v1/accounts/roles/', body, fallback: '/api/v1/roles/');
    return AppRole.fromJson(d);
  }

  Future<AppRole> patchRole(String id, Map<String, dynamic> body) async {
    final d = await _patchWithFallback('/api/v1/accounts/roles/$id/', body, fallback: '/api/v1/roles/$id/');
    return AppRole.fromJson(d);
  }

  Future<void> deleteRole(String id) => _deleteWithFallback('/api/v1/accounts/roles/$id/', fallback: '/api/v1/roles/$id/');

  Future<PaginatedResult<UserRoleAssignment>> getUserRoles({
    int page = 1, String? userId, String? roleId,
  }) async {
    final q = <String, dynamic>{'page': page};
    if (userId != null) q['user'] = userId;
    if (roleId != null) q['role'] = roleId;
    final d = await _getWithFallback('/api/v1/accounts/user-roles/', fallback: '/api/v1/user-roles/', query: q);
    return PaginatedResult.fromJson(d, UserRoleAssignment.fromJson);
  }

  Future<UserRoleAssignment> assignUserRole(String userId, String roleId) async {
    final d = await _postWithFallback('/api/v1/accounts/user-roles/', {
      'user': userId,
      'role': roleId,
    }, fallback: '/api/v1/user-roles/');
    return UserRoleAssignment.fromJson(d);
  }

  Future<UserRoleAssignment> createUserRole(Map<String, dynamic> body) async {
    final d = await _postWithFallback('/api/v1/accounts/user-roles/', body, fallback: '/api/v1/user-roles/');
    return UserRoleAssignment.fromJson(d);
  }

  Future<void> removeUserRole(String id) => _deleteWithFallback('/api/v1/accounts/user-roles/$id/', fallback: '/api/v1/user-roles/$id/');

  // ─────────────────────────────────────────────────────────────────────────
  // AI TOOLS  /api/v1/generate_*
  // ─────────────────────────────────────────────────────────────────────────

  Future<dynamic> _callAiApi(String path, Map<String, dynamic> body) async {
    String baseAi = kAiBaseUrl;
    if (baseAi.endsWith('/')) baseAi = baseAi.substring(0, baseAi.length - 1);
    final uri = Uri.parse('$baseAi$path');
    final h = <String, String>{'Content-Type': 'application/json'};
    if (TokenStore.access != null) {
      h['Authorization'] = 'Bearer ${TokenStore.access}';
    }
    try {
      final res = await _client.post(uri, headers: h, body: jsonEncode(body));
      if (res.statusCode >= 400) {
        throw ApiException('AI API Error ${res.statusCode}', statusCode: res.statusCode);
      }
      return jsonDecode(res.body);
    } catch (e) {
      // Fallback to main API base url if AI port fails
      final fallbackRes = await post(path, body);
      return fallbackRes;
    }
  }

  Future<dynamic> generateLessonPlan(Map<String, dynamic> payload) async => await AiService.generateLessonPlan(payload);
  Future<dynamic> generateWorksheet(Map<String, dynamic> payload) async => await AiService.generateWorksheet(payload);
  Future<dynamic> evaluateWorksheet(Map<String, dynamic> payload) async => await AiService.evaluateWorksheet(payload);
  Future<dynamic> generateQuiz(Map<String, dynamic> payload) async => await AiService.generateQuiz(payload);
  Future<dynamic> generateQuestionPaper(Map<String, dynamic> payload) async => await AiService.generateQuestionPaper(payload);
  Future<dynamic> generateStudyNotes(Map<String, dynamic> payload) async => await AiService.generateStudyNotes(payload);
  Future<dynamic> generatePresentationOutline(Map<String, dynamic> payload) async => await AiService.generatePresentationOutline(payload);
  Future<dynamic> generateRubric(Map<String, dynamic> payload) async => await AiService.generateRubric(payload);

  Future<String> askAI(String prompt) async {
    try {
      final res = await post('/api/v1/operations/ai-chat/', {'prompt': prompt});
      return res['reply'] as String;
    } catch (e) {
      return 'Sorry, I am having trouble connecting to the AI server right now. Error: $e';
    }
  }

  Future<dynamic> saveAIContent({
    required String className,
    required String subject,
    required String contentType,
    required dynamic data,
  }) async {
    return await _postWithFallback('/api/v1/academics/saved-ai-content/', {
      'class_name': className,
      'subject': subject,
      'content_type': contentType,
      'data': data,
    }, fallback: '/api/v1/saved-ai-content/');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PROFILE PICTURE  —  R2 upload flow
  // ─────────────────────────────────────────────────────────────────────────

  /// Step 1: Get a presigned upload URL from the backend
  Future<Map<String, dynamic>> getProfileImageUploadUrl({
    required String fileName,
    required String contentType,
    required String profileType,
  }) async {
    final d = await post('/api/v1/uploads/profile-image/', {
      'file_name': fileName,
      'content_type': contentType,
      'profile_type': profileType,
    });
    return Map<String, dynamic>.from(d);
  }

  /// Step 2: Upload file bytes directly to R2 using the presigned URL
  Future<void> uploadToR2(String uploadUrl, List<int> bytes, String contentType) async {
    final res = await _client.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: bytes,
    );
    if (res.statusCode >= 400) {
      throw ApiException('Upload to R2 failed (${res.statusCode})', statusCode: res.statusCode);
    }
  }

  /// Step 3: Update profile with the uploaded file path
  Future<Map<String, dynamic>> updateProfilePicture({
    required String profileType,
    required String filePath,
  }) async {
    final d = await patch('/api/v1/profiles/${profileType}s/me/', {
      'profile_picture': filePath,
    });
    return Map<String, dynamic>.from(d);
  }

  /// Step 4: Fetch profile picture presigned URL for display
  Future<Map<String, dynamic>> fetchProfilePictureUrl(String profileType) async {
    final d = await get('/api/v1/profiles/me/picture/', query: {
      'profile_type': profileType,
    });
    return Map<String, dynamic>.from(d);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODELS  —  All IDs are String (UUID) to match backend
// ─────────────────────────────────────────────────────────────────────────────

class AuthResult {
  final String access;
  final String refresh;
  AuthResult({required this.access, required this.refresh});
  factory AuthResult.fromJson(Map<String, dynamic> j) =>
      AuthResult(access: j['access'] ?? '', refresh: j['refresh'] ?? '');
}

class AuthMe {
  final String  id;
  final String  email;
  final String  firstName;
  final String  lastName;
  final String? schoolId;
  final String? schoolName;
  final String? schoolSubdomain;
  final bool    isStaff;

  AuthMe({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.schoolId,
    this.schoolName,
    this.schoolSubdomain,
    this.isStaff = false,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory AuthMe.fromJson(Map<String, dynamic> j) => AuthMe(
        id:              j['id']?.toString() ?? '',
        email:           j['email'] ?? '',
        firstName:       j['first_name'] ?? '',
        lastName:        j['last_name'] ?? '',
        schoolId:        j['school']?.toString(),
        schoolName:      j['school_name']?.toString(),
        schoolSubdomain: j['school_subdomain']?.toString(),
        isStaff:         j['is_staff'] == true,
      );
}

class ProfileContext {
  final ProfileIdentity identity;
  final List<String>    roles;
  final bool            isSuperuser;
  final ProfileLinks    profiles;

  ProfileContext({
    required this.identity,
    required this.roles,
    required this.isSuperuser,
    required this.profiles,
  });

  factory ProfileContext.fromJson(Map<String, dynamic> j) => ProfileContext(
        identity:    ProfileIdentity.fromJson(j['identity'] ?? {}),
        roles:       (j['roles'] as List? ?? []).map((e) => e.toString()).toList(),
        isSuperuser: j['is_superuser'] == true,
        profiles:    ProfileLinks.fromJson(j['profiles'] ?? {}),
      );
}

class ProfileIdentity {
  final String  id;
  final String  email;
  final String  firstName;
  final String  lastName;
  final String? schoolId;

  ProfileIdentity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.schoolId,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory ProfileIdentity.fromJson(Map<String, dynamic> j) => ProfileIdentity(
        id:        j['id']?.toString() ?? '',
        email:     j['email'] ?? '',
        firstName: j['first_name'] ?? '',
        lastName:  j['last_name'] ?? '',
        schoolId:  j['school_id']?.toString(),
      );
}

class ProfileLinks {
  final ProfileLink student;
  final ProfileLink teacher;
  final ProfileLink parent;

  ProfileLinks({required this.student, required this.teacher, required this.parent});

  factory ProfileLinks.fromJson(Map<String, dynamic> j) => ProfileLinks(
        student: ProfileLink.fromJson(j['student'] ?? {}),
        teacher: ProfileLink.fromJson(j['teacher'] ?? {}),
        parent:  ProfileLink.fromJson(j['parent']  ?? {}),
      );
}

class ProfileLink {
  final bool    exists;
  final String? id;
  ProfileLink({required this.exists, this.id});
  factory ProfileLink.fromJson(Map<String, dynamic> j) => ProfileLink(
        exists: j['exists'] == true,
        id:     j['id']?.toString(),
      );
}

/// Legacy ProfileMe kept so existing screens compile unchanged
class ProfileMe {
  final String  id;
  final String  displayName;
  final String  role;
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
}

// ── Pagination ─────────────────────────────────────────────────────────────

class PaginatedResult<T> {
  final int     count;
  final String? next;
  final String? previous;
  final List<T> results;

  PaginatedResult({required this.count, this.next, this.previous, required this.results});
  bool get hasMore => next != null;

  factory PaginatedResult.fromJson(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
    if (raw is List) {
      final list = raw.whereType<Map<String, dynamic>>().map(fromJson).toList();
      return PaginatedResult(count: list.length, results: list);
    }
    final j = raw as Map<String, dynamic>;
    final list = (j['results'] as List? ?? []).whereType<Map<String, dynamic>>().map(fromJson).toList();
    return PaginatedResult(count: j['count'] ?? list.length, next: j['next'], previous: j['previous'], results: list);
  }
}

// ── TenantUser ─────────────────────────────────────────────────────────────

class TenantUser {
  final String  id;
  final String  email;
  final String  firstName;
  final String  lastName;
  final String? schoolId;
  final String? schoolName;
  final bool    isStaff;

  TenantUser({required this.id, required this.email, required this.firstName, required this.lastName, this.schoolId, this.schoolName, this.isStaff = false});

  String get fullName => '$firstName $lastName'.trim();

  factory TenantUser.fromJson(Map<String, dynamic> j) => TenantUser(
        id: j['id']?.toString() ?? '',
        email: j['email'] ?? '',
        firstName: j['first_name'] ?? '',
        lastName: j['last_name'] ?? '',
        schoolId: j['school']?.toString(),
        schoolName: j['school_name']?.toString(),
        isStaff: j['is_staff'] == true,
      );
}

// ── StudentProfile ─────────────────────────────────────────────────────────

class StudentProfile {
  final String  id;
  final String  fullName;
  final String? enrollmentNumber;
  final String? bloodGroup;
  final String? phone;
  final String? email;
  final String? userId;
  final bool    isArchived;
  final Map<String, dynamic> raw;

  StudentProfile({required this.id, required this.fullName, this.enrollmentNumber, this.bloodGroup, this.phone, this.email, this.userId, this.isArchived = false, required this.raw});

  // Legacy getters used by existing UI without changes
  String? get gradeClass    => null;
  String? get rollNumber    => enrollmentNumber;
  String? get attendancePct => null;

  factory StudentProfile.fromJson(Map<String, dynamic> j) {
    final uRaw  = j['user'];
    final u     = uRaw is Map<String, dynamic> ? uRaw : <String, dynamic>{};
    final first = (u['first_name'] ?? j['first_name'] ?? '').toString();
    final last  = (u['last_name']  ?? j['last_name']  ?? '').toString();
    final name  = '$first $last'.trim();
    return StudentProfile(
      id:               j['id']?.toString() ?? '',
      fullName:         name.isNotEmpty ? name : 'Student',
      enrollmentNumber: j['enrollment_number']?.toString(),
      bloodGroup:       j['blood_group']?.toString(),
      phone:            j['phone_number']?.toString(),
      email:            (u['email'] ?? j['email'])?.toString(),
      userId:           uRaw is String ? uRaw : (u['id'] ?? j['user'])?.toString(),
      isArchived:       j['is_archived'] == true,
      raw:              j,
    );
  }
}

// ── TeacherProfile ─────────────────────────────────────────────────────────

class TeacherProfile {
  final String  id;
  final String  fullName;
  final String? employeeId;
  final String? qualification;
  final String? joiningDate;
  final String? email;
  final String? userId;
  final Map<String, dynamic> raw;

  TeacherProfile({required this.id, required this.fullName, this.employeeId, this.qualification, this.joiningDate, this.email, this.userId, required this.raw});

  // Legacy getter
  String? get subject => qualification;

  factory TeacherProfile.fromJson(Map<String, dynamic> j) {
    final uRaw  = j['user'];
    final u     = uRaw is Map<String, dynamic> ? uRaw : <String, dynamic>{};
    final first = (u['first_name'] ?? j['first_name'] ?? '').toString();
    final last  = (u['last_name']  ?? j['last_name']  ?? '').toString();
    final name  = '$first $last'.trim();
    return TeacherProfile(
      id:            j['id']?.toString() ?? '',
      fullName:      name.isNotEmpty ? name : 'Teacher',
      employeeId:    j['employee_id']?.toString(),
      qualification: j['qualification']?.toString(),
      joiningDate:   j['joining_date']?.toString(),
      email:         (u['email'] ?? j['email'])?.toString(),
      userId:        uRaw is String ? uRaw : (u['id'] ?? j['user'])?.toString(),
      raw:           j,
    );
  }
}

// ── ParentProfile ──────────────────────────────────────────────────────────

class ParentProfile {
  final String  id;
  final String  fullName;
  final String? occupation;
  final String? emergencyContact;
  final String? email;
  final String? userId;
  final Map<String, dynamic> raw;

  ParentProfile({required this.id, required this.fullName, this.occupation, this.emergencyContact, this.email, this.userId, required this.raw});

  // Legacy getter
  String? get linkedStudent => null;

  factory ParentProfile.fromJson(Map<String, dynamic> j) {
    final uRaw  = j['user'];
    final u     = uRaw is Map<String, dynamic> ? uRaw : <String, dynamic>{};
    final first = (u['first_name'] ?? j['first_name'] ?? '').toString();
    final last  = (u['last_name']  ?? j['last_name']  ?? '').toString();
    final name  = '$first $last'.trim();
    return ParentProfile(
      id:               j['id']?.toString() ?? '',
      fullName:         name.isNotEmpty ? name : 'Parent',
      occupation:       j['occupation']?.toString(),
      emergencyContact: j['emergency_contact_number']?.toString(),
      email:            (u['email'] ?? j['email'])?.toString(),
      userId:           uRaw is String ? uRaw : (u['id'] ?? j['user'])?.toString(),
      raw:              j,
    );
  }
}

// ── ParentStudentMapping ───────────────────────────────────────────────────

class ParentStudentMapping {
  final String  id;
  final String  parentId;
  final String  studentId;
  final String? parentEmail;
  final String? studentName;
  final String  relationship;
  final bool    isPrimaryContact;
  final bool    canViewAcademics;
  final bool    canPayFees;

  ParentStudentMapping({required this.id, required this.parentId, required this.studentId, this.parentEmail, this.studentName, this.relationship = 'Guardian', this.isPrimaryContact = true, this.canViewAcademics = true, this.canPayFees = true});

  factory ParentStudentMapping.fromJson(Map<String, dynamic> j) => ParentStudentMapping(
        id:               j['id']?.toString() ?? '',
        parentId:         j['parent']?.toString() ?? '',
        studentId:        j['student']?.toString() ?? '',
        parentEmail:      j['user_email']?.toString(),
        studentName:      j['student_name']?.toString(),
        relationship:     j['relationship']?.toString() ?? 'Guardian',
        isPrimaryContact: j['is_primary_contact'] != false,
        canViewAcademics: j['can_view_academics'] != false,
        canPayFees:       j['can_pay_fees'] != false,
      );
}

// ── AcademicYear ───────────────────────────────────────────────────────────

class AcademicYear {
  final String id;
  final String name;
  final String startDate;
  final String endDate;
  final bool   isActive;

  AcademicYear({required this.id, required this.name, required this.startDate, required this.endDate, this.isActive = false});

  factory AcademicYear.fromJson(Map<String, dynamic> j) => AcademicYear(
        id:        j['id']?.toString() ?? '',
        name:      j['name'] ?? '',
        startDate: j['start_date'] ?? '',
        endDate:   j['end_date'] ?? '',
        isActive:  j['is_active'] == true,
      );
}

// ── ClassLevel ─────────────────────────────────────────────────────────────

class ClassLevel {
  final String id;
  final String name;
  final int    numericOrder;

  ClassLevel({required this.id, required this.name, required this.numericOrder});

  factory ClassLevel.fromJson(Map<String, dynamic> j) => ClassLevel(
        id:           j['id']?.toString() ?? '',
        name:         j['name'] ?? '',
        numericOrder: j['numeric_order'] ?? 0,
      );
}

// ── Section ────────────────────────────────────────────────────────────────

class Section {
  final String  id;
  final String  name;
  final String  classLevelId;
  final String? classLevelName;

  Section({required this.id, required this.name, required this.classLevelId, this.classLevelName});

  factory Section.fromJson(Map<String, dynamic> j) => Section(
        id:             j['id']?.toString() ?? '',
        name:           j['name'] ?? '',
        classLevelId:   j['class_level']?.toString() ?? '',
        classLevelName: j['class_level_name']?.toString(),
      );
}

// ── Subject ────────────────────────────────────────────────────────────────

class Subject {
  final String  id;
  final String  name;
  final String? code;

  Subject({required this.id, required this.name, this.code});

  factory Subject.fromJson(Map<String, dynamic> j) => Subject(
        id:   j['id']?.toString() ?? '',
        name: j['name'] ?? '',
        code: j['code']?.toString(),
      );
}

// ── Enrollment ─────────────────────────────────────────────────────────────

class Enrollment {
  final String  id;
  final String  studentId;
  final String  studentName;
  final String? enrollmentNo;
  final String  academicYearId;
  final String? academicYearName;
  final String  classLevelId;
  final String? classLevelName;
  final String  sectionId;
  final String? sectionName;
  final String? rollNumber;
  final String? enrollmentDate;
  final Map<String, dynamic> raw;

  Enrollment({required this.id, required this.studentId, required this.studentName, this.enrollmentNo, required this.academicYearId, this.academicYearName, required this.classLevelId, this.classLevelName, required this.sectionId, this.sectionName, this.rollNumber, this.enrollmentDate, required this.raw});

  // Legacy getters
  String? get className => classLevelName != null && sectionName != null ? '${classLevelName!} ${sectionName!}' : classLevelName ?? sectionName;
  String? get status    => null;

  factory Enrollment.fromJson(Map<String, dynamic> j) => Enrollment(
        id:               j['id']?.toString() ?? '',
        studentId:        j['student']?.toString() ?? '',
        studentName:      j['student_name'] ?? 'Student',
        enrollmentNo:     j['student_enrollment_no']?.toString(),
        academicYearId:   j['academic_year']?.toString() ?? '',
        academicYearName: j['academic_year_name']?.toString(),
        classLevelId:     j['class_level']?.toString() ?? '',
        classLevelName:   j['class_level_name']?.toString(),
        sectionId:        j['section']?.toString() ?? '',
        sectionName:      j['section_name']?.toString(),
        rollNumber:       j['roll_number']?.toString(),
        enrollmentDate:   j['enrollment_date']?.toString(),
        raw:              j,
      );
}

// ── TeacherAssignment ──────────────────────────────────────────────────────

class TeacherAssignment {
  final String  id;
  final String  teacherId;
  final String  teacherName;
  final String? employeeId;
  final String  academicYearId;
  final String? academicYearName;
  final String  classLevelId;
  final String? classLevelName;
  final String  sectionId;
  final String? sectionName;
  final String  subjectId;
  final String? subjectName;
  final bool    isClassTeacher;
  final Map<String, dynamic> raw;

  TeacherAssignment({required this.id, required this.teacherId, required this.teacherName, this.employeeId, required this.academicYearId, this.academicYearName, required this.classLevelId, this.classLevelName, required this.sectionId, this.sectionName, required this.subjectId, this.subjectName, this.isClassTeacher = false, required this.raw});

  // Legacy
  String? get subject   => subjectName;
  String? get className => classLevelName != null && sectionName != null ? '${classLevelName!} ${sectionName!}' : classLevelName;

  factory TeacherAssignment.fromJson(Map<String, dynamic> j) => TeacherAssignment(
        id:               j['id']?.toString() ?? '',
        teacherId:        j['teacher']?.toString() ?? '',
        teacherName:      j['teacher_name'] ?? 'Teacher',
        employeeId:       j['teacher_employee_id']?.toString(),
        academicYearId:   j['academic_year']?.toString() ?? '',
        academicYearName: j['academic_year_name']?.toString(),
        classLevelId:     j['class_level']?.toString() ?? '',
        classLevelName:   j['class_level_name']?.toString(),
        sectionId:        j['section']?.toString() ?? '',
        sectionName:      j['section_name']?.toString(),
        subjectId:        j['subject']?.toString() ?? '',
        subjectName:      j['subject_name']?.toString(),
        isClassTeacher:   j['is_class_teacher'] == true,
        raw:              j,
      );
}

// ── AttendanceRecord ───────────────────────────────────────────────────────

class AttendanceRecord {
  final String  id;
  final String  studentId;
  final String  studentName;
  final String? enrollmentNo;
  final String  status;
  final String? date;
  final String? remarks;

  AttendanceRecord({required this.id, required this.studentId, required this.studentName, this.enrollmentNo, required this.status, this.date, this.remarks});

  factory AttendanceRecord.fromJson(Map<String, dynamic> j) => AttendanceRecord(
        id:           j['id']?.toString() ?? '',
        studentId:    j['student']?.toString() ?? '',
        studentName:  j['student_name'] ?? 'Student',
        enrollmentNo: j['student_enrollment_no']?.toString(),
        status:       j['status'] ?? 'Present',
        date:         j['date']?.toString(),
        remarks:      j['remarks']?.toString(),
      );
}

// ── Exam ───────────────────────────────────────────────────────────────────

class Exam {
  final String  id;
  final String  name;
  final String  academicYearId;
  final String? academicYearName;
  final String  startDate;
  final String  endDate;
  final bool    isPublished;
  final Map<String, dynamic> raw;

  Exam({required this.id, required this.name, required this.academicYearId, this.academicYearName, required this.startDate, required this.endDate, this.isPublished = false, required this.raw});

  // Legacy
  String? get date    => startDate;
  String? get subject => null;

  factory Exam.fromJson(Map<String, dynamic> j) => Exam(
        id:               j['id']?.toString() ?? '',
        name:             j['name'] ?? 'Exam',
        academicYearId:   j['academic_year']?.toString() ?? '',
        academicYearName: j['academic_year_name']?.toString(),
        startDate:        j['start_date'] ?? '',
        endDate:          j['end_date'] ?? '',
        isPublished:      j['is_published'] == true,
        raw:              j,
      );
}

// ── StudentGrade ───────────────────────────────────────────────────────────

class StudentGrade {
  final String  id;
  final String  examId;
  final String? examName;
  final String  studentId;
  final String  studentName;
  final String  subjectId;
  final String? subjectName;
  final double  marksObtained;
  final double  maxMarks;
  final String? remarks;

  StudentGrade({required this.id, required this.examId, this.examName, required this.studentId, required this.studentName, required this.subjectId, this.subjectName, required this.marksObtained, this.maxMarks = 100, this.remarks});

  double get percentage => maxMarks > 0 ? (marksObtained / maxMarks * 100) : 0;
  String get gradeLetter {
    final p = percentage;
    if (p >= 95) return 'A+';
    if (p >= 85) return 'A';
    if (p >= 75) return 'B+';
    if (p >= 65) return 'B';
    if (p >= 50) return 'C';
    if (p >= 35) return 'D';
    return 'F';
  }
  // Legacy
  String? get score => '$marksObtained / $maxMarks';
  String? get grade => gradeLetter;

  factory StudentGrade.fromJson(Map<String, dynamic> j) => StudentGrade(
        id:            j['id']?.toString() ?? '',
        examId:        j['exam']?.toString() ?? '',
        examName:      j['exam_name']?.toString(),
        studentId:     j['student']?.toString() ?? '',
        studentName:   j['student_name'] ?? 'Student',
        subjectId:     j['subject']?.toString() ?? '',
        subjectName:   j['subject_name']?.toString(),
        marksObtained: double.tryParse(j['marks_obtained']?.toString() ?? '0') ?? 0,
        maxMarks:      double.tryParse(j['max_marks']?.toString() ?? '100') ?? 100,
        remarks:       j['remarks']?.toString(),
      );
}

// ── AppPermission ──────────────────────────────────────────────────────────

class AppPermission {
  final String id;
  final String name;
  final String codename;
  final String module;

  AppPermission({required this.id, required this.name, required this.codename, required this.module});

  factory AppPermission.fromJson(Map<String, dynamic> j) => AppPermission(
        id:       j['id']?.toString() ?? '',
        name:     j['name'] ?? '',
        codename: j['codename'] ?? '',
        module:   j['module'] ?? '',
      );
}

// ── AppRole ────────────────────────────────────────────────────────────────

class AppRole {
  final String            id;
  final String            name;
  final String            description;
  final List<String>      permissionIds;
  final List<AppPermission> permissionDetails;

  AppRole({required this.id, required this.name, required this.description, required this.permissionIds, this.permissionDetails = const []});

  factory AppRole.fromJson(Map<String, dynamic> j) {
    final permIds = (j['permissions'] as List? ?? []).map((e) => e.toString()).toList();
    final details = (j['permission_details'] as List? ?? []).whereType<Map<String, dynamic>>().map(AppPermission.fromJson).toList();
    return AppRole(
      id:                j['id']?.toString() ?? '',
      name:              j['name'] ?? '',
      description:       j['description'] ?? '',
      permissionIds:     permIds,
      permissionDetails: details,
    );
  }
}

// ── UserRoleAssignment ─────────────────────────────────────────────────────

class UserRoleAssignment {
  final String  id;
  final String  userId;
  final String  roleId;
  final String? userEmail;
  final String? roleName;

  UserRoleAssignment({required this.id, required this.userId, required this.roleId, this.userEmail, this.roleName});

  factory UserRoleAssignment.fromJson(Map<String, dynamic> j) => UserRoleAssignment(
        id:        j['id']?.toString() ?? '',
        userId:    j['user']?.toString() ?? '',
        roleId:    j['role']?.toString() ?? '',
        userEmail: j['user_email']?.toString(),
        roleName:  j['role_name']?.toString(),
      );
}

// ── SchoolAssignment ───────────────────────────────────────────────────────

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

  factory SchoolAssignment.fromJson(Map<String, dynamic> j) {
    String? subId;
    String? subName;
    if (j['subject'] is Map) {
      subId = j['subject']['id']?.toString();
      subName = j['subject']['name']?.toString();
    } else {
      subId = j['subject']?.toString();
      subName = j['subject_name']?.toString();
    }

    String? secId;
    String? secName;
    if (j['section'] is Map) {
      secId = j['section']['id']?.toString();
      secName = j['section']['name']?.toString();
    } else {
      secId = j['section']?.toString();
      secName = j['section_name']?.toString();
    }

    return SchoolAssignment(
      id:          j['id']?.toString() ?? '',
      title:       j['title'] ?? '',
      description: j['description']?.toString(),
      dueDate:     j['due_date']?.toString(),
      subjectId:   subId,
      subjectName: subName ?? 'Unknown Subject',
      sectionId:   secId,
      sectionName: secName,
      maxMarks:    (j['max_marks'] as num?)?.toDouble(),
      status:      (j['submission_status'] ?? j['status'])?.toString() ?? 'Pending',
    );
  }
}

// ── AssignmentSubmission ───────────────────────────────────────────────────

class AssignmentSubmission {
  final String id;
  final String assignmentId;
  final String studentId;
  final String? assignmentTitle;
  final String? status;
  final String? submittedAt;
  final String? fileUrl;
  final double? marksObtained;
  final double? grade;

  AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.assignmentTitle,
    this.status,
    this.submittedAt,
    this.fileUrl,
    this.marksObtained,
    this.grade,
  });

  factory AssignmentSubmission.fromJson(Map<String, dynamic> j) {
    String assignmentId = '';
    if (j['assignment'] is Map) {
      assignmentId = j['assignment']['id']?.toString() ?? '';
    } else {
      assignmentId = j['assignment']?.toString() ?? '';
    }

    String studentId = '';
    if (j['student'] is Map) {
      studentId = j['student']['id']?.toString() ?? '';
    } else {
      studentId = j['student']?.toString() ?? '';
    }

    String? assignmentTitle;
    if (j['assignment_title'] != null) {
      assignmentTitle = j['assignment_title']?.toString();
    } else if (j['assignment_name'] != null) {
      assignmentTitle = j['assignment_name']?.toString();
    } else if (j['assignment'] is Map) {
      assignmentTitle = j['assignment']['title']?.toString();
    }

    String? fileUrl;
    if (j['file'] is String) {
      fileUrl = j['file'];
    } else if (j['file'] is Map) {
      fileUrl = j['file']['url']?.toString();
    }

    double? grade;
    if (j['marks_obtained'] != null) {
      grade = (j['marks_obtained'] as num?)?.toDouble();
    } else if (j['grade'] != null) {
      grade = double.tryParse(j['grade']?.toString() ?? '');
    }

    return AssignmentSubmission(
      id:            j['id']?.toString() ?? '',
      assignmentId:  assignmentId,
      studentId:     studentId,
      assignmentTitle: assignmentTitle,
      status:        (j['status'] ?? j['submission_status'])?.toString(),
      submittedAt:   j['submitted_at']?.toString(),
      fileUrl:       fileUrl,
      marksObtained: (j['marks_obtained'] as num?)?.toDouble(),
      grade:         grade,
    );
  }
}

// ── AttendanceSummaryData ──────────────────────────────────────────────────
class AttendanceSummaryData {
  final int totalDays;
  final int present;
  final int absent;
  final int late;
  final double attendancePercentage;

  AttendanceSummaryData({
    this.totalDays = 0,
    this.present = 0,
    this.absent = 0,
    this.late = 0,
    this.attendancePercentage = 0.0,
  });

  factory AttendanceSummaryData.fromJson(Map<String, dynamic> j) => AttendanceSummaryData(
    totalDays: j['total_days'] ?? 0,
    present: j['present'] ?? 0,
    absent: j['absent'] ?? 0,
    late: j['late'] ?? 0,
    attendancePercentage: (j['attendance_percentage'] as num?)?.toDouble() ?? 0.0,
  );
}

// ── ReportCardData ─────────────────────────────────────────────────────────
class ReportCardData {
  final double overallPercentage;
  final List<dynamic> exams;
  ReportCardData({this.overallPercentage = 0.0, this.exams = const []});
  
  factory ReportCardData.fromJson(Map<String, dynamic> j) => ReportCardData(
    overallPercentage: (j['overall_percentage'] as num?)?.toDouble() ?? 0.0,
    exams: j['exams'] ?? [],
  );
}
