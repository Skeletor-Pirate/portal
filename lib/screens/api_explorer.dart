// ─────────────────────────────────────────────────────────────────────────────
// API EXPLORER  —  live test & register tool
// Full editable request bodies. Token auto-fills from login response.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../theme.dart';
import '../services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENDPOINT REGISTRY
// ─────────────────────────────────────────────────────────────────────────────

class _Ep {
  final String tag;
  final String method;
  final String path;
  final String desc;
  final bool requiresAuth;
  final Map<String, dynamic>? defaultBody;

  const _Ep({
    required this.tag,
    required this.method,
    required this.path,
    required this.desc,
    this.requiresAuth = true,
    this.defaultBody,
  });
}

const _endpoints = <_Ep>[
  // ── AUTH ─────────────────────────────────────────────────────────────────
  _Ep(tag:'auth', method:'POST', path:'/api/v1/auth/login/',
      desc:'Obtain JWT access + refresh tokens',
      requiresAuth:false,
      defaultBody:{'email':'admin@school.com','password':'yourpassword'}),
  _Ep(tag:'auth', method:'POST', path:'/api/v1/auth/refresh/',
      desc:'Refresh access token using refresh token',
      requiresAuth:false,
      defaultBody:{'refresh':'<paste_refresh_token_here>'}),
  _Ep(tag:'auth', method:'GET',  path:'/api/v1/auth/me/',
      desc:'Get current authenticated user account'),

  // ── USERS (Tenant) ────────────────────────────────────────────────────────
  _Ep(tag:'auth', method:'GET',  path:'/api/v1/users/',
      desc:'List all users in the school (tenant)'),
  _Ep(tag:'auth', method:'POST', path:'/api/v1/users/',
      desc:'Create a new user account',
      defaultBody:{'email':'newuser@school.com','password':'SecurePass123','first_name':'Jane','last_name':'Doe'}),

  // ── PROFILES ─────────────────────────────────────────────────────────────
  _Ep(tag:'profiles', method:'GET',  path:'/api/v1/profiles/me/',
      desc:'Get full profile of the logged-in user'),
  _Ep(tag:'profiles', method:'GET',  path:'/api/v1/profiles/students/',
      desc:'List all student profiles (paginated)'),
  _Ep(tag:'profiles', method:'POST', path:'/api/v1/profiles/students/',
      desc:'Create a new student profile',
      defaultBody:{'user':'<user-uuid>','enrollment_number':'STU-001','blood_group':'O+','phone_number':'+919876543210','date_of_birth':'2005-06-15'}),
  _Ep(tag:'profiles', method:'GET',  path:'/api/v1/profiles/teachers/',
      desc:'List all teacher profiles'),
  _Ep(tag:'profiles', method:'POST', path:'/api/v1/profiles/teachers/',
      desc:'Create a new teacher profile',
      defaultBody:{'user':'<user-uuid>','employee_id':'EMP-001','qualification':'M.Sc Physics','joining_date':'2023-06-01','phone_number':'+919876543210'}),
  _Ep(tag:'profiles', method:'GET',  path:'/api/v1/profiles/parents/',
      desc:'List all parent profiles'),
  _Ep(tag:'profiles', method:'POST', path:'/api/v1/profiles/parents/',
      desc:'Create a new parent profile',
      defaultBody:{'user':'<user-uuid>','occupation':'Engineer','emergency_contact_number':'+919876543210','phone_number':'+919876543210'}),
  _Ep(tag:'profiles', method:'GET',  path:'/api/v1/profiles/parent-student-mappings/',
      desc:'List parent-student links'),
  _Ep(tag:'profiles', method:'POST', path:'/api/v1/profiles/parent-student-mappings/',
      desc:'Link a parent to a student',
      defaultBody:{'parent':'<parent-profile-uuid>','student':'<student-profile-uuid>','relationship':'Father','is_primary_contact':true,'can_view_academics':true,'can_pay_fees':true}),

  // ── ACADEMICS ────────────────────────────────────────────────────────────
  _Ep(tag:'academics', method:'GET',  path:'/api/v1/academics/academic-years/',
      desc:'List all academic years'),
  _Ep(tag:'academics', method:'POST', path:'/api/v1/academics/academic-years/',
      desc:'Create a new academic year',
      defaultBody:{'name':'2025-26','start_date':'2025-06-01','end_date':'2026-03-31','is_active':false}),
  _Ep(tag:'academics', method:'GET',  path:'/api/v1/academics/class-levels/',
      desc:'List all class levels (e.g. Grade 1, Grade 10)'),
  _Ep(tag:'academics', method:'POST', path:'/api/v1/academics/class-levels/',
      desc:'Create a new class level',
      defaultBody:{'name':'Grade 10','numeric_order':10}),
  _Ep(tag:'academics', method:'GET',  path:'/api/v1/academics/sections/',
      desc:'List all sections (e.g. Section A, Section B)'),
  _Ep(tag:'academics', method:'POST', path:'/api/v1/academics/sections/',
      desc:'Create a section inside a class level',
      defaultBody:{'class_level':'<class-level-uuid>','name':'A'}),
  _Ep(tag:'academics', method:'GET',  path:'/api/v1/academics/subjects/',
      desc:'List all subjects'),
  _Ep(tag:'academics', method:'POST', path:'/api/v1/academics/subjects/',
      desc:'Create a new subject',
      defaultBody:{'name':'Physics','code':'PHY101'}),
  _Ep(tag:'academics', method:'GET',  path:'/api/v1/academics/enrollments/',
      desc:'List all student enrollments'),
  _Ep(tag:'academics', method:'POST', path:'/api/v1/academics/enrollments/',
      desc:'Enrol a student in a class',
      defaultBody:{'student':'<student-profile-uuid>','academic_year':'<academic-year-uuid>','class_level':'<class-level-uuid>','section':'<section-uuid>','roll_number':'001'}),
  _Ep(tag:'academics', method:'POST', path:'/api/v1/academics/enrollments/bulk-promote/',
      desc:'Bulk promote students to next grade',
      defaultBody:{'student_ids':['<student-uuid-1>','<student-uuid-2>'],'target_academic_year_id':'<academic-year-uuid>','target_class_level_id':'<class-level-uuid>','target_section_id':'<section-uuid>'}),
  _Ep(tag:'academics', method:'GET',  path:'/api/v1/academics/teacher-assignments/',
      desc:'List teacher-class-subject assignments'),
  _Ep(tag:'academics', method:'POST', path:'/api/v1/academics/teacher-assignments/',
      desc:'Assign a teacher to a class and subject',
      defaultBody:{'teacher':'<teacher-profile-uuid>','academic_year':'<academic-year-uuid>','class_level':'<class-level-uuid>','section':'<section-uuid>','subject':'<subject-uuid>','is_class_teacher':false}),

  // ── OPERATIONS ───────────────────────────────────────────────────────────
  _Ep(tag:'operations', method:'GET',  path:'/api/v1/operations/attendance/',
      desc:'List all attendance records'),
  _Ep(tag:'operations', method:'POST', path:'/api/v1/operations/attendance/bulk-record/',
      desc:'Bulk record attendance for an entire class',
      defaultBody:{'date':'2025-04-10','academic_year_id':'<academic-year-uuid>','class_level_id':'<class-level-uuid>','section_id':'<section-uuid>','records':[{'student_id':'<student-uuid-1>','status':'Present','remarks':''},{'student_id':'<student-uuid-2>','status':'Absent','remarks':'Sick leave'}]}),
  _Ep(tag:'operations', method:'GET',  path:'/api/v1/operations/exams/',
      desc:'List all exams'),
  _Ep(tag:'operations', method:'POST', path:'/api/v1/operations/exams/',
      desc:'Create a new exam',
      defaultBody:{'name':'Mid-Term Examination 2025','academic_year':'<academic-year-uuid>','start_date':'2025-04-20','end_date':'2025-04-25','is_published':false}),
  _Ep(tag:'operations', method:'GET',  path:'/api/v1/operations/grades/',
      desc:'List all grade records'),
  _Ep(tag:'operations', method:'POST', path:'/api/v1/operations/grades/bulk-submit/',
      desc:'Submit grades for multiple students at once',
      defaultBody:{'exam_id':'<exam-uuid>','subject_id':'<subject-uuid>','section_id':'<section-uuid>','records':[{'student_id':'<student-uuid-1>','marks_obtained':88.00,'max_marks':100.00,'remarks':'Good performance'},{'student_id':'<student-uuid-2>','marks_obtained':72.00,'max_marks':100.00,'remarks':''}]}),

  // ── ACCOUNTS ─────────────────────────────────────────────────────────────
  _Ep(tag:'accounts', method:'GET',  path:'/api/v1/accounts/permissions/',
      desc:'List all system permissions'),
  _Ep(tag:'accounts', method:'GET',  path:'/api/v1/accounts/roles/',
      desc:'List all RBAC roles'),
  _Ep(tag:'accounts', method:'POST', path:'/api/v1/accounts/roles/',
      desc:'Create a custom RBAC role',
      defaultBody:{'name':'Class Teacher','description':'Handles classroom attendance and grades','permissions':['<permission-uuid-1>','<permission-uuid-2>']}),
  _Ep(tag:'accounts', method:'GET',  path:'/api/v1/accounts/user-roles/',
      desc:'List user-role assignments'),
  _Ep(tag:'accounts', method:'POST', path:'/api/v1/accounts/user-roles/',
      desc:'Assign a role to a user',
      defaultBody:{'user':'<user-uuid>','role':'<role-uuid>'}),
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
  final _firstCtrl = TextEditingController();
  final _lastCtrl  = TextEditingController();
  final _userCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool   _loading  = false;
  bool   _obs1     = true;
  bool   _obs2     = true;
  String? _error;
  String? _success;

  @override
  void dispose() {
    for (final c in [_firstCtrl,_lastCtrl,_userCtrl,_emailCtrl,_passCtrl,_pass2Ctrl]) c.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final first = _firstCtrl.text.trim();
    final last  = _lastCtrl.text.trim();
    final user  = _userCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text;
    final pass2 = _pass2Ctrl.text;
    if ([first,last,user,email,pass,pass2].any((s) => s.isEmpty)) {
      setState(() { _error='Please fill in all fields.'; _success=null; }); return;
    }
    if (pass != pass2) {
      setState(() { _error='Passwords do not match.'; _success=null; }); return;
    }
    if (pass.length < 8) {
      setState(() { _error='Password must be at least 8 characters.'; _success=null; }); return;
    }
    setState(() { _loading=true; _error=null; _success=null; });
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/api/v1/accounts/users/'),
        headers: {'Content-Type':'application/json'},
        body: jsonEncode({'username':user,'email':email,'password':pass,'first_name':first,'last_name':last}),
      ).timeout(const Duration(seconds: 15));
      final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
      if (res.statusCode == 201 || res.statusCode == 200) {
        setState(() { _success='Account created! Log in as $user.'; _error=null; });
      } else {
        String msg = 'Registration failed (${res.statusCode})';
        if (body is Map) {
          if (body['detail'] != null) msg = body['detail'].toString();
          else if (body['username'] != null) msg = 'Username: ${(body['username'] as List).first}';
          else if (body['email'] != null) msg = 'Email: ${(body['email'] as List).first}';
          else if (body['password'] != null) msg = 'Password: ${(body['password'] as List).first}';
        }
        setState(() { _error=msg; _success=null; });
      }
    } catch (e) {
      setState(() { _error='Could not reach server: $e'; _success=null; });
    } finally {
      if (mounted) setState(() => _loading=false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        Container(
          padding: EdgeInsets.fromLTRB(16,topPad+12,16,18),
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft,end: Alignment.bottomRight,colors:[AppColors.gradA,AppColors.gradB])),
          child: Row(children: [
            GestureDetector(onTap: ()=>Navigator.of(context).pop(),
              child: Container(width:36,height:36,decoration:BoxDecoration(color:Colors.white.withOpacity(0.15),borderRadius:BorderRadius.circular(rMd),border:Border.all(color:Colors.white.withOpacity(0.2),width:1.5)),
                child: const Icon(Icons.arrow_back_rounded,size:16,color:Colors.white))),
            const SizedBox(width:12),
            Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text('Create Account',style:GoogleFonts.dmSerifDisplay(fontSize:20,color:Colors.white)),
              Text('Register a new user',style:GoogleFonts.plusJakartaSans(fontSize:11,color:Colors.white.withOpacity(0.65))),
            ])),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20,24,20,20+botPad),
          child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            _serverBadge(),
            const SizedBox(height:20),
            Row(children:[
              Expanded(child:_fld('First Name',_firstCtrl,Icons.person_outline_rounded)),
              const SizedBox(width:10),
              Expanded(child:_fld('Last Name',_lastCtrl,Icons.person_outline_rounded)),
            ]),
            _fld('Username',_userCtrl,Icons.alternate_email_rounded),
            _fld('Email',_emailCtrl,Icons.email_outlined,type:TextInputType.emailAddress),
            _passFld('Password',_passCtrl,_obs1,()=>setState(()=>_obs1=!_obs1)),
            _passFld('Confirm Password',_pass2Ctrl,_obs2,()=>setState(()=>_obs2=!_obs2)),
            if (_error!=null) ...[const SizedBox(height:12), _errorBox(_error!)],
            if (_success!=null) ...[const SizedBox(height:12), _successBox(_success!)],
            const SizedBox(height:24),
            _gradBtn(_loading?null:_register, _loading
              ? const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white))
              : Text('Create Account',style:GoogleFonts.plusJakartaSans(fontSize:14,fontWeight:FontWeight.w700,color:Colors.white))),
            const SizedBox(height:12),
            GestureDetector(
              onTap:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>const ApiExplorerScreen())),
              child:Container(width:double.infinity,padding:const EdgeInsets.symmetric(vertical:13),
                decoration:BoxDecoration(border:Border.all(color:AppColors.border2,width:1.5),borderRadius:BorderRadius.circular(rMd)),
                child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[
                  const Icon(Icons.api_rounded,size:15,color:AppColors.navy),const SizedBox(width:8),
                  Text('Open API Explorer',style:GoogleFonts.plusJakartaSans(fontSize:13,fontWeight:FontWeight.w600,color:AppColors.navy)),
                ])),
            ),
          ]),
        )),
      ]),
    );
  }

  Widget _serverBadge() => Container(
    width:double.infinity,padding:const EdgeInsets.symmetric(horizontal:14,vertical:10),
    decoration:BoxDecoration(color:AppColors.blueLight,borderRadius:BorderRadius.circular(rMd),border:Border.all(color:AppColors.border,width:1.5)),
    child:Row(children:[const Icon(Icons.dns_rounded,size:14,color:AppColors.blue),const SizedBox(width:8),
      Expanded(child:Text(kBaseUrl,style:GoogleFonts.plusJakartaSans(fontSize:11,fontWeight:FontWeight.w600,color:AppColors.blue,letterSpacing:0.2)))]),
  );

  Widget _fld(String label, TextEditingController ctrl, IconData icon, {TextInputType? type}) =>
    Padding(padding:const EdgeInsets.only(bottom:14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(label,style:GoogleFonts.plusJakartaSans(fontSize:11,fontWeight:FontWeight.w600,color:AppColors.text3)),
      const SizedBox(height:6),
      TextField(controller:ctrl,keyboardType:type,style:GoogleFonts.plusJakartaSans(fontSize:14,color:AppColors.text1),
        decoration:InputDecoration(prefixIcon:Icon(icon,size:18,color:AppColors.text4),filled:true,fillColor:AppColors.surface,
          contentPadding:const EdgeInsets.symmetric(horizontal:14,vertical:14),
          border:OutlineInputBorder(borderRadius:BorderRadius.circular(rMd),borderSide:const BorderSide(color:AppColors.border,width:1.5)),
          enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(rMd),borderSide:const BorderSide(color:AppColors.border,width:1.5)),
          focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(rMd),borderSide:const BorderSide(color:AppColors.blue,width:1.5)))),
    ]));

  Widget _passFld(String label, TextEditingController ctrl, bool obs, VoidCallback toggle) =>
    Padding(padding:const EdgeInsets.only(bottom:14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(label,style:GoogleFonts.plusJakartaSans(fontSize:11,fontWeight:FontWeight.w600,color:AppColors.text3)),
      const SizedBox(height:6),
      TextField(controller:ctrl,obscureText:obs,style:GoogleFonts.plusJakartaSans(fontSize:14,color:AppColors.text1),
        decoration:InputDecoration(
          prefixIcon:const Icon(Icons.lock_outline_rounded,size:18,color:AppColors.text4),
          suffixIcon:GestureDetector(onTap:toggle,child:Icon(obs?Icons.visibility_off_rounded:Icons.visibility_rounded,size:18,color:AppColors.text4)),
          filled:true,fillColor:AppColors.surface,contentPadding:const EdgeInsets.symmetric(horizontal:14,vertical:14),
          border:OutlineInputBorder(borderRadius:BorderRadius.circular(rMd),borderSide:const BorderSide(color:AppColors.border,width:1.5)),
          enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(rMd),borderSide:const BorderSide(color:AppColors.border,width:1.5)),
          focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(rMd),borderSide:const BorderSide(color:AppColors.blue,width:1.5)))),
    ]));
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
  final _tokenCtrl   = TextEditingController();
  final _baseUrlCtrl = TextEditingController(text: kBaseUrl);
  String _filterTag  = 'all';
  final Map<String, _TestResult?> _results = {};
  bool _testingAll = false;
  bool _showUrlEdit = false;

  static const _tags = ['all','auth','profiles','academics','operations','accounts'];

  @override
  void initState() {
    super.initState();
    if (TokenStore.access != null) _tokenCtrl.text = TokenStore.access!;
  }

  @override
  void dispose() { _tokenCtrl.dispose(); _baseUrlCtrl.dispose(); super.dispose(); }

  List<_Ep> get _filtered =>
      _endpoints.where((e) => _filterTag == 'all' || e.tag == _filterTag).toList();

  bool get _hasToken => _tokenCtrl.text.trim().isNotEmpty;
  String get _baseUrl => _baseUrlCtrl.text.trim().isNotEmpty ? _baseUrlCtrl.text.trim() : kBaseUrl;

  Color _tagColor(String t) {
    switch(t) {
      case 'auth':       return AppColors.navy;
      case 'profiles':   return AppColors.blue;
      case 'academics':  return AppColors.teal;
      case 'operations': return AppColors.green;
      case 'accounts':   return AppColors.amber;
      default:           return AppColors.text3;
    }
  }

  Color _methodColor(String m) {
    switch(m) {
      case 'GET':    return const Color(0xFF22C55E);
      case 'POST':   return AppColors.blue;
      case 'PATCH':  return AppColors.amber;
      case 'DELETE': return AppColors.red;
      default:       return AppColors.text3;
    }
  }

  Future<_TestResult> _fire(_Ep ep, Map<String, dynamic> body) async {
    final token = _tokenCtrl.text.trim();
    final sw    = Stopwatch()..start();
    try {
      final headers = <String,String>{'Content-Type':'application/json'};
      if (ep.requiresAuth && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
      final uri = Uri.parse('$_baseUrl${ep.path}');
      http.Response res;
      if (ep.method == 'GET') {
        res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      } else {
        res = await http.post(uri, headers: headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 15));
      }
      sw.stop();
      String respBody = res.body;
      try {
        final decoded = jsonDecode(respBody);
        respBody = const JsonEncoder.withIndent('  ').convert(decoded);
        // Auto-extract token from successful login
        if ((ep.path.contains('login') || ep.path.contains('auth')) &&
            res.statusCode == 200 && decoded is Map) {
          final access  = decoded['access']?.toString();
          final refresh = decoded['refresh']?.toString();
          if (access != null && access.isNotEmpty) {
            setState(() => _tokenCtrl.text = access);
            TokenStore.save(access: access, refresh: refresh ?? '');
          }
        }
      } catch (_) {}
      return _TestResult(
        statusCode: res.statusCode,
        body: respBody,
        ms: sw.elapsedMilliseconds,
        ok: res.statusCode < 400,
        isUnauth: res.statusCode == 401,
      );
    } catch (e) {
      sw.stop();
      return _TestResult(statusCode:0, body:'Network error: $e', ms:sw.elapsedMilliseconds, ok:false);
    }
  }

  Future<void> _testAll() async {
    setState(() { _testingAll=true; _results.clear(); });
    for (final ep in _filtered) {
      final body = Map<String,dynamic>.from(ep.defaultBody ?? {});
      final r = await _fire(ep, body);
      if (mounted) setState(() => _results[ep.path+ep.method] = r);
    }
    if (mounted) setState(() => _testingAll=false);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;
    final passed = _results.values.where((r) => r?.ok==true).length;
    final failed = _results.values.where((r) => r?.ok==false).length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children:[
        // ── Header ────────────────────────────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(14,topPad+10,14,14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,
              colors:[Color(0xFF0F0C29),Color(0xFF1A1A2E),Color(0xFF2D1B8E)]),
          ),
          child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            // Title row
            Row(children:[
              GestureDetector(onTap:()=>Navigator.of(context).pop(),
                child:Container(width:34,height:34,
                  decoration:BoxDecoration(color:Colors.white.withOpacity(0.1),borderRadius:BorderRadius.circular(rMd),
                    border:Border.all(color:Colors.white.withOpacity(0.15),width:1.5)),
                  child:const Icon(Icons.arrow_back_rounded,size:15,color:Colors.white))),
              const SizedBox(width:10),
              Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text('API Explorer',style:GoogleFonts.dmSerifDisplay(fontSize:18,color:Colors.white)),
                GestureDetector(
                  onTap:()=>setState(()=>_showUrlEdit=!_showUrlEdit),
                  child:Text(_baseUrl,style:GoogleFonts.plusJakartaSans(fontSize:9,color:const Color(0xFF00FF88),letterSpacing:0.5,decoration:TextDecoration.underline,decorationColor:const Color(0xFF00FF88)))),
              ])),
              if (_results.isNotEmpty)...[
                _statPill('$passed',AppColors.green),
                const SizedBox(width:5),
                _statPill('$failed',AppColors.red,fail:true),
              ],
            ]),

            // URL editor (collapsible)
            if (_showUrlEdit)...[
              const SizedBox(height:8),
              Container(
                padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),
                decoration:BoxDecoration(color:Colors.white.withOpacity(0.06),borderRadius:BorderRadius.circular(rSm),
                  border:Border.all(color:const Color(0xFF00FF88).withOpacity(0.3))),
                child:TextField(
                  controller:_baseUrlCtrl,
                  onChanged:(_)=>setState((){}),
                  style:GoogleFonts.plusJakartaSans(fontSize:11,color:const Color(0xFF00FF88)),
                  decoration:InputDecoration(hintText:'http://your-server:8081',
                    hintStyle:GoogleFonts.plusJakartaSans(fontSize:11,color:Colors.white.withOpacity(0.3)),
                    border:InputBorder.none,isDense:true,contentPadding:EdgeInsets.zero,
                    prefixIcon:const Icon(Icons.edit_rounded,size:12,color:Color(0xFF00FF88)),
                    prefixIconConstraints:const BoxConstraints(minWidth:24)),
                ),
              ),
            ],

            const SizedBox(height:10),

            // Token field
            Container(
              padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),
              decoration:BoxDecoration(
                color:_hasToken ? const Color(0xFF00FF88).withOpacity(0.08) : Colors.white.withOpacity(0.06),
                borderRadius:BorderRadius.circular(rMd),
                border:Border.all(
                  color:_hasToken ? const Color(0xFF00FF88).withOpacity(0.5) : Colors.white.withOpacity(0.15),
                  width:1.5),
              ),
              child:Row(children:[
                Icon(Icons.key_rounded,size:14,color:_hasToken?const Color(0xFF00FF88):Colors.white.withOpacity(0.4)),
                const SizedBox(width:8),
                Expanded(child:TextField(
                  controller:_tokenCtrl,
                  onChanged:(_)=>setState((){}),
                  style:GoogleFonts.plusJakartaSans(fontSize:11,
                    color:_hasToken?const Color(0xFF00FF88):Colors.white.withOpacity(0.5)),
                  decoration:InputDecoration(
                    hintText:'Bearer token — auto-fills after login',
                    hintStyle:GoogleFonts.plusJakartaSans(fontSize:11,color:Colors.white.withOpacity(0.28)),
                    border:InputBorder.none,isDense:true,contentPadding:EdgeInsets.zero),
                )),
                if (_hasToken)...[
                  GestureDetector(
                    onTap:(){Clipboard.setData(ClipboardData(text:_tokenCtrl.text));},
                    child:const Icon(Icons.copy_rounded,size:12,color:Color(0xFF00FF88))),
                  const SizedBox(width:8),
                  GestureDetector(
                    onTap:()=>setState(()=>_tokenCtrl.clear()),
                    child:const Icon(Icons.close_rounded,size:12,color:Color(0xFF00FF88))),
                ],
              ]),
            ),

            // No-token warning
            if (!_hasToken)...[
              const SizedBox(height:8),
              Container(
                padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),
                decoration:BoxDecoration(
                  color:const Color(0xFFFCD34D).withOpacity(0.12),
                  borderRadius:BorderRadius.circular(rSm),
                  border:Border.all(color:const Color(0xFFFCD34D).withOpacity(0.4))),
                child:Row(children:[
                  const Icon(Icons.info_outline_rounded,size:12,color:Color(0xFFFCD34D)),
                  const SizedBox(width:7),
                  Expanded(child:Text('Run POST /api/v1/auth/login/ to get a token. Edit the body with your credentials first.',
                    style:GoogleFonts.plusJakartaSans(fontSize:10,color:const Color(0xFFFCD34D),height:1.4))),
                ]),
              ),
            ],
            if (_hasToken)...[
              const SizedBox(height:6),
              Container(
                padding:const EdgeInsets.symmetric(horizontal:12,vertical:6),
                decoration:BoxDecoration(
                  color:const Color(0xFF00FF88).withOpacity(0.08),
                  borderRadius:BorderRadius.circular(rSm),
                  border:Border.all(color:const Color(0xFF00FF88).withOpacity(0.3))),
                child:Row(children:[
                  const Icon(Icons.check_circle_rounded,size:11,color:Color(0xFF00FF88)),
                  const SizedBox(width:6),
                  Text('Token active — all endpoints unlocked',
                    style:GoogleFonts.plusJakartaSans(fontSize:10,color:const Color(0xFF00FF88))),
                ]),
              ),
            ],

            const SizedBox(height:10),

            // Filter chips + test all
            Row(children:[
              Expanded(child:SingleChildScrollView(
                scrollDirection:Axis.horizontal,
                child:Row(children:_tags.map((t)=>GestureDetector(
                  onTap:()=>setState(()=>_filterTag=t),
                  child:Container(
                    margin:const EdgeInsets.only(right:6),
                    padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),
                    decoration:BoxDecoration(
                      color:_filterTag==t ? _tagColor(t) : Colors.white.withOpacity(0.1),
                      borderRadius:BorderRadius.circular(rFull)),
                    child:Text(t,style:GoogleFonts.plusJakartaSans(fontSize:10,fontWeight:FontWeight.w600,color:Colors.white))),
                )).toList()),
              )),
              const SizedBox(width:8),
              GestureDetector(
                onTap:_testingAll?null:_testAll,
                child:Container(
                  padding:const EdgeInsets.symmetric(horizontal:12,vertical:6),
                  decoration:BoxDecoration(
                    color:const Color(0xFF00FF88).withOpacity(0.12),
                    borderRadius:BorderRadius.circular(rSm),
                    border:Border.all(color:const Color(0xFF00FF88).withOpacity(0.45),width:1.5)),
                  child:_testingAll
                    ? const SizedBox(width:12,height:12,child:CircularProgressIndicator(strokeWidth:1.5,color:Color(0xFF00FF88)))
                    : Row(mainAxisSize:MainAxisSize.min,children:[
                        const Icon(Icons.play_arrow_rounded,size:12,color:Color(0xFF00FF88)),
                        const SizedBox(width:4),
                        Text('Test All',style:GoogleFonts.plusJakartaSans(fontSize:10,fontWeight:FontWeight.w700,color:const Color(0xFF00FF88))),
                      ]),
                ),
              ),
            ]),
          ]),
        ),

        // ── Endpoint list ─────────────────────────────────────────────────
        Expanded(child:ListView.builder(
          padding:EdgeInsets.fromLTRB(12,8,12,12+botPad),
          itemCount:_filtered.length,
          itemBuilder:(_, i) {
            final ep  = _filtered[i];
            final key = ep.path+ep.method;
            return _EndpointCard(
              ep:          ep,
              result:      _results[key],
              methodColor: _methodColor(ep.method),
              token:       _tokenCtrl.text.trim(),
              hasToken:    _hasToken,
              onResult:    (r) => setState(() => _results[key] = r),
              onFire:      _fire,
            );
          },
        )),
      ]),
    );
  }

  Widget _statPill(String v, Color c, {bool fail=false}) => Container(
    padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),
    decoration:BoxDecoration(color:c.withOpacity(0.15),borderRadius:BorderRadius.circular(rFull),border:Border.all(color:c.withOpacity(0.4),width:1)),
    child:Row(mainAxisSize:MainAxisSize.min,children:[
      Icon(fail?Icons.close_rounded:Icons.check_rounded,size:10,color:c),
      const SizedBox(width:3),
      Text(v,style:GoogleFonts.plusJakartaSans(fontSize:11,fontWeight:FontWeight.w700,color:c)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TEST RESULT
// ─────────────────────────────────────────────────────────────────────────────

class _TestResult {
  final int    statusCode;
  final String body;
  final int    ms;
  final bool   ok;
  final bool   isUnauth;
  _TestResult({required this.statusCode,required this.body,required this.ms,required this.ok,this.isUnauth=false});
}

// ─────────────────────────────────────────────────────────────────────────────
// ENDPOINT CARD — fully editable request body
// ─────────────────────────────────────────────────────────────────────────────

class _EndpointCard extends StatefulWidget {
  final _Ep         ep;
  final _TestResult? result;
  final Color       methodColor;
  final String      token;
  final bool        hasToken;
  final void Function(_TestResult) onResult;
  final Future<_TestResult> Function(_Ep, Map<String,dynamic>) onFire;

  const _EndpointCard({
    required this.ep,
    required this.result,
    required this.methodColor,
    required this.token,
    required this.hasToken,
    required this.onResult,
    required this.onFire,
  });

  @override
  State<_EndpointCard> createState() => _EndpointCardState();
}

class _EndpointCardState extends State<_EndpointCard> {
  bool _expanded = false;
  bool _testing  = false;
  bool _jsonError = false;
  late TextEditingController _bodyCtrl;

  @override
  void initState() {
    super.initState();
    final initial = widget.ep.defaultBody != null
        ? const JsonEncoder.withIndent('  ').convert(widget.ep.defaultBody)
        : '';
    _bodyCtrl = TextEditingController(text: initial);
  }

  @override
  void dispose() { _bodyCtrl.dispose(); super.dispose(); }

  Map<String,dynamic> _parseBody() {
    if (_bodyCtrl.text.trim().isEmpty) return {};
    try {
      final parsed = jsonDecode(_bodyCtrl.text.trim());
      if (parsed is Map<String,dynamic>) { setState(()=>_jsonError=false); return parsed; }
    } catch (_) {}
    setState(()=>_jsonError=true);
    return {};
  }

  Future<void> _run() async {
    final body = _parseBody();
    if (_jsonError) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid JSON — fix the request body first.'), duration: Duration(seconds: 2)));
      return;
    }
    setState(()=>_testing=true);
    final r = await widget.onFire(widget.ep, body);
    widget.onResult(r);
    if (mounted) setState((){_testing=false; _expanded=true;});
  }

  void _formatJson() {
    try {
      final decoded = jsonDecode(_bodyCtrl.text.trim());
      _bodyCtrl.text = const JsonEncoder.withIndent('  ').convert(decoded);
      setState(()=>_jsonError=false);
    } catch (_) { setState(()=>_jsonError=true); }
  }

  void _resetBody() {
    if (widget.ep.defaultBody != null) {
      _bodyCtrl.text = const JsonEncoder.withIndent('  ').convert(widget.ep.defaultBody);
      setState(()=>_jsonError=false);
    }
  }

  Color get _borderColor {
    final r = widget.result;
    if (r == null) return AppColors.border;
    if (r.ok) return const Color(0xFF86EFAC);
    return const Color(0xFFFCA5A5);
  }

  Color get _statusColor {
    final r = widget.result;
    if (r == null) return AppColors.text4;
    return r.ok ? AppColors.green : AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.result;
    final isPost = widget.ep.method != 'GET';

    return Container(
      margin:const EdgeInsets.only(bottom:9),
      decoration:BoxDecoration(
        color:AppColors.surface,
        border:Border.all(color:_borderColor,width:1.5),
        borderRadius:BorderRadius.circular(rLg),
        boxShadow:shadowSm),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        // ── Header row ──────────────────────────────────────────────────
        GestureDetector(
          onTap:()=>setState(()=>_expanded=!_expanded),
          child:Padding(
            padding:const EdgeInsets.fromLTRB(12,12,12,10),
            child:Row(children:[
              // Method badge
              Container(
                padding:const EdgeInsets.symmetric(horizontal:7,vertical:3),
                decoration:BoxDecoration(color:widget.methodColor.withOpacity(0.12),borderRadius:BorderRadius.circular(rSm)),
                child:Text(widget.ep.method,style:GoogleFonts.plusJakartaSans(fontSize:9,fontWeight:FontWeight.w800,color:widget.methodColor,letterSpacing:0.5))),
              const SizedBox(width:8),
              Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Row(children:[
                  Expanded(child:Text(widget.ep.path,style:GoogleFonts.plusJakartaSans(fontSize:11,fontWeight:FontWeight.w700,color:AppColors.text1))),
                  if (widget.ep.requiresAuth)
                    Icon(widget.hasToken?Icons.lock_open_rounded:Icons.lock_rounded,size:11,
                      color:widget.hasToken?AppColors.green:AppColors.amber),
                ]),
                Text(widget.ep.desc,style:GoogleFonts.plusJakartaSans(fontSize:10,color:AppColors.text3)),
              ])),
              if (res!=null)...[
                Column(crossAxisAlignment:CrossAxisAlignment.end,children:[
                  Text('${res.statusCode}',style:GoogleFonts.plusJakartaSans(fontSize:12,fontWeight:FontWeight.w800,color:_statusColor)),
                  Text('${res.ms}ms',style:GoogleFonts.plusJakartaSans(fontSize:9,color:AppColors.text4)),
                ]),
                const SizedBox(width:8),
              ],
              // Run button
              GestureDetector(
                onTap:_testing?null:_run,
                child:Container(
                  width:30,height:30,
                  decoration:BoxDecoration(
                    color:widget.hasToken||!widget.ep.requiresAuth ? AppColors.blueLight : AppColors.amberLight,
                    borderRadius:BorderRadius.circular(rSm)),
                  child:Center(child:_testing
                    ? const SizedBox(width:13,height:13,child:CircularProgressIndicator(strokeWidth:1.5,color:AppColors.blue))
                    : Icon(
                        widget.hasToken||!widget.ep.requiresAuth ? Icons.play_arrow_rounded : Icons.lock_rounded,
                        size:15,
                        color:widget.hasToken||!widget.ep.requiresAuth ? AppColors.blue : AppColors.amber))),
              ),
            ]),
          ),
        ),

        // ── Expanded body ───────────────────────────────────────────────
        if (_expanded)...[
          const Divider(height:1,color:AppColors.border),
          Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[

            // Locked hint
            if (widget.ep.requiresAuth && !widget.hasToken)...[
              Container(
                margin:const EdgeInsets.only(bottom:10),
                padding:const EdgeInsets.all(10),
                decoration:BoxDecoration(color:const Color(0xFFFFFBEB),borderRadius:BorderRadius.circular(rSm),
                  border:Border.all(color:const Color(0xFFFCD34D))),
                child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  const Icon(Icons.lock_rounded,size:12,color:Color(0xFFB45309)),
                  const SizedBox(width:7),
                  Expanded(child:Text(
                    'This endpoint requires auth. Steps:\n1. Expand POST /api/v1/auth/login/\n2. Edit username/password and tap ▶\n3. Token auto-fills — then come back here.',
                    style:GoogleFonts.plusJakartaSans(fontSize:10,color:const Color(0xFFB45309),height:1.5))),
                ]),
              ),
            ],

            // Editable body (POST/PATCH only)
            if (isPost)...[
              Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
                Row(children:[
                  Text('REQUEST BODY',style:GoogleFonts.plusJakartaSans(fontSize:9,fontWeight:FontWeight.w700,letterSpacing:1.5,color:AppColors.text4)),
                  const SizedBox(width:6),
                  Container(padding:const EdgeInsets.symmetric(horizontal:6,vertical:2),
                    decoration:BoxDecoration(color:AppColors.blueLight,borderRadius:BorderRadius.circular(rSm)),
                    child:Text('EDITABLE',style:GoogleFonts.plusJakartaSans(fontSize:8,fontWeight:FontWeight.w700,color:AppColors.blue,letterSpacing:0.8))),
                ]),
                Row(children:[
                  _miniBtn('Format',Icons.auto_fix_high_rounded,AppColors.blue,_formatJson),
                  const SizedBox(width:6),
                  _miniBtn('Reset',Icons.restart_alt_rounded,AppColors.amber,_resetBody),
                  const SizedBox(width:6),
                  _miniBtn('Copy',Icons.copy_rounded,AppColors.text3,
                    ()=>Clipboard.setData(ClipboardData(text:_bodyCtrl.text))),
                ]),
              ]),
              const SizedBox(height:6),
              Container(
                decoration:BoxDecoration(
                  color:const Color(0xFF111827),
                  borderRadius:BorderRadius.circular(rMd),
                  border:Border.all(color:_jsonError ? AppColors.red.withOpacity(0.7) : const Color(0xFF00FF88).withOpacity(0.2)),
                ),
                child:TextField(
                  controller:_bodyCtrl,
                  maxLines:null,
                  onChanged:(_)=>setState(()=>_jsonError=false),
                  style:GoogleFonts.sourceCodePro(fontSize:11,color:const Color(0xFF9CDCFE),height:1.5),
                  decoration:InputDecoration(
                    contentPadding:const EdgeInsets.all(12),
                    border:InputBorder.none,
                    hintText:'{}',
                    hintStyle:GoogleFonts.sourceCodePro(fontSize:11,color:Colors.white.withOpacity(0.2))),
                ),
              ),
              if (_jsonError)...[
                const SizedBox(height:4),
                Text('⚠ Invalid JSON',style:GoogleFonts.plusJakartaSans(fontSize:10,color:AppColors.red)),
              ],
              const SizedBox(height:10),
            ],

            // Response
            if (res != null)...[
              Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
                Row(children:[
                  Text('RESPONSE',style:GoogleFonts.plusJakartaSans(fontSize:9,fontWeight:FontWeight.w700,letterSpacing:1.5,color:AppColors.text4)),
                  const SizedBox(width:6),
                  _statusBadge(res),
                ]),
                GestureDetector(
                  onTap:()=>Clipboard.setData(ClipboardData(text:res.body)),
                  child:const Icon(Icons.copy_rounded,size:13,color:AppColors.text4)),
              ]),
              const SizedBox(height:6),
              if (res.isUnauth)...[
                Container(
                  margin:const EdgeInsets.only(bottom:8),
                  padding:const EdgeInsets.all(10),
                  decoration:BoxDecoration(color:const Color(0xFFFFFBEB),borderRadius:BorderRadius.circular(rSm),
                    border:Border.all(color:const Color(0xFFFCD34D))),
                  child:Text(
                    '401 Unauthorized — run POST /auth/login/ first to get a token, then retry.',
                    style:GoogleFonts.plusJakartaSans(fontSize:10,color:const Color(0xFFB45309),height:1.4)),
                ),
              ],
              Container(
                width:double.infinity,
                constraints:const BoxConstraints(maxHeight:260),
                padding:const EdgeInsets.all(11),
                decoration:BoxDecoration(
                  color:const Color(0xFF0D1117),
                  borderRadius:BorderRadius.circular(rMd),
                  border:Border.all(color:res.ok ? const Color(0xFF86EFAC).withOpacity(0.4) : const Color(0xFFFCA5A5).withOpacity(0.4),width:1)),
                child:SingleChildScrollView(
                  child:Text(res.body,style:GoogleFonts.sourceCodePro(fontSize:10,
                    color:res.ok ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5)))),
              ),
            ] else if (!isPost)
              Text('Tap ▶ to test this endpoint',
                style:GoogleFonts.plusJakartaSans(fontSize:11,color:AppColors.text4)),
          ])),
        ],
      ]),
    );
  }

  Widget _miniBtn(String label, IconData icon, Color color, VoidCallback onTap) =>
    GestureDetector(onTap:onTap,child:Row(mainAxisSize:MainAxisSize.min,children:[
      Icon(icon,size:11,color:color),
      const SizedBox(width:3),
      Text(label,style:GoogleFonts.plusJakartaSans(fontSize:9,fontWeight:FontWeight.w600,color:color)),
    ]));

  Widget _statusBadge(_TestResult r) => Container(
    padding:const EdgeInsets.symmetric(horizontal:6,vertical:2),
    decoration:BoxDecoration(
      color:r.ok ? AppColors.greenLight : AppColors.redLight,
      borderRadius:BorderRadius.circular(rSm)),
    child:Text('${r.statusCode}',style:GoogleFonts.plusJakartaSans(
      fontSize:9,fontWeight:FontWeight.w800,
      color:r.ok ? AppColors.green : AppColors.red)),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────────────────────────

Widget _errorBox(String msg) => Container(
  padding:const EdgeInsets.symmetric(horizontal:14,vertical:10),
  decoration:BoxDecoration(color:AppColors.redLight,borderRadius:BorderRadius.circular(rMd),border:Border.all(color:const Color(0xFFFCA5A5),width:1.5)),
  child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Icon(Icons.error_outline_rounded,size:14,color:AppColors.red),
    const SizedBox(width:8),
    Expanded(child:Text(msg,style:GoogleFonts.plusJakartaSans(fontSize:12,color:AppColors.red))),
  ]),
);

Widget _successBox(String msg) => Container(
  padding:const EdgeInsets.symmetric(horizontal:14,vertical:12),
  decoration:BoxDecoration(color:AppColors.greenLight,borderRadius:BorderRadius.circular(rMd),border:Border.all(color:const Color(0xFF86EFAC),width:1.5)),
  child:Row(children:[
    const Icon(Icons.check_circle_outline_rounded,size:14,color:AppColors.green),
    const SizedBox(width:8),
    Expanded(child:Text(msg,style:GoogleFonts.plusJakartaSans(fontSize:12,fontWeight:FontWeight.w600,color:AppColors.green))),
  ]),
);

Widget _gradBtn(VoidCallback? onTap, Widget child) => GestureDetector(
  onTap:onTap,
  child:AnimatedContainer(duration:const Duration(milliseconds:150),
    width:double.infinity,padding:const EdgeInsets.symmetric(vertical:14),
    decoration:BoxDecoration(
      gradient:const LinearGradient(colors:[AppColors.gradA,AppColors.gradC],begin:Alignment.topLeft,end:Alignment.bottomRight),
      borderRadius:BorderRadius.circular(rMd),boxShadow:shadowMd),
    child:Center(child:child)),
);
