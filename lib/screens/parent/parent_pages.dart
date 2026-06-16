import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../models/role_config.dart';
import '../../services/api_service.dart';
import '../../services/app_store.dart';
import '../../widgets/builders.dart';
import '../../widgets/interactive.dart';
import '../page_router.dart';

class ParentPages extends StatelessWidget {
  final String page;
  const ParentPages({super.key, required this.page});
  @override
  Widget build(BuildContext context) {
    switch (page) {
      case 'dashboard':     return const _Dashboard();
      case 'childoverview': return const _ChildOverview();
      case 'grades':        return const _Grades();
      case 'attendance':    return const _Attendance();
      case 'assignments':   return const _Assignments();
      case 'payments':      return const _Payments();
      case 'insights':      return const _Insights();
      default:              return defaultPage(page);
    }
  }
}

class _Dashboard extends StatefulWidget {
  const _Dashboard();
  @override
  State<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<_Dashboard> {
  ProfileMe? _profile;
  ParentStudentMapping? _mapping;
  double _childAvg = 0.0;
  double _childAtt = 0.0;
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
      final api = ApiService();
      final p = await api.getMyProfile();
      if (mounted) setState(() => _profile = p);

      final maps = await api.getParentStudentMappings();
      if (maps.results.isNotEmpty) {
        final m = maps.results.first;
        final gradesRes = await api.getGrades(studentId: m.studentId);
        final attRes = await api.getAttendance(studentId: m.studentId);
        
        double totalObt = 0, totalMax = 0;
        for (var g in gradesRes.results) {
          totalObt += g.marksObtained ?? 0;
          totalMax += g.maxMarks ?? 100;
        }
        double avg = totalMax > 0 ? (totalObt / totalMax * 100) : 0.0;
        
        int present = 0;
        for (var a in attRes.results) {
          if (a.status == 'Present' || a.status == 'Late') present++;
        }
        double att = attRes.results.isNotEmpty ? (present / attRes.results.length * 100) : 0.0;
        
        if (mounted) setState(() {
          _mapping = m;
          _childAvg = avg;
          _childAtt = att;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cfg   = kRoles[UserRole.parent]!;
    final store = AppStore.instance;
    final name   = store.currentUserName.isNotEmpty ? store.currentUserName : (_profile?.displayName ?? 'Parent');
    final school = store.currentSchool.isNotEmpty ? store.currentSchool : (_profile?.schoolName ?? 'School');

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      heroPortrait(cfg.avatarAsset, school),
      profileInfo(name, 'Guardian', cfg.idLabel),
      pageTitle('Dashboard'),
      if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue)))
      else if (_mapping != null) ...[
        appCard(Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 48, height: 48, decoration: const BoxDecoration(color: AppColors.blueLight, shape: BoxShape.circle), child: const Icon(Icons.person_rounded, color: AppColors.blue)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_mapping!.studentName ?? 'Student', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text1)),
                Text('${_mapping!.relationship} · Mapped', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3)),
              ])),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(rSm)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('AVG. SCORE', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.text4)),
                const SizedBox(height: 4),
                Text('${_childAvg.toStringAsFixed(1)}%', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.green)),
              ]))),
              const SizedBox(width: 12),
              Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(rSm)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ATTENDANCE', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.text4)),
                const SizedBox(height: 4),
                Text('${_childAtt.toStringAsFixed(1)}%', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.blue)),
              ]))),
            ]),
          ]),
        )),
      ] else appCard(const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No student linked to this account.')))),
      secLabel('Quick Actions'),
      actionGrid([
        ActionItem(icon: Icons.bar_chart_rounded,     label: 'Child Grades',  bg: AppColors.blueLight,  iconColor: AppColors.blue,
            onTap: () => showToast(context, 'Opening grades…')),
        ActionItem(icon: Icons.fact_check_rounded,    label: 'Attendance',    bg: AppColors.greenLight, iconColor: AppColors.green,
            onTap: () => showToast(context, 'Opening attendance…')),
        ActionItem(icon: Icons.description_rounded,   label: 'Assignments',   bg: AppColors.tealLight,  iconColor: AppColors.teal,
            onTap: () => showToast(context, 'Opening assignments…')),
        ActionItem(icon: Icons.credit_card_rounded,   label: 'Pay Fees',      bg: AppColors.redLight,   iconColor: AppColors.red,
            onTap: () => showPayFees(context)),
        ActionItem(icon: Icons.auto_awesome_rounded,  label: 'AI Insights',   bg: AppColors.amberLight, iconColor: AppColors.amber,
            onTap: () => showToast(context, 'Opening AI insights…')),
        ActionItem(icon: Icons.chat_rounded,          label: 'Message',       bg: AppColors.blueLight,  iconColor: AppColors.blue,
            onTap: () => showMessageTeacher(context)),
      ]),
      const SizedBox(height: 16),
    ]);
  }
}

