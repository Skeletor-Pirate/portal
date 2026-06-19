import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../widgets/builders.dart';
import '../../widgets/interactive.dart';

class NotificationsHub extends StatelessWidget {
  const NotificationsHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Notifications Hub', style: GoogleFonts.dmSerifDisplay(color: AppColors.text1, fontSize: 24)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text1),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const ChipRow(chips: ['All', 'Academic', 'Attendance', 'Financial']),
          const SizedBox(height: 16),
          _dateLabel('Today'),
          appCard(Column(children: [
            _notifItem(Icons.fact_check_rounded, 'Attendance Alert', 'Arjun was marked Late for 1st period Mathematics.', '8:15 AM', AppColors.amber),
            const Divider(height: 1, color: AppColors.border),
            _notifItem(Icons.grade_rounded, 'New Grade Posted', 'Physics Midterm results are now available. Score: 88%', '10:30 AM', AppColors.green),
          ])),
          const SizedBox(height: 24),
          _dateLabel('Yesterday'),
          appCard(Column(children: [
            _notifItem(Icons.auto_awesome_rounded, 'AI Insight Generated', 'A new personalized study roadmap is ready for review.', '4:00 PM', AppColors.blue),
            const Divider(height: 1, color: AppColors.border),
            _notifItem(Icons.payment_rounded, 'Fee Reminder', 'Term 2 Tuition Fee is due in 5 days.', '9:00 AM', AppColors.red),
          ])),
          const SizedBox(height: 24),
          _dateLabel('This Week'),
          appCard(Column(children: [
            _notifItem(Icons.assignment_rounded, 'Assignment Missing', 'History Essay is past due. Please submit ASAP.', 'Mon, 2:00 PM', AppColors.amber),
          ])),
        ]),
      ),
    );
  }

  Widget _dateLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12, left: 4),
    child: Text(text.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.text4)),
  );

  Widget _notifItem(IconData icon, String title, String body, String time, Color color) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(rMd)),
        child: Icon(icon, size: 20, color: color),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text1)),
          Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text4)),
        ]),
        const SizedBox(height: 4),
        Text(body, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3, height: 1.5)),
      ])),
    ]),
  );
}
