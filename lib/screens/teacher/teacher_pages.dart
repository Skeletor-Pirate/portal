import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../models/role_config.dart';
import '../../services/api_service.dart';
import '../../services/app_store.dart' hide Exam;
import '../../widgets/builders.dart';
import '../../widgets/interactive.dart';
import '../page_router.dart';

class TeacherPages extends StatelessWidget {
  final String page;
  const TeacherPages({super.key, required this.page});
  @override
  Widget build(BuildContext context) {
    switch (page) {
      case 'dashboard':   return const _Dashboard();
      case 'attendance':  return const _Attendance();
      case 'assignments': return const _Assignments();
      case 'grades':      return const _Grades();
      case 'timetable':   return const _Timetable();
      case 'exams':       return const _Exams();
      case 'analytics':   return const _Analytics();
      default:            return defaultPage(page);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────

class _Dashboard extends StatefulWidget {
  const _Dashboard();
  @override State<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<_Dashboard> {
  ProfileMe? _profile;
  List<TeacherAssignment> _myAssignments = [];

  @override
  void initState() {
    super.initState();
    if (TokenStore.hasTokens && !AppStore.instance.isDevMode) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    try {
      final ctx = await ApiService().getProfileContext();
      if (!mounted) return;
      setState(() {
        _profile = ProfileMe(id: ctx.identity.id, displayName: ctx.identity.fullName, role: ctx.roles.isNotEmpty ? ctx.roles.first : '', schoolName: null, idLabel: null, raw: {});
      });
      if (ctx.profiles.teacher.id != null) {
        final res = await ApiService().getTeacherAssignments(teacherId: ctx.profiles.teacher.id, status: 'current');
        if (mounted) setState(() => _myAssignments = res.results);
      }
    } catch (_) {
      try {
        final p = await ApiService().getMyProfile();
        if (mounted) setState(() => _profile = p);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg    = kRoles[UserRole.teacher]!;
    final store  = AppStore.instance;
    final name   = store.currentUserName.isNotEmpty ? store.currentUserName : (_profile?.displayName ?? cfg.name);
    final school = store.currentSchool.isNotEmpty ? store.currentSchool : (_profile?.schoolName ?? 'Westfield Academy');

    return ValueListenableBuilder(
      valueListenable: AppStore.instance.assignments,
      builder: (context, asgns, _) {
        final pending = asgns.fold<int>(0, (sum, a) => sum + (a.total - a.submitted));
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          heroPortrait(cfg.avatarAsset, school),
          profileInfo(name, 'Faculty', cfg.idLabel),
          pageTitle('Dashboard', subtitle: 'AI-Powered Portal'),
          ValueListenableBuilder<int>(
            valueListenable: AppStore.instance.globalAttendanceInt,
            builder: (ctx, attVal, _) => quickStatsBar([
              QsItem(val: '${_myAssignments.length}', label: 'My Classes'),
              QsItem(val: '$attVal%', label: 'Attendance'),
              QsItem(val: '$pending', label: 'Pending'),
              QsItem(val: '${asgns.length}', label: 'Assignments'),
            ]),
          ),

          if (_myAssignments.isNotEmpty) ...[
            secLabel("My Class Assignments"),
            appCard(Column(children: _myAssignments.take(5).map((a) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.teal, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${a.subjectName ?? "Subject"} · ${a.classLevelName ?? ""} ${a.sectionName ?? ""}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
                  Text(a.academicYearName ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
                ])),
                if (a.isClassTeacher) appBadge('Class Teacher', bg: AppColors.amberLight, color: AppColors.amber),
              ]),
            )).toList())),
          ] else ...[
            secLabel("Today's Classes"),
            appCard(ttRows([
              TtItem(time: '08:00–09:30', subject: 'Physics 11-B', room: 'Lab 2',    status: 'Completed', barColor: AppColors.teal, badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
              TtItem(time: '10:15–11:45', subject: 'Science 10-A', room: 'Room 204', status: 'Active',    barColor: AppColors.blue, badgeBg: AppColors.blueLight,  badgeColor: AppColors.blue),
              TtItem(time: '13:00–14:30', subject: 'Chemistry 12', room: 'Lab 3',    status: 'Upcoming',  barColor: AppColors.navy, badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3),
            ])),
          ],

          secLabel('Quick Actions'),
          actionGrid([
            ActionItem(icon: Icons.note_add_rounded,      label: 'Assignment',    bg: AppColors.blueLight,  iconColor: AppColors.blue,  onTap: () => showCreateAssignment(context)),
            ActionItem(icon: Icons.edit_calendar_rounded, label: 'Schedule Exam', bg: AppColors.amberLight, iconColor: AppColors.amber, onTap: () => showScheduleExam(context)),
            ActionItem(icon: Icons.bar_chart_rounded,     label: 'Grades',        bg: AppColors.tealLight,  iconColor: AppColors.teal,  onTap: () => showToast(context, 'Opening grade book…')),
            ActionItem(icon: Icons.campaign_rounded,      label: 'Announce',      bg: AppColors.redLight,   iconColor: AppColors.red,   onTap: () => showAnnounce(context)),
            ActionItem(icon: Icons.trending_up_rounded,   label: 'Analytics',     bg: AppColors.greenLight, iconColor: AppColors.green, onTap: () => showToast(context, 'Opening analytics…')),
            ActionItem(icon: Icons.notifications_rounded, label: 'Notifications', bg: AppColors.blueLight,  iconColor: AppColors.blue,  onTap: () => showNotifications(context)),
          ]),

          ValueListenableBuilder(
            valueListenable: AppStore.instance.announcements,
            builder: (ctx, anns, _) {
              if (anns.isEmpty) return const SizedBox.shrink();
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                secLabel('Recent Announcements'),
                appCard(Column(children: anns.take(3).map((ann) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                  child: Row(children: [
                    Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.redLight, borderRadius: BorderRadius.circular(rMd)), child: const Icon(Icons.campaign_rounded, size: 16, color: AppColors.red)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(ann.audience, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.red, letterSpacing: 0.5)),
                      Text(ann.message, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text1), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ])),
                    Text(ann.time, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4)),
                  ]),
                )).toList())),
              ]);
            },
          ),
          const SizedBox(height: 16),
        ]);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ATTENDANCE — live API bulk-record
