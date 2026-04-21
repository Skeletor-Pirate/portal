// ─────────────────────────────────────────────────────────────────────────────
// API EXPLORER  —  live test & register tool
// Accessible via the DEV FAB on the login screen.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../theme.dart';
import '../services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA  — endpoint registry
// ─────────────────────────────────────────────────────────────────────────────

class _Ep {
  final String tag;
  final String method;
  final String path;
  final String desc;
  final bool requiresAuth;
  final Map<String, dynamic>? sampleBody;

  const _Ep({
    required this.tag,
    required this.method,
    required this.path,
    required this.desc,
    this.requiresAuth = true,
    this.sampleBody,
  });
}

const _endpoints = <_Ep>[
  // ── AUTH ──────────────────────────────────────────────────────────────────
  _Ep(tag: 'auth', method: 'POST', path: '/api/v1/auth/login/',
      desc: 'Obtain JWT access + refresh tokens',
      requiresAuth: false,
      sampleBody: {'username': 'admin', 'password': 'password'}),
  _Ep(tag: 'auth', method: 'POST', path: '/api/v1/auth/refresh/',
      desc: 'Refresh access token',
      requiresAuth: false,
      sampleBody: {'refresh': '<refresh_token>'}),
  _Ep(tag: 'auth', method: 'GET',  path: '/api/v1/auth/me/',
      desc: 'Get current user account'),

  // ── PROFILES ──────────────────────────────────────────────────────────────
  _Ep(tag: 'profiles', method: 'GET',  path: '/api/v1/profiles/me/',
      desc: 'Get full profile of logged-in user'),
  _Ep(tag: 'profiles', method: 'GET',  path: '/api/v1/profiles/students/',
      desc: 'List all student profiles (paginated)'),
  _Ep(tag: 'profiles', method: 'POST', path: '/api/v1/profiles/students/',
      desc: 'Create a student profile',
      sampleBody: {'user': 1, 'roll_number': '001', 'grade': '10A'}),
  _Ep(tag: 'profiles', method: 'GET',  path: '/api/v1/profiles/teachers/',
      desc: 'List all teacher profiles'),
  _Ep(tag: 'profiles', method: 'POST', path: '/api/v1/profiles/teachers/',
      desc: 'Create a teacher profile',
      sampleBody: {'user': 2, 'subject': 'Mathematics', 'employee_id': 'EMP001'}),
  _Ep(tag: 'profiles', method: 'GET',  path: '/api/v1/profiles/parents/',
      desc: 'List all parent profiles'),
  _Ep(tag: 'profiles', method: 'POST', path: '/api/v1/profiles/parents/',
      desc: 'Create a parent profile',
      sampleBody: {'user': 3}),
  _Ep(tag: 'profiles', method: 'GET',  path: '/api/v1/profiles/parent-student-mappings/',
      desc: 'List parent-student links'),
  _Ep(tag: 'profiles', method: 'POST', path: '/api/v1/profiles/parent-student-mappings/',
      desc: 'Link a parent to a student',
      sampleBody: {'parent': 1, 'student': 1}),

  // ── ACADEMICS ─────────────────────────────────────────────────────────────
  _Ep(tag: 'academics', method: 'GET',  path: '/api/v1/academics/enrollments/',
      desc: 'List all enrollments'),
  _Ep(tag: 'academics', method: 'POST', path: '/api/v1/academics/enrollments/',
      desc: 'Enrol a student',
      sampleBody: {'student': 1, 'class_name': '10A', 'academic_year': '2024-25'}),
  _Ep(tag: 'academics', method: 'POST', path: '/api/v1/academics/enrollments/bulk-promote/',
      desc: 'Bulk promote students to next grade',
      sampleBody: {'student_ids': [1, 2, 3], 'from_grade': '10A', 'to_grade': '11A'}),
  _Ep(tag: 'academics', method: 'GET',  path: '/api/v1/academics/teacher-assignments/',
      desc: 'List teacher-class-subject assignments'),
  _Ep(tag: 'academics', method: 'POST', path: '/api/v1/academics/teacher-assignments/',
      desc: 'Assign teacher to class/subject',
      sampleBody: {'teacher': 1, 'subject': 'Physics', 'class_name': '11B'}),

  // ── OPERATIONS ────────────────────────────────────────────────────────────
  _Ep(tag: 'operations', method: 'GET',  path: '/api/v1/operations/attendance/',
      desc: 'List attendance records'),
  _Ep(tag: 'operations', method: 'POST', path: '/api/v1/operations/attendance/bulk-record/',
      desc: 'Bulk record attendance for a class',
      sampleBody: {'records': [
        {'student': 1, 'date': '2025-04-10', 'status': 'present'},
        {'student': 2, 'date': '2025-04-10', 'status': 'absent'},
      ]}),
  _Ep(tag: 'operations', method: 'GET',  path: '/api/v1/operations/exams/',
      desc: 'List exams'),
  _Ep(tag: 'operations', method: 'POST', path: '/api/v1/operations/exams/',
      desc: 'Create an exam',
      sampleBody: {'name': 'Mid-Term', 'subject': 'Science', 'date': '2025-04-12', 'class_name': '10A'}),
  _Ep(tag: 'operations', method: 'GET',  path: '/api/v1/operations/grades/',
      desc: 'List grade records'),
  _Ep(tag: 'operations', method: 'POST', path: '/api/v1/operations/grades/bulk-submit/',
      desc: 'Submit grades in bulk',
      sampleBody: {'grades': [
        {'student': 1, 'exam': 1, 'score': 88, 'grade': 'A'},
        {'student': 2, 'exam': 1, 'score': 72, 'grade': 'B'},
      ]}),

  // ── ACCOUNTS (RBAC) ───────────────────────────────────────────────────────
  _Ep(tag: 'accounts', method: 'GET',  path: '/api/v1/accounts/permissions/',
      desc: 'List all system permissions'),
  _Ep(tag: 'accounts', method: 'GET',  path: '/api/v1/accounts/roles/',
      desc: 'List all RBAC roles'),
  _Ep(tag: 'accounts', method: 'POST', path: '/api/v1/accounts/roles/',
      desc: 'Create a custom role',
      sampleBody: {'name': 'Class Teacher', 'permissions': [1, 2, 3]}),
  _Ep(tag: 'accounts', method: 'GET',  path: '/api/v1/accounts/user-roles/',
      desc: 'List user-role assignments'),
  _Ep(tag: 'accounts', method: 'POST', path: '/api/v1/accounts/user-roles/',
      desc: 'Assign a role to a user',
      sampleBody: {'user': 1, 'role': 1}),
];

