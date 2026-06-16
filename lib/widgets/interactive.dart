// ─────────────────────────────────────────────────────────────────────────────
// INTERACTIVE LAYER — all modal sheets, dialogs, and stateful features
// New admin modals (add profile, academic setup, role management, mapping) use
// real backend API calls. Legacy modals still use AppStore for demo mode.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/app_store.dart';
import '../services/api_service.dart' hide Exam;
import '../services/ai_service.dart';
import '../services/db_service.dart';
import 'builders.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SHEET OPENER
// ─────────────────────────────────────────────────────────────────────────────

Future<T?> showSheet<T>(BuildContext ctx, Widget child, {bool tall = false}) =>
    showModalBottomSheet<T>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: tall ? 0.92 : 0.72,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, sc) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(rXl)),
          ),
          child: Column(children: [
            const SizedBox(height: 12),
            Container(width: 36, height: 4,
                decoration: BoxDecoration(color: AppColors.border2,
                    borderRadius: BorderRadius.circular(rFull))),
            const SizedBox(height: 4),
            Expanded(child: SingleChildScrollView(
                controller: sc, child: child)),
          ]),
        ),
      ),
    );

// ─────────────────────────────────────────────────────────────────────────────
// TOAST
// ─────────────────────────────────────────────────────────────────────────────

void showToast(BuildContext ctx, String msg,
    {Color color = AppColors.green, IconData icon = Icons.check_circle_rounded}) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 2),
    content: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1060),
        borderRadius: BorderRadius.circular(rLg),
        boxShadow: shadowMd,
      ),
      child: Row(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: GoogleFonts.plusJakartaSans(
            fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white))),
      ]),
    ),
  ));
}

// ─────────────────────────────────────────────────────────────────────────────
// CONFIRM DIALOG
// ─────────────────────────────────────────────────────────────────────────────

Future<bool> confirmDialog(BuildContext ctx,
    {required String title, required String body, String confirm = 'Confirm',
     Color confirmColor = AppColors.red}) async {
  final result = await showDialog<bool>(
    context: ctx,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rLg)),
      title: Text(title, style: GoogleFonts.dmSerifDisplay(fontSize: 18, color: AppColors.text1)),
      content: Text(body, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3, height: 1.5)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text3))),
        TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirm, style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w700, color: confirmColor))),
      ],
    ),
  );
  return result ?? false;
}

// ═════════════════════════════════════════════════════════════════════════════
// TEACHER MODALS
// ═════════════════════════════════════════════════════════════════════════════

// ── Create Assignment ──────────────────────────────────────────────────────

Future<void> showCreateAssignment(BuildContext ctx, {VoidCallback? onDone}) async {
  await showSheet(ctx, _CreateAssignmentSheet(), tall: true);
  if (onDone != null) onDone();
}

class _CreateAssignmentSheet extends StatefulWidget {
  @override
  State<_CreateAssignmentSheet> createState() => _CreateAssignmentSheetState();
}
class _CreateAssignmentSheetState extends State<_CreateAssignmentSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _dueCtrl   = TextEditingController();
  
  List<TeacherAssignment> _classes = [];
  String? _selectedClassId;
  
  bool _loading = false;
  bool _done    = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClasses();
    final now = DateTime.now().add(const Duration(days: 7));
    _dueCtrl.text = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }

  Future<void> _loadClasses() async {
    if (!TokenStore.hasTokens) return;
    try {
      final ctx = await ApiService().getProfileContext();
      if (ctx.profiles.teacher.id != null) {
        final res = await ApiService().getTeacherAssignments(teacherId: ctx.profiles.teacher.id, status: 'current');
        if (mounted) setState(() {
          _classes = res.results;
          _selectedClassId = res.results.isNotEmpty ? res.results.first.id : null;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); _dueCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      showToast(context, 'Please enter a title', color: AppColors.red, icon: Icons.error_outline_rounded);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      if (TokenStore.hasTokens && _selectedClassId != null) {
        final selectedClass = _classes.firstWhere((c) => c.id == _selectedClassId);
        final me = await ApiService().getMe();
        try {
          await DbService.createAssignment(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            subjectId: selectedClass.subjectId!,
            sectionId: selectedClass.sectionId!,
            teacherId: me.id,
            schoolId: me.schoolId ?? '',
            dueDate: DateTime.parse(_dueCtrl.text.trim()),
          );
        } catch (e) {
          throw ApiException('Failed to create assignment in DB: $e');
        }
      }
      
      AppStore.instance.prependActivity('Assignment Created', _titleCtrl.text.trim());
      
      if (mounted) setState(() { _done = true; _loading = false; });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Assignment Created!',
        'Students have been notified.', Icons.note_add_rounded);

    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Create Assignment', Icons.note_add_rounded, AppColors.blue),
        const SizedBox(height: 20),
        _label('Title'),
        _tf(_titleCtrl, 'e.g. Chapter 5: Forces Lab Report'),
        
        if (_classes.isNotEmpty) ...[
          _label('Class'),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(rMd)),
            child: DropdownButtonHideUnderline(child: DropdownButton<String>(
              value: _selectedClassId,
              isExpanded: true,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text1),
              items: _classes.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.subjectName ?? "Subject"} ${c.classLevelName?.replaceAll("Grade ", "") ?? ""}-${c.sectionName ?? ""}'))).toList(),
              onChanged: (v) => setState(() => _selectedClassId = v),
            )),
          ),
        ],
        
        _label('Due Date (YYYY-MM-DD)'),
        _tf(_dueCtrl, '2025-04-20'),
        _label('Instructions (optional)'),
        _tf(_descCtrl, 'Write detailed instructions here...', lines: 3),
        
        if (_error != null) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.redLight, borderRadius: BorderRadius.circular(rMd)),
            child: Text(_error!, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.red))),
        ],
        
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _loading ? null : _submit,
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.gradA, AppColors.gradC]), borderRadius: BorderRadius.circular(rMd), boxShadow: shadowMd),
            child: Center(child: _loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Create Assignment', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)))),
        ),
      ]),
    );
  }
}

// ── Announce ───────────────────────────────────────────────────────────────

void showAnnounce(BuildContext ctx) => showSheet(ctx, _AnnounceSheet(), tall: true);

class _AnnounceSheet extends StatefulWidget {
  @override
  State<_AnnounceSheet> createState() => _AnnounceSheetState();
}
class _AnnounceSheetState extends State<_AnnounceSheet> {
  final _msgCtrl = TextEditingController();
  String _audience = 'All My Classes';
  bool   _done = false;

  @override
  void dispose() { _msgCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Announcement Sent!',
        'Notified: $_audience', Icons.campaign_rounded);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Post Announcement', Icons.campaign_rounded, AppColors.red),
        const SizedBox(height: 20),
        _label('Send To'),
        _dropdown(_audience, ['All My Classes','Science 10-A','Physics 11-B','Chemistry 12'],
            (v) => setState(() => _audience = v!)),
        _label('Message'),
        _tf(_msgCtrl, 'Type your announcement...', lines: 4),
        const SizedBox(height: 24),
        navyBtn('Post Announcement', onTap: () {
          if (_msgCtrl.text.trim().isEmpty) {
            showToast(context, 'Message cannot be empty', color: AppColors.red, icon: Icons.error_outline_rounded);
            return;
          }
          AppStore.instance.addAnnouncement(Announcement(
            id: AppStore.nextId(),
            audience: _audience,
            message: _msgCtrl.text.trim(),
            time: 'Just now',
          ));
          AppStore.instance.prependActivity('Announcement Posted', '\$_audience · \${_msgCtrl.text.trim().substring(0, _msgCtrl.text.trim().length.clamp(0, 40))}…');
          setState(() => _done = true);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context);
          });
        }),
      ]),
    );
  }
}

// ── Schedule Exam ──────────────────────────────────────────────────────────

void showScheduleExam(BuildContext ctx, {VoidCallback? onDone}) => showSheet(ctx, _ScheduleExamSheet(onDone: onDone), tall: true);

class _ScheduleExamSheet extends StatefulWidget {
  final VoidCallback? onDone;
  const _ScheduleExamSheet({this.onDone});
  @override
  State<_ScheduleExamSheet> createState() => _ScheduleExamSheetState();
}
class _ScheduleExamSheetState extends State<_ScheduleExamSheet> {
  final _nameCtrl  = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl   = TextEditingController();
  List<AcademicYear> _years = [];
  String? _selectedYearId;
  bool   _loading = false;
  bool   _done    = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadYears();
    final now = DateTime.now();
    final fmt = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
    _startCtrl.text = fmt;
    _endCtrl.text = fmt;
  }

  Future<void> _loadYears() async {
    if (!TokenStore.hasTokens) return;
    try {
      final res = await ApiService().getAcademicYears();
      if (mounted) setState(() {
        _years = res.results;
        _selectedYearId = res.results.isNotEmpty ? res.results.first.id : null;
      });
    } catch (_) {}
  }

  @override
  void dispose() { _nameCtrl.dispose(); _startCtrl.dispose(); _endCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Exam name is required.'); return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      if (TokenStore.hasTokens && _selectedYearId != null) {
        await ApiService().createExam({
          'name':          _nameCtrl.text.trim(),
          'academic_year': _selectedYearId!,
          'start_date':    _startCtrl.text.trim(),
          'end_date':      _endCtrl.text.trim(),
          'is_published':  false,
        });
      }
      // Also update AppStore for demo/offline mode
      AppStore.instance.addExam(Exam(
        id: AppStore.nextId(),
        sub: 'EXAM',
        title: _nameCtrl.text.trim(),
        dateStr: _startCtrl.text,
        room: 'TBD',
        status: 'Upcoming',
        type: 'Written',
      ));
      AppStore.instance.prependActivity('Exam Scheduled', _nameCtrl.text.trim());
      if (mounted) setState(() { _done = true; _loading = false; });
      widget.onDone?.call();
      Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.pop(context); });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Exam Scheduled!', _nameCtrl.text.trim(), Icons.edit_calendar_rounded);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Schedule Exam', Icons.edit_calendar_rounded, AppColors.amber),
        const SizedBox(height: 20),
        _label('Exam Name'),
        _tf(_nameCtrl, 'e.g. Mid-Term Examination'),
        if (_years.isNotEmpty) ...[
          _label('Academic Year'),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(rMd)),
            child: DropdownButtonHideUnderline(child: DropdownButton<String>(
              value: _selectedYearId,
              isExpanded: true,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text1),
              items: _years.map((y) => DropdownMenuItem(value: y.id, child: Text(y.name))).toList(),
              onChanged: (v) => setState(() => _selectedYearId = v),
            )),
          ),
        ],
        _label('Start Date (YYYY-MM-DD)'),
        _tf(_startCtrl, '2025-04-22'),
        _label('End Date (YYYY-MM-DD)'),
        _tf(_endCtrl, '2025-04-22'),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.redLight, borderRadius: BorderRadius.circular(rMd)),
            child: Text(_error!, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.red))),
        ],
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _loading ? null : _submit,
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.gradA, AppColors.gradC]), borderRadius: BorderRadius.circular(rMd), boxShadow: shadowMd),
            child: Center(child: _loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Schedule Exam', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)))),
        ),
      ]),
    );
  }
}