// ─────────────────────────────────────────────────────────────────────────────

class _Attendance extends StatefulWidget {
  const _Attendance();
  @override State<_Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<_Attendance> {
  // Context loaded from profile
  List<TeacherAssignment> _assignments = [];
  List<StudentProfile>    _students    = [];
  List<Enrollment>        _enrollments = [];
  int    _assignIdx = 0;
  bool   _loading   = true;
  bool   _saving    = false;
  String? _error;

  // attendance state: studentId → status
  Map<String, String> _statuses = {};
  bool _saved = false;

  String? _teacherProfileId;

  @override
  void initState() { super.initState(); _bootstrap(); }

  Future<void> _bootstrap() async {
    if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
    try {
      final ctx = await ApiService().getProfileContext();
      _teacherProfileId = ctx.profiles.teacher.id;
      if (_teacherProfileId != null) {
        final res = await ApiService().getTeacherAssignments(teacherId: _teacherProfileId, status: 'current');
        if (mounted) {
          setState(() => _assignments = res.results);
          if (_assignments.isNotEmpty) {
            await _loadStudents();
            return; // _loadStudents handles setting _loading to false
          }
        }
      }
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _loadStudents() async {
    if (_assignments.isEmpty) { setState(() => _loading = false); return; }
    final a = _assignments[_assignIdx];
    try {
      // Get enrollments for this section + academic year
      final res = await ApiService().getEnrollments(status: 'current');
      final sectionEnrollments = res.results.where((e) => e.sectionId == a.sectionId).toList();
      
      // Fetch today's attendance for this section so UI doesn't reset to 'Present'
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
      final attendanceRes = await ApiService().getAttendance(date: dateStr, sectionId: a.sectionId);
      final attendanceMap = { for (var rec in attendanceRes.results) rec.studentId: rec.status };

      final Map<String, String> initial = {};
      for (final e in sectionEnrollments) {
        initial[e.studentId] = attendanceMap[e.studentId] ?? 'Present';
      }
      if (mounted) setState(() {
        _enrollments = sectionEnrollments;
        _statuses = initial;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _save() async {
    if (_assignments.isEmpty) return;
    final a = _assignments[_assignIdx];
    setState(() => _saving = true);
    try {
      final records = _enrollments.map((e) => {
        'student_id': e.studentId,
        'status':     _statuses[e.studentId] ?? 'Present',
        'remarks':    '',
      }).toList();

      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';

      await ApiService().bulkRecordAttendance(
        academicYearId: a.academicYearId,
        classLevelId:   a.classLevelId,
        sectionId:      a.sectionId,
        date:           dateStr,
        records:        records,
      );

      // Re-fetch attendance after saving to update dashboard statistics!
      AppStore.instance.initSession();

      AppStore.instance.prependActivity('Attendance Saved', '${a.classLevelName ?? ""} ${a.sectionName ?? ""} · $dateStr');
      if (mounted) {
        setState(() { _saved = true; _saving = false; });
        showToast(context, 'Attendance saved for ${a.classLevelName ?? ""} ${a.sectionName ?? ""}');
        Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _saved = false); });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showToast(context, e.toString(), color: AppColors.red, icon: Icons.error_outline_rounded);
      }
    }
  }

  String _dateStr() {
    final now = DateTime.now();
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${now.day} ${m[now.month-1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Fallback to dummy data if not authenticated or no assignments
    if (!TokenStore.hasTokens || (_assignments.isEmpty && !_loading)) {
      return _buildFallbackAttendance(context);
    }

    if (_loading) return Column(children: [
      pageTitle('Attendance'),
      const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
    ]);

    if (_error != null) return Column(children: [
      pageTitle('Attendance'),
      _apiWarning(_error!),
      _buildFallbackAttendance(context),
    ]);

    final a        = _assignments.isNotEmpty ? _assignments[_assignIdx] : null;
    final present  = _statuses.values.where((v) => v == 'Present').length;
    final late     = _statuses.values.where((v) => v == 'Late').length;
    final absent   = _statuses.values.where((v) => v == 'Absent').length;
    final halfDay  = _statuses.values.where((v) => v == 'Half-Day').length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Attendance', subtitle: 'Mark attendance · ${_dateStr()}'),
      // Class selector chips
      if (_assignments.length > 1)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: Row(children: _assignments.asMap().entries.map((entry) => GestureDetector(
            onTap: () { setState(() { _assignIdx = entry.key; _loading = true; }); _loadStudents(); },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _assignIdx == entry.key ? AppColors.navy : AppColors.surface,
                border: Border.all(color: _assignIdx == entry.key ? AppColors.navy : AppColors.border, width: 1.5),
                borderRadius: BorderRadius.circular(rFull),
              ),
              child: Text('${entry.value.classLevelName ?? ""} ${entry.value.sectionName ?? ""} · ${entry.value.subjectName ?? ""}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: _assignIdx == entry.key ? Colors.white : AppColors.text3)),
            ),
          )).toList()),
        ),

      // Summary bar
      Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(rLg), boxShadow: shadowSm),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _chip('Present', present, AppColors.green),
          _chip('Late',    late,    AppColors.amber),
          _chip('Absent',  absent,  AppColors.red),
          if (halfDay > 0) _chip('Half', halfDay, AppColors.navy),
        ]),
      ),

      appCard(Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text('${a?.classLevelName ?? ""} ${a?.sectionName ?? ""} · ${a?.subjectName ?? ""}',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1))),
            Row(children: [
              if (_saved) ...[
                const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.green),
                const SizedBox(width: 4),
                Text('Saved', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.green, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
              ],
              appBadge('${_enrollments.length} students', bg: AppColors.blueLight, color: AppColors.blue),
            ]),
          ]),
        ),

        if (_enrollments.isEmpty)
          Padding(padding: const EdgeInsets.all(20), child: Center(child: Column(children: [
            const Icon(Icons.people_outline_rounded, size: 32, color: AppColors.text4),
            const SizedBox(height: 8),
            Text('No students enrolled in this section.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)),
          ]))),

        ..._enrollments.map((enr) {
          final cur = _statuses[enr.studentId] ?? 'Present';
          Color rowBg = AppColors.surface;
          if (cur == 'Absent')   rowBg = AppColors.redLight.withOpacity(0.25);
          if (cur == 'Late')     rowBg = AppColors.amberLight.withOpacity(0.35);
          if (cur == 'Half-Day') rowBg = AppColors.blueLight.withOpacity(0.25);

          final initials = enr.studentName.split(' ').where((x) => x.isNotEmpty).map((x) => x[0]).join('');

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: rowBg,
              border: const Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(children: [
              Container(width: 38, height: 38,
                decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(rMd)),
                child: Center(child: Text(initials, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.teal)))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(enr.studentName, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
                Text('Roll: ${enr.rollNumber ?? "—"} · ID: ${enr.enrollmentNo ?? "—"}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
              ])),
              Row(children: [
                _attBtn(cur, 'Present',  Icons.check_rounded,       AppColors.green, AppColors.greenLight, enr.studentId),
                const SizedBox(width: 4),
                _attBtn(cur, 'Late',     Icons.access_time_rounded,  AppColors.amber, AppColors.amberLight, enr.studentId),
                const SizedBox(width: 4),
                _attBtn(cur, 'Absent',   Icons.close_rounded,        AppColors.red,   AppColors.redLight,   enr.studentId),
                const SizedBox(width: 4),
                _attBtn(cur, 'Half-Day', Icons.splitscreen_rounded,  AppColors.navy,  AppColors.blueLight,  enr.studentId),
              ]),
            ]),
          );
        }),
      ])),

      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        child: GestureDetector(
          onTap: _saving ? null : _save,
          child: Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.gradA, AppColors.gradC], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(rMd), boxShadow: shadowMd),
            child: Center(child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Save Attendance to Server', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
          ),
        ),
      ),
      const SizedBox(height: 16),
    ]);
  }

  Widget _chip(String label, int count, Color color) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: count > 0 ? color : AppColors.border, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text('$count $label', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: count > 0 ? color : AppColors.text4)),
  ]);

  Widget _attBtn(String cur, String val, IconData icon, Color color, Color bg, String studentId) =>
    GestureDetector(
      onTap: () => setState(() => _statuses[studentId] = val),
      child: Container(
        width: 26, height: 26,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: cur == val ? color : AppColors.border, width: 1.5), color: cur == val ? bg : Colors.transparent),
        child: Center(child: Icon(icon, size: 11, color: cur == val ? color : AppColors.text4)),
      ),
    );

  // Fallback when no real data available
  Widget _buildFallbackAttendance(BuildContext context) {
    final dummyClasses = const ['Science 10-A', 'Physics 11-B', 'Chemistry 12'];
    final dummyStudents = const [
      [('Aisha Okonkwo','01'),('Ben Carter','02'),('Clara Singh','03'),('David Lee','04'),('Eva Martinez','05')],
      [('George Patel','01'),('Hannah Kim','02'),('Ivan Nguyen','03'),('Julia Adams','04')],
      [('Lara Singh','01'),('Meera Osei','02'),('Niko Hassan','03'),('Omar Rivera','04')],
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Attendance (Demo)', subtitle: 'Connect to backend for live data'),
      const ChipRow(chips: ['Science 10-A', 'Physics 11-B', 'Chemistry 12']),
      appCard(Padding(padding: const EdgeInsets.all(16), child: Text(
        'Log in with real credentials to mark live attendance. Demo mode shows static data.',
        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3, height: 1.5),
      ))),
      const SizedBox(height: 16),
    ]);
  }
}