class _ChildOverview extends StatefulWidget {
  const _ChildOverview();
  @override State<_ChildOverview> createState() => _ChildOverviewState();
}

class _ChildOverviewState extends State<_ChildOverview> {
  bool _loading = true;
  ParentStudentMapping? _mapping;
  double _childAvg = 0.0;
  double _childAtt = 0.0;
  String _gpaBand = '—';

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
    try {
      final api = ApiService();
      final maps = await api.getParentStudentMappings();
      if (maps.results.isNotEmpty) {
        final m = maps.results.first;
        final gradesRes = await api.getGrades(studentId: m.studentId);
        final attRes = await api.getAttendance(studentId: m.studentId);
        
        double totalObt = 0, totalMax = 0;
        for (var g in gradesRes.results) {
          totalObt += g.marksObtained ?? 0;
          totalMax += g.maxMarks ?? 100;
        }
        double avg = totalMax > 0 ? (totalObt / totalMax * 100) : 0.0;
        
        int present = 0;
        for (var a in attRes.results) {
          if (a.status == 'Present' || a.status == 'Late') present++;
        }
        double att = attRes.results.isNotEmpty ? (present / attRes.results.length * 100) : 0.0;
        
        String gpa = '—';
        if (gradesRes.results.isNotEmpty) {
          if (avg >= 90) gpa = 'A+';
          else if (avg >= 80) gpa = 'A';
          else if (avg >= 70) gpa = 'B+';
          else if (avg >= 60) gpa = 'B';
          else if (avg >= 50) gpa = 'C';
          else gpa = 'D';
        }

        if (mounted) setState(() {
          _mapping = m; _childAvg = avg; _childAtt = att; _gpaBand = gpa;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Child Overview', subtitle: _mapping?.studentName ?? 'Overview'),
      if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue)))
      else if (_mapping != null) ...[
        statGrid([
          StatItem(icon: Icons.bar_chart_rounded,    iconBg: AppColors.blueLight,  iconColor: AppColors.blue,  val: '${_childAvg.toStringAsFixed(1)}%', label: 'Overall Avg', delta: 0),
          StatItem(icon: Icons.fact_check_rounded,   iconBg: AppColors.greenLight, iconColor: AppColors.green, val: '${_childAtt.toStringAsFixed(1)}%', label: 'Attendance', delta: 0),
          StatItem(icon: Icons.description_rounded,  iconBg: AppColors.amberLight, iconColor: AppColors.amber, val: '—',   label: 'Pending Tasks',  delta: 0),
          StatItem(icon: Icons.emoji_events_rounded, iconBg: AppColors.tealLight,  iconColor: AppColors.teal,  val: _gpaBand,  label: 'GPA Band',       delta: 0),
        ]),
      ] else appCard(const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No student linked to this account.')))),
      const SizedBox(height: 16),
    ]);
  }
}

class _Grades extends StatefulWidget {
  const _Grades();
  @override State<_Grades> createState() => _GradesState();
}

