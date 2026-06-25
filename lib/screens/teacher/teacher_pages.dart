import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../theme.dart';
import '../../utils/constants.dart';
import '../../utils/pdf_generator.dart';
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
      case 'classes':     return const _Classes();
      case 'attendance':  return const _Attendance();
      case 'grades':      return const _Grades();
      case 'aitools':     return const _AITools();
      case 'assignments': return const _Assignments();
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
  double _avgAttendance = 0.0;
  double _avgPerformance = 0.0;
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    if (TokenStore.hasTokens && !AppStore.instance.isDevMode) {
      _loadData();
    } else {
      _statsLoading = false;
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
        await _loadStats();
      }
    } catch (_) {
      try {
        final p = await ApiService().getMyProfile();
        if (mounted) setState(() => _profile = p);
      } catch (_) {}
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  Future<void> _loadStats() async {
    if (_myAssignments.isEmpty) {
      if (mounted) setState(() => _statsLoading = false);
      return;
    }
    
    int totalAttendanceRecords = 0;
    int totalPresent = 0;
    double totalObtainedMarks = 0;
    double totalMaxMarks = 0;

    final api = ApiService();

    await Future.wait(_myAssignments.map((cls) async {
      final sectionId = cls.sectionId;
      final academicYearId = cls.academicYearId;
      final subjectId = cls.subjectId;

      if (sectionId == null || academicYearId == null) return;

      try {
        final results = await Future.wait([
          api.getEnrollments(status: 'current'),
          api.getAttendance(sectionId: sectionId),
          subjectId != null ? api.getGrades(subjectId: subjectId) : Future.value(PaginatedResult<StudentGrade>(count: 0, results: [])),
        ]);

        final enrollments = (results[0] as PaginatedResult<Enrollment>).results.where((e) => e.sectionId == sectionId).toList();
        final attendance = (results[1] as PaginatedResult<AttendanceRecord>).results;
        final grades = (results[2] as PaginatedResult<StudentGrade>).results;

        final Map<String, int> attTotal = {};
        final Map<String, int> attPresent = {};
        for (var record in attendance) {
          attTotal[record.studentId] = (attTotal[record.studentId] ?? 0) + 1;
          if (record.status == 'Present' || record.status == 'Late') {
            attPresent[record.studentId] = (attPresent[record.studentId] ?? 0) + 1;
          }
        }

        final Map<String, StudentGrade> maxGrades = {};
        for (var grade in grades) {
          final sId = grade.studentId;
          final currentMax = maxGrades[sId]?.marksObtained ?? 0;
          if (grade.marksObtained > currentMax || !maxGrades.containsKey(sId)) {
            maxGrades[sId] = grade;
          }
        }

        for (var student in enrollments) {
          final sId = student.studentId;
          if (attTotal.containsKey(sId)) {
            totalAttendanceRecords += attTotal[sId]!;
            totalPresent += attPresent[sId] ?? 0;
          }
          if (maxGrades.containsKey(sId)) {
            totalObtainedMarks += maxGrades[sId]!.marksObtained;
            totalMaxMarks += maxGrades[sId]!.maxMarks;
          }
        }
      } catch (e) {
        // Ignore individual class fetch errors
      }
    }));

    if (mounted) {
      setState(() {
        _avgAttendance = totalAttendanceRecords > 0 ? (totalPresent / totalAttendanceRecords * 100) : 0.0;
        _avgPerformance = totalMaxMarks > 0 ? (totalObtainedMarks / totalMaxMarks * 100) : 0.0;
        _statsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg    = kRoles[UserRole.teacher]!;
    final store  = AppStore.instance;
    final name   = store.currentUserName.isNotEmpty ? store.currentUserName : (_profile?.displayName ?? cfg.name);
    final school = store.currentSchool.isNotEmpty ? store.currentSchool : (_profile?.schoolName ?? 'Westfield Academy');

    final attStr = _statsLoading ? '--' : _avgAttendance.toStringAsFixed(1);
    final perfStr = _statsLoading ? '--' : _avgPerformance.toStringAsFixed(1);

    // Get real assignments count if possible, but since it's 404ing, we'll just show 0 or mock it.
    // To match the Tasks tab accurately, we should just show 0 for now.
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      heroPortrait(cfg.avatarAsset, school),
      profileInfo(name, 'Faculty', cfg.idLabel),
      pageTitle('Dashboard', subtitle: 'AI-Powered Portal'),
      quickStatsBar([
        QsItem(val: '${_myAssignments.length}', label: 'My Classes'),
        QsItem(val: '$attStr%', label: 'Attendance'),
        QsItem(val: '$perfStr%', label: 'Performance'),
        QsItem(val: '0', label: 'Assignments'),
      ]),

      if (_myAssignments.isNotEmpty) ...[
        secLabel("My Classes"),
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

class _Assignments extends StatefulWidget {
  const _Assignments();

  @override
  State<_Assignments> createState() => _AssignmentsState();
}

class _AssignmentsState extends State<_Assignments> {
  List<SchoolAssignment> _assignments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!TokenStore.hasTokens) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final res = await ApiService().getAssignments();
      if (mounted) setState(() {
        _assignments = res.results;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Color _col(String k) {
    final lower = k.toLowerCase();
    if (lower.contains('math')) return AppColors.blue;
    if (lower.contains('phys') || lower.contains('sci')) return AppColors.teal;
    if (lower.contains('hist')) return AppColors.green;
    if (lower.contains('eng')) return AppColors.amber;
    return AppColors.blue;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        pageTitle('Assignments'),
        const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Assignments'),
      if (_error != null)
        Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.redLight, borderRadius: BorderRadius.circular(rMd), border: Border.all(color: AppColors.red)),
          child: Text('Error: $_error\nShowing demo fallback data.', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.red)),
        ),
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: Row(children: [
        Expanded(child: Text('${_assignments.length} assignment${_assignments.length == 1 ? "" : "s"}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3))),
      ])),
      const ChipRow(chips: ['All', 'Active', 'Submitted', 'Graded']),
      if (_assignments.isEmpty && _error == null)
        appCard(const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No assignments found.'))))
      else
        appCard(Column(children: _assignments.map((a) {
          final color = _col(a.subjectName ?? 'blue');
          // Mock submission count for UI demo based on string length
          final total = 30;
          final submitted = (a.title.length * 3) % total;
          
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 3, height: 64, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(rFull))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text((a.subjectName ?? 'Subject').toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: color)),
                  const SizedBox(width: 8),
                  appBadge(a.sectionName ?? 'Class', bg: AppColors.bg, color: AppColors.text3),
                ]),
                const SizedBox(height: 3),
                Text(a.title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.calendar_today_rounded, size: 10, color: AppColors.text4),
                  const SizedBox(width: 4),
                  Text('Due ${a.dueDate ?? "TBD"}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
                  const SizedBox(width: 12),
                  Text('$submitted/$total submitted',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: submitted == total ? AppColors.green : AppColors.text3, fontWeight: submitted == total ? FontWeight.w600 : FontWeight.normal)),
                ]),
              ])),
              GestureDetector(
                onTap: () => showToast(context, 'Opening ${a.title} submissions…'),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(rSm)), child: Text('View', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.blue))),
              ),
            ]),
          );
        }).toList())),
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Create Assignment', onTap: () => showCreateAssignment(context, onDone: _loadData))),
      const SizedBox(height: 16),
    ]);
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