Widget _apiWarning(String msg) => Container(
  margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  decoration: BoxDecoration(color: AppColors.amberLight, borderRadius: BorderRadius.circular(rMd), border: Border.all(color: const Color(0xFFFCD34D), width: 1.5)),
  child: Row(children: [
    const Icon(Icons.wifi_off_rounded, size: 14, color: AppColors.amber),
    const SizedBox(width: 8),
    Expanded(child: Text('Showing cached data · $msg', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.amber))),
  ]),
);

// ─────────────────────────────────────────────────────────────────────────────
// GRADES — live API bulk-submit
// ─────────────────────────────────────────────────────────────────────────────

class _Grades extends StatefulWidget {
  const _Grades();
  @override State<_Grades> createState() => _GradesState();
}

class _GradesState extends State<_Grades> {
  List<Exam>              _exams       = [];
  List<TeacherAssignment> _assignments = [];
  List<Enrollment>        _enrollments = [];
  List<Subject>           _subjects    = [];
  String? _selectedExamId;
  String? _selectedSubjectId;
  String? _selectedSectionId;
  String? _selectedAssignmentLabel;
  int     _assignIdx = 0;

  // marks: studentId → marks string
  final Map<String, TextEditingController> _markCtrl = {};
  bool   _loading  = true;
  bool   _saving   = false;
  String? _error;
  String? _teacherProfileId;