class _GradesState extends State<_Grades> {
  bool _loading = true;
  ParentStudentMapping? _mapping;
  List<StudentGrade> _grades = [];

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
    try {
      final api = ApiService();
      final maps = await api.getParentStudentMappings();
      if (maps.results.isNotEmpty) {
        final m = maps.results.first;
        final gradesRes = await api.getGrades(studentId: m.studentId);
        if (mounted) setState(() { _mapping = m; _grades = gradesRes.results; });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override Widget build(BuildContext context) {
    double totalObt = 0, totalMax = 0;
    for (var g in _grades) {
      totalObt += g.marksObtained ?? 0;
      totalMax += g.maxMarks ?? 100;
    }
    double avg = totalMax > 0 ? (totalObt / totalMax * 100) : 0.0;
    
    String gpa = '—';
    if (_grades.isNotEmpty) {
      if (avg >= 90) gpa = 'A+';
      else if (avg >= 80) gpa = 'A';
      else if (avg >= 70) gpa = 'B+';
      else if (avg >= 60) gpa = 'B';
      else if (avg >= 50) gpa = 'C';
      else gpa = 'D';
    }

    final colors = [AppColors.blue, AppColors.teal, AppColors.navy, AppColors.amber, AppColors.green];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Grades & Report Card', subtitle: _mapping?.studentName ?? 'Grades'),
      if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue)))
      else if (_mapping != null && _grades.isEmpty)
        appCard(const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No grades published yet.'))))
      else if (_mapping != null) ...[
        appCard(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${avg.toStringAsFixed(1)}%', style: GoogleFonts.dmSerifDisplay(fontSize: 26, color: AppColors.text1)),
                Text("${_mapping!.studentName}'s Average", style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(gradient: blueGrad(), borderRadius: BorderRadius.circular(rFull)),
                child: Text(gpa, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ]),
          ),
          GradeBars(items: _grades.take(6).toList().asMap().entries.map((entry) {
            final g = entry.value;
            final pct = (g.maxMarks ?? 100) > 0 ? ((g.marksObtained ?? 0) / (g.maxMarks ?? 100) * 100).clamp(0, 100).toInt() : 0;
            return GradeItem(subject: g.subjectName ?? 'Subject', value: pct, color: colors[entry.key % colors.length]);
          }).toList()),
        ])),
      ] else appCard(const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No student linked to this account.')))),
      const SizedBox(height: 16),
    ]);
  }
}

class _Attendance extends StatefulWidget {
  const _Attendance();
  @override State<_Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<_Attendance> {
  bool _loading = true;
  ParentStudentMapping? _mapping;
  int _present = 0, _absent = 0, _late = 0, _total = 0;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
    try {
      final api = ApiService();
      final maps = await api.getParentStudentMappings();
      if (maps.results.isNotEmpty) {
        final m = maps.results.first;
        final attRes = await api.getAttendance(studentId: m.studentId);
        int p = 0, a = 0, l = 0;
        for (var r in attRes.results) {
          if (r.status == 'Present') p++;
          else if (r.status == 'Absent') a++;
          else if (r.status == 'Late') l++;
          else p++;
        }
        if (mounted) setState(() {
          _mapping = m; _total = attRes.results.length; _present = p; _absent = a; _late = l;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override Widget build(BuildContext context) {
    final overallPct = _total > 0 ? ((_present + _late) / _total * 100) : 0.0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Attendance', subtitle: _mapping?.studentName != null ? "${_mapping!.studentName}'s attendance record" : "Attendance"),
      if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue)))
      else if (_mapping != null) ...[
        appCard(Padding(padding: const EdgeInsets.all(14), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _attStat('${overallPct.toStringAsFixed(0)}%', AppColors.green, 'Overall'),
            _attStat('$_present',  AppColors.blue,  'Present'),
            _attStat('$_absent',   AppColors.red,   'Absent'),
            _attStat('$_late',     AppColors.amber, 'Late'),
          ]),
          const Divider(height: 28, color: AppColors.border),
          ProgressBar(label: 'Attendance Rate', value: overallPct.toInt(), gradient: greenGrad()),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.info_outline_rounded, size: 12, color: AppColors.text4),
            const SizedBox(width: 5),
            Text('Minimum required: 75%',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
          ]),
        ]))),
      ] else appCard(const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No student linked to this account.')))),
      const SizedBox(height: 16),
    ]);
  }

  Widget _attStat(String val, Color color, String label) => Column(children: [
    Text(val, style: GoogleFonts.dmSerifDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
    Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4)),
  ]);
}

