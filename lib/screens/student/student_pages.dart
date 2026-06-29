import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme.dart';
import '../../models/role_config.dart';
import '../../services/api_service.dart';
import '../../services/app_store.dart';
import '../../widgets/builders.dart';
import '../../widgets/interactive.dart';
import '../page_router.dart';

class StudentPages extends StatelessWidget {
  final String page;
  const StudentPages({super.key, required this.page});
  @override
  Widget build(BuildContext context) {
    switch (page) {
      case 'dashboard':   return const _Dashboard();
      case 'subjects':    return const _Subjects();
      case 'assignments': return const _Assignments();
      case 'grades':      return const _Grades();
      case 'attendance':  return const _Attendance();
      case 'timetable':   return const _Timetable();
      case 'materials':   return const _Materials();
      default:            return defaultPage(page);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD — live API when authenticated
// ─────────────────────────────────────────────────────────────────────────────

class _Dashboard extends StatefulWidget {
  const _Dashboard();
  @override
  State<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<_Dashboard> {
  ProfileMe? _profile;
  Map<String, dynamic>? _dashboardData;
  AttendanceSummaryData? _attendanceSummary;
  ReportCardData? _reportCard;
  List<Subject> _subjects = [];
  List<StudentGrade> _grades = [];
  List<AttendanceRecord> _attendanceRecords = [];
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
      final results = await Future.wait([
        ApiService().getMyProfile(),
        ApiService().getStudentDashboard(),
        ApiService().getAttendanceSummary(),
        ApiService().getReportCard(),
        ApiService().getStudentSubjects(),
        ApiService().getStudentGrades(),
        ApiService().getStudentAttendanceRecords(),
      ]);

      if (!mounted) return;

      setState(() {
        _profile = results[0] as ProfileMe;
        _dashboardData = results[1] as Map<String, dynamic>;
        _attendanceSummary = results[2] as AttendanceSummaryData;
        _reportCard = results[3] as ReportCardData;
        _subjects = (results[4] as PaginatedResult<Subject>).results;
        _grades = (results[5] as PaginatedResult<StudentGrade>).results;
        _attendanceRecords = (results[6] as PaginatedResult<AttendanceRecord>).results;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _monthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[month - 1];
  }

  Map<String, dynamic> _statusBadge(double value, String type) {
    if (type == 'attendance') {
      if (value >= 80) return {'label': 'ON TRACK', 'color': AppColors.green};
      if (value >= 65) return {'label': 'SATISFACTORY', 'color': AppColors.amber};
      return {'label': 'AT RISK', 'color': AppColors.red};
    }
    if (value >= 75) return {'label': 'EXCELLENT', 'color': AppColors.green};
    if (value >= 60) return {'label': 'GOOD', 'color': AppColors.blue};
    if (value >= 45) return {'label': 'SATISFACTORY', 'color': AppColors.amber};
    return {'label': 'AT RISK', 'color': AppColors.red};
  }

  Map<String, dynamic> _subjectIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('math')) return {'icon': Icons.calculate_rounded, 'bg': AppColors.blueLight, 'color': AppColors.blue};
    if (lower.contains('phys')) return {'icon': Icons.science_rounded, 'bg': AppColors.blueLight, 'color': AppColors.blue};
    if (lower.contains('chem')) return {'icon': Icons.biotech_rounded, 'bg': AppColors.greenLight, 'color': AppColors.green};
    if (lower.contains('bio')) return {'icon': Icons.biotech_rounded, 'bg': AppColors.tealLight, 'color': AppColors.teal};
    if (lower.contains('eng') || lower.contains('lit')) return {'icon': Icons.menu_book_rounded, 'bg': AppColors.blueLight, 'color': AppColors.navy};
    if (lower.contains('hindi') || lower.contains('sanskrit') || lower.contains('language')) return {'icon': Icons.translate_rounded, 'bg': AppColors.redLight, 'color': AppColors.red};
    return {'icon': Icons.book_rounded, 'bg': AppColors.border, 'color': AppColors.text1};
  }

  List<Map<String, dynamic>> _buildRecentActivity() {
    final events = <Map<String, dynamic>>[];
    final recentGrades = (_dashboardData?['recent_grades'] as List?) ?? [];
    for (final raw in recentGrades.whereType<Map<String, dynamic>>()) {
      final ts = raw['updated_at'] ?? raw['created_at'] ?? raw['exam_date'] ?? raw['date'];
      if (ts == null) continue;
      final date = DateTime.tryParse(ts.toString());
      if (date == null) continue;
      final subject = raw['subject_name'] ?? raw['subject'] ?? 'Subject';
      final exam = raw['exam_name'] ?? raw['exam'] ?? 'exam';
      final grade = raw['letter_grade'] ?? raw['grade'] ?? raw['grade_letter'] ?? '';
      events.add({
        'id': 'grade-${raw['id'] ?? raw.hashCode}',
        'title': 'Grade Updated: $subject',
        'detail': grade.isNotEmpty ? 'You received a $grade for $exam.' : 'A grade update was recorded for $subject.',
        'timestamp': date,
        'icon': Icons.check_circle_rounded,
        'iconBg': AppColors.greenLight,
        'iconColor': AppColors.green,
      });
    }

    for (final record in _attendanceRecords) {
      if (record.date == null) continue;
      final date = DateTime.tryParse(record.date!);
      if (date == null) continue;
      final status = record.status;
      events.add({
        'id': 'att-${record.id}-${record.date}',
        'title': 'Attendance Marked',
        'detail': '$status for ${record.remarks ?? record.enrollmentNo ?? 'the day'}.',
        'timestamp': date,
        'icon': status == 'Present' ? Icons.event_available_rounded : status == 'Absent' ? Icons.event_busy_rounded : Icons.info_rounded,
        'iconBg': status == 'Present' ? AppColors.greenLight : status == 'Absent' ? AppColors.redLight : AppColors.amberLight,
        'iconColor': status == 'Present' ? AppColors.green : status == 'Absent' ? AppColors.red : AppColors.amber,
      });
    }

    final activity = events
        .where((e) => e['timestamp'] is DateTime)
        .toList()
      ..sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

    return activity.take(6).toList();
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes} mins ago';
    if (diff.inDays < 1) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator(color: AppColors.blue)));
    }