// ─────────────────────────────────────────────────────────────────────────────
// MY CLASSES
// ─────────────────────────────────────────────────────────────────────────────

class _Classes extends StatefulWidget {
  const _Classes();
  @override State<_Classes> createState() => _ClassesState();
}

class _ClassesState extends State<_Classes> {
  List<TeacherAssignment> _assignments = [];
  Map<String, double> _performanceMap = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!TokenStore.hasTokens) {
      setState(() => _loading = false);
      return;
    }
    try {
      final ctx = await ApiService().getProfileContext();
      if (ctx.profiles.teacher.id != null) {
        final res = await ApiService().getTeacherAssignments(teacherId: ctx.profiles.teacher.id, status: 'current');
        final classes = res.results;
        
        final perfMap = <String, double>{};
        final api = ApiService();
        
        // Calculate performance for each class
        await Future.wait(classes.map((cls) async {
          final sectionId = cls.sectionId;
          final subjectId = cls.subjectId;
          if (sectionId == null || subjectId == null) return;
          try {
            final gradesRes = await api.getGrades(subjectId: subjectId);
            final enrollRes = await api.getEnrollments(status: 'current');
            final enrollments = enrollRes.results.where((e) => e.sectionId == sectionId).toList();
            
            final enrolledStudentIds = enrollments.map((e) => e.studentId).toSet();
            final relevantGrades = gradesRes.results.where((g) => enrolledStudentIds.contains(g.studentId)).toList();
            
            if (relevantGrades.isNotEmpty) {
              final Map<String, StudentGrade> maxGrades = {};
              for (var grade in relevantGrades) {
                final sId = grade.studentId;
                final currentMax = maxGrades[sId]?.marksObtained ?? 0;
                if (grade.marksObtained > currentMax || !maxGrades.containsKey(sId)) {
                  maxGrades[sId] = grade;
                }
              }
              double totalObt = 0;
              double totalMax = 0;
              for (var grade in maxGrades.values) {
                totalObt += grade.marksObtained;
                totalMax += grade.maxMarks;
              }
              if (totalMax > 0) {
                perfMap[cls.id] = (totalObt / totalMax) * 100;
              }
            }
          } catch (_) {}
        }));

        if (mounted) {
          setState(() {
            _assignments = classes;
            _performanceMap = perfMap;
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Column(children: [
        pageTitle('My Classes'),
        const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
      ]);
    }
    
    if (!TokenStore.hasTokens) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        pageTitle('My Classes', subtitle: 'Sign in to see live classes'),
        appCard(Padding(padding: const EdgeInsets.all(16), child: Text('Sign in with real credentials to view assigned classes.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3, height: 1.5)))),
        const SizedBox(height: 16),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('My Classes', subtitle: '${_assignments.length} Active Classes'),
      if (_assignments.isEmpty)
        Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No classes assigned.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)))),
      ..._assignments.map((a) {
        final perfStr = _performanceMap.containsKey(a.id) ? '${_performanceMap[a.id]!.toStringAsFixed(1)}%' : 'N/A';
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: appCard(Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(rSm)),
                  child: Text('Active', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 1.0)),
                ),
                if (a.isClassTeacher) appBadge('Class Teacher', bg: AppColors.amberLight, color: AppColors.amber),
              ]),
              const SizedBox(height: 12),
              Text('${a.subjectName ?? "Subject"} ${a.classLevelName?.replaceAll("Grade ", "") ?? ""}-${a.sectionName ?? ""}', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text1)),
              const SizedBox(height: 4),
              Text('${a.academicYearName ?? ""}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.text3)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(rSm)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('STATUS', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.text4)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.groups_rounded, size: 14, color: AppColors.blue),
                      const SizedBox(width: 6),
                      Text('Enrolled', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text1)),
                    ]),
                  ]),
                )),
                const SizedBox(width: 12),
                Expanded(child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(rSm)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('AVG. PERFORMANCE', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.text4)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.horizontal_rule_rounded, size: 14, color: Colors.black),
                      const SizedBox(width: 6),
                      Text(perfStr, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black)),
                    ]),
                  ]),
                )),
              ]),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.class_rounded, color: AppColors.blue),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${a.subjectName ?? "Subject"} Details', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text1)),
                                    Text('${a.classLevelName?.replaceAll("Grade ", "") ?? ""}-${a.sectionName ?? ""}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.text3)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: AppColors.text3),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(children: [
                            Expanded(child: appCard(Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(children: [
                                const Icon(Icons.menu_book_rounded, color: AppColors.blue, size: 28),
                                const SizedBox(height: 12),
                                Text('Course Syllabus', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1)),
                                const SizedBox(height: 4),
                                Text('Not uploaded yet', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
                              ]),
                            ))),
                            const SizedBox(width: 12),
                            Expanded(child: appCard(Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(children: [
                                const Icon(Icons.folder_shared_rounded, color: AppColors.amber, size: 28),
                                const SizedBox(height: 12),
                                Text('Learning Materials', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1)),
                                const SizedBox(height: 4),
                                Text('Empty folder', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
                              ]),
                            ))),
                          ]),
                          const SizedBox(height: 24),
                          dangerBtn('Close Details', onTap: () => Navigator.pop(context)),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(rSm)),
                  child: Center(child: Text('View Class Details →', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.blue))),
                ),
              ),
            ]),
          )),
        );
      }),
      const SizedBox(height: 16),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI TOOLS