// ── Publish Grades ─────────────────────────────────────────────────────────

void showPublishGrades(BuildContext ctx, String className) async {
  final ok = await confirmDialog(ctx,
      title: 'Publish Grades?',
      body: 'This will make grades for $className visible to students and parents.',
      confirm: 'Publish', confirmColor: AppColors.green);
  if (ok && ctx.mounted) {
    showToast(ctx, 'Grades published for $className', color: AppColors.green);
  }
}

// ── Save Attendance ────────────────────────────────────────────────────────

void showAttendanceSaved(BuildContext ctx) {
  showToast(ctx, 'Attendance saved successfully');
}

// ═════════════════════════════════════════════════════════════════════════════
// STUDENT MODALS
// ═════════════════════════════════════════════════════════════════════════════

// ── Submit Assignment ──────────────────────────────────────────────────────

void showSubmitAssignment(BuildContext ctx, String title) {
  showSheet(ctx, _SubmitAssignmentSheet(title: title));
}

class _SubmitAssignmentSheet extends StatefulWidget {
  final String title;
  const _SubmitAssignmentSheet({required this.title});
  @override
  State<_SubmitAssignmentSheet> createState() => _SubmitAssignmentSheetState();
}
class _SubmitAssignmentSheetState extends State<_SubmitAssignmentSheet> {
  final _noteCtrl = TextEditingController();
  bool _done = false;

  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Assignment Submitted!',
        widget.title, Icons.check_circle_rounded);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Submit Assignment', Icons.upload_file_rounded, AppColors.blue),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(rMd),
              border: Border.all(color: AppColors.border)),
          child: Text(widget.title, style: GoogleFonts.plusJakartaSans(
              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
        ),
        const SizedBox(height: 16),
        // Simulated file attachment
        GestureDetector(
          onTap: () => showToast(context, 'File picker would open here',
              color: AppColors.blue, icon: Icons.folder_open_rounded),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border2, width: 1.5),
              borderRadius: BorderRadius.circular(rMd),
              color: AppColors.bg,
            ),
            child: Column(children: [
              const Icon(Icons.upload_file_rounded, size: 28, color: AppColors.text4),
              const SizedBox(height: 6),
              Text('Tap to attach file', style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: AppColors.text4)),
              Text('PDF, DOC, DOCX, ZIP', style: GoogleFonts.plusJakartaSans(
                  fontSize: 10, color: AppColors.text4)),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        _label('Note to teacher (optional)'),
        _tf(_noteCtrl, 'Add a note...', lines: 2),
        const SizedBox(height: 24),
        navyBtn('Submit Assignment', onTap: () {
          setState(() => _done = true);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context);
          });
        }),
      ]),
    );
  }
}

// ── Download Material ──────────────────────────────────────────────────────

void showDownloadMaterial(BuildContext ctx, String name) async {
  showToast(ctx, 'Downloading $name…', color: AppColors.teal, icon: Icons.download_rounded);
  await Future.delayed(const Duration(seconds: 2));
  if (ctx.mounted) showToast(ctx, '$name saved to Downloads', color: AppColors.green);
}

// ── Ask AI ─────────────────────────────────────────────────────────────────

void showAiChat(BuildContext ctx) => showSheet(ctx, const _AiChatSheet(), tall: true);

class _AiChatSheet extends StatefulWidget {
  const _AiChatSheet();
  @override
  State<_AiChatSheet> createState() => _AiChatSheetState();
}
class _AiChatSheetState extends State<_AiChatSheet> {
  final _ctrl  = TextEditingController();
  final _scroll = ScrollController();
  final _msgs  = <_ChatMsg>[
    const _ChatMsg(false, "Hi! I'm your AI study assistant. Ask me anything about your subjects, assignments, or exam prep."),
  ];
  bool _thinking = false;

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    setState(() {
      _msgs.add(_ChatMsg(true, text));
      _thinking = true;
    });
    _scrollDown();
    
    // Call real API
    final reply = await AiService.askDeepSeek(text);
    
    if (!mounted) return;
    setState(() {
      _msgs.add(_ChatMsg(false, reply));
      _thinking = false;
    });
    _scrollDown();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            gradient: blueGrad(),
            borderRadius: BorderRadius.circular(rMd),
          ),
          child: const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AI Study Assistant', style: GoogleFonts.dmSerifDisplay(fontSize: 16, color: AppColors.text1)),
          Text('Powered by Academic Architect AI', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4)),
        ]),
      ]),
    ),
    const Divider(height: 1, color: AppColors.border),
    SizedBox(
      height: 340,
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.all(16),
        itemCount: _msgs.length + (_thinking ? 1 : 0),
        itemBuilder: (_, i) {
          if (_thinking && i == _msgs.length) return _typingBubble();
          final m = _msgs[i];
          return _bubble(m);
        },
      ),
    ),
    const Divider(height: 1, color: AppColors.border),
    Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Row(children: [
        Expanded(child: TextField(
          controller: _ctrl,
          onSubmitted: (_) => _send(),
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text1),
          decoration: InputDecoration(
            hintText: 'Ask anything…',
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text4),
            filled: true, fillColor: AppColors.bg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(rFull),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rFull),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rFull),
                borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
          ),
        )),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _send,
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(gradient: blueGrad(), shape: BoxShape.circle),
            child: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
          ),
        ),
      ]),
    ),
  ]);

  Widget _bubble(_ChatMsg m) => Align(
    alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: m.isUser ? AppColors.navy : AppColors.blueLight,
        borderRadius: BorderRadius.circular(rLg),
      ),
      child: Text(m.text, style: GoogleFonts.plusJakartaSans(
          fontSize: 12, color: m.isUser ? Colors.white : AppColors.text1, height: 1.5)),
    ),
  );

  Widget _typingBubble() => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(rLg)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _dot(0), const SizedBox(width: 4),
        _dot(1), const SizedBox(width: 4),
        _dot(2),
      ]),
    ),
  );

  Widget _dot(int i) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: Duration(milliseconds: 400 + i * 150),
    curve: Curves.easeInOut,
    builder: (_, v, __) => Opacity(
      opacity: v,
      child: Container(width: 6, height: 6,
          decoration: const BoxDecoration(color: AppColors.blue, shape: BoxShape.circle)),
    ),
  );
}

class _ChatMsg {
  final bool isUser;
  final String text;
  const _ChatMsg(this.isUser, this.text);
}

// ═════════════════════════════════════════════════════════════════════════════
// PARENT MODALS
// ═════════════════════════════════════════════════════════════════════════════

// ── Pay Fees ───────────────────────────────────────────────────────────────

void showPayFees(BuildContext ctx,
    {String amount = '₹24,500', String desc = 'Term 2 Tuition'}) {
  showSheet(ctx, _PayFeesSheet(amount: amount, desc: desc), tall: true);
}

class _PayFeesSheet extends StatefulWidget {
  final String amount;
  final String desc;
  const _PayFeesSheet({required this.amount, required this.desc});
  @override
  State<_PayFeesSheet> createState() => _PayFeesSheetState();
}
class _PayFeesSheetState extends State<_PayFeesSheet> {
  int    _step    = 0; // 0=select method, 1=enter details, 2=processing, 3=done
  String _method  = 'UPI';

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case 3:
        return _successPanel(context, 'Payment Successful!',
            '${widget.amount} · ${widget.desc}\nRef: TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
            Icons.check_circle_rounded);
      case 2:
        return _processingPanel();
      case 1:
        return _detailsForm(context);
      default:
        return _selectMethod(context);
    }
  }

  Widget _selectMethod(BuildContext ctx) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sheetTitle('Pay Fees', Icons.payment_rounded, AppColors.navy),
      const SizedBox(height: 8),
      // Amount banner
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: blueGrad(),
          borderRadius: BorderRadius.circular(rLg),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.desc, style: GoogleFonts.plusJakartaSans(
              fontSize: 11, color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 4),
          Text(widget.amount, style: GoogleFonts.dmSerifDisplay(
              fontSize: 28, color: Colors.white)),
          Text('Due: April 15, 2025', style: GoogleFonts.plusJakartaSans(
              fontSize: 11, color: Colors.white.withOpacity(0.7))),
        ]),
      ),
      Text('SELECT PAYMENT METHOD', style: GoogleFonts.plusJakartaSans(
          fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.text4)),
      const SizedBox(height: 12),
      ...['UPI', 'Credit / Debit Card', 'Net Banking', 'Cash at Office'].map(
        (m) => GestureDetector(
          onTap: () => setState(() { _method = m; _step = 1; }),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _method == m ? AppColors.blueLight : AppColors.surface,
              border: Border.all(
                color: _method == m ? AppColors.blue : AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(rMd),
            ),
            child: Row(children: [
              Icon(_payIcon(m), size: 18, color: _method == m ? AppColors.blue : AppColors.text3),
              const SizedBox(width: 12),
              Text(m, style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: _method == m ? AppColors.blue : AppColors.text1)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 12,
                  color: _method == m ? AppColors.blue : AppColors.text4),
            ]),
          ),
        ),
      ),
    ]),
  );

  Widget _detailsForm(BuildContext ctx) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        GestureDetector(onTap: () => setState(() => _step = 0),
            child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.text2)),
        const SizedBox(width: 10),
        _sheetTitle('Pay via $_method', Icons.payment_rounded, AppColors.navy),
      ]),
      const SizedBox(height: 20),
      if (_method == 'UPI') ...[
        _label('UPI ID'),
        _tfStatic('yourname@upi'),
        _label('Amount'),
        _tfStatic(widget.amount.replaceAll('₹', '')),
      ] else if (_method == 'Credit / Debit Card') ...[
        _label('Card Number'),
        _tfStatic('•••• •••• •••• ••••'),
        _label('Card Holder Name'),
        _tfStatic(''),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('Expiry (MM/YY)'), _tfStatic(''),
          ])),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('CVV'), _tfStatic(''),
          ])),
        ]),
      ] else if (_method == 'Net Banking') ...[
        _label('Select Bank'),
        _tfStatic('SBI / HDFC / ICICI / Axis / Others'),
      ] else ...[
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.amberLight,
            borderRadius: BorderRadius.circular(rMd),
            border: Border.all(color: const Color(0xFFFCD34D)),
          ),
          child: Text('Please visit the school accounts office with cash payment of ${widget.amount}. Office hours: Mon–Fri 9AM–4PM.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.amber, height: 1.5)),
        ),
      ],
      const SizedBox(height: 24),
      navyBtn(_method == 'Cash at Office' ? 'Got It' : 'Pay ${widget.amount}',
          onTap: () async {
        if (_method == 'Cash at Office') { Navigator.pop(ctx); return; }
        setState(() => _step = 2);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _step = 3);
      }),
    ]),
  );

  Widget _processingPanel() => SizedBox(
    height: 280,
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const CircularProgressIndicator(color: AppColors.blue),
      const SizedBox(height: 20),
      Text('Processing Payment…', style: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text1)),
      const SizedBox(height: 6),
      Text('Please do not close this screen', style: GoogleFonts.plusJakartaSans(
          fontSize: 11, color: AppColors.text3)),
    ])),
  );

  IconData _payIcon(String m) {
    switch (m) {
      case 'UPI':                return Icons.qr_code_rounded;
      case 'Credit / Debit Card': return Icons.credit_card_rounded;
      case 'Net Banking':        return Icons.account_balance_rounded;
      default:                   return Icons.payments_rounded;
    }
  }
}