    final cfg = kRoles[UserRole.student]!;
    final name = _profile?.displayName ?? cfg.name;
    final firstName = name.split(' ').first;

    final attendancePct = _attendanceSummary?.attendancePercentage ?? 0.0;
    final overallPct = _reportCard?.overallPercentage ?? 0.0;
    final hasAttendance = _attendanceSummary != null && _attendanceSummary!.totalDays > 0;
    final hasReport = _reportCard != null && _reportCard!.overallPercentage > 0;

    final feesLabel = (_dashboardData?['fees_status'] as String?) ?? 'Unavailable';
    final feesBadge = (_dashboardData?['fees_status'] != null) ? AppColors.green : AppColors.red;
    final feesValue = (_dashboardData?['fees_status'] as String?) ?? 'Not Available';

    final now = DateTime.now();
    final monthName = _monthName(now.month);
    final attendanceMap = <String, AttendanceRecord>{};
    for (final record in _attendanceRecords) {
      if (record.date != null) {
        final parsed = DateTime.tryParse(record.date!);
        if (parsed != null) {
          attendanceMap['${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}'] = record;
        }
      }
    }

    final monthlyCounts = {'Present': 0, 'Absent': 0, 'Late': 0};
    for (final record in _attendanceRecords) {
      if (record.date == null) continue;
      final date = DateTime.tryParse(record.date!);
      if (date == null || date.year != now.year || date.month != now.month) continue;
      if (monthlyCounts.containsKey(record.status)) {
        monthlyCounts[record.status] = monthlyCounts[record.status]! + 1;
      }
    }

    final gradeMap = <String, StudentGrade>{};
    for (final grade in _grades) {
      if (grade.subjectId.isNotEmpty) {
        gradeMap[grade.subjectId] = grade;
      }
    }

    final List<Subject> displaySubjects = List.from(_subjects);
    displaySubjects.sort((a, b) {
      final aGrade = gradeMap[a.id]?.percentage ?? -1;
      final bGrade = gradeMap[b.id]?.percentage ?? -1;
      return bGrade.compareTo(aGrade);
    });