// ─────────────────────────────────────────────────────────────────────────────

class _AITools extends StatefulWidget {
  const _AITools();
  @override State<_AITools> createState() => _AIToolsState();
}

class _AIToolsState extends State<_AITools> {
  final TextEditingController _topicCtrl = TextEditingController();
  
  String _selectedSubject = 'Mathematics';
  String _selectedClass = '10';
  String _selectedChapter = '10 - CIRCLES';
  
  void _onClassChanged(String? newClass) {
    if (newClass == null) return;
    setState(() {
      _selectedClass = newClass;
      final chapters = AppConstants.mathematicsChapters[newClass] ?? [];
      _selectedChapter = chapters.isNotEmpty ? chapters.first : '';
    });
  }
  
  bool _loading = false;
  dynamic _result;
  String? _error;
  String _activeTool = 'Lesson Plan';

  final List<String> _tools = [
    'Lesson Plan', 'Worksheet', 'Quiz', 'Study Notes', 'Rubric',
    'Question Paper', 'Presentation Outline',
  ];

  Future<void> _generate() async {
    // Topic is optional — fall back to the selected chapter if blank
    final topic = _topicCtrl.text.trim();
    final effectiveTopic = topic.isNotEmpty ? topic : _selectedChapter;

    setState(() { _loading = true; _result = null; _error = null; });
    try {
      final payload = {
        'subject': _selectedSubject,
        'grade': _selectedClass,
        'chapter': _selectedChapter,
        'topic': effectiveTopic,
      };
      
      dynamic res;
      if (_activeTool == 'Lesson Plan')           res = await ApiService().generateLessonPlan(payload);
      else if (_activeTool == 'Worksheet')         res = await ApiService().generateWorksheet(payload);
      else if (_activeTool == 'Quiz')              res = await ApiService().generateQuiz(payload);
      else if (_activeTool == 'Study Notes')       res = await ApiService().generateStudyNotes(payload);
      else if (_activeTool == 'Rubric')            res = await ApiService().generateRubric(payload);
      else if (_activeTool == 'Question Paper')    res = await ApiService().generateQuestionPaper(payload);
      else if (_activeTool == 'Presentation Outline') res = await ApiService().generatePresentationOutline(payload);
      
      if (mounted) {
        setState(() {
          _loading = false;
          _result = res;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('AI Tools Workspace', subtitle: 'Generate content instantly'),
      
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
        child: Row(children: _tools.map((t) => GestureDetector(
          onTap: () => setState(() { _activeTool = t; _result = null; _error = null; }),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _activeTool == t ? const Color(0xFF6B38D4) : AppColors.surface,
              border: Border.all(color: _activeTool == t ? const Color(0xFF6B38D4) : AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(rFull),
            ),
            child: Row(children: [
              Icon(Icons.auto_awesome_rounded, size: 12, color: _activeTool == t ? Colors.white : AppColors.text4),
              const SizedBox(width: 6),
              Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: _activeTool == t ? Colors.white : AppColors.text3)),
            ]),
          ),
        )).toList()),
      ),
      
      appCard(Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Subject', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text2)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedSubject,
                items: ['Mathematics'].map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) => setState(() => _selectedSubject = v!),
                decoration: InputDecoration(
                  filled: true, fillColor: AppColors.bg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(rSm), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rSm), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rSm), borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
                ),
              ),
            ])),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Class', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text2)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedClass,
                items: ['9', '10'].map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: _onClassChanged,
                decoration: InputDecoration(
                  filled: true, fillColor: AppColors.bg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(rSm), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rSm), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rSm), borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
                ),
              ),
            ])),
          ]),
          const SizedBox(height: 16),
          Text('Chapter Name', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text2)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _selectedChapter,
            items: (AppConstants.mathematicsChapters[_selectedClass] ?? []).map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (v) => setState(() => _selectedChapter = v!),
            decoration: InputDecoration(
              filled: true, fillColor: AppColors.bg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(rSm), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rSm), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rSm), borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Specific Topic (Optional)', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text2)),
          const SizedBox(height: 6),
          TextField(
            controller: _topicCtrl,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text1),
            decoration: InputDecoration(
              hintText: 'e.g. Tangent properties',
              filled: true, fillColor: AppColors.bg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(rSm), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rSm), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rSm), borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _loading ? null : _generate,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: _loading ? const Color(0xFF6B38D4).withOpacity(0.5) : const Color(0xFF6B38D4), borderRadius: BorderRadius.circular(rMd), boxShadow: shadowSm),
              child: Center(child: _loading
                ? Row(mainAxisSize: MainAxisSize.min, children: [
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                    const SizedBox(width: 10),
                    Text('Generating...', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ])
                : Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.psychology_rounded, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('Generate $_activeTool', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ])),
            ),
          ),
        ]),
      )),
      
      if (_error != null)
        Padding(padding: const EdgeInsets.fromLTRB(14, 16, 14, 0), child: _apiWarning(_error!)),
        
      if (_loading)
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
          child: Shimmer.fromColors(
            baseColor: AppColors.surface,
            highlightColor: Colors.white.withOpacity(0.5),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(rLg)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 200, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 16),
                Container(width: double.infinity, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Container(width: double.infinity, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Container(width: 250, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 24),
                Container(width: 150, height: 18, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 12),
                Container(width: double.infinity, height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
              ]),
            ),
          ),
        ),
        
      if (_result != null && !_loading)
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(rLg), boxShadow: shadowSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(rLg)),
                    border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.psychology_rounded, size: 16, color: Color(0xFF6B38D4)),
                      const SizedBox(width: 8),
                      Text('$_activeTool Result', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF6B38D4))),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(text: _result.toString()));
                          if (mounted) showToast(context, 'Copied to clipboard');
                        },
                        child: const Icon(Icons.copy_rounded, size: 16, color: AppColors.text3),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () async {
                          try {
                            await PdfGenerator.sharePdf(_activeTool, _result);
                          } catch(e) {
                            if (mounted) showToast(context, 'Failed to generate PDF: $e', color: AppColors.red);
                          }
                        },
                        child: const Icon(Icons.download_rounded, size: 16, color: AppColors.text3),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () async {
                          try {
                            await ApiService().saveAIContent(
                              className: _selectedClass,
                              subject: _selectedSubject,
                              contentType: _activeTool,
                              data: _result is Map ? _result : {'content': _result.toString()},
                            );
                            if (mounted) showToast(context, 'Saved to Workspace', color: AppColors.green, icon: Icons.check_circle_rounded);
                          } catch (e) {
                            if (mounted) showToast(context, 'Failed to save: $e', color: AppColors.red);
                          }
                        },
                        child: const Icon(Icons.save_rounded, size: 16, color: AppColors.text3),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildResultView(_result),
                ),
              ],
            ),
          ),
        ),
        
      const SizedBox(height: 32),
    ]);
  }

  Widget _buildResultView(dynamic data) {
    if (data == null) return const SizedBox.shrink();
    if (data is String) {
      return _buildMarkdown(data);
    }
    if (data is Map<String, dynamic>) {
      if (_activeTool == 'Quiz') return _QuizWidget(data: data);
      if (_activeTool == 'Lesson Plan') return _buildLessonPlanView(data);
      if (_activeTool == 'Worksheet') return _WorksheetWidget(data: data);
      if (_activeTool == 'Study Notes') return _buildStudyNotesView(data);
      if (_activeTool == 'Rubric') return _buildRubricView(data);
      if (_activeTool == 'Question Paper') return _buildQuestionPaperView(data);
      if (_activeTool == 'Presentation Outline') return _buildPresentationOutlineView(data);
      
      // Generic Map view
      List<Widget> children = [];
      if (data.containsKey('title') || data.containsKey('lesson_title')) {
        children.add(Text(data['title'] ?? data['lesson_title'], style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF6B38D4))));
        children.add(const SizedBox(height: 16));
      }
      data.forEach((key, value) {
        if (key != 'title' && key != 'subject' && key != 'class_name' && key != 'topic' && key != 'lesson_title') {
          children.add(Text(_capitalize(key), style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text1)));
          children.add(const SizedBox(height: 8));
          if (value is List) {
            for (var item in value) {
              children.add(Padding(padding: const EdgeInsets.only(bottom: 4, left: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B38D4))),
                Expanded(child: Text(item.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2))),
              ])));
            }
          } else {
            children.add(Text(value.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2)));
          }
          children.add(const SizedBox(height: 16));
        }
      });
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
    }
    return Text(data.toString());
  }

  Widget _buildWorksheetView(Map<String, dynamic> data) {
    List<Widget> children = [];
    if (data['title'] != null) {
      children.add(Text(data['title'], style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF6B38D4))));
      children.add(const SizedBox(height: 16));
    }

    if (data['instructions'] != null) {
      children.add(_buildSectionHeader('info', 'Instructions'));
      children.add(Container(
        width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
        child: Text(data['instructions'], style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2)),
      ));
    }

    if (data['questions'] != null && (data['questions'] as List).isNotEmpty) {
      children.add(_buildSectionHeader('task_alt', 'Questions'));
      int i = 1;
      for (var q in data['questions']) {
        children.add(Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border), boxShadow: shadowSm),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF6B38D4).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text('Q$i', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6B38D4))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(q['question'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text1))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              if (q['type'] != null)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.border)),
                  child: Text(q['type'].toString().toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.text3)),
                ),
              if (q['marks'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.orange.withOpacity(0.5))),
                  child: Text('${q['marks']} Marks', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange[800])),
                ),
            ]),
            if (q['options'] != null && (q['options'] as List).isNotEmpty) ...[
              const SizedBox(height: 12),
              ...((q['options'] as List).map((opt) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    const Icon(Icons.radio_button_unchecked, size: 16, color: AppColors.text3),
                    const SizedBox(width: 8),
                    Expanded(child: Text(opt.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2))),
                  ]),
                );
              }).toList())
            ] else ...[
              const SizedBox(height: 12),
              TextField(
                maxLines: (q['type'] != null && (q['type'].toString().toLowerCase().contains('long') || q['type'].toString().toLowerCase().contains('proof') || q['type'].toString().toLowerCase().contains('diagram'))) ? 4 : 1,
                decoration: InputDecoration(
                  hintText: 'Type your answer here...',
                  filled: true, fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
            ]
          ]),
        ));
        i++;
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _buildQuizView(Map<String, dynamic> data) {
    List<Widget> children = [];
    if (data['title'] != null) {
      children.add(Text(data['title'], style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF6B38D4))));
      children.add(const SizedBox(height: 16));
    }

    if (data['questions'] != null && (data['questions'] as List).isNotEmpty) {
      children.add(Text('Questions', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text1)));
      children.add(const SizedBox(height: 12));
      int i = 1;
      for (var q in data['questions']) {
        children.add(Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$i. ${q['question']}', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text1)),
            const SizedBox(height: 12),
            if (q['options'] != null) ...((q['options'] as List).map((opt) {
              bool isCorrect = q['correct_answer'] == opt;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isCorrect ? Colors.green : AppColors.border),
                ),
                child: Row(children: [
                  Expanded(child: Text(opt.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: isCorrect ? Colors.green[800] : AppColors.text2))),
                  if (isCorrect) const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                ]),
              );
            }).toList()),
            if (q['explanation'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF6B38D4).withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Explanation', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF6B38D4))),
                  const SizedBox(height: 4),
                  Text(q['explanation'].toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2)),
                ]),
              )
            ]
          ]),
        ));
        i++;
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _buildLessonPlanView(Map<String, dynamic> data) {
    List<Widget> children = [];
    final title = data['title'] ?? data['lesson_title'] ?? 'Lesson Plan';
    children.add(Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF6B38D4))));
    children.add(const SizedBox(height: 16));

    if (data['curriculum_alignment'] != null) {
      children.add(_buildSectionHeader('bookmark', 'Curriculum Alignment'));
      children.add(Container(
        width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
        child: Text(data['curriculum_alignment'], style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2)),
      ));
    }

    if (data['learning_objectives'] != null) {
      children.add(_buildSectionHeader('task_alt', 'Learning Objectives'));
      for (var obj in data['learning_objectives']) {
        children.add(Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.check_rounded, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(obj['objective'] ?? obj.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2))),
        ])));
      }
      children.add(const SizedBox(height: 16));
    }

    if (data['introduction'] != null) {
      children.add(_buildSectionHeader('waving_hand', 'Introduction'));
      children.add(Container(
        width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: const Color(0xFF6B38D4).withOpacity(0.05), border: const Border(left: BorderSide(color: Color(0xFF6B38D4), width: 4))),
        child: Text(data['introduction'], style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2)),
      ));
    }

    if (data['activities'] != null) {
      children.add(_buildSectionHeader('hourglass_empty', 'Activities'));
      for (var act in data['activities']) {
        children.add(Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF6B38D4), borderRadius: BorderRadius.circular(4)),
              child: Text(act['duration'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(act['activity_title'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text1)),
                const SizedBox(height: 4),
                Text(act['description'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3)),
              ]),
            ))
          ]),
        ));
      }
      children.add(const SizedBox(height: 16));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _buildStudyNotesView(Map<String, dynamic> data) {
    List<Widget> children = [];
    if (data['title'] != null) {
      children.add(Text(data['title'], style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF6B38D4))));
      children.add(const SizedBox(height: 16));
    }

    if (data['summary'] != null) {
      children.add(_buildSectionHeader('info', 'Summary'));
      children.add(Text(data['summary'].toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2)));
      children.add(const SizedBox(height: 16));
    }

    if (data['key_concepts'] != null && (data['key_concepts'] as List).isNotEmpty) {
      children.add(_buildSectionHeader('bookmark', 'Key Concepts'));
      for (var c in data['key_concepts']) {
        children.add(Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.circle, size: 6, color: Color(0xFF6B38D4)),
          const SizedBox(width: 8),
          Expanded(child: Text(c.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2))),
        ])));
      }
      children.add(const SizedBox(height: 16));
    }

    if (data['detailed_notes'] != null && (data['detailed_notes'] as List).isNotEmpty) {
      children.add(_buildSectionHeader('waving_hand', 'Detailed Notes'));
      for (var n in data['detailed_notes']) {
        children.add(Container(
          width: double.infinity, margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border), boxShadow: shadowSm),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (n['heading'] != null) ...[
              Text(n['heading'].toString(), style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.text1)),
              const SizedBox(height: 8),
            ],
            if (n['content'] != null)
              Text(n['content'].toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2, height: 1.5)),
          ]),
        ));
      }
    }

    if (data['important_formulas'] != null && (data['important_formulas'] as List).isNotEmpty) {
      children.add(_buildSectionHeader('task_alt', 'Important Formulas'));
      for (var f in data['important_formulas']) {
        children.add(Container(
          margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF6B38D4).withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF6B38D4).withOpacity(0.2))),
          child: Row(children: [
            const Icon(Icons.functions_rounded, color: Color(0xFF6B38D4), size: 18),
            const SizedBox(width: 12),
            Expanded(child: Text(f.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1))),
          ]),
        ));
      }
      children.add(const SizedBox(height: 16));
    }

    if (data['tips'] != null) {
      children.add(_buildSectionHeader('info', 'Tips'));
      children.add(Container(
        width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.withOpacity(0.3))),
        child: Text(data['tips'].toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.orange[800])),
      ));
    }

    if (data['practice_problems'] != null && (data['practice_problems'] as List).isNotEmpty) {
      children.add(_buildSectionHeader('hourglass_empty', 'Practice Problems'));
      int i = 1;
      for (var p in data['practice_problems']) {
        if (p is Map) {
          children.add(Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$i.', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text1)),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p['problem']?.toString() ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
              const SizedBox(height: 4),
              Text('Solution: ${p['solution']?.toString() ?? ''}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text2)),
            ])),
          ])));
        } else {
          children.add(Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$i.', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text1)),
            const SizedBox(width: 8),
            Expanded(child: Text(p.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2))),
          ])));
        }
        i++;
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _buildRubricView(Map<String, dynamic> data) {
    List<Widget> children = [];
    if (data['title'] != null) {
      children.add(Text(data['title'], style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF6B38D4))));
      children.add(const SizedBox(height: 16));
    }

    if (data['criteria'] != null && (data['criteria'] as List).isNotEmpty) {
      for (var crit in data['criteria']) {
        children.add(Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border), boxShadow: shadowSm),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(12)), border: Border(bottom: BorderSide(color: AppColors.border))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(crit['criterion']?.toString() ?? 'Criterion', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text1))),
                if (crit['weight'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF6B38D4), borderRadius: BorderRadius.circular(4)),
                    child: Text('${crit['weight']}%', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
              ]),
            ),
            _buildRubricLevel('Excellent', crit['excellent'], Colors.green),
            _buildRubricLevel('Good', crit['good'], Colors.blue),
            _buildRubricLevel('Satisfactory', crit['satisfactory'], Colors.orange),
            _buildRubricLevel('Needs Impr.', crit['needs_improvement'], Colors.red),
          ]),
        ));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _buildRubricLevel(String level, dynamic desc, Color color) {
    if (desc == null || desc.toString().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 80, child: Text(level, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: color))),
        Expanded(child: Text(desc.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text2))),
      ]),
    );
  }

  Widget _buildQuestionPaperView(Map<String, dynamic> data) {
    List<Widget> children = [];
    if (data['title'] != null) {
      children.add(Text(data['title'], style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF6B38D4))));
      children.add(const SizedBox(height: 8));
    }
    
    children.add(Row(children: [
      if (data['total_marks'] != null)
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(4)), child: Text('Total Marks: ${data['total_marks']}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600))),
      const SizedBox(width: 8),
      if (data['duration'] != null)
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(4)), child: Text('Duration: ${data['duration']}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600))),
    ]));
    children.add(const SizedBox(height: 16));

    if (data['instructions'] != null && (data['instructions'] as List).isNotEmpty) {
      children.add(_buildSectionHeader('info', 'Instructions'));
      for (var inst in data['instructions']) {
        children.add(Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text3)),
          Expanded(child: Text(inst.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text2))),
        ])));
      }
      children.add(const SizedBox(height: 16));
    }

    if (data['sections'] != null && (data['sections'] as List).isNotEmpty) {
      for (var sec in data['sections']) {
        children.add(Container(
          width: double.infinity, margin: const EdgeInsets.only(top: 16, bottom: 12), padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF6B38D4), borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(sec['name']?.toString() ?? 'Section', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white))),
            if (sec['marks'] != null)
              Text('${sec['marks']} Marks', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
          ]),
        ));

        if (sec['questions'] != null && (sec['questions'] as List).isNotEmpty) {
          int i = 1;
          for (var q in sec['questions']) {
            children.add(Container(
              margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Q$i.', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text1)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(q is Map ? (q['question']?.toString() ?? q['text']?.toString() ?? '') : q.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1))),
                  if (q is Map && q['marks'] != null)
                    Padding(padding: const EdgeInsets.only(left: 8), child: Text('[${q['marks']}]', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.text3))),
                ]),
                if (q is Map && q['options'] != null) ...[
                  const SizedBox(height: 8),
                  ...((q['options'] as List).map((opt) => Padding(
                    padding: const EdgeInsets.only(left: 24, bottom: 4),
                    child: Text('• ${opt.toString()}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text2)),
                  )).toList())
                ]
              ]),
            ));
            i++;
          }
        }
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _buildPresentationOutlineView(Map<String, dynamic> data) {
    List<Widget> children = [];
    if (data['title'] != null) {
      children.add(Text(data['title'], style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF6B38D4))));
      children.add(const SizedBox(height: 8));
    }
    if (data['total_slides'] != null) {
      children.add(Text('Total Slides: ${data['total_slides']}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text3)));
      children.add(const SizedBox(height: 16));
    }

    if (data['slides'] != null && (data['slides'] as List).isNotEmpty) {
      for (var slide in data['slides']) {
        children.add(Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border), boxShadow: shadowSm),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(12)), border: Border(bottom: BorderSide(color: AppColors.border))),
              child: Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF6B38D4), borderRadius: BorderRadius.circular(4)), child: Text('Slide ${slide['slide_number'] ?? ''}', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                const SizedBox(width: 12),
                Expanded(child: Text(slide['title']?.toString() ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text1))),
              ]),
            ),
            if (slide['content'] != null && (slide['content'] as List).isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: (slide['content'] as List).map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B38D4))),
                    Expanded(child: Text(c.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text1))),
                  ]),
                )).toList()),
              ),
            if (slide['speaker_notes'] != null)
              Container(
                width: double.infinity, padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Color(0xFFF1F5F9), borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Speaker Notes', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.text3)),
                  const SizedBox(height: 4),
                  Text(slide['speaker_notes'].toString(), style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text2, fontStyle: FontStyle.italic)),
                ]),
              ),
          ]),
        ));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _buildSectionHeader(String iconName, String title) {
    IconData icon = Icons.info;
    if (iconName == 'bookmark') icon = Icons.bookmark_rounded;
    if (iconName == 'task_alt') icon = Icons.task_alt_rounded;
    if (iconName == 'waving_hand') icon = Icons.waving_hand_rounded;
    if (iconName == 'hourglass_empty') icon = Icons.hourglass_empty_rounded;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFF6B38D4).withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Icon(icon, size: 14, color: const Color(0xFF6B38D4))),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF6B38D4))),
      ]),
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).replaceAll('_', ' ');

  Widget _buildMarkdown(String data) {
    return MarkdownBody(
      data: data,
      builders: {
        'latex': LatexElementBuilder(),
      },
      extensionSet: md.ExtensionSet(
        [LatexBlockSyntax()],
        [LatexInlineSyntax()],
      ),
      styleSheet: MarkdownStyleSheet(
        p: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text1, height: 1.6),
        h1: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF6B38D4), height: 1.4),
        h2: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF6B38D4), height: 1.4),
        h3: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text1, height: 1.4),
        strong: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text1),
        listBullet: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF6B38D4), fontWeight: FontWeight.w900),
        blockquoteDecoration: BoxDecoration(
          color: AppColors.bg,
          border: const Border(left: BorderSide(color: Color(0xFF6B38D4), width: 4)),
          borderRadius: BorderRadius.circular(4),
        ),
        blockquotePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        tableCellsPadding: const EdgeInsets.all(8),
        tableBorder: TableBorder.all(color: AppColors.border, width: 1.5),
        tableBody: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text1),
        tableHead: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.text1),
      ),
      selectable: true,
    );
  }
}

