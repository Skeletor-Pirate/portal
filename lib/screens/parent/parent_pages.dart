import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../models/role_config.dart';
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

class _Dashboard extends StatelessWidget {
  const _Dashboard();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    heroPortrait(kRoles[UserRole.parent]!.avatarAsset, 'Westfield Academy'),
    profileInfo('Alexander Pierce', 'Guardian', 'Guardian ID: #8821'),
    pageTitle('Dashboard'),
    childCard(),
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
    secLabel('Recent Updates'),
    appCard(Padding(padding: const EdgeInsets.all(16), child: timeline([
      TlItem(title: 'Grade Posted',       sub: 'Math Mid-Term: 82/100 · B+',    time: 'Today',      color: AppColors.blue),
      TlItem(title: 'Attendance Alert',   sub: 'Late arrival on Apr 1',          time: '2 days ago', color: AppColors.amber),
      TlItem(title: 'Assignment Graded',  sub: 'History Essay: A · Great work!', time: '3 days ago', color: AppColors.green),
      TlItem(title: 'Fee Due Reminder',   sub: 'Term 2 fee due Apr 15',          time: 'Apr 1',      color: AppColors.red),
    ]))),
    const SizedBox(height: 16),
  ]);
}

class _ChildOverview extends StatelessWidget {
  const _ChildOverview();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Child Overview', subtitle: 'Arjun Mehta · Grade 10A · Term 2'),
    statGrid([
      StatItem(icon: Icons.bar_chart_rounded,    iconBg: AppColors.blueLight,  iconColor: AppColors.blue,  val: '88%', label: 'Overall Avg',    delta: 3),
      StatItem(icon: Icons.fact_check_rounded,   iconBg: AppColors.greenLight, iconColor: AppColors.green, val: '91%', label: 'Attendance',     delta: 1),
      StatItem(icon: Icons.description_rounded,  iconBg: AppColors.amberLight, iconColor: AppColors.amber, val: '2',   label: 'Pending Tasks',  delta: 0),
      StatItem(icon: Icons.emoji_events_rounded, iconBg: AppColors.tealLight,  iconColor: AppColors.teal,  val: 'B+',  label: 'GPA Band',       delta: 0),
    ]),
    secLabel("Today's Schedule"),
    appCard(ttRows([
      TtItem(time: '08:00–09:00', subject: 'Mathematics', room: 'Room 101', status: 'Done',     barColor: AppColors.blue,  badgeBg: AppColors.greenLight,    badgeColor: AppColors.green),
      TtItem(time: '09:15–10:15', subject: 'Physics',     room: 'Lab 2',    status: 'Active',   barColor: AppColors.teal,  badgeBg: AppColors.blueLight,     badgeColor: AppColors.blue),
      TtItem(time: '11:00–12:00', subject: 'English',     room: 'Room 204', status: 'Upcoming', barColor: AppColors.navy,  badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3),
      TtItem(time: '13:30–14:30', subject: 'History',     room: 'Room 108', status: 'Upcoming', barColor: AppColors.amber, badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3),
    ])),
    secLabel('Upcoming Deadlines'),
    appCard(asgnCards([
      AsgItem(sub: 'MATHEMATICS', title: 'Quadratic Equations Set B', due: 'Tomorrow', barColor: AppColors.blue,  badge: 'Pending',   badgeBg: AppColors.amberLight, badgeColor: AppColors.amber),
      AsgItem(sub: 'PHYSICS',     title: 'Chapter 4 Problems',        due: 'Apr 12',   barColor: AppColors.teal,  badge: 'Submitted', badgeBg: AppColors.blueLight,  badgeColor: AppColors.blue),
    ])),
    Padding(padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
        child: outlineBtn('Message Teacher', onTap: () => showMessageTeacher(context))),
    const SizedBox(height: 16),
  ]);
}

class _Grades extends StatelessWidget {
  const _Grades();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Grades & Report Card', subtitle: 'Arjun Mehta · Term 2'),
    appCard(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('83.5%', style: GoogleFonts.dmSerifDisplay(fontSize: 26, color: AppColors.text1)),
            Text("Arjun's Average · Term 2", style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(gradient: blueGrad(), borderRadius: BorderRadius.circular(rFull)),
            child: Text('B+', style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ]),
      ),
      GradeBars(items: [
        GradeItem(subject: 'Mathematics', value: 82, color: AppColors.blue),
        GradeItem(subject: 'English',     value: 79, color: AppColors.navy),
        GradeItem(subject: 'Physics',     value: 91, color: AppColors.teal),
        GradeItem(subject: 'Chemistry',   value: 85, color: AppColors.green),
        GradeItem(subject: 'History',     value: 76, color: AppColors.amber),
      ]),
    ])),
    Padding(padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
        child: outlineBtn('Download Report Card',
            onTap: () => showDownloadMaterial(context, "Arjun's Report Card"))),
    const SizedBox(height: 16),
  ]);
}

class _Attendance extends StatelessWidget {
  const _Attendance();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Attendance', subtitle: "Arjun's attendance record"),
    appCard(Padding(padding: const EdgeInsets.all(14), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _attStat('91%', AppColors.green, 'Overall'),
        _attStat('46',  AppColors.blue,  'Present'),
        _attStat('3',   AppColors.red,   'Absent'),
        _attStat('2',   AppColors.amber, 'Late'),
      ]),
      const Divider(height: 28, color: AppColors.border),
      ProgressBar(label: 'Attendance Rate', value: 91, gradient: greenGrad()),
      const SizedBox(height: 8),
      Row(children: [
        const Icon(Icons.info_outline_rounded, size: 12, color: AppColors.text4),
        const SizedBox(width: 5),
        Text('Minimum required: 75% · Arjun is on track',
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
      ]),
    ]))),
    const SizedBox(height: 16),
  ]);
  Widget _attStat(String val, Color color, String label) => Column(children: [
    Text(val, style: GoogleFonts.dmSerifDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
    Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4)),
  ]);
}

class _Assignments extends StatelessWidget {
  const _Assignments();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Assignments', subtitle: "Arjun's tasks"),
    const ChipRow(chips: ['All', 'Pending', 'Submitted', 'Graded']),
    appCard(asgnCards([
      AsgItem(sub: 'MATHEMATICS', title: 'Quadratic Equations Set B', due: 'Tomorrow', barColor: AppColors.blue,  badge: 'Pending',    badgeBg: AppColors.amberLight, badgeColor: AppColors.amber),
      AsgItem(sub: 'PHYSICS',     title: 'Chapter 4 Problems',        due: 'Mar 30',   barColor: AppColors.teal,  badge: 'Submitted',  badgeBg: AppColors.blueLight,  badgeColor: AppColors.blue),
      AsgItem(sub: 'HISTORY',     title: 'WWII Analysis Essay',       due: 'Mar 25',   barColor: AppColors.green, badge: 'Graded · A', badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
    ])),
    Padding(padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
        child: outlineBtn('Message Teacher about Assignment',
            onTap: () => showMessageTeacher(context))),
    const SizedBox(height: 16),
  ]);
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