  @override
  void initState() { super.initState(); _bootstrap(); }

  @override
  void dispose() {
    for (final c in _markCtrl.values) c.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
    try {
      final ctx = await ApiService().getProfileContext();
      _teacherProfileId = ctx.profiles.teacher.id;
      final results = await Future.wait([
        ApiService().getExams(),
        _teacherProfileId != null
          ? ApiService().getTeacherAssignments(teacherId: _teacherProfileId, status: 'current')
          : Future.value(PaginatedResult<TeacherAssignment>(count: 0, results: [])),
      ]);
      if (!mounted) return;
      final exams = (results[0] as PaginatedResult<Exam>).results;
      final assignments = (results[1] as PaginatedResult<TeacherAssignment>).results;
      setState(() {
        _exams = exams;
        _assignments = assignments;
        if (exams.isNotEmpty) _selectedExamId = exams.first.id;
        if (assignments.isNotEmpty) {
          _selectedSectionId = assignments.first.sectionId;
          _selectedSubjectId = assignments.first.subjectId;
          _selectedAssignmentLabel = '${assignments.first.classLevelName ?? ""} ${assignments.first.sectionName ?? ""} · ${assignments.first.subjectName ?? ""}';
        }
        _loading = false;
      });
      if (assignments.isNotEmpty) await _loadEnrollments(assignments.first.sectionId);
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _loadEnrollments(String sectionId) async {
    try {
      final res = await ApiService().getEnrollments(status: 'current');
      final sectionEnrollments = res.results.where((e) => e.sectionId == sectionId).toList();
      for (final c in _markCtrl.values) c.dispose();
      _markCtrl.clear();
      for (final e in sectionEnrollments) {
        _markCtrl[e.studentId] = TextEditingController();
      }
      if (mounted) setState(() => _enrollments = sectionEnrollments);
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_selectedExamId == null || _selectedSubjectId == null || _selectedSectionId == null) {
      showToast(context, 'Please select an exam and a class/subject first.', color: AppColors.amber, icon: Icons.warning_rounded);
      return;
    }
    setState(() => _saving = true);
    try {
      final records = _enrollments.where((e) => _markCtrl[e.studentId]?.text.trim().isNotEmpty == true).map((e) {
        final marks = double.tryParse(_markCtrl[e.studentId]!.text.trim()) ?? 0;
        return {'student_id': e.studentId, 'marks_obtained': marks, 'max_marks': 100.0};
      }).toList();

      if (records.isEmpty) {
        showToast(context, 'Enter marks for at least one student.', color: AppColors.amber, icon: Icons.warning_rounded);
        setState(() => _saving = false);
        return;
      }

      final detail = await ApiService().bulkSubmitGrades(
        examId:    _selectedExamId!,
        subjectId: _selectedSubjectId!,
        sectionId: _selectedSectionId!,
        records:   records,
      );

      AppStore.instance.prependActivity('Grades Submitted', '$_selectedAssignmentLabel');
      if (mounted) {
        showToast(context, detail);
        setState(() => _saving = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showToast(context, e.toString(), color: AppColors.red, icon: Icons.error_outline_rounded);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Column(children: [
      pageTitle('Record Grades'),
      const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
    ]);

    // Fallback if no API
    if (!TokenStore.hasTokens) return _buildFallback(context);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Record Grades', subtitle: _selectedAssignmentLabel ?? 'Select a class'),
      if (_error != null) _apiWarning(_error!),

      // Exam selector
      if (_exams.isNotEmpty) ...[
        secLabel('Select Exam'),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(rMd)),
            child: DropdownButtonHideUnderline(child: DropdownButton<String>(
              value: _selectedExamId,
              isExpanded: true,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text1),
              items: _exams.map((e) => DropdownMenuItem(value: e.id, child: Text('${e.name} · ${e.startDate}'))).toList(),
              onChanged: (v) => setState(() => _selectedExamId = v),
            )),
          ),
        ),
      ],

      // Assignment (class+subject) selector
      if (_assignments.isNotEmpty) ...[
        secLabel('Select Class & Subject'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: Row(children: _assignments.asMap().entries.map((entry) {
            final a = entry.value;
            final label = '${a.classLevelName ?? ""} ${a.sectionName ?? ""}\n${a.subjectName ?? ""}';
            return GestureDetector(
              onTap: () async {
                setState(() {
                  _assignIdx = entry.key;
                  _selectedSectionId = a.sectionId;
                  _selectedSubjectId = a.subjectId;
                  _selectedAssignmentLabel = '${a.classLevelName ?? ""} ${a.sectionName ?? ""} · ${a.subjectName ?? ""}';
                });
                await _loadEnrollments(a.sectionId);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: _assignIdx == entry.key ? AppColors.navy : AppColors.surface,
                  border: Border.all(color: _assignIdx == entry.key ? AppColors.navy : AppColors.border, width: 1.5),
                  borderRadius: BorderRadius.circular(rMd),
                ),
                child: Text(label, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: _assignIdx == entry.key ? Colors.white : AppColors.text3)),
              ),
            );
          }).toList()),
        ),
      ],