// ── Message Teacher ────────────────────────────────────────────────────────

void showMessageTeacher(BuildContext ctx) => showSheet(ctx, _MessageSheet(), tall: true);

class _MessageSheet extends StatefulWidget {
  @override
  State<_MessageSheet> createState() => _MessageSheetState();
}
class _MessageSheetState extends State<_MessageSheet> {
  final _msgCtrl = TextEditingController();
  String _teacher = 'Dr. Elena Vance';
  bool   _done    = false;

  @override
  void dispose() { _msgCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Message Sent!',
        'To: $_teacher · You will receive a reply via the portal.', Icons.chat_rounded);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Message Teacher', Icons.chat_rounded, AppColors.teal),
        const SizedBox(height: 20),
        _label('To'),
        _dropdown(_teacher, ['Dr. Elena Vance','Mr. James Hoang','Ms. Sarah Kim','Mr. David Osei'],
            (v) => setState(() => _teacher = v!)),
        _label('Subject'),
        _tfStatic('Re: Arjun Mehta — Academic Query'),
        _label('Message'),
        _tf(_msgCtrl, 'Type your message to the teacher...', lines: 4),
        const SizedBox(height: 24),
        navyBtn('Send Message', onTap: () {
          if (_msgCtrl.text.trim().isEmpty) {
            showToast(context, 'Message is empty', color: AppColors.red, icon: Icons.error_outline_rounded);
            return;
          }
          setState(() => _done = true);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context);
          });
        }),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ADMIN MODALS
// ═════════════════════════════════════════════════════════════════════════════

void showAddStudent(BuildContext ctx, {VoidCallback? onDone}) =>
    showSheet(ctx, _AddProfileSheet(type: 'Student', onDone: onDone), tall: true);
void showAddTeacher(BuildContext ctx, {VoidCallback? onDone}) =>
    showSheet(ctx, _AddProfileSheet(type: 'Teacher', onDone: onDone), tall: true);
void showAddParent(BuildContext ctx, {VoidCallback? onDone}) =>
    showSheet(ctx, _AddProfileSheet(type: 'Parent', onDone: onDone), tall: true);

/// Two-step creation: first create a User account, then create the profile.
class _AddProfileSheet extends StatefulWidget {
  final String type;
  final VoidCallback? onDone;
  const _AddProfileSheet({required this.type, this.onDone});
  @override
  State<_AddProfileSheet> createState() => _AddProfileSheetState();
}

class _AddProfileSheetState extends State<_AddProfileSheet> {
  final _firstCtrl  = TextEditingController();
  final _lastCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _idCtrl     = TextEditingController();      // enrollmentNo / employeeId
  final _extraCtrl  = TextEditingController();       // bloodGroup / qualification / occupation
  bool _loading = false;
  bool _done    = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_firstCtrl, _lastCtrl, _emailCtrl, _passCtrl, _idCtrl, _extraCtrl]) c.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final first = _firstCtrl.text.trim();
    final last  = _lastCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text;
    final id    = _idCtrl.text.trim();

    if (first.isEmpty || last.isEmpty || email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'First name, last name, email and password are required.');
      return;
    }
    if (id.isEmpty) {
      setState(() => _error = widget.type == 'Student' ? 'Enrollment number is required.' : widget.type == 'Teacher' ? 'Employee ID is required.' : null);
      if (widget.type != 'Parent' && id.isEmpty) return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      // Step 1: Create User account
      late TenantUser user;
      try {
        user = await ApiService().createUser({
          'first_name': first,
          'last_name':  last,
          'email':      email,
          'password':   pass,
        });
      } on ApiException catch (e) {
        throw ApiException('User creation failed: ${e.message}', statusCode: e.statusCode);
      }

      // Step 2: Assign appropriate Role
      try {
        final rolesRes = await ApiService().getRoles();
        final roleName = widget.type; // 'Student', 'Teacher', or 'Parent'
        final match = rolesRes.results.firstWhere((r) => r.name.toLowerCase() == roleName.toLowerCase(), orElse: () => rolesRes.results.first);
        await ApiService().createUserRole({
          'user': user.id,
          'role': match.id,
        });
      } catch (e) {
        // Silently continue if role assignment already exists or fails (backend might handle it)
        print('Role assignment note: $e');
      }

      // Step 3: Create the typed Profile
      try {
        if (widget.type == 'Student') {
          await ApiService().createStudent({
            'user':               user.id,
            'enrollment_number':  id,
            'blood_group':        _extraCtrl.text.trim().isNotEmpty ? _extraCtrl.text.trim() : null,
          });
        } else if (widget.type == 'Teacher') {
          await ApiService().createTeacher({
            'user':          user.id,
            'employee_id':   id,
            'qualification': _extraCtrl.text.trim().isNotEmpty ? _extraCtrl.text.trim() : null,
          });
        } else {
          await ApiService().createParent({
            'user':       user.id,
            'occupation': _extraCtrl.text.trim().isNotEmpty ? _extraCtrl.text.trim() : null,
          });
        }
      } on ApiException catch (e) {
        throw ApiException('${widget.type} profile creation failed: ${e.message}', statusCode: e.statusCode);
      }

      AppStore.instance.prependActivity('${widget.type} Added', '$first $last');
      if (mounted) setState(() { _done = true; _loading = false; });
      widget.onDone?.call();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String get _idLabel => widget.type == 'Student' ? 'Enrollment Number' : widget.type == 'Teacher' ? 'Employee ID' : 'Occupation (optional)';
  String get _idHint  => widget.type == 'Student' ? 'e.g. ENR-2025-001' : widget.type == 'Teacher' ? 'e.g. EMP-042' : 'e.g. Engineer';
  String get _extraLabel => widget.type == 'Student' ? 'Blood Group (optional)' : widget.type == 'Teacher' ? 'Qualification (optional)' : 'Emergency Contact (optional)';
  String get _extraHint  => widget.type == 'Student' ? 'e.g. O+' : widget.type == 'Teacher' ? 'e.g. B.Sc Physics' : 'e.g. +91 98765 00000';

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, '${widget.type} Added!', '${_firstCtrl.text} ${_lastCtrl.text} created successfully.', Icons.person_add_rounded);

    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Add ${widget.type}', Icons.person_add_rounded, AppColors.blue),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.all(10), margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(rMd)),
          child: Text('Creates a user account + ${widget.type.toLowerCase()} profile in one step.', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.blue))),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ _label('First Name'), _tf(_firstCtrl, 'First name') ])),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ _label('Last Name'), _tf(_lastCtrl, 'Last name') ])),
        ]),
        _label('Email Address'),
        _tf(_emailCtrl, 'email@school.com', type: TextInputType.emailAddress),
        _label('Password (temporary)'),
        _tf(_passCtrl, 'Min. 8 characters', obscure: true),
        _label(_idLabel),
        _tf(_idCtrl, _idHint),
        _label(_extraLabel),
        _tf(_extraCtrl, _extraHint),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.redLight, borderRadius: BorderRadius.circular(rMd), border: Border.all(color: const Color(0xFFFCA5A5))),
            child: Row(children: [ const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.red), const SizedBox(width: 8), Expanded(child: Text(_error!, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.red))) ])),
        ],
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _loading ? null : _submit,
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.gradA, AppColors.gradC], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(rMd), boxShadow: shadowMd),
            child: Center(child: _loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Create ${widget.type}', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
          ),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ACCOUNTANT MODALS
// ═════════════════════════════════════════════════════════════════════════════

void showGenerateInvoice(BuildContext ctx) =>
    showSheet(ctx, _GenerateInvoiceSheet(), tall: true);

