// ─────────────────────────────────────────────────────────────────────────────
// INTERACTIVE LAYER — all modal sheets, dialogs, and stateful features
// Every action button wires here. Uses dummy data — no real API required.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
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

void showCreateAssignment(BuildContext ctx) {
  showSheet(ctx, _CreateAssignmentSheet(), tall: true);
}

class _CreateAssignmentSheet extends StatefulWidget {
  @override
  State<_CreateAssignmentSheet> createState() => _CreateAssignmentSheetState();
}
class _CreateAssignmentSheetState extends State<_CreateAssignmentSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  String _subject  = 'Science 10-A';
  String _due      = 'Apr 20, 2025';
  bool   _done     = false;

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Assignment Created!',
        'Students in $_subject have been notified.', Icons.note_add_rounded);

    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Create Assignment', Icons.note_add_rounded, AppColors.blue),
        const SizedBox(height: 20),
        _label('Title'),
        _tf(_titleCtrl, 'e.g. Chapter 5: Forces Lab Report'),
        _label('Class'),
        _dropdown(_subject, ['Science 10-A','Physics 11-B','Chemistry 12'],
            (v) => setState(() => _subject = v!)),
        _label('Due Date'),
        _dropdown(_due, ['Apr 15, 2025','Apr 20, 2025','Apr 25, 2025','May 1, 2025'],
            (v) => setState(() => _due = v!)),
        _label('Instructions (optional)'),
        _tf(_descCtrl, 'Write detailed instructions here...', lines: 3),
        const SizedBox(height: 24),
        navyBtn('Create Assignment', onTap: () {
          if (_titleCtrl.text.trim().isEmpty) {
            showToast(context, 'Please enter a title', color: AppColors.red, icon: Icons.error_outline_rounded);
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

void showScheduleExam(BuildContext ctx) => showSheet(ctx, _ScheduleExamSheet(), tall: true);

class _ScheduleExamSheet extends StatefulWidget {
  @override
  State<_ScheduleExamSheet> createState() => _ScheduleExamSheetState();
}
class _ScheduleExamSheetState extends State<_ScheduleExamSheet> {
  final _nameCtrl = TextEditingController();
  String _class   = 'Science 10-A';
  String _date    = 'Apr 22, 2025';
  String _type    = 'Written';
  bool   _done    = false;

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Exam Scheduled!',
        '${_nameCtrl.text} · $_class · $_date', Icons.edit_calendar_rounded);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Schedule Exam', Icons.edit_calendar_rounded, AppColors.amber),
        const SizedBox(height: 20),
        _label('Exam Name'),
        _tf(_nameCtrl, 'e.g. Mid-Term Examination'),
        _label('Class'),
        _dropdown(_class, ['Science 10-A','Physics 11-B','Chemistry 12'],
            (v) => setState(() => _class = v!)),
        _label('Date'),
        _dropdown(_date, ['Apr 15, 2025','Apr 18, 2025','Apr 22, 2025','Apr 25, 2025'],
            (v) => setState(() => _date = v!)),
        _label('Type'),
        _dropdown(_type, ['Written','Practical','MCQ','Oral'],
            (v) => setState(() => _type = v!)),
        const SizedBox(height: 24),
        navyBtn('Schedule Exam', onTap: () {
          if (_nameCtrl.text.trim().isEmpty) {
            showToast(context, 'Enter exam name', color: AppColors.red, icon: Icons.error_outline_rounded);
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

  static const _replies = {
    'physics': "Physics tip: For Newton's laws, remember F=ma. The net force equals mass times acceleration. For your Chapter 5 lab report, focus on measuring force and calculating resulting acceleration accurately.",
    'math': "For quadratic equations, use the formula x = (−b ± √(b²−4ac)) / 2a. Make sure to identify a, b, and c from the standard form ax²+bx+c=0 first.",
    'english': "For The Great Gatsby essay: focus on the theme of the American Dream vs reality. Gatsby represents the corrupted version — wealth without moral foundation. Use specific quotes from Chapter 5 and 9.",
    'exam': "Exam prep strategy: Start with past papers, identify weak topics, then do focused revision. Sleep 8 hrs before the exam. Arrive 15 minutes early.",
    'attendance': "Your attendance is 96% — well above the 75% minimum. Keep it up! Consistent attendance correlates strongly with better grades.",
    'grade': "Your current average is 87.4% — an A−. You're doing great! To push into A territory, focus on Chemistry (79%) and English (84%). Those have the most room for improvement.",
  };

  String _getReply(String q) {
    final lower = q.toLowerCase();
    for (final k in _replies.keys) {
      if (lower.contains(k)) return _replies[k]!;
    }
    return "Great question! Based on your current performance, I'd suggest reviewing your notes from the past week and focusing on practice problems. Would you like tips on a specific subject?";
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    setState(() {
      _msgs.add(_ChatMsg(true, text));
      _thinking = true;
    });
    _scrollDown();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _msgs.add(_ChatMsg(false, _getReply(text)));
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

void showAddStudent(BuildContext ctx) => showSheet(ctx, _AddProfileSheet(type: 'Student'), tall: true);
void showAddTeacher(BuildContext ctx) => showSheet(ctx, _AddProfileSheet(type: 'Teacher'), tall: true);
void showAddParent(BuildContext ctx)  => showSheet(ctx, _AddProfileSheet(type: 'Parent'),  tall: true);

class _AddProfileSheet extends StatefulWidget {
  final String type;
  const _AddProfileSheet({required this.type});
  @override
  State<_AddProfileSheet> createState() => _AddProfileSheetState();
}
class _AddProfileSheetState extends State<_AddProfileSheet> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _idCtrl    = TextEditingController();
  String _grade    = 'Grade 10';
  bool   _done     = false;

  @override
  void dispose() {
    for (final c in [_firstCtrl, _lastCtrl, _emailCtrl, _idCtrl]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context,
        '${widget.type} Profile Created!',
        '${_firstCtrl.text} ${_lastCtrl.text} added successfully.',
        Icons.person_add_rounded);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Add ${widget.type}', Icons.person_add_rounded, AppColors.blue),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('First Name'),
            _tf(_firstCtrl, 'First name'),
          ])),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('Last Name'),
            _tf(_lastCtrl, 'Last name'),
          ])),
        ]),
        _label('Email'),
        _tf(_emailCtrl, 'email@school.com', type: TextInputType.emailAddress),
        if (widget.type == 'Student') ...[
          _label('Grade / Class'),
          _dropdown(_grade, ['Grade 9','Grade 10','Grade 11','Grade 12'],
              (v) => setState(() => _grade = v!)),
          _label('Roll Number'),
          _tf(_idCtrl, 'e.g. 042', type: TextInputType.number),
        ] else if (widget.type == 'Teacher') ...[
          _label('Employee ID'),
          _tf(_idCtrl, 'e.g. EMP-042'),
          _label('Subject Specialisation'),
          _dropdown(_grade, ['Mathematics','Physics','Chemistry','English','History','Biology'],
              (v) => setState(() => _grade = v!)),
        ] else ...[
          _label('Guardian ID'),
          _tf(_idCtrl, 'e.g. PR-042'),
        ],
        const SizedBox(height: 24),
        navyBtn('Create Profile', onTap: () {
          if (_firstCtrl.text.trim().isEmpty || _lastCtrl.text.trim().isEmpty) {
            showToast(context, 'Enter first and last name',
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
    {int lines = 1, TextInputType? type}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        maxLines: lines,
        keyboardType: type,
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

void showBulkPromote(BuildContext ctx) =>
    showSheet(ctx, _BulkPromoteSheet());

class _BulkPromoteSheet extends StatefulWidget {
  @override
  State<_BulkPromoteSheet> createState() => _BulkPromoteSheetState();
}
class _BulkPromoteSheetState extends State<_BulkPromoteSheet> {
  String _from = 'Grade 10';
  String _to   = 'Grade 11';
  bool   _done = false;
  final Set<String> _selected = {'Maya Johnson', 'Arjun Mehta', 'Leo Chen'};
  static const _students = ['Maya Johnson', 'Arjun Mehta', 'Leo Chen', 'Zara Williams', 'Sofia Rodriguez'];

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Students Promoted!',
        '${_selected.length} students moved from $_from to $_to.', Icons.trending_up_rounded);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Bulk Promote', Icons.trending_up_rounded, AppColors.teal),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('From Grade'),
            _dropdown(_from, ['Grade 9','Grade 10','Grade 11'], (v) => setState(() => _from = v!)),
          ])),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 14),
            child: const Icon(Icons.arrow_forward_rounded, color: AppColors.text3),
          ),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('To Grade'),
            _dropdown(_to, ['Grade 10','Grade 11','Grade 12'], (v) => setState(() => _to = v!)),
          ])),
        ]),
        _label('Select Students'),
        ..._students.map((s) => GestureDetector(
          onTap: () => setState(() => _selected.contains(s) ? _selected.remove(s) : _selected.add(s)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _selected.contains(s) ? AppColors.blueLight : AppColors.surface,
              borderRadius: BorderRadius.circular(rMd),
              border: Border.all(
                  color: _selected.contains(s) ? AppColors.blue : AppColors.border, width: 1.5),
            ),
            child: Row(children: [
              Icon(_selected.contains(s) ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                  size: 18, color: _selected.contains(s) ? AppColors.blue : AppColors.text4),
              const SizedBox(width: 10),
              Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600,
                  color: _selected.contains(s) ? AppColors.blue : AppColors.text1)),
            ]),
          ),
        )),
        const SizedBox(height: 16),
        navyBtn('Promote ${_selected.length} Student${_selected.length == 1 ? '' : 's'}',
          onTap: () {
            if (_selected.isEmpty) {
              showToast(context, 'Select at least one student', color: AppColors.red, icon: Icons.error_outline_rounded);
              return;
            }
            setState(() => _done = true);
            Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.pop(context); });
          }),
      ]),
    );
  }
}

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