class _Assignments extends StatefulWidget {
  const _Assignments();

  @override
  State<_Assignments> createState() => _AssignmentsState();
}

class _AssignmentsState extends State<_Assignments> {
  List<SchoolAssignment> _assignments = [];
  ParentStudentMapping? _mapping;
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
      final api = ApiService();
      final maps = await api.getParentStudentMappings();
      if (maps.results.isNotEmpty) {
        final m = maps.results.first;
        // In a real app we might need to fetch assignments by sectionId or just all assignments
        // Since getAssignments() without params gets all, and backend filters by user, we just call it.
        final res = await api.getAssignments();
        if (mounted) setState(() {
          _mapping = m;
          _assignments = res.results;
          _loading = false;
        });
      } else {
        if (mounted) setState(() { _loading = false; });
      }
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Color _badgeBg(String s) {
    if (s == 'Pending') return AppColors.amberLight;
    if (s.startsWith('Graded')) return AppColors.greenLight;
    return AppColors.blueLight;
  }
  Color _badgeColor(String s) {
    if (s == 'Pending') return AppColors.amber;
    if (s.startsWith('Graded')) return AppColors.green;
    return AppColors.blue;
  }

  Color _col(String s) {
    final lower = s.toLowerCase();
    if (lower.contains('math')) return AppColors.blue;
    if (lower.contains('phys') || lower.contains('sci')) return AppColors.teal;
    if (lower.contains('hist')) return AppColors.green;
    if (lower.contains('eng')) return AppColors.amber;
    return AppColors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final childName = _mapping?.studentName ?? "Student";

    if (_loading) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        pageTitle('Assignments', subtitle: "$childName's tasks"),
        const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
      ]);
    }

    if (!TokenStore.hasTokens || (_assignments.isEmpty && _error == null)) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        pageTitle('Assignments', subtitle: "$childName's tasks"),
        appCard(Padding(padding: const EdgeInsets.all(20), child: Center(child: Text(
          'No assignments available.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3),
        )))),
        const SizedBox(height: 16),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Assignments', subtitle: "$childName's tasks"),
      if (_error != null)
        Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.redLight, borderRadius: BorderRadius.circular(rMd), border: Border.all(color: AppColors.red)),
          child: Text('Error: $_error\nShowing demo fallback data.', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.red)),
        ),
      const ChipRow(chips: ['All', 'Pending', 'Submitted', 'Graded']),
      appCard(asgnCards(_assignments.map((a) {
        final st = a.status ?? 'Pending';
        return AsgItem(
          sub: a.subjectName?.toUpperCase() ?? 'SUBJECT',
          title: a.title,
          due: a.dueDate ?? 'TBD',
          barColor: _col(a.subjectName ?? 'blue'),
          badge: st,
          badgeBg: _badgeBg(st),
          badgeColor: _badgeColor(st),
        );
      }).toList())),
      Padding(padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
          child: outlineBtn('Message Teacher about Assignment',
              onTap: () => showMessageTeacher(context))),
      const SizedBox(height: 16),
    ]);
  }
}