class _WorksheetWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  const _WorksheetWidget({Key? key, required this.data}) : super(key: key);
  @override
  State<_WorksheetWidget> createState() => _WorksheetWidgetState();
}

class _WorksheetWidgetState extends State<_WorksheetWidget> {
  final Map<int, String> _answers = {};
  bool _evaluating = false;
  Map<String, dynamic>? _evaluationResult;

  Widget _buildSectionHeader(String iconName, String title) {
    IconData icon = Icons.info;
    if (iconName == 'task_alt') icon = Icons.task_alt_rounded;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFF6B38D4).withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Icon(icon, size: 14, color: const Color(0xFF6B38D4))),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF6B38D4))),
      ]),
    );
  }

  Future<void> _submit() async {
    setState(() { _evaluating = true; });
    try {
      final questions = widget.data['questions'] as List;
      List<Map<String, dynamic>> payloadAnswers = [];
      for (int i = 0; i < questions.length; i++) {
        payloadAnswers.add({
          'question': questions[i]['question'],
          'student_answer': _answers[i] ?? '',
          'type': questions[i]['type'],
          'marks': questions[i]['marks'],
        });
      }
      final payload = {
        'worksheet_data': {
          'title': widget.data['title'],
          'answers': payloadAnswers
        }
      };
      final res = await ApiService().evaluateWorksheet(payload);
      setState(() {
        _evaluationResult = res;
        _evaluating = false;
      });
    } catch (e) {
      setState(() { _evaluating = false; });
      if (mounted) showToast(context, 'Evaluation failed: $e', color: AppColors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    final data = widget.data;
    if (data['title'] != null) {
      children.add(Text(data['title'], style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF6B38D4))));
      children.add(const SizedBox(height: 16));
    }

    if (data['instructions'] != null) {
      children.add(_buildSectionHeader('info', 'Instructions'));
      children.add(Container(
        width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
        child: Text(data['instructions'], style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2)),
      ));
    }

    if (_evaluationResult != null) {
      children.add(Container(
        padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green)),
        child: Row(children: [
          const Icon(Icons.stars_rounded, color: Colors.green, size: 32),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Evaluation Complete', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[800])),
            Text('Score: ${_evaluationResult!['score']} / ${_evaluationResult!['total_marks']}', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green[900])),
          ]))
        ]),
      ));
    }

    if (data['questions'] != null && (data['questions'] as List).isNotEmpty) {
      children.add(_buildSectionHeader('task_alt', 'Questions'));
      final questions = data['questions'] as List;
      for (int i = 0; i < questions.length; i++) {
        var q = questions[i];
        var eval;
        if (_evaluationResult != null && _evaluationResult!['evaluations'] != null) {
          if (i < (_evaluationResult!['evaluations'] as List).length) {
            eval = _evaluationResult!['evaluations'][i];
          }
        }

        children.add(Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border), boxShadow: shadowSm),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF6B38D4).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text('Q${i+1}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6B38D4))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(q['question'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text1))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              if (q['type'] != null)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.border)),
                  child: Text(q['type'].toString().toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.text3)),
                ),
              if (q['marks'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.orange.withOpacity(0.5))),
                  child: Text('${q['marks']} Marks', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange[800])),
                ),
            ]),
            const SizedBox(height: 12),
            if (q['options'] != null && (q['options'] as List).isNotEmpty) ...[
              ...((q['options'] as List).map((opt) {
                bool isSelected = _answers[i] == opt.toString();
                return GestureDetector(
                  onTap: _evaluationResult != null ? null : () => setState(() => _answers[i] = opt.toString()),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
                      Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, size: 16, color: isSelected ? const Color(0xFF6B38D4) : AppColors.text3),
                      const SizedBox(width: 8),
                      Expanded(child: Text(opt.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2))),
                    ]),
                  ),
                );
              }).toList())
            ] else ...[
              TextField(
                enabled: _evaluationResult == null,
                onChanged: (val) => _answers[i] = val,
                maxLines: (q['type'] != null && (q['type'].toString().toLowerCase().contains('long') || q['type'].toString().toLowerCase().contains('proof') || q['type'].toString().toLowerCase().contains('diagram'))) ? 4 : 1,
                decoration: InputDecoration(
                  hintText: 'Type your answer here...',
                  filled: true, fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
            ],
            if (eval != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (eval['is_correct'] == true) ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: (eval['is_correct'] == true) ? Colors.green : Colors.red)
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon((eval['is_correct'] == true) ? Icons.check_circle : Icons.cancel, color: (eval['is_correct'] == true) ? Colors.green : Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Text('${eval['marks_awarded']} / ${eval['max_marks']} Marks', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: (eval['is_correct'] == true) ? Colors.green[800] : Colors.red[800])),
                  ]),
                  if (eval['feedback'] != null) ...[
                    const SizedBox(height: 8),
                    Text(eval['feedback'].toString(), style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text1)),
                  ]
                ]),
              )
            ]
          ]),
        ));
      }

      if (_evaluationResult == null) {
        children.add(const SizedBox(height: 16));
        children.add(GestureDetector(
          onTap: _evaluating ? null : _submit,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(color: _evaluating ? const Color(0xFF6B38D4).withOpacity(0.5) : const Color(0xFF6B38D4), borderRadius: BorderRadius.circular(rMd), boxShadow: shadowSm),
            child: Center(child: _evaluating
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                  const SizedBox(width: 10),
                  Text('Evaluating...', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                ])
              : Text('Submit Answers', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
          ),
        ));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }
}