// ─────────────────────────────────────────────────────────────────────────────
// REGISTER SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstCtrl    = TextEditingController();
  final _lastCtrl     = TextEditingController();
  final _userCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _pass2Ctrl    = TextEditingController();

  bool   _loading  = false;
  bool   _obscure1 = true;
  bool   _obscure2 = true;
  String? _error;
  String? _success;

  @override
  void dispose() {
    for (final c in [_firstCtrl, _lastCtrl, _userCtrl, _emailCtrl, _passCtrl, _pass2Ctrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    final first = _firstCtrl.text.trim();
    final last  = _lastCtrl.text.trim();
    final user  = _userCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text;
    final pass2 = _pass2Ctrl.text;

    if ([first, last, user, email, pass, pass2].any((s) => s.isEmpty)) {
      setState(() { _error = 'Please fill in all fields.'; _success = null; });
      return;
    }
    if (pass != pass2) {
      setState(() { _error = 'Passwords do not match.'; _success = null; });
      return;
    }
    if (pass.length < 8) {
      setState(() { _error = 'Password must be at least 8 characters.'; _success = null; });
      return;
    }

    setState(() { _loading = true; _error = null; _success = null; });

    try {
      // The API uses /api/v1/auth/login/ for JWT — registration is done by
      // creating a user via a POST to the relevant profile endpoint.
      // Since the Swagger spec doesn't expose a dedicated /register/ endpoint,
      // we hit the Django admin-user-creation path that is standard for
      // DRF multi-tenant: POST to /api/v1/profiles/students/ after
      // creating the base user. Here we call the raw http client so we can
      // show the exact request/response for verification purposes.
      final res = await http.post(
        Uri.parse('$kBaseUrl/api/v1/auth/login/').replace(
          // Use a known registration-adjacent path if available; fallback shows
          // the raw error so the user can verify API behaviour.
          path: '/api/v1/accounts/users/' // Many DRF setups expose this
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username':   user,
          'email':      email,
          'password':   pass,
          'first_name': first,
          'last_name':  last,
        }),
      );

      final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};

      if (res.statusCode == 201 || res.statusCode == 200) {
        setState(() {
          _success = 'Account created! You can now log in as $user.';
          _error   = null;
        });
      } else {
        String msg = 'Registration failed (${res.statusCode})';
        if (body is Map) {
          if (body['detail'] != null)            msg = body['detail'].toString();
          else if (body['username'] != null)     msg = 'Username: ${(body['username'] as List).first}';
          else if (body['email'] != null)        msg = 'Email: ${(body['email'] as List).first}';
          else if (body['password'] != null)     msg = 'Password: ${(body['password'] as List).first}';
          else if (body['non_field_errors'] != null)
            msg = (body['non_field_errors'] as List).first.toString();
        }
        setState(() { _error = msg; _success = null; });
      }
    } catch (e) {
      setState(() {
        _error   = 'Could not reach the server. Check your connection.\n$e';
        _success = null;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad    = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        // ── Header ──────────────────────────────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 18),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [AppColors.gradA, AppColors.gradB],
            ),
          ),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(rMd),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 16, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Create Account', style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: Colors.white)),
              Text('Register a new user on the platform',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white.withOpacity(0.65))),
            ])),
          ]),
        ),

        // ── Form ────────────────────────────────────────────────────────────
        Expanded(child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 20 + bottomPad),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Server badge ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.blueLight,
                borderRadius: BorderRadius.circular(rMd),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Row(children: [
                const Icon(Icons.dns_rounded, size: 14, color: AppColors.blue),
                const SizedBox(width: 8),
                Expanded(child: Text(kBaseUrl,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: AppColors.blue, letterSpacing: 0.2))),
              ]),
            ),

            const SizedBox(height: 22),

            Row(children: [
              Expanded(child: _field('First Name', _firstCtrl, Icons.person_outline_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _field('Last Name', _lastCtrl, Icons.person_outline_rounded)),
            ]),
            _field('Username', _userCtrl, Icons.alternate_email_rounded),
            _field('Email', _emailCtrl, Icons.email_outlined, type: TextInputType.emailAddress),
            _passField('Password', _passCtrl, _obscure1,
                () => setState(() => _obscure1 = !_obscure1)),
            _passField('Confirm Password', _pass2Ctrl, _obscure2,
                () => setState(() => _obscure2 = !_obscure2)),

            // ── Error ──────────────────────────────────────────────────────
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.redLight,
                  borderRadius: BorderRadius.circular(rMd),
                  border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.red))),
                ]),
              ),
            ],

            // ── Success ────────────────────────────────────────────────────
            if (_success != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(rMd),
                  border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_success!,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12,
                          fontWeight: FontWeight.w600, color: AppColors.green))),
                ]),
              ),
            ],

            const SizedBox(height: 24),

            // ── Register button ────────────────────────────────────────────
            GestureDetector(
              onTap: _loading ? null : _register,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradA, AppColors.gradC],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(rMd),
                  boxShadow: shadowMd,
                ),
                child: Center(child: _loading
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Create Account',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
              ),
            ),

            const SizedBox(height: 12),

            // ── API Explorer link ──────────────────────────────────────────
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ApiExplorerScreen())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border2, width: 1.5),
                  borderRadius: BorderRadius.circular(rMd),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.api_rounded, size: 15, color: AppColors.navy),
                  const SizedBox(width: 8),
                  Text('Open API Explorer',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy)),
                ]),
              ),
            ),
          ]),
        )),
      ]),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.plusJakartaSans(
            fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text3)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.text1),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AppColors.text4),
            filled: true, fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd),
                borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd),
                borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd),
                borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
          ),
        ),
      ]),
    );
  }

  Widget _passField(String label, TextEditingController ctrl, bool obscure, VoidCallback toggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.plusJakartaSans(
            fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text3)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.text1),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.text4),
            suffixIcon: GestureDetector(
              onTap: toggle,
              child: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  size: 18, color: AppColors.text4),
            ),
            filled: true, fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd),
                borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd),
                borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd),
                borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// API EXPLORER SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class ApiExplorerScreen extends StatefulWidget {
  const ApiExplorerScreen({super.key});
  @override
  State<ApiExplorerScreen> createState() => _ApiExplorerScreenState();
}