class _Payments extends StatefulWidget {
  const _Payments();
  @override
  State<_Payments> createState() => _PaymentsState();
}
class _PaymentsState extends State<_Payments> {
  bool _term2Paid = false;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Payments', subtitle: 'Arjun Mehta · Fee Account'),
    finBanner('Outstanding Balance', _term2Paid ? '0' : '24,500',
        _term2Paid ? 'All dues cleared · Term 2' : 'Term 2 Tuition · Due April 15, 2025'),
    if (!_term2Paid)
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: navyBtn('Pay Now Online', onTap: () async {
            await showSheet(context,
                _PayFeesSheet(amount: '₹24,500', desc: 'Term 2 Tuition'),
                tall: true);
            // After sheet closes, mark as paid if user completed payment
            if (mounted) setState(() => _term2Paid = true);
          })),
    secLabel('Payment History'),
    appCard(Column(children: [
      if (_term2Paid)
        invRow('INV-089', 'Term 2 Tuition', 'Paid just now', '₹24,500', 'Paid',
            AppColors.greenLight, AppColors.green),
      invRow('INV-075', 'Term 1 Tuition',  'Paid Nov 10, 2024', '₹24,500', 'Paid',    AppColors.greenLight, AppColors.green),
      invRow('INV-062', 'Activity Fee',    'Paid Nov 10, 2024', '₹3,200',  'Paid',    AppColors.greenLight, AppColors.green),
      invRow('INV-051', 'Examination Fee', 'Paid Mar 5, 2025',  '₹1,800',  'Paid',    AppColors.greenLight, AppColors.green),
      if (!_term2Paid)
        invRow('INV-089', 'Term 2 Tuition', 'Due Apr 15, 2025', '₹24,500', 'Due',
            AppColors.amberLight, AppColors.amber),
    ])),
    const SizedBox(height: 16),
  ]);

  Widget invRow(String id, String name, String type, String amount, String status,
      Color bg, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(children: [
          Container(width: 38, height: 38,
              decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(rMd)),
              child: const Center(child: Icon(Icons.receipt_long_rounded, size: 16, color: AppColors.blue))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(id, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.text4)),
            Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
            Text(type, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(amount, style: GoogleFonts.dmSerifDisplay(fontSize: 15, color: AppColors.text1)),
            const SizedBox(height: 4),
            appBadge(status, bg: bg, color: color),
          ]),
        ]),
      );
}

// Expose _PayFeesSheet for re-use inside this file
class _PayFeesSheet extends StatefulWidget {
  final String amount, desc;
  const _PayFeesSheet({required this.amount, required this.desc});
  @override
  State<_PayFeesSheet> createState() => _PayFeesSheetState();
}
class _PayFeesSheetState extends State<_PayFeesSheet> {
  int _step = 0;
  String _method = 'UPI';
  @override
  Widget build(BuildContext context) {
    if (_step == 3) return _successWidget();
    if (_step == 2) return _processingWidget();
    if (_step == 1) return _detailsWidget(context);
    return _methodWidget(context);
  }