class _GenerateInvoiceSheet extends StatefulWidget {
  @override
  State<_GenerateInvoiceSheet> createState() => _GenerateInvoiceSheetState();
}
class _GenerateInvoiceSheetState extends State<_GenerateInvoiceSheet> {
  final _nameCtrl = TextEditingController();
  String _type  = 'Term 2 Tuition';
  String _grade = 'Grade 10 (₹24,500)';
  bool   _done  = false;

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Invoice Generated!',
        'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)} · ${_nameCtrl.text}',
        Icons.receipt_long_rounded);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Generate Invoice', Icons.receipt_long_rounded, AppColors.red),
        const SizedBox(height: 20),
        _label('Student Name / ID'),
        _tf(_nameCtrl, 'Search student…'),
        _label('Fee Type'),
        _dropdown(_type, ['Term 2 Tuition','Activity Fee','Lab Fee','Exam Fee','Transport','Library'],
            (v) => setState(() => _type = v!)),
        _label('Grade (determines amount)'),
        _dropdown(_grade,
            ['Grade 9 (₹24,500)','Grade 10 (₹24,500)','Grade 11 (₹28,000)','Grade 12 (₹28,000)'],
            (v) => setState(() => _grade = v!)),
        const SizedBox(height: 24),
        navyBtn('Generate & Send Invoice', onTap: () {
          if (_nameCtrl.text.trim().isEmpty) {
            showToast(context, 'Enter student name or ID',
                color: AppColors.red, icon: Icons.error_outline_rounded);
            return;
          }
          setState(() => _done = true);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context);
          });
        }),
      ]),
    );
  }
}

// ── Approve / Reject transaction ───────────────────────────────────────────

Future<void> showApproveTransaction(BuildContext ctx,
    {required String name, required String amount, required String id}) async {
  final ok = await confirmDialog(ctx,
      title: 'Approve Payment?',
      body: '$name · $amount\nRef: $id',
      confirm: 'Approve', confirmColor: AppColors.green);
  if (ok && ctx.mounted) {
    showToast(ctx, '$id approved', color: AppColors.green);
  }
}

Future<void> showRejectTransaction(BuildContext ctx,
    {required String name, required String id}) async {
  final ok = await confirmDialog(ctx,
      title: 'Reject Transaction?',
      body: 'This will mark $id from $name as rejected.',
      confirm: 'Reject', confirmColor: AppColors.red);
  if (ok && ctx.mounted) {
    showToast(ctx, '$id rejected', color: AppColors.red, icon: Icons.cancel_rounded);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GLOBAL ADMIN MODALS
// ─────────────────────────────────────────────────────────────────────────────

void showSetupSchool(BuildContext ctx) =>
    showSheet(ctx, _SetupSchoolSheet(), tall: true);

class _SetupSchoolSheet extends StatefulWidget {
  @override
  State<_SetupSchoolSheet> createState() => _SetupSchoolSheetState();
}
class _SetupSchoolSheetState extends State<_SetupSchoolSheet> {
  final _nameCtrl   = TextEditingController();
  final _domainCtrl = TextEditingController();
  bool  _done = false;

  @override
  void dispose() { _nameCtrl.dispose(); _domainCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'School Registered!',
        '${_nameCtrl.text} · ${_domainCtrl.text}.educore.io', Icons.home_work_rounded);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Setup New School', Icons.home_work_rounded, AppColors.blue),
        const SizedBox(height: 20),
        _label('School Name'),
        _tf(_nameCtrl, 'e.g. Sunrise International Academy'),
        _label('Subdomain'),
        _tf(_domainCtrl, 'e.g. sunrise'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(rSm)),
          child: Text('Domain preview: ${_domainCtrl.text.isEmpty ? 'xxx' : _domainCtrl.text}.educore.io',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.blue)),
        ),
        const SizedBox(height: 16),
        _label('Admin Email'),
        _tfStatic('admin@school.com'),
        const SizedBox(height: 24),
        navyBtn('Create School Tenant', onTap: () {
          if (_nameCtrl.text.trim().isEmpty) {
            showToast(context, 'Enter school name',
                color: AppColors.red, icon: Icons.error_outline_rounded);
            return;
          }
          setState(() => _done = true);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context);
          });
        }),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────────────────────────

Widget _sheetTitle(String title, IconData icon, Color color) => Row(children: [
  Container(
    width: 36, height: 36,
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(rMd),
    ),
    child: Icon(icon, size: 18, color: color),
  ),
  const SizedBox(width: 10),
  Text(title, style: GoogleFonts.dmSerifDisplay(fontSize: 19, color: AppColors.text1)),
]);

Widget _label(String t) => Padding(
  padding: const EdgeInsets.only(bottom: 6, top: 2),
  child: Text(t, style: GoogleFonts.plusJakartaSans(
      fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text3)),
);

Widget _tf(TextEditingController ctrl, String hint,
    {int lines = 1, TextInputType? type, bool obscure = false}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        maxLines: obscure ? 1 : lines,
        keyboardType: type,
        obscureText: obscure,
        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text1),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text4),
          filled: true, fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd),
              borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd),
              borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd),
              borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
        ),
      ),
    );

Widget _tfStatic(String hint) => Padding(
  padding: const EdgeInsets.only(bottom: 14),
  child: TextField(
    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text1),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text4),
      filled: true, fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
    ),
  ),
);

Widget _dropdown(String val, List<String> items, ValueChanged<String?> onChanged) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: val,
        decoration: InputDecoration(
          filled: true, fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd),
              borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd),
              borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd),
              borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
        ),
        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text1),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onChanged,
      ),
    );

Widget _successPanel(BuildContext ctx, String title, String sub, IconData icon) =>
    Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppColors.greenLight,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF86EFAC), width: 2),
          ),
          child: Icon(icon, size: 32, color: AppColors.green),
        ),
        const SizedBox(height: 16),
        Text(title, style: GoogleFonts.dmSerifDisplay(fontSize: 22, color: AppColors.text1),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(sub, style: GoogleFonts.plusJakartaSans(
            fontSize: 13, color: AppColors.text3, height: 1.5),
            textAlign: TextAlign.center),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              gradient: blueGrad(),
              borderRadius: BorderRadius.circular(rMd),
              boxShadow: shadowSm,
            ),
            child: Text('Done', style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ]),
    );

// ═════════════════════════════════════════════════════════════════════════════
// NEW FEATURES
// ═════════════════════════════════════════════════════════════════════════════

// ── Notification Center ────────────────────────────────────────────────────

void showNotifications(BuildContext ctx) =>
    showSheet(ctx, const _NotificationsSheet());

class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet();
  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}
class _NotificationsSheetState extends State<_NotificationsSheet> {
  final _notifs = [
    _Notif(true,  AppColors.blue,  'Assignment Due Tomorrow',   'Quadratic Equations Set B · Mathematics',  '5m ago',  Icons.assignment_rounded),
    _Notif(true,  AppColors.green, 'Grade Posted',              'Physics Unit Test: 91/100 · A+',            '14m ago', Icons.grade_rounded),
    _Notif(true,  AppColors.red,   'Attendance Alert',          'You were marked late on Apr 14',            '2h ago',  Icons.access_time_rounded),
    _Notif(false, AppColors.amber, 'Exam Scheduled',            'Chemistry Practical · Apr 22 · Lab 3',     '1d ago',  Icons.edit_calendar_rounded),
    _Notif(false, AppColors.teal,  'New Material Uploaded',     'Physics Notes Chapter 5 · Dr. Vance',      '2d ago',  Icons.description_rounded),
    _Notif(false, AppColors.navy,  'Fee Reminder',              'Term 2 Tuition due Apr 15 · ₹24,500',      '3d ago',  Icons.payment_rounded),
  ];

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(rMd)),
          child: const Icon(Icons.notifications_rounded, size: 18, color: AppColors.blue)),
        const SizedBox(width: 10),
        Expanded(child: Text('Notifications',
            style: GoogleFonts.dmSerifDisplay(fontSize: 19, color: AppColors.text1))),
        GestureDetector(
          onTap: () { setState(() => _notifs.forEach((n) => n.read = true)); },
          child: Text('Mark all read', style: GoogleFonts.plusJakartaSans(
              fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.blue)),
        ),
      ]),
    ),
    const SizedBox(height: 12),
    const Divider(height: 1, color: AppColors.border),
    ..._notifs.map((n) => GestureDetector(
      onTap: () => setState(() => n.read = true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: n.read ? AppColors.surface : AppColors.blueLight.withOpacity(0.4),
          border: const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: n.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(rMd),
            ),
            child: Icon(n.icon, size: 18, color: n.color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(n.title, style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: n.read ? FontWeight.w500 : FontWeight.w700,
                  color: AppColors.text1))),
              Text(n.time, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4)),
            ]),
            const SizedBox(height: 2),
            Text(n.body, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
          ])),
          if (!n.read) ...[
            const SizedBox(width: 8),
            Container(width: 8, height: 8,
                decoration: const BoxDecoration(color: AppColors.blue, shape: BoxShape.circle)),
          ],
        ]),
      ),
    )),
    const SizedBox(height: 16),
  ]);
}
class _Notif {
  bool read; final Color color; final String title, body, time; final IconData icon;
  _Notif(this.read, this.color, this.title, this.body, this.time, this.icon);
}

// ── Student Leaderboard ────────────────────────────────────────────────────

void showLeaderboard(BuildContext ctx) =>
    showSheet(ctx, const _LeaderboardSheet());