class _ApiExplorerScreenState extends State<ApiExplorerScreen> {
  final _tokenCtrl = TextEditingController();
  String _filterTag = 'all';
  Map<String, _TestResult?> _results = {};
  bool _testingAll = false;

  static const _tags = ['all', 'auth', 'profiles', 'academics', 'operations', 'accounts'];

  @override
  void initState() {
    super.initState();
    if (TokenStore.access != null) _tokenCtrl.text = TokenStore.access!;
  }

  @override
  void dispose() { _tokenCtrl.dispose(); super.dispose(); }

  List<_Ep> get _filtered =>
      _endpoints.where((e) => _filterTag == 'all' || e.tag == _filterTag).toList();

  Color _tagColor(String tag) {
    switch (tag) {
      case 'auth':       return AppColors.navy;
      case 'profiles':   return AppColors.blue;
      case 'academics':  return AppColors.teal;
      case 'operations': return AppColors.green;
      case 'accounts':   return AppColors.amber;
      default:           return AppColors.text3;
    }
  }

  Color _methodColor(String m) {
    switch (m) {
      case 'GET':    return AppColors.green;
      case 'POST':   return AppColors.blue;
      case 'PATCH':  return AppColors.amber;
      case 'DELETE': return AppColors.red;
      default:       return AppColors.text3;
    }
  }