  Widget _methodWidget(BuildContext ctx) => Padding(
    padding: const EdgeInsets.fromLTRB(20,16,20,32),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width:36,height:36,decoration:BoxDecoration(color:AppColors.navy.withOpacity(0.1),borderRadius:BorderRadius.circular(rMd)),
            child:const Icon(Icons.payment_rounded,size:18,color:AppColors.navy)),
        const SizedBox(width:10),
        Text('Pay Fees',style:GoogleFonts.dmSerifDisplay(fontSize:19,color:AppColors.text1)),
      ]),
      const SizedBox(height:12),
      Container(width:double.infinity,padding:const EdgeInsets.all(16),margin:const EdgeInsets.only(bottom:20),
        decoration:BoxDecoration(gradient:blueGrad(),borderRadius:BorderRadius.circular(rLg)),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(widget.desc,style:GoogleFonts.plusJakartaSans(fontSize:11,color:Colors.white.withOpacity(0.7))),
          const SizedBox(height:4),
          Text(widget.amount,style:GoogleFonts.dmSerifDisplay(fontSize:28,color:Colors.white)),
          Text('Due: April 15, 2025',style:GoogleFonts.plusJakartaSans(fontSize:11,color:Colors.white.withOpacity(0.7))),
        ]),
      ),
      ...['UPI','Credit / Debit Card','Net Banking','Cash at Office'].map((m) =>
        GestureDetector(onTap:()=>setState((){_method=m;_step=1;}),
          child:Container(width:double.infinity,margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.symmetric(horizontal:16,vertical:14),
            decoration:BoxDecoration(color:_method==m?AppColors.blueLight:AppColors.surface,
              border:Border.all(color:_method==m?AppColors.blue:AppColors.border,width:1.5),
              borderRadius:BorderRadius.circular(rMd)),
            child:Row(children:[
              Icon(_icon(m),size:18,color:_method==m?AppColors.blue:AppColors.text3),
              const SizedBox(width:12),
              Text(m,style:GoogleFonts.plusJakartaSans(fontSize:13,fontWeight:FontWeight.w600,color:_method==m?AppColors.blue:AppColors.text1)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded,size:12,color:_method==m?AppColors.blue:AppColors.text4),
            ]))),
      ),
    ]),
  );

  Widget _detailsWidget(BuildContext ctx) => Padding(
    padding:const EdgeInsets.fromLTRB(20,16,20,32),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      GestureDetector(onTap:()=>setState(()=>_step=0),
        child:Row(children:[const Icon(Icons.arrow_back_rounded,size:18,color:AppColors.text2),const SizedBox(width:8),
          Text('Pay via $_method',style:GoogleFonts.dmSerifDisplay(fontSize:18,color:AppColors.text1))])),
      const SizedBox(height:20),
      if(_method=='UPI')...[
        _lbl('UPI ID'), _field('yourname@upi'),
        _lbl('Amount'), _field(widget.amount.replaceAll('₹','')),
      ] else if(_method=='Credit / Debit Card')...[
        _lbl('Card Number'), _field('•••• •••• •••• ••••'),
        _lbl('Card Holder'), _field(''),
        Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[_lbl('MM/YY'),_field('')])),
          const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[_lbl('CVV'),_field('')]))]),
      ] else if(_method=='Net Banking')...[
        _lbl('Select Bank'),_field('SBI / HDFC / ICICI / Axis'),
      ] else...[
        Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:AppColors.amberLight,borderRadius:BorderRadius.circular(rMd),border:Border.all(color:const Color(0xFFFCD34D))),
          child:Text('Please visit school accounts office with cash of ${widget.amount}. Office: Mon–Fri 9AM–4PM.',
              style:GoogleFonts.plusJakartaSans(fontSize:12,color:AppColors.amber,height:1.5))),
      ],
      const SizedBox(height:24),
      navyBtn(_method=='Cash at Office'?'Got It':'Pay ${widget.amount}', onTap:() async {
        if(_method=='Cash at Office'){Navigator.pop(ctx);return;}
        setState(()=>_step=2);
        await Future.delayed(const Duration(seconds:2));
        if(mounted) setState(()=>_step=3);
      }),
    ]),
  );

  Widget _processingWidget() => SizedBox(height:260,child:Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    const CircularProgressIndicator(color:AppColors.blue),const SizedBox(height:20),
    Text('Processing Payment…',style:GoogleFonts.plusJakartaSans(fontSize:14,fontWeight:FontWeight.w600,color:AppColors.text1)),
    const SizedBox(height:6),Text('Please do not close this screen',style:GoogleFonts.plusJakartaSans(fontSize:11,color:AppColors.text3)),
  ])));

  Widget _successWidget() => Padding(padding:const EdgeInsets.fromLTRB(20,40,20,40),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    Container(width:72,height:72,decoration:BoxDecoration(color:AppColors.greenLight,shape:BoxShape.circle,border:Border.all(color:const Color(0xFF86EFAC),width:2)),
        child:const Icon(Icons.check_circle_rounded,size:32,color:AppColors.green)),
    const SizedBox(height:16),
    Text('Payment Successful!',style:GoogleFonts.dmSerifDisplay(fontSize:22,color:AppColors.text1),textAlign:TextAlign.center),
    const SizedBox(height:8),
    Text('${widget.amount} · ${widget.desc}\nRef: TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        style:GoogleFonts.plusJakartaSans(fontSize:13,color:AppColors.text3,height:1.5),textAlign:TextAlign.center),
    const SizedBox(height:28),
    GestureDetector(onTap:()=>Navigator.pop(context),child:Container(padding:const EdgeInsets.symmetric(horizontal:32,vertical:12),
      decoration:BoxDecoration(gradient:blueGrad(),borderRadius:BorderRadius.circular(rMd),boxShadow:shadowSm),
      child:Text('Done',style:GoogleFonts.plusJakartaSans(fontSize:13,fontWeight:FontWeight.w700,color:Colors.white)))),
  ]));

  Widget _lbl(String t) => Padding(padding:const EdgeInsets.only(bottom:6,top:2),child:Text(t,style:GoogleFonts.plusJakartaSans(fontSize:11,fontWeight:FontWeight.w600,color:AppColors.text3)));
  Widget _field(String h) => Padding(padding:const EdgeInsets.only(bottom:14),child:TextField(style:GoogleFonts.plusJakartaSans(fontSize:13,color:AppColors.text1),decoration:InputDecoration(hintText:h,hintStyle:GoogleFonts.plusJakartaSans(fontSize:13,color:AppColors.text4),filled:true,fillColor:AppColors.surface,contentPadding:const EdgeInsets.symmetric(horizontal:14,vertical:12),border:OutlineInputBorder(borderRadius:BorderRadius.circular(rMd),borderSide:const BorderSide(color:AppColors.border,width:1.5)),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(rMd),borderSide:const BorderSide(color:AppColors.border,width:1.5)),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(rMd),borderSide:const BorderSide(color:AppColors.blue,width:1.5)))));
  IconData _icon(String m){switch(m){case 'UPI':return Icons.qr_code_rounded;case 'Credit / Debit Card':return Icons.credit_card_rounded;case 'Net Banking':return Icons.account_balance_rounded;default:return Icons.payments_rounded;}}
}