    final recentEvents = _buildRecentActivity();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Banner
      Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: blueGrad(),
          borderRadius: BorderRadius.circular(rLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, $firstName!', style: GoogleFonts.dmSerifDisplay(fontSize: 24, color: Colors.white)),
            const SizedBox(height: 8),
            Text('You are currently leading with exceptional progress. Here\'s what\'s happening in your academic journey today.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white.withOpacity(0.9), height: 1.5)),
          ],
        ),
      ),

      // Stats Row
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          _statCard(
            Icons.calendar_today_rounded,
            AppColors.blue,
            'Attendance Rate',
            hasAttendance ? '${attendancePct.toStringAsFixed(1)}%' : 'N/A',
            _statusBadge(attendancePct, 'attendance')['label'] as String,
            _statusBadge(attendancePct, 'attendance')['color'] as Color,
          ),
          const SizedBox(width: 12),
          _statCard(
            Icons.star_rounded,
            AppColors.amber,
            'Overall Percentage',
            hasReport ? '${overallPct.toStringAsFixed(1)}%' : 'N/A',
            _statusBadge(overallPct, 'performance')['label'] as String,
            _statusBadge(overallPct, 'performance')['color'] as Color,
          ),
          const SizedBox(width: 12),
          _statCard(
            Icons.verified_rounded,
            AppColors.green,
            'Fees Status',
            feesValue,
            feesLabel.toUpperCase(),
            feesBadge,
          ),
        ]),
      ),

      const SizedBox(height: 16),
      secLabel('$monthName ${now.year} Visual Presence Log'),
      appCard(Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (_attendanceRecords.isEmpty) ...[
            Text('Attendance records are not available yet.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3)),
            const SizedBox(height: 12),
            Text('We will show your daily presence here once the backend provides attendance logs.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3)),
          ] else ...[
            Wrap(spacing: 8, runSpacing: 8, children: [
              _presenceLegend('Present', AppColors.greenLight, AppColors.green),
              _presenceLegend('Absent', AppColors.redLight, AppColors.red),
              _presenceLegend('Late', AppColors.amberLight, AppColors.amber),
            ]),
            const SizedBox(height: 14),
            _attendanceCalendar(now, attendanceMap),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _presenceStat('Present', monthlyCounts['Present'] ?? 0, AppColors.green),
              _presenceStat('Absent', monthlyCounts['Absent'] ?? 0, AppColors.red),
              _presenceStat('Late', monthlyCounts['Late'] ?? 0, AppColors.amber),
            ]),
          ],
        ]),
      )),

      secLabel('My Subjects'),
      appCard(Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          if (displaySubjects.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Center(child: Text('No subjects available yet.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3))))
          else
            ...displaySubjects.take(4).map((subject) {
              final grade = gradeMap[subject.id];
              final percent = grade?.percentage ?? 0.0;
              final subjectIcon = _subjectIcon(subject.name);
              final badge = grade != null ? grade.gradeLetter : 'N/A';
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: subjectIcon['bg'] as Color,
                      borderRadius: BorderRadius.circular(rMd),
                    ),
                    child: Icon(subjectIcon['icon'] as IconData, color: subjectIcon['color'] as Color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(subject.name, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text1)),
                    if (subject.code != null) ...[
                      const SizedBox(height: 2),
                      Text(subject.code!, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text4)),
                    ],
                    const SizedBox(height: 8),
                    ProgressBar(label: 'Progress', value: percent.clamp(0, 100).toInt(), gradient: blueGrad()),
                  ])),
                  appBadge(badge, bg: (grade != null ? AppColors.blueLight : AppColors.border), color: (grade != null ? AppColors.blue : AppColors.text4)),
                ]),
              );
            }).toList(),
          if (displaySubjects.length > 4)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('View all subjects in the Subjects tab', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text3)),
              ),
            ),
        ]),
      )),

      secLabel('Quick Actions'),
      actionGrid([
        ActionItem(icon: Icons.help_outline_rounded, label: 'Help Desk', bg: AppColors.blueLight, iconColor: AppColors.blue, onTap: () => showToast(context, 'Help Desk')),
        ActionItem(icon: Icons.account_balance_wallet_rounded, label: 'Fees', bg: AppColors.blueLight, iconColor: AppColors.blue, onTap: () => showPayFees(context, amount: '0', desc: 'Fees overview')),
      ]),

      secLabel('Recent Activity'),
      appCard(Padding(
        padding: const EdgeInsets.all(16),
        child: recentEvents.isEmpty
            ? Center(child: Text('No recent activity available yet.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3)))
            : Column(children: [
                ...recentEvents.map((event) {
                  final date = event['timestamp'] as DateTime;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(color: event['iconBg'] as Color, borderRadius: BorderRadius.circular(rFull)),
                        child: Icon(event['icon'] as IconData, color: event['iconColor'] as Color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(event['title'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1)),
                        const SizedBox(height: 6),
                        Text(event['detail'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3)),
                        const SizedBox(height: 6),
                        Text(_timeAgo(date), style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4)),
                      ])),
                    ]),
                  );
                }).toList(),
              ]),
      )),

      const SizedBox(height: 16),
    ]);
  }

  Widget _presenceLegend(String label, Color bg, Color color) => Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(rFull))),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: color)),
      ]);

  Widget _presenceStat(String label, int count, Color color) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
        const SizedBox(height: 4),
        Text('$count', style: GoogleFonts.dmSerifDisplay(fontSize: 18, color: color)),
      ]);

  Widget _attendanceCalendar(DateTime now, Map<String, AttendanceRecord> attendanceMap) {
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = DateTime(now.year, now.month, 1).weekday % 7;
    final cells = <Widget>[];

    const weekdayLabels = ['S','M','T','W','T','F','S'];
    for (final label in weekdayLabels) {
      cells.add(Center(child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.text3))));
    }
    for (var i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      final record = attendanceMap[dateKey];
      final status = record?.status;
      final bgColor = status == 'Present'
          ? AppColors.greenLight
          : status == 'Absent'
              ? AppColors.redLight
              : status == 'Late'
                  ? AppColors.amberLight
                  : AppColors.surface;
      final borderColor = status == 'Present'
          ? AppColors.green
          : status == 'Absent'
              ? AppColors.red
              : status == 'Late'
                  ? AppColors.amber
                  : AppColors.border;
      final textColor = status != null ? AppColors.text1 : AppColors.text4;
      cells.add(Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(day.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: textColor)),
        ),
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      children: cells,
    );
  }

  Widget _statCard(IconData icon, Color iconColor, String title, String value, String badgeText, Color badgeColor) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(rMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(badgeText, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: badgeColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text1)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUBJECTS — web-aligned with dynamic performance calculation
// ─────────────────────────────────────────────────────────────────────────────

class _Subjects extends StatefulWidget {
  const _Subjects();
  @override
  State<_Subjects> createState() => _SubjectsState();
}

class _SubjectsState extends State<_Subjects> {
  List<Subject> _subjects = [];
  List<StudentGrade> _grades = [];
  List<SchoolAssignment> _upcoming = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!TokenStore.hasTokens) {
      setState(() => _loading = false);
      return;
    }
    try {
      final results = await Future.wait([
        ApiService().getStudentSubjects(),
        ApiService().getStudentGrades(),
        ApiService().getUpcomingAssignments(),
      ]);
      if (mounted) {
        setState(() {
          _subjects = (results[0] as PaginatedResult<Subject>).results;
          _grades = (results[1] as PaginatedResult<StudentGrade>).results;
          _upcoming = (results[2] as PaginatedResult<SchoolAssignment>).results;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Calculate performance metadata for a given percentage
  Map<String, dynamic> _getPerformanceMeta(int percentage) {
    if (percentage == 0) return { 'barColor': AppColors.slate, 'label': 'No data', 'labelColor': AppColors.text4 };
    if (percentage >= 80) return { 'barColor': AppColors.green, 'label': 'Excellent', 'labelColor': AppColors.green };
    if (percentage >= 65) return { 'barColor': AppColors.blue, 'label': 'Good', 'labelColor': AppColors.blue };
    if (percentage >= 50) return { 'barColor': AppColors.amber, 'label': 'Average', 'labelColor': AppColors.amber };
    return { 'barColor': AppColors.red, 'label': 'Needs work', 'labelColor': AppColors.red };
  }

  /// Get dynamic insight message based on overall performance
  String _getInsightMessage(int overallPct) {
    if (overallPct >= 80) return 'Outstanding! You\'re performing excellently across all subjects. Keep this momentum going!';
    if (overallPct >= 65) return 'Good progress! A little more focus on weaker subjects will push you to the top tier.';
    if (overallPct >= 50) return 'You\'re on the right track. Consistent study sessions can significantly improve your scores.';
    return 'There\'s room to grow! Consider reaching out to your teachers for extra support and guidance.';
  }

  /// Get emoji icon based on performance
  IconData _getPerformanceIcon(int overallPct) {
    if (overallPct >= 80) return Icons.emoji_events_rounded;
    if (overallPct >= 65) return Icons.trending_up_rounded;
    if (overallPct >= 50) return Icons.auto_awesome_rounded;
    return Icons.support_agent_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        pageTitle('My Subjects'),
        const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
      ]);
    }

    // Calculate performance metrics
    final gradedSubjects = _subjects.where((s) => _grades.any((g) => g.subjectId == s.id || g.subjectName == s.name)).toList();
    final subjectsWithPct = gradedSubjects.map((s) {
      final g = _grades.firstWhere((gr) => gr.subjectId == s.id || gr.subjectName == s.name, orElse: () => StudentGrade(id: '', examId: '', studentId: '', studentName: '', subjectId: s.id, marksObtained: 0, maxMarks: 0));
      final pct = (g.maxMarks > 0) ? ((g.marksObtained / g.maxMarks) * 100).round() : 0;
      return { 'name': s.name, 'pct': pct };
    }).toList();

    final overallPct = subjectsWithPct.isNotEmpty
        ? (subjectsWithPct.fold(0, (sum, s) => sum + (s['pct'] as int)) / subjectsWithPct.length).round()
        : 0;

    final topSubject = subjectsWithPct.isEmpty ? null : subjectsWithPct.fold<Map<String, dynamic>>(subjectsWithPct[0], (a, b) => (b['pct'] as int) > (a['pct'] as int) ? b : a);
    final weakSubject = subjectsWithPct.isEmpty ? null : subjectsWithPct.fold<Map<String, dynamic>>(subjectsWithPct[0], (a, b) => (b['pct'] as int) < (a['pct'] as int) ? b : a);
    final excellentCount = subjectsWithPct.where((s) => (s['pct'] as int) >= 80).length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('The Academic Architect'),
      
      // Subjects Table/List Card
      appCard(Column(children: [
        // Table header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text('SUBJECT NAME', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.text3))),
              Expanded(flex: 2, child: Text('MARKS', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.text3))),
              Expanded(flex: 4, child: Text('PERFORMANCE (%)', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.text3))),
              SizedBox(width: 60, child: Text('STATUS', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.text3))),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),

        // Subject rows
        if (_subjects.isEmpty)
          Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No subjects found for your class.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)))),
        ..._subjects.map((s) {
          final gradeInfo = _grades.firstWhere((g) => g.subjectId == s.id || g.subjectName == s.name, orElse: () => StudentGrade(id: '', examId: '', studentId: '', studentName: '', subjectId: s.id, marksObtained: 0, maxMarks: 0));
          final hasGrade = gradeInfo.id.isNotEmpty && gradeInfo.maxMarks > 0;
          final percentage = hasGrade ? ((gradeInfo.marksObtained / gradeInfo.maxMarks) * 100).round() : 0;
          final meta = _getPerformanceMeta(percentage);
          final marksString = hasGrade ? '${gradeInfo.marksObtained.toStringAsFixed(0)} / ${gradeInfo.maxMarks.toStringAsFixed(0)}' : 'N/A';
          final percentageString = hasGrade ? '$percentage%' : '—';

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(
              children: [
                Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.name, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text1)),
                  Text(s.code ?? 'No code', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text4), maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                Expanded(flex: 2, child: Text(marksString, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: hasGrade ? FontWeight.bold : FontWeight.normal, color: hasGrade ? AppColors.text1 : AppColors.text3))),
                Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ClipRRect(borderRadius: BorderRadius.circular(rSm), child: LinearProgressIndicator(value: hasGrade ? (percentage / 100) : 0, minHeight: 6, backgroundColor: AppColors.border, valueColor: AlwaysStoppedAnimation(meta['barColor'] as Color))),
                  const SizedBox(height: 2),
                  Text(percentageString, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
                ])),
                SizedBox(width: 60, child: appBadge(meta['label'] as String, bg: (meta['barColor'] as Color).withValues(alpha: 0.1), color: meta['barColor'] as Color)),
              ],
            ),
          );
        }),
      ])),
      const SizedBox(height: 16),

      // Overall Performance & Upcoming Tasks
      Column(children: [
        // Overall Performance Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: blueGrad(), borderRadius: BorderRadius.circular(rMd)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(_getPerformanceIcon(overallPct), color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Overall Performance: $overallPct%', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ])),
            ]),
            const SizedBox(height: 12),
            Text(_getInsightMessage(overallPct), style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)), maxLines: 2),
            const SizedBox(height: 16),

            // Stats row
            Column(children: [
              if (topSubject != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(rSm)),
                    child: Row(children: [
                      const Icon(Icons.star_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Top Subject', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.8))),
                        Text('${topSubject['name']} — ${topSubject['pct']}%', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      ])),
                    ]),
                  ),
                ),
              if (weakSubject != null && (weakSubject['pct'] as int) < 65)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(rSm)),
                    child: Row(children: [
                      const Icon(Icons.priority_high_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Focus On', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.8))),
                        Text('${weakSubject['name']} — ${weakSubject['pct']}%', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      ])),
                    ]),
                  ),
                ),
              if (excellentCount > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(rSm)),
                  child: Row(children: [
                    const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Excellent in', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.8))),
                      Text('$excellentCount Subject${excellentCount > 1 ? 's' : ''}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ])),
                  ]),
                ),
            ]),
          ]),
        ),
        const SizedBox(height: 16),

        // Upcoming Subject Tasks
        appCard(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('UPCOMING SUBJECT TASKS', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.teal, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          if (_upcoming.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Center(child: Text('No upcoming tasks.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3)))),
          ..._upcoming.take(3).map((task) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(rSm)),
                child: const Icon(Icons.assignment_rounded, size: 16, color: AppColors.teal),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(task.title, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.text1), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('Due ${task.dueDate ?? "TBD"}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
              ])),
            ]),
          )).toList(),
        ])),
        const SizedBox(height: 16),
      ]),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ASSIGNMENTS — student module with tabs and file upload support