class _LeaderboardSheet extends StatelessWidget {
  const _LeaderboardSheet();
  static const _data = [
    (1, 'Maya Johnson',    'Grade 10B', AppColors.amber, 98, '🥇'),
    (2, 'Leo Chen',        'Grade 9A',  AppColors.text3, 96, '🥈'),
    (3, 'Zara Williams',   'Grade 11C', AppColors.amber, 94, '🥉'),
    (4, 'Alex Rivers',     'Grade 11B', AppColors.blue,  92, ''),
    (5, 'Clara Singh',     'Grade 10A', AppColors.text3, 90, ''),
    (6, 'Sofia Rodriguez', 'Grade 12B', AppColors.text3, 89, ''),
    (7, 'George Patel',    'Grade 11B', AppColors.text3, 87, ''),
    (8, 'Arjun Mehta',     'Grade 10A', AppColors.text3, 85, ''),
  ];

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.amberLight, borderRadius: BorderRadius.circular(rMd)),
          child: const Icon(Icons.emoji_events_rounded, size: 18, color: AppColors.amber)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Class Leaderboard', style: GoogleFonts.dmSerifDisplay(fontSize: 19, color: AppColors.text1)),
          Text('Term 2 · All Subjects · Top 10', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
        ]),
      ]),
    ),
    const Divider(height: 1, color: AppColors.border),
    ..._data.map((s) {
      final isMe = s.$4 == AppColors.blue;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.blueLight.withOpacity(0.5) : AppColors.surface,
          border: const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          SizedBox(width: 28, child: Text(
            s.$6.isNotEmpty ? s.$6 : '${s.$1}',
            style: GoogleFonts.plusJakartaSans(
                fontSize: s.$6.isNotEmpty ? 18 : 13,
                fontWeight: FontWeight.w700,
                color: s.$4),
            textAlign: TextAlign.center,
          )),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.$2 + (isMe ? ' (You)' : ''),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: isMe ? FontWeight.w700 : FontWeight.w600,
                    color: AppColors.text1)),
            Text(s.$3, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isMe ? AppColors.blueLight : AppColors.bg,
              borderRadius: BorderRadius.circular(rFull),
              border: Border.all(color: isMe ? AppColors.blue.withOpacity(0.3) : AppColors.border),
            ),
            child: Text('${s.$5}%', style: GoogleFonts.plusJakartaSans(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: isMe ? AppColors.blue : AppColors.text1)),
          ),
        ]),
      );
    }),
    const SizedBox(height: 16),
  ]);
}

// ── Quick Notes (Student) ──────────────────────────────────────────────────

void showQuickNotes(BuildContext ctx) =>
    showSheet(ctx, _QuickNotesSheet(), tall: true);

class _QuickNotesSheet extends StatefulWidget {
  @override
  State<_QuickNotesSheet> createState() => _QuickNotesSheetState();
}
class _QuickNotesSheetState extends State<_QuickNotesSheet> {
  final _ctrl = TextEditingController();
  final List<String> _notes = [
    'Physics: F = ma — Newton\'s 2nd Law. Remember units: kg·m/s²',
    'English essay structure: Hook → Thesis → 3 body paragraphs → Conclusion',
    'Maths: Quadratic formula x = (−b ± √(b²−4ac)) / 2a',
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.amberLight, borderRadius: BorderRadius.circular(rMd)),
          child: const Icon(Icons.note_alt_rounded, size: 18, color: AppColors.amber)),
        const SizedBox(width: 10),
        Text('Quick Notes', style: GoogleFonts.dmSerifDisplay(fontSize: 19, color: AppColors.text1)),
      ]),
    ),
    Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(children: [
        Expanded(child: TextField(
          controller: _ctrl,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text1),
          decoration: InputDecoration(
            hintText: 'Add a new note…',
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text4),
            filled: true, fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd),
                borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd),
                borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd),
                borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
          ),
        )),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            if (_ctrl.text.trim().isNotEmpty) {
              setState(() { _notes.insert(0, _ctrl.text.trim()); _ctrl.clear(); });
            }
          },
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(gradient: blueGrad(), borderRadius: BorderRadius.circular(rMd)),
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ),
      ]),
    ),
    ..._notes.asMap().entries.map((e) => Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(rMd),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: shadowSm,
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.sticky_note_2_rounded, size: 16, color: AppColors.amber),
        const SizedBox(width: 10),
        Expanded(child: Text(e.value, style: GoogleFonts.plusJakartaSans(
            fontSize: 12, color: AppColors.text1, height: 1.5))),
        GestureDetector(
          onTap: () => setState(() => _notes.removeAt(e.key)),
          child: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.text4),
        ),
      ]),
    )),
    const SizedBox(height: 16),
  ]);
}

// ── Bulk Promote Students (Admin) ──────────────────────────────────────────

// showBulkPromote is defined below with real API implementation

// ── Record Manual Payment (Accountant) ────────────────────────────────────

void showManualPayment(BuildContext ctx) =>
    showSheet(ctx, _ManualPaymentSheet(), tall: true);

class _ManualPaymentSheet extends StatefulWidget {
  @override
  State<_ManualPaymentSheet> createState() => _ManualPaymentSheetState();
}
class _ManualPaymentSheetState extends State<_ManualPaymentSheet> {
  final _studentCtrl = TextEditingController();
  final _amountCtrl  = TextEditingController();
  final _refCtrl     = TextEditingController();
  String _method = 'Cash';
  bool   _done   = false;

  @override
  void dispose() { _studentCtrl.dispose(); _amountCtrl.dispose(); _refCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Payment Recorded!',
        '${_studentCtrl.text} · ₹${_amountCtrl.text} via $_method', Icons.receipt_long_rounded);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Record Manual Payment', Icons.edit_note_rounded, AppColors.blue),
        const SizedBox(height: 20),
        _label('Student Name / ID'),
        _tf(_studentCtrl, 'Search student…'),
        _label('Amount (₹)'),
        _tf(_amountCtrl, '0.00', type: TextInputType.number),
        _label('Payment Method'),
        _dropdown(_method, ['Cash','Cheque','Bank Transfer','Demand Draft'], (v) => setState(() => _method = v!)),
        _label('Reference / Cheque No.'),
        _tf(_refCtrl, 'Reference number (optional)'),
        const SizedBox(height: 16),
        navyBtn('Record Payment', onTap: () {
          if (_studentCtrl.text.trim().isEmpty || _amountCtrl.text.trim().isEmpty) {
            showToast(context, 'Fill in student name and amount', color: AppColors.red, icon: Icons.error_outline_rounded);
            return;
          }
          setState(() => _done = true);
          Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.pop(context); });
        }),
      ]),
    );
  }
}

// ── View Report (Accountant) ───────────────────────────────────────────────

void showFinancialReport(BuildContext ctx) =>
    showSheet(ctx, const _FinancialReportSheet(), tall: true);

class _FinancialReportSheet extends StatelessWidget {
  const _FinancialReportSheet();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(rMd)),
          child: const Icon(Icons.pie_chart_rounded, size: 18, color: AppColors.blue)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Financial Report', style: GoogleFonts.dmSerifDisplay(fontSize: 19, color: AppColors.text1)),
          Text('Term 2 · 2024–25', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
        ])),
      ]),
    ),
    const Divider(height: 1, color: AppColors.border),
    Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Summary cards
        Row(children: [
          Expanded(child: _reportCard('Total Billed', '₹73.1L', AppColors.blue, AppColors.blueLight)),
          const SizedBox(width: 10),
          Expanded(child: _reportCard('Collected', '₹18.4L', AppColors.green, AppColors.greenLight)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _reportCard('Pending', '₹4.1L', AppColors.amber, AppColors.amberLight)),
          const SizedBox(width: 10),
          Expanded(child: _reportCard('Overdue', '₹0.6L', AppColors.red, AppColors.redLight)),
        ]),
        const SizedBox(height: 20),
        Text('MONTHLY BREAKDOWN', style: GoogleFonts.plusJakartaSans(
            fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.text4)),
        const SizedBox(height: 12),
        ...[
          ('January 2025',  '₹6.2L',  94, AppColors.green),
          ('February 2025', '₹5.8L',  88, AppColors.green),
          ('March 2025',    '₹4.9L',  74, AppColors.amber),
          ('April 2025',    '₹1.5L',  23, AppColors.red),
        ].map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(r.$1, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text2)),
              Row(children: [
                Text(r.$2, style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text1)),
                const SizedBox(width: 8),
                Text('${r.$3}%', style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, fontWeight: FontWeight.w600, color: r.$4)),
              ]),
            ]),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(rFull),
              child: Container(
                height: 6, color: AppColors.border,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: r.$3 / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: r.$4,
                      borderRadius: BorderRadius.circular(rFull),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        )),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            showToast(context, 'Report exported as PDF', color: AppColors.green);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(rMd),
              border: Border.all(color: AppColors.border2, width: 1.5),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.download_rounded, size: 15, color: AppColors.blue),
              const SizedBox(width: 8),
              Text('Export PDF Report', style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.blue)),
            ]),
          ),
        ),
      ]),
    ),
  ]);

  Widget _reportCard(String label, String val, Color color, Color bg) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(rMd),
            border: Border.all(color: color.withOpacity(0.2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: color)),
          const SizedBox(height: 4),
          Text(val, style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: color)),
        ]),
      );
}

// ── Enrol Student (Admin) ──────────────────────────────────────────────────

// showEnrolStudent is defined below with real API implementation

// ── System Alert (Global Admin) ────────────────────────────────────────────

void showSystemAlert(BuildContext ctx) =>
    showSheet(ctx, _SystemAlertSheet(), tall: true);

class _SystemAlertSheet extends StatefulWidget {
  @override
  State<_SystemAlertSheet> createState() => _SystemAlertSheetState();
}
class _SystemAlertSheetState extends State<_SystemAlertSheet> {
  final _msgCtrl  = TextEditingController();
  String _type    = 'Maintenance';
  String _scope   = 'All Schools';
  bool   _done    = false;

  @override
  void dispose() { _msgCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Alert Sent!',
        'System ${"$_type alert"} broadcast to $_scope.', Icons.notifications_active_rounded);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Broadcast System Alert', Icons.notifications_active_rounded, AppColors.red),
        const SizedBox(height: 20),
        _label('Alert Type'),
        _dropdown(_type, ['Maintenance','Outage','Update','Security','Info'],
            (v) => setState(() => _type = v!)),
        _label('Scope'),
        _dropdown(_scope, ['All Schools','Westfield Academy','Northgate Prep','Sunrise International'],
            (v) => setState(() => _scope = v!)),
        _label('Message'),
        _tf(_msgCtrl, 'Describe the alert…', lines: 3),
        const SizedBox(height: 24),
        navyBtn('Broadcast Alert', onTap: () {
          if (_msgCtrl.text.trim().isEmpty) {
            showToast(context, 'Enter alert message',
                color: AppColors.red, icon: Icons.error_outline_rounded);
            return;
          }
          setState(() => _done = true);
          Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.pop(context); });
        }),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// NEW API-BACKED ADMIN MODALS
// ═════════════════════════════════════════════════════════════════════════════

// ── Update showBulkPromote to accept onDone ────────────────────────────────

void showBulkPromote(BuildContext ctx, {VoidCallback? onDone}) =>
    showSheet(ctx, _BulkPromoteApiSheet(onDone: onDone), tall: true);