void showEnrolStudent(BuildContext ctx) =>
    showSheet(ctx, _EnrolStudentSheet(), tall: true);

class _EnrolStudentSheet extends StatefulWidget {
  @override
  State<_EnrolStudentSheet> createState() => _EnrolStudentSheetState();
}
class _EnrolStudentSheetState extends State<_EnrolStudentSheet> {
  final _nameCtrl  = TextEditingController();
  String _grade    = 'Grade 10';
  String _year     = '2024–25';
  bool   _done     = false;

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_done) return _successPanel(context, 'Student Enrolled!',
        '${_nameCtrl.text} · $_grade · $_year', Icons.school_rounded);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetTitle('Enrol Student', Icons.school_rounded, AppColors.green),
        const SizedBox(height: 20),
        _label('Student Name / ID'),
        _tf(_nameCtrl, 'Search or enter student name…'),
        _label('Grade / Class'),
        _dropdown(_grade, ['Grade 9','Grade 10','Grade 11','Grade 12'],
            (v) => setState(() => _grade = v!)),
        _label('Academic Year'),
        _dropdown(_year, ['2024–25','2025–26'],
            (v) => setState(() => _year = v!)),
        const SizedBox(height: 24),
        navyBtn('Confirm Enrolment', onTap: () {
          if (_nameCtrl.text.trim().isEmpty) {
            showToast(context, 'Enter student name or ID',
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