// ─────────────────────────────────────────────────────────────────────────────

class _Assignments extends StatefulWidget {
  const _Assignments();
  @override
  State<_Assignments> createState() => _AssignmentsState();
}

class _AssignmentsState extends State<_Assignments> {
  List<SchoolAssignment> _assignments = [];
  List<AssignmentSubmission> _submissions = [];
  bool _loading = true;
  String? _error;
  int _activeTab = 0;

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
      final results = await Future.wait([
        ApiService().getStudentAssignments(),
        ApiService().getStudentSubmissions(),
      ]);

      if (!mounted) return;

      setState(() {
        _assignments = (results[0] as PaginatedResult<SchoolAssignment>).results;
        _submissions = (results[1] as PaginatedResult<AssignmentSubmission>).results;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Map<String, AssignmentSubmission> get _submissionMap {
    return {for (final s in _submissions) s.assignmentId: s};
  }

  Color _statusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('pending')) return AppColors.amber;
    if (lower.contains('late')) return AppColors.red;
    if (lower.contains('submitted')) return AppColors.blue;
    if (lower.contains('graded')) return AppColors.green;
    return AppColors.slate;
  }

  Color _statusBg(String status) => _statusColor(status).withAlpha((0.12 * 255).round());

  Future<void> _showSubmitSheet(SchoolAssignment assignment) async {
    XFile? pickedFile;
    bool uploading = false;
    String? uploadError;

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          final navigator = Navigator.of(context);
          return Container(
            margin: const EdgeInsets.only(top: 80),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Submit Assignment', style: GoogleFonts.dmSerifDisplay(fontSize: 22, color: AppColors.text1)),
                const SizedBox(height: 4),
                Text(assignment.title, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)),
                const SizedBox(height: 16),
                Text('Choose a file to upload', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text1)),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(rMd),
                  ),
                  child: Text(
                    pickedFile?.name ?? 'Tap to select an image or document',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3),
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: uploading
                          ? null
                          : () async {
                              final picker = ImagePicker();
                              final file = await picker.pickImage(source: ImageSource.gallery);
                              if (file != null) {
                                setSheetState(() => pickedFile = file);
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rMd)),
                        foregroundColor: AppColors.text1,
                      ),
                      child: Text('Choose File', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                Text(
                  'Supported formats: JPG, PNG, PDF. Submission goes through the student upload flow on the backend.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3),
                ),
                if (uploadError != null) ...[
                  const SizedBox(height: 10),
                  Text(uploadError!, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.red)),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: uploading
                        ? null
                        : () async {
                            if (pickedFile == null) {
                              setSheetState(() => uploadError = 'Choose a file before uploading.');
                              return;
                            }
                            final studentId = AppStore.instance.studentProfileId;
                            if (studentId == null) {
                              setSheetState(() => uploadError = 'Unable to submit assignment: missing student profile.');
                              return;
                            }
                            setSheetState(() {
                              uploading = true;
                              uploadError = null;
                            });
                            try {
                              final bytes = await pickedFile!.readAsBytes();
                              final contentType = pickedFile!.mimeType ?? 'application/octet-stream';
                              await ApiService().submitAssignmentFile(
                                assignmentId: assignment.id,
                                studentId: studentId,
                                fileName: pickedFile!.name,
                                bytes: bytes,
                                contentType: contentType,
                              );
                              navigator.pop(true);
                            } catch (e) {
                              setSheetState(() {
                                uploadError = 'Upload failed: $e';
                                uploading = false;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rMd)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: uploading
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Upload Submission', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: uploading ? null : () => navigator.pop(false),
                    child: Text('Cancel', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );

    if (submitted == true) {
      await _loadData();
      if (!mounted) return;
      showToast(context, 'Submitted ${assignment.title} successfully.');
    }
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return appBadge(status, bg: _statusBg(status), color: color);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        pageTitle('Assignments & Submissions', subtitle: 'Upload your work and keep track of what you submitted'),
        const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
      ]);
    }

    final assignments = _assignments;
    final submissions = _submissions;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Assignments & Submissions', subtitle: 'Upload your work and keep track of what you submitted'),
      const SizedBox(height: 16),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          _buildTab('Assignments (${assignments.length})', 0),
          const SizedBox(width: 10),
          _buildTab('My Submissions (${submissions.length})', 1),
        ]),
      ),
      const SizedBox(height: 12),

      if (_error != null)
        appCard(Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Unable to load assignments: $_error', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.red)),
        )),

      if (_activeTab == 0) ...[
        if (assignments.isEmpty)
          appCard(Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No assignments yet.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3))))),
        if (assignments.isNotEmpty) ...assignments.map((assignment) => _buildAssignmentCard(assignment)).toList(),
      ] else ...[
        if (submissions.isEmpty)
          appCard(Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No submissions yet.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3))))),
        if (submissions.isNotEmpty) ...submissions.map((submission) => _buildSubmissionCard(submission)).toList(),
      ],

      const SizedBox(height: 20),
    ]);
  }

  Widget _buildTab(String label, int index) {
    final active = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.navy : AppColors.surface,
            borderRadius: BorderRadius.circular(rMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.text1)),
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(SchoolAssignment assignment) {
    final submission = _submissionMap[assignment.id];
    final status = assignment.status?.isNotEmpty == true ? assignment.status! : (submission != null ? 'Submitted' : 'Pending');
    final alreadySubmitted = submission != null || ['submitted', 'graded'].contains(status.toLowerCase());

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(rMd),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          appBadge(assignment.subjectName ?? 'Subject', bg: AppColors.blueLight, color: AppColors.blue),
          _statusBadge(status),
        ]),
        const SizedBox(height: 12),
        Text(assignment.title, style: GoogleFonts.dmSerifDisplay(fontSize: 18, color: AppColors.text1)),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.text3),
          const SizedBox(width: 6),
          Text(
            assignment.dueDate != null ? 'Due ${assignment.dueDate}' : 'Due date not set',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3),
          ),
        ]),
        if (assignment.description != null && assignment.description!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(assignment.description!, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text2, height: 1.5)),
        ],
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: alreadySubmitted ? null : () => _showSubmitSheet(assignment),
              style: ElevatedButton.styleFrom(
                backgroundColor: alreadySubmitted ? AppColors.slate : AppColors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rMd)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(alreadySubmitted ? 'Already Submitted' : 'Submit Now', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _buildSubmissionCard(AssignmentSubmission submission) {
    final assignmentTitle = submission.assignmentTitle ?? 'Assignment';
    final status = submission.status ?? 'Submitted';
    final submittedAt = submission.submittedAt != null ? _formatDate(submission.submittedAt!) : 'Unknown date';
    final gradeValue = submission.grade ?? submission.marksObtained;
    final gradeLabel = gradeValue != null ? '${gradeValue.toStringAsFixed(1)}' : 'Pending';

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(rMd),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(assignmentTitle, style: GoogleFonts.dmSerifDisplay(fontSize: 16, color: AppColors.text1)),
          _statusBadge(status),
        ]),
        const SizedBox(height: 10),
        Text('Submitted: $submittedAt', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3)),
        const SizedBox(height: 8),
        Text('Grade: $gradeLabel', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text2)),
      ]),
    );
  }

  String _formatDate(String raw) {
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GRADES — live API when authenticated
// ─────────────────────────────────────────────────────────────────────────────

class _Grades extends StatefulWidget {
  const _Grades();
  @override
  State<_Grades> createState() => _GradesState();
}

class _GradesState extends State<_Grades> {
  List<StudentGrade> _grades = [];
  ReportCardData? _reportCard;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!TokenStore.hasTokens) {
      setState(() => _loading = false);
      return;
    }
    try {
      final results = await Future.wait([
        ApiService().getStudentGrades(),
        ApiService().getReportCard(),
      ]);
      if (mounted) setState(() { 
        _grades = (results[0] as PaginatedResult<StudentGrade>).results; 
        _reportCard = results[1] as ReportCardData;
        _loading = false; 
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        pageTitle('Academic Report Card'),
        const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
      ]);
    }

    final overallPct = _reportCard?.overallPercentage ?? 0.0;
    String overallGrade = '—';
    if (overallPct >= 90) overallGrade = 'A+';
    else if (overallPct >= 80) overallGrade = 'A';
    else if (overallPct >= 70) overallGrade = 'B+';
    else if (overallPct >= 60) overallGrade = 'B';
    else if (overallPct >= 50) overallGrade = 'C';
    else if (overallPct > 0) overallGrade = 'D';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Academic Report Card'),
      
      // Top GPA Banner
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: blueGrad(), borderRadius: BorderRadius.circular(rMd)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cumulative GPA', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                const SizedBox(height: 4),
                Text(overallGrade, style: GoogleFonts.dmSerifDisplay(fontSize: 32, color: Colors.white)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Overall Percentage', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                const SizedBox(height: 4),
                Text('${overallPct.toStringAsFixed(1)}%', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      if (_grades.isEmpty) appCard(Padding(padding: const EdgeInsets.all(20), child: Center(child: Text(
        'No grades available yet. Results will appear here once published.',
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3),
      )))),
      
      if (_grades.isNotEmpty)
        appCard(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text('SUBJECT', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.text3))),
                  Expanded(flex: 2, child: Text('EXAM', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.text3))),
                  Expanded(flex: 2, child: Text('SCORE', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.text3))),
                  const SizedBox(width: 40, child: Text('GRADE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.text3))),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            ..._grades.map((g) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(g.subjectName ?? 'Subject', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text1))),
                    Expanded(flex: 2, child: Text(g.examName ?? 'Exam', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text2))),
                    Expanded(flex: 2, child: Text('${g.marksObtained.toStringAsFixed(1)}/${g.maxMarks.toStringAsFixed(1)}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text2))),
                    SizedBox(width: 40, child: appBadge(g.gradeLetter, bg: AppColors.blueLight, color: AppColors.blue)),
                  ],
                ),
              );
            }),
          ],
        )),
      const SizedBox(height: 16),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ATTENDANCE — live API when authenticated