class _BulkPromoteApiSheet extends StatefulWidget {
  final VoidCallback? onDone;
  const _BulkPromoteApiSheet({this.onDone});
  @override
  State<_BulkPromoteApiSheet> createState() => _BulkPromoteApiSheetState();
}

class _BulkPromoteApiSheetState extends State<_BulkPromoteApiSheet> {
  List<StudentProfile> _students        = [];
  List<AcademicYear>   _years           = [];
  List<ClassLevel>     _classes         = [];
  List<Section>        _sections        = [];
  Set<String>          _selected        = {};
  String?              _targetYearId;
  String?              _targetClassId;
  String?              _targetSectionId;
  bool _loading = true;
  bool _saving  = false;
  bool _done    = false;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
    try {
      final results = await Future.wait([
        ApiService().getStudents(),
        ApiService().getAcademicYears(),
        ApiService().getClassLevels(),
        ApiService().getSections(),
      ]);
      if (!mounted) return;
      final years   = (results[1] as PaginatedResult<AcademicYear>).results;
      final classes = (results[2] as PaginatedResult<ClassLevel>).results;
      final sects   = (results[3] as PaginatedResult<Section>).results;
      setState(() {
        _students = (results[0] as PaginatedResult<StudentProfile>).results;
        _years    = years;
        _classes  = classes;
        _sections = sects;
        _targetYearId    = years.isNotEmpty    ? years.first.id    : null;
        _targetClassId   = classes.isNotEmpty  ? classes.first.id  : null;
        _targetSectionId = sects.isNotEmpty    ? sects.first.id    : null;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _promote() async {
    if (_selected.isEmpty) { setState(() => _error = 'Select at least one student.'); return; }
    if (_targetYearId == null || _targetClassId == null || _targetSectionId == null) {
      setState(() => _error = 'Select target year, class, and section.'); return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      final detail = await ApiService().bulkPromote(
        studentIds:           _selected.toList(),
        targetAcademicYearId: _targetYearId!,
        targetClassLevelId:   _targetClassId!,
        targetSectionId:      _targetSectionId!,
      );
      AppStore.instance.prependActivity('Bulk Promotion', '${_selected.length} students promoted');
      if (mounted) setState(() { _done = true; _saving = false; });
      widget.onDone?.call();
      Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.pop(context); });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _saving = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Students Promoted!', '${_selected.length} students moved successfully.', Icons.trending_up_rounded);
    if (_loading) return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: AppColors.blue)));

    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Bulk Promote Students', Icons.trending_up_rounded, AppColors.teal),
        const SizedBox(height: 16),

        _label('Target Academic Year'),
        _apiDropdown<AcademicYear>(_years, _targetYearId, (y) => y.name, (v) => setState(() => _targetYearId = v)),
        _label('Target Class'),
        _apiDropdown<ClassLevel>(_classes, _targetClassId, (c) => c.name, (v) => setState(() => _targetClassId = v)),
        _label('Target Section'),
        _apiDropdown<Section>(_sections, _targetSectionId, (s) => '${s.classLevelName ?? ""} — ${s.name}', (v) => setState(() => _targetSectionId = v)),

        _label('Select Students (${_selected.length} selected)'),
        Container(
          height: 200,
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(rMd)),
          child: ListView(children: _students.map((s) => CheckboxListTile(
            value: _selected.contains(s.id),
            onChanged: (v) => setState(() { if (v == true) _selected.add(s.id); else _selected.remove(s.id); }),
            title: Text(s.fullName, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text1)),
            subtitle: Text('ID: ${s.enrollmentNumber ?? "—"}', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text3)),
            dense: true,
            activeColor: AppColors.blue,
          )).toList()),
        ),

        if (_error != null) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.redLight, borderRadius: BorderRadius.circular(rMd)),
            child: Text(_error!, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.red))),
        ],
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _saving ? null : _promote,
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.gradA, AppColors.gradC]), borderRadius: BorderRadius.circular(rMd), boxShadow: shadowMd),
            child: Center(child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Promote ${_selected.length} Students', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)))),
        ),
      ]),
    );
  }
}

// ── showEnrolStudent ───────────────────────────────────────────────────────

void showEnrolStudent(BuildContext ctx, {VoidCallback? onDone}) =>
    showSheet(ctx, _EnrolStudentApiSheet(onDone: onDone), tall: true);

class _EnrolStudentApiSheet extends StatefulWidget {
  final VoidCallback? onDone;
  const _EnrolStudentApiSheet({this.onDone});
  @override
  State<_EnrolStudentApiSheet> createState() => _EnrolStudentApiSheetState();
}

class _EnrolStudentApiSheetState extends State<_EnrolStudentApiSheet> {
  List<StudentProfile> _students = [];
  List<AcademicYear>   _years    = [];
  List<ClassLevel>     _classes  = [];
  List<Section>        _sections = [];
  String? _studentId;
  String? _yearId;
  String? _classId;
  String? _sectionId;
  final _rollCtrl = TextEditingController();
  bool _loading = true;
  bool _saving  = false;
  bool _done    = false;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _rollCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
    try {
      final results = await Future.wait([
        ApiService().getStudents(),
        ApiService().getAcademicYears(),
        ApiService().getClassLevels(),
        ApiService().getSections(),
      ]);
      if (!mounted) return;
      final years   = (results[1] as PaginatedResult<AcademicYear>).results;
      final classes = (results[2] as PaginatedResult<ClassLevel>).results;
      final sects   = (results[3] as PaginatedResult<Section>).results;
      final studs   = (results[0] as PaginatedResult<StudentProfile>).results;
      setState(() {
        _students  = studs;
        _years     = years;
        _classes   = classes;
        _sections  = sects;
        _studentId = studs.isNotEmpty  ? studs.first.id  : null;
        _yearId    = years.isNotEmpty  ? years.first.id  : null;
        _classId   = classes.isNotEmpty ? classes.first.id : null;
        _sectionId = sects.isNotEmpty  ? sects.first.id  : null;
        _loading   = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _submit() async {
    if (_studentId == null || _yearId == null || _classId == null || _sectionId == null) {
      setState(() => _error = 'All fields are required.'); return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      await ApiService().createEnrollment({
        'student':       _studentId!,
        'academic_year': _yearId!,
        'class_level':   _classId!,
        'section':       _sectionId!,
        if (_rollCtrl.text.trim().isNotEmpty) 'roll_number': _rollCtrl.text.trim(),
      });
      AppStore.instance.prependActivity('Student Enrolled', 'Enrollment created');
      if (mounted) setState(() { _done = true; _saving = false; });
      widget.onDone?.call();
      Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.pop(context); });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _saving = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Student Enrolled!', 'Enrollment created successfully.', Icons.how_to_reg_rounded);
    if (_loading) return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: AppColors.blue)));

    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Enroll Student', Icons.how_to_reg_rounded, AppColors.blue),
        const SizedBox(height: 16),
        _label('Student'),
        _apiDropdown<StudentProfile>(_students, _studentId, (s) => '${s.fullName} (${s.enrollmentNumber ?? "—"})', (v) => setState(() => _studentId = v)),
        _label('Academic Year'),
        _apiDropdown<AcademicYear>(_years, _yearId, (y) => y.name, (v) => setState(() => _yearId = v)),
        _label('Class Level'),
        _apiDropdown<ClassLevel>(_classes, _classId, (c) => c.name, (v) => setState(() => _classId = v)),
        _label('Section'),
        _apiDropdown<Section>(_sections, _sectionId, (s) => '${s.classLevelName ?? ""} — ${s.name}', (v) => setState(() => _sectionId = v)),
        _label('Roll Number (optional)'),
        _tf(_rollCtrl, 'e.g. 042', type: TextInputType.number),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.redLight, borderRadius: BorderRadius.circular(rMd)),
            child: Text(_error!, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.red))),
        ],
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _saving ? null : _submit,
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.gradA, AppColors.gradC]), borderRadius: BorderRadius.circular(rMd), boxShadow: shadowMd),
            child: Center(child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Enroll Student', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)))),
        ),
      ]),
    );
  }
}

// ── Academic Year CRUD ─────────────────────────────────────────────────────

void showAddAcademicYear(BuildContext ctx, {VoidCallback? onDone}) =>
    showSheet(ctx, _AddAcademicYearSheet(onDone: onDone), tall: true);

class _AddAcademicYearSheet extends StatefulWidget {
  final VoidCallback? onDone;
  const _AddAcademicYearSheet({this.onDone});
  @override State<_AddAcademicYearSheet> createState() => _AddAcademicYearSheetState();
}
class _AddAcademicYearSheetState extends State<_AddAcademicYearSheet> {
  final _nameCtrl  = TextEditingController();
  final _startCtrl = TextEditingController(text: '2025-06-01');
  final _endCtrl   = TextEditingController(text: '2026-03-31');
  bool _isActive = false;
  bool _loading = false;
  bool _done    = false;
  String? _error;

  @override
  void dispose() { _nameCtrl.dispose(); _startCtrl.dispose(); _endCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) { setState(() => _error = 'Name is required.'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService().createAcademicYear({
        'name':       _nameCtrl.text.trim(),
        'start_date': _startCtrl.text.trim(),
        'end_date':   _endCtrl.text.trim(),
        'is_active':  _isActive,
      });
      AppStore.instance.prependActivity('Academic Year Created', _nameCtrl.text.trim());
      if (mounted) setState(() { _done = true; _loading = false; });
      widget.onDone?.call();
      Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.pop(context); });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Academic Year Created!', _nameCtrl.text, Icons.calendar_month_rounded);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Add Academic Year', Icons.calendar_month_rounded, AppColors.blue),
        const SizedBox(height: 20),
        _label('Name'), _tf(_nameCtrl, 'e.g. 2025–2026'),
        _label('Start Date (YYYY-MM-DD)'), _tf(_startCtrl, '2025-06-01'),
        _label('End Date (YYYY-MM-DD)'),   _tf(_endCtrl, '2026-03-31'),
        Row(children: [
          Checkbox(value: _isActive, activeColor: AppColors.blue, onChanged: (v) => setState(() => _isActive = v ?? false)),
          Text('Mark as Active Year', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2)),
        ]),
        if (_error != null) _errBox(_error!),
        const SizedBox(height: 20),
        _submitBtn('Create Academic Year', _loading, _submit),
      ]),
    );
  }
}