      // Grade entry table
      appCard(Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(children: [
            Expanded(child: Text('Student', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.text4))),
            SizedBox(width: 90, child: Text('Marks / 100', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.text4), textAlign: TextAlign.center)),
            SizedBox(width: 44, child: Text('Grade', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.text4), textAlign: TextAlign.center)),
          ]),
        ),
        if (_enrollments.isEmpty)
          Padding(padding: const EdgeInsets.all(20), child: Center(child: Text(_assignments.isEmpty ? 'No class assignments found. Ask admin to assign you to a class.' : 'No students enrolled in this section.', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3)))),
        ..._enrollments.map((enr) {
          final ctrl = _markCtrl[enr.studentId]!;
          final marksStr = ctrl.text.trim();
          final marks = double.tryParse(marksStr);
          final pct = marks != null ? (marks / 100 * 100).clamp(0, 100) : 0.0;
          String gradeLetter = '—';
          Color gradeColor = AppColors.text3;
          Color gradeBg    = const Color(0xFFF1F5F9);
          if (marks != null) {
            if (pct >= 95) { gradeLetter = 'A+'; gradeColor = AppColors.green; gradeBg = AppColors.greenLight; }
            else if (pct >= 85) { gradeLetter = 'A';  gradeColor = AppColors.green; gradeBg = AppColors.greenLight; }
            else if (pct >= 75) { gradeLetter = 'B+'; gradeColor = AppColors.blue;  gradeBg = AppColors.blueLight; }
            else if (pct >= 65) { gradeLetter = 'B';  gradeColor = AppColors.blue;  gradeBg = AppColors.blueLight; }
            else if (pct >= 50) { gradeLetter = 'C';  gradeColor = AppColors.amber; gradeBg = AppColors.amberLight; }
            else if (pct >= 35) { gradeLetter = 'D';  gradeColor = AppColors.amber; gradeBg = AppColors.amberLight; }
            else                 { gradeLetter = 'F';  gradeColor = AppColors.red;   gradeBg = AppColors.redLight; }
          }
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(enr.studentName, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text1)),
                Text('Roll: ${enr.rollNumber ?? "—"}', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text3)),
              ])),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: ctrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1),
                  decoration: InputDecoration(
                    hintText: '0–100',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text4),
                    filled: true, fillColor: AppColors.bg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(rSm), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rSm), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rSm), borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(width: 36, child: Center(child: appBadge(gradeLetter, bg: gradeBg, color: gradeColor))),
            ]),
          );
        }),
      ])),

      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        child: GestureDetector(
          onTap: _saving ? null : _submit,
          child: Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.gradA, AppColors.gradC], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(rMd), boxShadow: shadowMd),
            child: Center(child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Submit Grades to Server', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
          ),
        ),
      ),
      const SizedBox(height: 16),
    ]);
  }

  Widget _buildFallback(BuildContext context) {
    final classes = [
      ('Science 10-A','Mid-Term',[('A. Okonkwo','94','A+',AppColors.greenLight,AppColors.green),('B. Carter','67','B',AppColors.blueLight,AppColors.blue),('C. Singh','88','A',AppColors.greenLight,AppColors.green),]),
      ('Physics 11-B','Unit 3',[('G. Patel','88','A',AppColors.greenLight,AppColors.green),('H. Kim','72','B',AppColors.blueLight,AppColors.blue),]),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Record Grades', subtitle: 'Demo Mode · Sign in for live grading'),
      appCard(Padding(padding: const EdgeInsets.all(16), child: Text('Sign in with real credentials to submit grades directly to the backend via the secure bulk-submit API.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3, height: 1.5)))),
      const SizedBox(height: 16),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ASSIGNMENTS — from AppStore (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class _Assignments extends StatelessWidget {
  const _Assignments();
  Color _col(String k) {
    switch (k) { case 'teal': return AppColors.teal; case 'navy': return AppColors.navy; case 'amber': return AppColors.amber; case 'green': return AppColors.green; case 'red': return AppColors.red; default: return AppColors.blue; }
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Assignment>>(
      valueListenable: AppStore.instance.assignments,
      builder: (ctx, asgns, _) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        pageTitle('Assignments'),
        Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: Row(children: [
          Expanded(child: Text('${asgns.length} assignment${asgns.length == 1 ? "" : "s"}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3))),
          appBadge('${asgns.fold(0, (s, a) => s + a.submitted)}/${asgns.fold(0, (s, a) => s + a.total)} submitted', bg: AppColors.blueLight, color: AppColors.blue),
        ])),
        const ChipRow(chips: ['All', 'Active', 'Submitted', 'Graded']),
        appCard(Column(children: asgns.map((a) {
          final color = _col(a.color);
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 3, height: 64, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(rFull))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(a.sub, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: color)),
                  const SizedBox(width: 8),
                  appBadge(a.className, bg: AppColors.bg, color: AppColors.text3),
                ]),
                const SizedBox(height: 3),
                Text(a.title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.calendar_today_rounded, size: 10, color: AppColors.text4),
                  const SizedBox(width: 4),
                  Text('Due ${a.due}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
                  const SizedBox(width: 12),
                  Text('${a.submitted}/${a.total} submitted',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: a.submitted == a.total ? AppColors.green : AppColors.text3, fontWeight: a.submitted == a.total ? FontWeight.w600 : FontWeight.normal)),
                ]),
              ])),
              GestureDetector(
                onTap: () => showToast(ctx, 'Opening ${a.sub} submissions…'),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(rSm)), child: Text('View', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.blue))),
              ),
            ]),
          );
        }).toList())),
        Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Create Assignment', onTap: () => showCreateAssignment(ctx))),
        const SizedBox(height: 16),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXAMS — live API