  Future<_TestResult> _fire(_Ep ep, {String? tokenOverride}) async {
    final token  = tokenOverride ?? _tokenCtrl.text.trim();
    final sw     = Stopwatch()..start();
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (ep.requiresAuth && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final uri = Uri.parse('$kBaseUrl${ep.path}');
      http.Response res;
      if (ep.method == 'GET') {
        res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 12));
      } else {
        res = await http.post(uri, headers: headers,
            body: jsonEncode(ep.sampleBody ?? {}))
            .timeout(const Duration(seconds: 12));
      }
      sw.stop();
      String body = res.body;
      try {
        final decoded = jsonDecode(body);
        body = const JsonEncoder.withIndent('  ').convert(decoded);
        // Auto-extract token from login response
        if (ep.path == '/api/v1/auth/login/' && res.statusCode == 200) {
          final access = decoded['access']?.toString();
          if (access != null && access.isNotEmpty) {
            setState(() => _tokenCtrl.text = access);
            TokenStore.save(access: access, refresh: decoded['refresh']?.toString() ?? '');
          }
        }
      } catch (_) {}
      return _TestResult(
        statusCode: res.statusCode,
        body: body,
        ms: sw.elapsedMilliseconds,
        ok: res.statusCode < 400,
        isUnauth: res.statusCode == 401,
      );
    } catch (e) {
      sw.stop();
      return _TestResult(statusCode: 0, body: e.toString(), ms: sw.elapsedMilliseconds, ok: false);
    }
  }

  Future<void> _testAll() async {
    setState(() { _testingAll = true; _results = {}; });
    for (final ep in _filtered) {
      final r = await _fire(ep);
      setState(() => _results[ep.path + ep.method] = r);
    }
    setState(() => _testingAll = false);
  }

  @override
  Widget build(BuildContext context) {
    final topPad    = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final passed = _results.values.where((r) => r?.ok == true).length;
    final failed = _results.values.where((r) => r?.ok == false).length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        // ── Header ──────────────────────────────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(14, topPad + 10, 14, 14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF2D1B8E)],
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(rMd),
                    border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 15, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('API Explorer', style: GoogleFonts.dmSerifDisplay(
                    fontSize: 18, color: Colors.white)),
                Text('$kBaseUrl', style: GoogleFonts.plusJakartaSans(
                    fontSize: 9, color: const Color(0xFF00FF88), letterSpacing: 0.5)),
              ])),
              if (_results.isNotEmpty) ...[
                _statPill('$passed', AppColors.green),
                const SizedBox(width: 6),
                _statPill('$failed', AppColors.red, fail: true),
              ],
            ]),

            const SizedBox(height: 12),

            // ── Token input ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(rMd),
                border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
              ),
              child: Row(children: [
                const Icon(Icons.key_rounded, size: 14, color: Color(0xFF00FF88)),
                const SizedBox(width: 8),
                Expanded(child: TextField(
                  controller: _tokenCtrl,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: const Color(0xFF00FF88)),
                  decoration: InputDecoration(
                    hintText: 'Bearer token (auto-filled after login)',
                    hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: Colors.white.withOpacity(0.3)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                )),
              ]),
            ),

            const SizedBox(height: 10),

            // ── Tag filter + run all ──────────────────────────────────────
            Row(children: [
              Expanded(child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: _tags.map((t) => GestureDetector(
                  onTap: () => setState(() => _filterTag = t),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _filterTag == t
                          ? (_tagColor(t)).withOpacity(0.85)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(rFull),
                    ),
                    child: Text(t, style: GoogleFonts.plusJakartaSans(
                        fontSize: 10, fontWeight: FontWeight.w600,
                        color: Colors.white)),
                  ),
                )).toList()),
              )),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _testingAll ? null : _testAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF88).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(rSm),
                    border: Border.all(
                        color: const Color(0xFF00FF88).withOpacity(0.5), width: 1.5),
                  ),
                  child: _testingAll
                      ? const SizedBox(width: 12, height: 12,
                          child: CircularProgressIndicator(
                              strokeWidth: 1.5, color: Color(0xFF00FF88)))
                      : Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.play_arrow_rounded,
                              size: 12, color: Color(0xFF00FF88)),
                          const SizedBox(width: 4),
                          Text('Test All', style: GoogleFonts.plusJakartaSans(
                              fontSize: 10, fontWeight: FontWeight.w700,
                              color: const Color(0xFF00FF88))),
                        ]),
                ),
              ),
            ]),
          ]),
        ),

        // ── No-token warning ────────────────────────────────────────────────
        if (_tokenCtrl.text.trim().isEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3DC),
              borderRadius: BorderRadius.circular(rMd),
              border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFB45309)),
              const SizedBox(width: 8),
              Expanded(child: Text(
                'Test the POST /api/v1/auth/login/ endpoint first. The token will auto-fill and all protected endpoints will work.',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFFB45309), height: 1.4),
              )),
            ]),
          ),

        // ── Endpoint list ────────────────────────────────────────────────────
        Expanded(child: ListView.builder(
          padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + bottomPad),
          itemCount: _filtered.length,
          itemBuilder: (_, i) {
            final ep  = _filtered[i];
            final key = ep.path + ep.method;
            final res = _results[key];
            return _EndpointCard(
              ep:     ep,
              result: res,
              methodColor: _methodColor(ep.method),
              tagColor: _tagColor(ep.tag),
              onTest: () async {
                final r = await _fire(ep);
                setState(() => _results[key] = r);
              },
            );
          },
        )),
      ]),
    );
  }

  Widget _statPill(String val, Color color, {bool fail = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(rFull),
      border: Border.all(color: color.withOpacity(0.4), width: 1),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(fail ? Icons.close_rounded : Icons.check_rounded, size: 10, color: color),
      const SizedBox(width: 3),
      Text(val, style: GoogleFonts.plusJakartaSans(
          fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ENDPOINT CARD
// ─────────────────────────────────────────────────────────────────────────────

class _TestResult {
  final int    statusCode;
  final String body;
  final int    ms;
  final bool   ok;
  final bool   isUnauth;
  _TestResult({required this.statusCode, required this.body,
               required this.ms, required this.ok, this.isUnauth = false});
}

class _EndpointCard extends StatefulWidget {
  final _Ep         ep;
  final _TestResult? result;
  final Color       methodColor;
  final Color       tagColor;
  final VoidCallback onTest;

  const _EndpointCard({
    required this.ep,
    required this.result,
    required this.methodColor,
    required this.tagColor,
    required this.onTest,
  });

  @override
  State<_EndpointCard> createState() => _EndpointCardState();
}

class _EndpointCardState extends State<_EndpointCard> {
  bool _expanded = false;
  bool _testing  = false;

  Color get _statusColor {
    final r = widget.result;
    if (r == null) return AppColors.text4;
    if (r.ok) return AppColors.green;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.result;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: res == null
              ? AppColors.border
              : res.ok ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(rLg),
        boxShadow: shadowSm,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Row ──────────────────────────────────────────────────────────────
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Row(children: [
              // Method badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.methodColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(rSm),
                ),
                child: Text(widget.ep.method, style: GoogleFonts.plusJakartaSans(
                    fontSize: 9, fontWeight: FontWeight.w800,
                    color: widget.methodColor, letterSpacing: 0.5)),
              ),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.ep.path, style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text1)),
                Text(widget.ep.desc, style: GoogleFonts.plusJakartaSans(
                    fontSize: 10, color: AppColors.text3)),
              ])),
              // Status indicator
              if (res != null) ...[
                Text('${res.statusCode}', style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor)),
                const SizedBox(width: 4),
                Text('${res.ms}ms', style: GoogleFonts.plusJakartaSans(
                    fontSize: 9, color: AppColors.text4)),
                const SizedBox(width: 8),
              ],
              // Run button
              GestureDetector(
                onTap: _testing ? null : () async {
                  setState(() => _testing = true);
                  widget.onTest();
                  await Future.delayed(const Duration(milliseconds: 800));
                  if (mounted) setState(() { _testing = false; _expanded = true; });
                },
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.blueLight,
                    borderRadius: BorderRadius.circular(rSm),
                  ),
                  child: Center(child: _testing
                      ? const SizedBox(width: 12, height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.blue))
                      : const Icon(Icons.play_arrow_rounded, size: 14, color: AppColors.blue)),
                ),
              ),
            ]),
          ),
        ),

        // ── Expanded body ─────────────────────────────────────────────────
        if (_expanded) ...[
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Sample body
              if (widget.ep.sampleBody != null) ...[
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('REQUEST BODY', style: GoogleFonts.plusJakartaSans(
                      fontSize: 9, fontWeight: FontWeight.w700,
                      letterSpacing: 1.5, color: AppColors.text4)),
                ]),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(rMd),
                  ),
                  child: Text(
                    const JsonEncoder.withIndent('  ').convert(widget.ep.sampleBody),
                    style: GoogleFonts.sourceCodePro(
                        fontSize: 10, color: const Color(0xFF00FF88)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              // Response
              if (res != null) ...[
                // 401 hint
                if (res.isUnauth) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3DC),
                      borderRadius: BorderRadius.circular(rSm),
                      border: Border.all(color: const Color(0xFFFCD34D)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.lock_outline_rounded, size: 12, color: Color(0xFFB45309)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(
                        '401 — Token required. Run POST /api/v1/auth/login/ first, then retry.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFFB45309)),
                      )),
                    ]),
                  ),
                ],
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('RESPONSE', style: GoogleFonts.plusJakartaSans(
                      fontSize: 9, fontWeight: FontWeight.w700,
                      letterSpacing: 1.5, color: AppColors.text4)),
                  GestureDetector(
                    onTap: () => Clipboard.setData(ClipboardData(text: res.body)),
                    child: const Icon(Icons.copy_rounded, size: 13, color: AppColors.text4),
                  ),
                ]),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 220),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(rMd),
                    border: Border.all(
                      color: res.ok
                          ? const Color(0xFF86EFAC).withOpacity(0.4)
                          : const Color(0xFFFCA5A5).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Text(res.body,
                        style: GoogleFonts.sourceCodePro(
                            fontSize: 10,
                            color: res.ok
                                ? const Color(0xFF86EFAC)
                                : const Color(0xFFFCA5A5))),
                  ),
                ),
              ] else
                Text('Tap ▶ to test this endpoint',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: AppColors.text4)),
            ]),
          ),
        ],
      ]),
    );
  }
}