// ── Class Level CRUD ───────────────────────────────────────────────────────

void showAddClassLevel(BuildContext ctx, {VoidCallback? onDone}) =>
    showSheet(ctx, _AddClassLevelSheet(onDone: onDone));

class _AddClassLevelSheet extends StatefulWidget {
  final VoidCallback? onDone;
  const _AddClassLevelSheet({this.onDone});
  @override State<_AddClassLevelSheet> createState() => _AddClassLevelSheetState();
}
class _AddClassLevelSheetState extends State<_AddClassLevelSheet> {
  final _nameCtrl  = TextEditingController();
  final _orderCtrl = TextEditingController();
  bool _loading = false;
  bool _done    = false;
  String? _error;

  @override
  void dispose() { _nameCtrl.dispose(); _orderCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _orderCtrl.text.trim().isEmpty) { setState(() => _error = 'Name and numeric order are required.'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService().createClassLevel({'name': _nameCtrl.text.trim(), 'numeric_order': int.tryParse(_orderCtrl.text.trim()) ?? 1});
      if (mounted) setState(() { _done = true; _loading = false; });
      widget.onDone?.call();
      Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.pop(context); });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Class Level Created!', _nameCtrl.text, Icons.class_rounded);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Add Class Level', Icons.class_rounded, AppColors.teal),
        const SizedBox(height: 20),
        _label('Name'), _tf(_nameCtrl, 'e.g. Grade 10'),
        _label('Numeric Order (for sorting)'), _tf(_orderCtrl, 'e.g. 10', type: TextInputType.number),
        if (_error != null) _errBox(_error!),
        const SizedBox(height: 20),
        _submitBtn('Create Class Level', _loading, _submit),
      ]),
    );
  }
}

// ── Section CRUD ───────────────────────────────────────────────────────────

void showAddSection(BuildContext ctx, {required List<ClassLevel> classLevels, VoidCallback? onDone}) =>
    showSheet(ctx, _AddSectionSheet(classLevels: classLevels, onDone: onDone));

class _AddSectionSheet extends StatefulWidget {
  final List<ClassLevel> classLevels;
  final VoidCallback? onDone;
  const _AddSectionSheet({required this.classLevels, this.onDone});
  @override State<_AddSectionSheet> createState() => _AddSectionSheetState();
}
class _AddSectionSheetState extends State<_AddSectionSheet> {
  final _nameCtrl = TextEditingController();
  String? _classId;
  bool _loading = false;
  bool _done    = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _classId = widget.classLevels.isNotEmpty ? widget.classLevels.first.id : null;
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _classId == null) { setState(() => _error = 'Name and class are required.'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService().createSection({'name': _nameCtrl.text.trim(), 'class_level': _classId!});
      if (mounted) setState(() { _done = true; _loading = false; });
      widget.onDone?.call();
      Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.pop(context); });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Section Created!', _nameCtrl.text, Icons.grid_view_rounded);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Add Section', Icons.grid_view_rounded, AppColors.amber),
        const SizedBox(height: 20),
        _label('Class Level'),
        _apiDropdown<ClassLevel>(widget.classLevels, _classId, (c) => c.name, (v) => setState(() => _classId = v)),
        _label('Section Name'), _tf(_nameCtrl, 'e.g. A'),
        if (_error != null) _errBox(_error!),
        const SizedBox(height: 20),
        _submitBtn('Create Section', _loading, _submit),
      ]),
    );
  }
}

// ── Subject CRUD ───────────────────────────────────────────────────────────

void showAddSubject(BuildContext ctx, {VoidCallback? onDone}) =>
    showSheet(ctx, _AddSubjectSheet(onDone: onDone));

class _AddSubjectSheet extends StatefulWidget {
  final VoidCallback? onDone;
  const _AddSubjectSheet({this.onDone});
  @override State<_AddSubjectSheet> createState() => _AddSubjectSheetState();
}
class _AddSubjectSheetState extends State<_AddSubjectSheet> {
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  bool _done    = false;
  String? _error;

  @override
  void dispose() { _nameCtrl.dispose(); _codeCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) { setState(() => _error = 'Subject name is required.'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService().createSubject({
        'name': _nameCtrl.text.trim(),
        if (_codeCtrl.text.trim().isNotEmpty) 'code': _codeCtrl.text.trim(),
      });
      if (mounted) setState(() { _done = true; _loading = false; });
      widget.onDone?.call();
      Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.pop(context); });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Subject Created!', _nameCtrl.text, Icons.book_rounded);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Add Subject', Icons.book_rounded, AppColors.green),
        const SizedBox(height: 20),
        _label('Subject Name'), _tf(_nameCtrl, 'e.g. Physics'),
        _label('Subject Code (optional)'), _tf(_codeCtrl, 'e.g. PHY101'),
        if (_error != null) _errBox(_error!),
        const SizedBox(height: 20),
        _submitBtn('Create Subject', _loading, _submit),
      ]),
    );
  }
}

// ── Role CRUD ──────────────────────────────────────────────────────────────

void showCreateRole(BuildContext ctx, {VoidCallback? onDone}) =>
    showSheet(ctx, _CreateRoleSheet(onDone: onDone), tall: true);

class _CreateRoleSheet extends StatefulWidget {
  final VoidCallback? onDone;
  const _CreateRoleSheet({this.onDone});
  @override State<_CreateRoleSheet> createState() => _CreateRoleSheetState();
}
class _CreateRoleSheetState extends State<_CreateRoleSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  List<AppPermission> _permissions    = [];
  Set<String>         _selectedPerms  = {};
  bool _loading = true;
  bool _saving  = false;
  bool _done    = false;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _nameCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
    try {
      final perms = await ApiService().getPermissions();
      if (mounted) setState(() { _permissions = perms; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) { setState(() => _error = 'Role name is required.'); return; }
    setState(() { _saving = true; _error = null; });
    try {
      await ApiService().createRole({
        'name':        _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'permissions': _selectedPerms.toList(),
      });
      AppStore.instance.prependActivity('Role Created', _nameCtrl.text.trim());
      if (mounted) setState(() { _done = true; _saving = false; });
      widget.onDone?.call();
      Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.pop(context); });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Role Created!', _nameCtrl.text, Icons.key_rounded);
    if (_loading) return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: AppColors.blue)));

    // Group permissions by module
    final byModule = <String, List<AppPermission>>{};
    for (final p in _permissions) {
      byModule.putIfAbsent(p.module, () => []).add(p);
    }

    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Create Role', Icons.key_rounded, AppColors.amber),
        const SizedBox(height: 20),
        _label('Role Name'), _tf(_nameCtrl, 'e.g. Class Teacher'),
        _label('Description (optional)'), _tf(_descCtrl, 'What does this role do?', lines: 2),
        _label('Assign Permissions (${_selectedPerms.length} selected)'),
        Container(
          height: 260,
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(rMd)),
          child: ListView(children: byModule.entries.expand((entry) => [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Text(entry.key.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: AppColors.text4)),
            ),
            ...entry.value.map((p) => CheckboxListTile(
              value: _selectedPerms.contains(p.id),
              onChanged: (v) => setState(() { if (v == true) _selectedPerms.add(p.id); else _selectedPerms.remove(p.id); }),
              title: Text(p.name, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text1)),
              subtitle: Text(p.codename, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text3)),
              dense: true,
              activeColor: AppColors.blue,
            )),
          ]).toList()),
        ),
        if (_error != null) _errBox(_error!),
        const SizedBox(height: 20),
        _submitBtn('Create Role', _saving, _submit),
      ]),
    );
  }
}

// ── Create User ────────────────────────────────────────────────────────────

void showCreateUser(BuildContext ctx, {VoidCallback? onDone}) =>
    showSheet(ctx, _CreateUserSheet(onDone: onDone), tall: true);

class _CreateUserSheet extends StatefulWidget {
  final VoidCallback? onDone;
  const _CreateUserSheet({this.onDone});
  @override State<_CreateUserSheet> createState() => _CreateUserSheetState();
}
class _CreateUserSheetState extends State<_CreateUserSheet> {
  final _firstCtrl  = TextEditingController();
  final _lastCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool _loading = false;
  bool _done    = false;
  String? _error;

  @override
  void dispose() { for (final c in [_firstCtrl, _lastCtrl, _emailCtrl, _passCtrl]) c.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_firstCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'First name, email and password are required.'); return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService().createUser({
        'first_name': _firstCtrl.text.trim(),
        'last_name':  _lastCtrl.text.trim(),
        'email':      _emailCtrl.text.trim(),
        'password':   _passCtrl.text,
      });
      AppStore.instance.prependActivity('User Created', '${_firstCtrl.text} ${_lastCtrl.text}');
      if (mounted) setState(() { _done = true; _loading = false; });
      widget.onDone?.call();
      Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.pop(context); });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'User Created!', '${_firstCtrl.text} ${_lastCtrl.text}', Icons.person_rounded);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Create User Account', Icons.person_add_rounded, AppColors.blue),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('First Name'), _tf(_firstCtrl, 'First name')])),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Last Name'), _tf(_lastCtrl, 'Last name')])),
        ]),
        _label('Email'), _tf(_emailCtrl, 'email@school.com', type: TextInputType.emailAddress),
        _label('Password'), _tf(_passCtrl, 'Temporary password', obscure: true),
        if (_error != null) _errBox(_error!),
        const SizedBox(height: 20),
        _submitBtn('Create User', _loading, _submit),
      ]),
    );
  }
}

// ── Assign Role to User ────────────────────────────────────────────────────

void showAssignRole(BuildContext ctx, {required List<TenantUser> users, required List<AppRole> roles, VoidCallback? onDone}) =>
    showSheet(ctx, _AssignRoleSheet(users: users, roles: roles, onDone: onDone));