// ─────────────────────────────────────────────────────────────────────────────

class _Exams extends StatefulWidget {
  const _Exams();
  @override State<_Exams> createState() => _ExamsState();
}

class _ExamsState extends State<_Exams> {
  List<Exam> _apiExams = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
      final res = await ApiService().getExams();
      if (mounted) setState(() { _apiExams = res.results; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _togglePublish(Exam e) async {
    try {
      await ApiService().patchExam(e.id, {'is_published': !e.isPublished});
      showToast(context, e.isPublished ? 'Results hidden from students' : 'Results published to students');
      _load();
    } catch (err) {
      showToast(context, err.toString(), color: AppColors.red, icon: Icons.error_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allExams = _apiExams;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Exams', subtitle: 'Manage examinations'),
      const ChipRow(chips: ['All', 'Upcoming', 'Published']),
      if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
      if (_error != null) _apiWarning(_error!),
      appCard(Column(children: [
        if (allExams.isEmpty && !_loading)
          Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No exams scheduled. Create one below.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)))),
        ...allExams.map((e) {
          final upcoming = DateTime.tryParse(e.startDate)?.isAfter(DateTime.now()) ?? false;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: upcoming ? AppColors.amberLight : AppColors.greenLight, borderRadius: BorderRadius.circular(rMd)),
                child: Center(child: Icon(Icons.edit_rounded, size: 18, color: upcoming ? AppColors.amber : AppColors.green))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.name, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
                Text('${e.startDate} → ${e.endDate}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
                Text(e.academicYearName ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4)),
              ])),
              GestureDetector(
                onTap: () => _togglePublish(e),
                child: appBadge(e.isPublished ? 'Published' : 'Hidden',
                    bg: e.isPublished ? AppColors.greenLight : const Color(0xFFF1F5F9),
                    color: e.isPublished ? AppColors.green : AppColors.text3),
              ),
            ]),
          );
        }),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 4), child: Text('Tap badge to toggle publish status', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4))),
      Padding(padding: const EdgeInsets.fromLTRB(14, 4, 14, 8), child: navyBtn('+ Schedule Exam', onTap: () => showScheduleExam(context, onDone: _load))),
      const SizedBox(height: 16),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TIMETABLE — static