// ─────────────────────────────────────────────────────────────────────────────

class _Attendance extends StatefulWidget {
  const _Attendance();
  @override
  State<_Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<_Attendance> {
  AttendanceSummaryData? _summary;
  List<AttendanceRecord> _records = [];
  List<AcademicYear> _academicYears = [];
  List<Subject> _subjects = [];
  
  DateTime _currentDate = DateTime.now();
  String _selectedYear = '';
  String _selectedSubject = '';
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!TokenStore.hasTokens) {
      setState(() => _loading = false);
      return;
    }
    try {
      final results = await Future.wait([
        ApiService().getAttendanceSummary(),
        ApiService().getStudentAttendanceRecords(),
        ApiService().getAcademicYears(),
        ApiService().getStudentSubjects(),
      ]);
      if (mounted) {
        setState(() {
          _summary = results[0] as AttendanceSummaryData;
          _records = (results[1] as PaginatedResult<AttendanceRecord>).results;
          _academicYears = (results[2] as PaginatedResult<AcademicYear>).results;
          _subjects = (results[3] as PaginatedResult<Subject>).results;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Get color for attendance status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present': return AppColors.green;
      case 'Absent': return AppColors.red;
      case 'Late': return AppColors.amber;
      default: return AppColors.slate;
    }
  }

  /// Get background color for calendar cell
  Color _getCellBgColor(String status) {
    switch (status) {
      case 'Present': return AppColors.greenLight;
      case 'Absent': return AppColors.redLight;
      case 'Late': return AppColors.amberLight;
      default: return AppColors.surface;
    }
  }

  /// Get border color for calendar cell
  Color _getCellBorderColor(String status) {
    switch (status) {
      case 'Present': return AppColors.green;
      case 'Absent': return AppColors.red;
      case 'Late': return AppColors.amber;
      default: return AppColors.border;
    }
  }

  /// Build attendance map for the current month
  Map<String, AttendanceRecord> _buildAttendanceMap() {
    final filtered = _records.where((r) {
      if (r.date == null) return false;
      final date = DateTime.tryParse(r.date!);
      if (date == null) return false;
      if (date.year != _currentDate.year || date.month != _currentDate.month) return false;
      return true;
    }).toList();

    final map = <String, AttendanceRecord>{};
    for (final record in filtered) {
      if (record.date != null) {
        final parsed = DateTime.tryParse(record.date!);
        if (parsed != null) {
          final key = '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
          map[key] = record;
        }
      }
    }
    return map;
  }

  /// Calculate monthly attendance breakdown
  Map<String, int> _getMonthlyBreakdown() {
    final breakdown = { 'Present': 0, 'Absent': 0, 'Late': 0 };
    for (final record in _records) {
      if (record.date != null) {
        final date = DateTime.tryParse(record.date!);
        if (date != null && date.year == _currentDate.year && date.month == _currentDate.month) {
          if (breakdown.containsKey(record.status)) {
            breakdown[record.status] = (breakdown[record.status] ?? 0) + 1;
          }
        }
      }
    }
    return breakdown;
  }

  /// Build calendar grid for current month
  List<Widget> _buildCalendarGrid() {
    final year = _currentDate.year;
    final month = _currentDate.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday % 7; // 0 = Sunday
    
    final attendanceMap = _buildAttendanceMap();
    final cells = <Widget>[];

    // Weekday headers
    const weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    for (final label in weekdayLabels) {
      cells.add(Center(child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.text3))));
    }

    // Empty cells for days before month starts
    for (var i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }

    // Calendar day cells
    for (var day = 1; day <= daysInMonth; day++) {
      final dateKey = '${year}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      final record = attendanceMap[dateKey];
      final status = record?.status ?? '';
      final bgColor = status.isNotEmpty ? _getCellBgColor(status) : AppColors.surface2;
      final borderColor = status.isNotEmpty ? _getCellBorderColor(status) : AppColors.border2;

      cells.add(
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(rSm),
          ),
          child: Center(child: Text('$day', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.text1))),
        ),
      );
    }

    return cells;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        pageTitle('Attendance'),
        const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
      ]);
    }

    final minRequirement = 75;
    final attendance = _summary?.attendancePercentage.round() ?? 0;
    final attendanceDiff = attendance - minRequirement;
    final requirementMet = attendance >= minRequirement;
    final monthlyBreakdown = _getMonthlyBreakdown();
    final monthName = _getMonthName(_currentDate.month);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Attendance'),
      
      // Filters
      Column(children: [
        Row(children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(rMd)),
              child: DropdownButton<String>(
                value: _selectedYear,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                hint: Text('All Academic Years', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
                items: [
                  DropdownMenuItem(value: '', child: Text('All Academic Years', style: GoogleFonts.plusJakartaSans(fontSize: 11))),
                  ..._academicYears.map((y) => DropdownMenuItem(value: y.id, child: Text(y.name, style: GoogleFonts.plusJakartaSans(fontSize: 11)))),
                ],
                onChanged: (v) => setState(() => _selectedYear = v ?? ''),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(rMd)),
              child: DropdownButton<String>(
                value: _selectedSubject,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                hint: Text('All Subjects', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
                items: [
                  DropdownMenuItem(value: '', child: Text('All Subjects', style: GoogleFonts.plusJakartaSans(fontSize: 11))),
                  ..._subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, style: GoogleFonts.plusJakartaSans(fontSize: 11)))),
                ],
                onChanged: (v) => setState(() => _selectedSubject = v ?? ''),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
      ]),

      // Overall Attendance Card
      appCard(Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(rMd)),
            child: const Icon(Icons.analytics_rounded, color: AppColors.blue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Overall Attendance', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.text3)),
            const SizedBox(height: 4),
            Row(children: [
              Text('$attendance%', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text1)),
              const SizedBox(width: 12),
              Expanded(child: Column(children: [
                ClipRRect(borderRadius: BorderRadius.circular(rSm), child: LinearProgressIndicator(value: attendance / 100, minHeight: 4, backgroundColor: AppColors.border, valueColor: const AlwaysStoppedAnimation(AppColors.blue))),
                const SizedBox(height: 2),
                Text('$attendance% of 100%', style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.text3)),
              ])),
            ]),
          ])),
        ]),
      )),
      const SizedBox(height: 12),

      // Min. Requirement Card
      appCard(Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Color(0xFFEDE7FF), borderRadius: BorderRadius.circular(rMd)),
            child: const Icon(Icons.gavel_rounded, color: Color(0xFF7C3AED), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Min. Requirement', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.text3)),
            const SizedBox(height: 4),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$minRequirement%', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text1)),
                Text('${attendanceDiff.abs()}% ${requirementMet ? 'above' : 'below'} limit', style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.text3)),
              ]),
              const Spacer(),
              appBadge(
                requirementMet ? 'Met' : 'Not Met',
                bg: requirementMet ? AppColors.greenLight : AppColors.redLight,
                color: requirementMet ? AppColors.green : AppColors.red,
              ),
            ]),
          ])),
        ]),
      )),
      const SizedBox(height: 12),

      // Monthly Breakdown Card
      appCard(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Monthly Breakdown', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.text3)),
            Text('$monthName ${_currentDate.year}', style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.text4)),
            const SizedBox(height: 12),
            if (monthlyBreakdown['Present'] == 0 && monthlyBreakdown['Absent'] == 0 && monthlyBreakdown['Late'] == 0)
              Center(child: Text('No data for this month', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3)))
            else
              SizedBox(
                height: 80,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _buildBreakdownBar('Present', monthlyBreakdown['Present'] ?? 0, AppColors.green, monthlyBreakdown),
                  _buildBreakdownBar('Absent', monthlyBreakdown['Absent'] ?? 0, AppColors.red, monthlyBreakdown),
                  _buildBreakdownBar('Late', monthlyBreakdown['Late'] ?? 0, AppColors.amber, monthlyBreakdown),
                ]),
              ),
          ]),
        ),
      ])),
      const SizedBox(height: 12),

      // Visual Presence Calendar
      appCard(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$monthName ${_currentDate.year}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text1)),
              Text('Visual Presence Log', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text3)),
            ]),
            Row(children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                iconSize: 20,
                onPressed: () => setState(() => _currentDate = DateTime(_currentDate.year, _currentDate.month - 1)),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                iconSize: 20,
                onPressed: () => setState(() => _currentDate = DateTime(_currentDate.year, _currentDate.month + 1)),
              ),
            ]),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1,
            children: _buildCalendarGrid(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),
            Wrap(spacing: 16, runSpacing: 12, children: [
              _legendItem('Present', AppColors.green),
              _legendItem('Absent', AppColors.red),
              _legendItem('Late', AppColors.amber),
              _legendItem('No Record', AppColors.slate),
            ]),
          ]),
        ),
      ])),
      const SizedBox(height: 12),

      // Recent Attendance Log
      secLabel('Recent Attendance Log'),
      appCard(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_records.isEmpty)
            Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No attendance records found.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3))))
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text('DATE', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.text3))),
                  Expanded(flex: 2, child: Text('STATUS', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.text3))),
                  Expanded(flex: 2, child: Text('NOTES', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.text3))),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            ..._records.take(10).map((r) {
              final statusColor = _getStatusColor(r.status);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(r.date ?? 'Unknown', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.text1))),
                    Expanded(flex: 2, child: appBadge(r.status, bg: statusColor.withValues(alpha: 0.1), color: statusColor)),
                    Expanded(flex: 2, child: Text(r.remarks ?? '—', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text2))),
                  ],
                ),
              );
            }).toList(),
          ]
        ],
      )),
      const SizedBox(height: 16),
    ]);
  }

  /// Build a breakdown bar for monthly statistics
  Widget _buildBreakdownBar(String label, int count, Color color, Map<String, int> breakdown) {
    final total = (breakdown['Present'] ?? 0) + (breakdown['Absent'] ?? 0) + (breakdown['Late'] ?? 0);
    final heightPercent = total > 0 ? ((count / total) * 100) : 0.0;

    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Text('$count', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 4),
      Container(
        width: 20,
        height: 40,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(rSm)),
        child: Stack(alignment: Alignment.bottomCenter, children: [
          Container(
            width: 20,
            height: (heightPercent / 100) * 40,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(rSm)),
          ),
        ]),
      ),
      const SizedBox(height: 4),
      Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.text3)),
    ]);
  }

  /// Build legend item for calendar
  Widget _legendItem(String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      ),
      const SizedBox(width: 6),
      Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text3)),
    ]);
  }

  /// Get month name
  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TIMETABLE — static (no backend endpoint yet)
// ─────────────────────────────────────────────────────────────────────────────

class _Timetable extends StatelessWidget {
  const _Timetable();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Timetable'),
    appCard(Padding(padding: const EdgeInsets.all(20), child: Center(child: Text(
      'Feature Not Supported By Backend Yet',
      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.red),
    )))),
    const SizedBox(height: 16),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// MATERIALS — static (no backend endpoint yet)
// ─────────────────────────────────────────────────────────────────────────────

class _Materials extends StatelessWidget {
  const _Materials();
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Learning Materials'),
      appCard(Padding(padding: const EdgeInsets.all(20), child: Center(child: Text(
        'Feature Not Supported By Backend Yet',
        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.red),
      )))),
      const SizedBox(height: 16),
    ]);
  }
}