class _AssignRoleSheet extends StatefulWidget {
  final List<TenantUser> users;
  final List<AppRole>    roles;
  final VoidCallback?    onDone;
  const _AssignRoleSheet({required this.users, required this.roles, this.onDone});
  @override State<_AssignRoleSheet> createState() => _AssignRoleSheetState();
}
class _AssignRoleSheetState extends State<_AssignRoleSheet> {
  String? _userId;
  String? _roleId;
  bool _loading = false;
  bool _done    = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _userId = widget.users.isNotEmpty ? widget.users.first.id : null;
    _roleId = widget.roles.isNotEmpty ? widget.roles.first.id : null;
  }

  Future<void> _submit() async {
    if (_userId == null || _roleId == null) { setState(() => _error = 'Select a user and a role.'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService().assignUserRole(_userId!, _roleId!);
      AppStore.instance.prependActivity('Role Assigned', 'User → ${widget.roles.firstWhere((r) => r.id == _roleId).name}');
      if (mounted) setState(() { _done = true; _loading = false; });
      widget.onDone?.call();
      Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.pop(context); });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Role Assigned!', 'User successfully assigned to role.', Icons.verified_user_rounded);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Assign Role to User', Icons.assignment_ind_rounded, AppColors.navy),
        const SizedBox(height: 20),
        _label('User'),
        _apiDropdown<TenantUser>(widget.users, _userId, (u) => '${u.fullName.isNotEmpty ? u.fullName : u.email}', (v) => setState(() => _userId = v)),
        _label('Role'),
        _apiDropdown<AppRole>(widget.roles, _roleId, (r) => r.name, (v) => setState(() => _roleId = v)),
        if (_error != null) _errBox(_error!),
        const SizedBox(height: 20),
        _submitBtn('Assign Role', _loading, _submit),
      ]),
    );
  }
}

// ── Parent-Student Mapping ─────────────────────────────────────────────────

void showAddMapping(BuildContext ctx, {VoidCallback? onDone}) =>
    showSheet(ctx, _AddMappingSheet(onDone: onDone), tall: true);

class _AddMappingSheet extends StatefulWidget {
  final VoidCallback? onDone;
  const _AddMappingSheet({this.onDone});
  @override State<_AddMappingSheet> createState() => _AddMappingSheetState();
}
class _AddMappingSheetState extends State<_AddMappingSheet> {
  List<ParentProfile>  _parents  = [];
  List<StudentProfile> _students = [];
  String? _parentId;
  String? _studentId;
  String _relationship = 'Father';
  bool _loading = true;
  bool _saving  = false;
  bool _done    = false;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
    try {
      final results = await Future.wait([ApiService().getParents(), ApiService().getStudents()]);
      if (!mounted) return;
      final parents  = (results[0] as PaginatedResult<ParentProfile>).results;
      final students = (results[1] as PaginatedResult<StudentProfile>).results;
      setState(() {
        _parents  = parents;
        _students = students;
        _parentId  = parents.isNotEmpty  ? parents.first.id  : null;
        _studentId = students.isNotEmpty ? students.first.id : null;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _submit() async {
    if (_parentId == null || _studentId == null) { setState(() => _error = 'Select a parent and a student.'); return; }
    setState(() { _saving = true; _error = null; });
    try {
      await ApiService().createMapping(_parentId!, _studentId!, _relationship);
      AppStore.instance.prependActivity('Parent Mapped', 'Parent → Student');
      if (mounted) setState(() { _done = true; _saving = false; });
      widget.onDone?.call();
      Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.pop(context); });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Mapping Created!', 'Parent linked to student.', Icons.share_rounded);
    if (_loading) return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: AppColors.blue)));

    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Add Parent–Student Mapping', Icons.share_rounded, AppColors.amber),
        const SizedBox(height: 20),
        _label('Parent'),
        _apiDropdown<ParentProfile>(_parents, _parentId, (p) => p.fullName, (v) => setState(() => _parentId = v)),
        _label('Student'),
        _apiDropdown<StudentProfile>(_students, _studentId, (s) => '${s.fullName} (${s.enrollmentNumber ?? "—"})', (v) => setState(() => _studentId = v)),
        _label('Relationship'),
        _dropdown(_relationship, ['Father','Mother','Guardian','Step-Father','Step-Mother'], (v) => setState(() => _relationship = v!)),
        if (_error != null) _errBox(_error!),
        const SizedBox(height: 20),
        _submitBtn('Create Mapping', _saving, _submit),
      ]),
    );
  }
}

// ── Teacher Assignment ─────────────────────────────────────────────────────

void showAddTeacherAssignment(BuildContext ctx, {VoidCallback? onDone}) =>
    showSheet(ctx, _AddTeacherAssignmentSheet(onDone: onDone), tall: true);

class _AddTeacherAssignmentSheet extends StatefulWidget {
  final VoidCallback? onDone;
  const _AddTeacherAssignmentSheet({this.onDone});
  @override State<_AddTeacherAssignmentSheet> createState() => _AddTeacherAssignmentSheetState();
}
class _AddTeacherAssignmentSheetState extends State<_AddTeacherAssignmentSheet> {
  List<TeacherProfile> _teachers = [];
  List<AcademicYear>   _years    = [];
  List<ClassLevel>     _classes  = [];
  List<Section>        _sections = [];
  List<Subject>        _subjects = [];
  String? _teacherId;
  String? _yearId;
  String? _classId;
  String? _sectionId;
  String? _subjectId;
  bool _isClassTeacher = false;
  bool _loading = true;
  bool _saving  = false;
  bool _done    = false;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
    try {
      final results = await Future.wait([
        ApiService().getTeachers(),
        ApiService().getAcademicYears(),
        ApiService().getClassLevels(),
        ApiService().getSections(),
        ApiService().getSubjects(),
      ]);
      if (!mounted) return;
      final teachers = (results[0] as PaginatedResult<TeacherProfile>).results;
      final years    = (results[1] as PaginatedResult<AcademicYear>).results;
      final classes  = (results[2] as PaginatedResult<ClassLevel>).results;
      final sects    = (results[3] as PaginatedResult<Section>).results;
      final subjects = (results[4] as PaginatedResult<Subject>).results;
      setState(() {
        _teachers  = teachers;  _teacherId  = teachers.isNotEmpty  ? teachers.first.id  : null;
        _years     = years;     _yearId     = years.isNotEmpty     ? years.first.id     : null;
        _classes   = classes;   _classId    = classes.isNotEmpty   ? classes.first.id   : null;
        _sections  = sects;     _sectionId  = sects.isNotEmpty     ? sects.first.id     : null;
        _subjects  = subjects;  _subjectId  = subjects.isNotEmpty  ? subjects.first.id  : null;
        _loading   = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _submit() async {
    if ([_teacherId, _yearId, _classId, _sectionId, _subjectId].any((v) => v == null)) {
      setState(() => _error = 'All fields are required.'); return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      await ApiService().createTeacherAssignment({
        'teacher':          _teacherId!,
        'academic_year':    _yearId!,
        'class_level':      _classId!,
        'section':          _sectionId!,
        'subject':          _subjectId!,
        'is_class_teacher': _isClassTeacher,
      });
      AppStore.instance.prependActivity('Teacher Assigned', 'Assignment created');
      if (mounted) setState(() { _done = true; _saving = false; });
      widget.onDone?.call();
      Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.pop(context); });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Teacher Assigned!', 'Assignment created successfully.', Icons.menu_book_rounded);
    if (_loading) return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: AppColors.blue)));

    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Assign Teacher', Icons.menu_book_rounded, AppColors.teal),
        const SizedBox(height: 20),
        _label('Teacher'),
        _apiDropdown<TeacherProfile>(_teachers, _teacherId, (t) => '${t.fullName} (${t.employeeId ?? "—"})', (v) => setState(() => _teacherId = v)),
        _label('Academic Year'),
        _apiDropdown<AcademicYear>(_years, _yearId, (y) => y.name, (v) => setState(() => _yearId = v)),
        _label('Class Level'),
        _apiDropdown<ClassLevel>(_classes, _classId, (c) => c.name, (v) => setState(() => _classId = v)),
        _label('Section'),
        _apiDropdown<Section>(_sections, _sectionId, (s) => '${s.classLevelName ?? ""} — ${s.name}', (v) => setState(() => _sectionId = v)),
        _label('Subject'),
        _apiDropdown<Subject>(_subjects, _subjectId, (s) => '${s.name}${s.code != null ? " (${s.code})" : ""}', (v) => setState(() => _subjectId = v)),
        Row(children: [
          Checkbox(value: _isClassTeacher, activeColor: AppColors.blue, onChanged: (v) => setState(() => _isClassTeacher = v ?? false)),
          Text('Designate as Class Teacher', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2)),
        ]),
        if (_error != null) _errBox(_error!),
        const SizedBox(height: 20),
        _submitBtn('Create Assignment', _saving, _submit),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS FOR NEW MODALS
// ─────────────────────────────────────────────────────────────────────────────

Widget _errBox(String msg) => Container(
  margin: const EdgeInsets.only(top: 8),
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(color: AppColors.redLight, borderRadius: BorderRadius.circular(rMd), border: Border.all(color: const Color(0xFFFCA5A5))),
  child: Row(children: [
    const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.red),
    const SizedBox(width: 8),
    Expanded(child: Text(msg, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.red))),
  ]),
);

Widget _submitBtn(String label, bool loading, VoidCallback onTap) =>
  GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.gradA, AppColors.gradC], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(rMd), boxShadow: shadowMd),
      child: Center(child: loading
        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
    ),
  );

/// Generic API-model dropdown — avoids repeating boilerplate
Widget _apiDropdown<T>(
  List<T> items,
  String? value,
  String Function(T) label,
  void Function(String?) onChanged,
) {
  // Map id getter per type
  String getId(T item) {
    if (item is AcademicYear) return item.id;
    if (item is ClassLevel)   return item.id;
    if (item is Section)      return item.id;
    if (item is Subject)      return item.id;
    if (item is TeacherProfile) return item.id;
    if (item is StudentProfile) return item.id;
    if (item is ParentProfile)  return item.id;
    if (item is TenantUser)     return item.id;
    if (item is AppRole)        return item.id;
    return '';
  }

  final validValue = items.any((i) => getId(i) == value) ? value : (items.isNotEmpty ? getId(items.first) : null);

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(rMd)),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(
      value: validValue,
      isExpanded: true,
      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text1),
      items: items.map((i) => DropdownMenuItem(value: getId(i), child: Text(label(i), overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
    )),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// END NEW API-BACKED ADMIN MODALS
// ─────────────────────────────────────────────────────────────────────────────