// ─────────────────────────────────────────────────────────────────────────────

class _Timetable extends StatelessWidget {
  const _Timetable();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('My Timetable'),
    const ChipRow(chips: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
    appCard(ttRows([
      TtItem(time: '08:00–09:30', subject: 'Physics 11-B', room: 'Lab 2',    status: 'Done',     barColor: AppColors.teal, badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
      TtItem(time: '10:15–11:45', subject: 'Science 10-A', room: 'Room 204', status: 'Active',   barColor: AppColors.blue, badgeBg: AppColors.blueLight,  badgeColor: AppColors.blue),
      TtItem(time: '13:00–14:30', subject: 'Chemistry 12', room: 'Lab 3',    status: 'Upcoming', barColor: AppColors.navy, badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3),
      TtItem(time: '15:00–15:45', subject: 'Staff Meeting', room: 'Conference', status: 'Upcoming', barColor: AppColors.amber, badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3),
    ])),
    secLabel('Class Attendance Summary'),
    appCard(Padding(padding: const EdgeInsets.all(14), child: Column(children: [
      ProgressBar(label: 'Science 10-A  (Term 2)', value: 94, gradient: greenGrad()),
      ProgressBar(label: 'Physics 11-B  (Term 2)', value: 88, gradient: blueGrad()),
      ProgressBar(label: 'Chemistry 12  (Term 2)', value: 97, gradient: tealGrad()),
    ]))),
    const SizedBox(height: 16),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// ANALYTICS — static
// ─────────────────────────────────────────────────────────────────────────────

class _Analytics extends StatelessWidget {
  const _Analytics();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Student Analytics', subtitle: 'All classes · Current Term'),
    ValueListenableBuilder<int>(
      valueListenable: AppStore.instance.globalAttendanceInt,
      builder: (ctx, attVal, _) => statGrid([
        StatItem(icon: Icons.bar_chart_rounded,    iconBg: AppColors.blueLight,  iconColor: AppColors.blue,  val: '78%', label: 'Combined Avg', delta: 3),
        StatItem(icon: Icons.emoji_events_rounded, iconBg: AppColors.amberLight, iconColor: AppColors.amber, val: '6',   label: 'Top Scorers',  delta: 0),
        StatItem(icon: Icons.warning_amber_rounded,iconBg: AppColors.redLight,   iconColor: AppColors.red,   val: '4',   label: 'At Risk',       delta: -2),
        StatItem(icon: Icons.fact_check_rounded,   iconBg: AppColors.greenLight, iconColor: AppColors.green, val: '$attVal%', label: 'Avg Attendance',delta: 1),
      ]),
    ),
    secLabel('Subject Averages · Mid-Term'),
    appCard(Padding(padding: const EdgeInsets.all(14), child: Column(children: [
      ProgressBar(label: 'Physics 11-B', value: 82, gradient: tealGrad()),
      ProgressBar(label: 'Science 10-A', value: 75, gradient: blueGrad()),
      ProgressBar(label: 'Chemistry 12', value: 68, gradient: amberGrad()),
    ]))),
    secLabel('AI Insights'),
    appCard(Padding(padding: const EdgeInsets.all(14), child: Column(children: [
      _insight(AppColors.blue,  Icons.trending_up_rounded,   'Grade Trend',       'Class average increased 5% over the past 3 weeks.'),
      const SizedBox(height: 14),
      _insight(AppColors.amber, Icons.warning_amber_rounded,  'At-Risk Students',  '4 students below 50%. Early intervention recommended.'),
      const SizedBox(height: 14),
      _insight(AppColors.green, Icons.task_alt_rounded,       'Attendance Impact', 'Students >90% attendance score 18% higher on average.'),
    ]))),
    const SizedBox(height: 16),
  ]);

  Widget _insight(Color color, IconData icon, String title, String body) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(width: 3, height: 52, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(rFull))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 13, color: color), const SizedBox(width: 5), Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1))]),
        const SizedBox(height: 3),
        Text(body, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3, height: 1.5)),
      ])),
    ],
  );
}