// lib/screens/parent/parent_pages.dart

// ... [Switch case and previous dashboards]

class _Insights extends StatelessWidget {
  const _Insights();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('AI Insights', subtitle: 'Personalised recommendations for Arjun'),
    appCard(Padding(padding: const EdgeInsets.all(14), child: Column(children: [
      _insight(AppColors.blue,  Icons.trending_up_rounded,    'Performance Trend',  "Arjun's Physics scores improved 8% over the last 3 tests."),
      const SizedBox(height: 14),
      _insight(AppColors.amber, Icons.warning_amber_rounded,  'Attendance Warning', '3 absences this month. Ensure regular attendance.'),
      const SizedBox(height: 14),
      _insight(AppColors.green, Icons.trending_up_rounded,    'Predicted Grade',    'Based on current performance, final grade predicted at B+ to A−.'),
    ]))),
    Padding(padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
        child: outlineBtn('Message Teacher', onTap: () => showMessageTeacher(context))),
    const SizedBox(height: 16),
  ]);

  Widget _insight(Color color, IconData icon, String title, String body) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 3, 
        height: 56, 
        // FIXED: Removed standalone color property, moved inside decoration
        decoration: BoxDecoration(
          color: color, 
          borderRadius: BorderRadius.circular(rFull)
        )
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 13, color: color), const SizedBox(width: 5),
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1))]),
        const SizedBox(height: 3),
        Text(body, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3, height: 1.5)),
      ])),
    ],
  );
}