class _QuizWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  const _QuizWidget({Key? key, required this.data}) : super(key: key);
  @override
  State<_QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<_QuizWidget> {
  final Map<int, String> _selectedOptions = {};

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    final data = widget.data;
    if (data['title'] != null) {
      children.add(Text(data['title'], style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF6B38D4))));
      children.add(const SizedBox(height: 16));
    }

    if (data['questions'] != null && (data['questions'] as List).isNotEmpty) {
      children.add(Text('Questions', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text1)));
      children.add(const SizedBox(height: 12));
      final questions = data['questions'] as List;
      for (int i = 0; i < questions.length; i++) {
        var q = questions[i];
        bool answered = _selectedOptions.containsKey(i);
        String? selected = _selectedOptions[i];

        children.add(Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${i+1}. ${q['question']}', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text1)),
            const SizedBox(height: 12),
            if (q['options'] != null) ...((q['options'] as List).map((opt) {
              bool isSelected = selected == opt.toString();
              bool isCorrect = q['correct_answer'] == opt;
              Color bgColor = Colors.white;
              Color borderColor = AppColors.border;
              Color textColor = AppColors.text2;
              Widget? trailing;

              if (answered) {
                if (isCorrect) {
                  bgColor = Colors.green.withOpacity(0.1);
                  borderColor = Colors.green;
                  textColor = Colors.green[800]!;
                  trailing = const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16);
                } else if (isSelected) {
                  bgColor = Colors.red.withOpacity(0.1);
                  borderColor = Colors.red;
                  textColor = Colors.red[800]!;
                  trailing = const Icon(Icons.cancel_rounded, color: Colors.red, size: 16);
                }
              } else if (isSelected) {
                borderColor = const Color(0xFF6B38D4);
                bgColor = const Color(0xFF6B38D4).withOpacity(0.05);
              }

              return GestureDetector(
                onTap: answered ? null : () => setState(() => _selectedOptions[i] = opt.toString()),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(children: [
                    Expanded(child: Text(opt.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: textColor))),
                    if (trailing != null) trailing,
                  ]),
                ),
              );
            }).toList()),
            if (answered && q['explanation'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF6B38D4).withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Explanation', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF6B38D4))),
                  const SizedBox(height: 4),
                  Text(q['explanation'].toString(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2)),
                ]),
              )
            ]
          ]),
        ));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }
}

