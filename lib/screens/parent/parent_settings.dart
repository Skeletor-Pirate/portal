import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../widgets/builders.dart';

class ParentSettings extends StatefulWidget {
  const ParentSettings({super.key});

  @override
  State<ParentSettings> createState() => _ParentSettingsState();
}

class _ParentSettingsState extends State<ParentSettings> {
  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _attendanceWarnings = true;
  bool _gradeUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Settings', style: GoogleFonts.dmSerifDisplay(color: AppColors.text1, fontSize: 24)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text1),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          
          secLabel('Linked Students'),
          appCard(Column(children: [
            _linkedStudent('Arjun Mehta', 'Grade 8 • Section B', true),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                const Icon(Icons.add_circle_outline_rounded, size: 20, color: AppColors.blue),
                const SizedBox(width: 12),
                Text('Link Another Child', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.blue)),
              ]),
            ),
          ])),
          const SizedBox(height: 24),

          secLabel('Notification Preferences'),
          appCard(Column(children: [
            _toggleItem('Push Notifications', 'Receive alerts on your device.', _pushNotifications, (v) => setState(() => _pushNotifications = v)),
            const Divider(height: 1, color: AppColors.border),
            _toggleItem('Email Alerts', 'Receive weekly summaries via email.', _emailAlerts, (v) => setState(() => _emailAlerts = v)),
            const Divider(height: 1, color: AppColors.border),
            _toggleItem('Attendance Warnings', 'Immediate alerts if child is late/absent.', _attendanceWarnings, (v) => setState(() => _attendanceWarnings = v)),
            const Divider(height: 1, color: AppColors.border),
            _toggleItem('Grade Updates', 'Alerts when new grades are posted.', _gradeUpdates, (v) => setState(() => _gradeUpdates = v)),
          ])),
          const SizedBox(height: 24),

          secLabel('Account & Billing'),
          appCard(Column(children: [
            _actionItem(Icons.credit_card_rounded, 'Payment Methods', 'Manage saved cards and UPI IDs.'),
            const Divider(height: 1, color: AppColors.border),
            _actionItem(Icons.receipt_long_rounded, 'Billing History', 'View past invoices and tax receipts.'),
          ])),
          const SizedBox(height: 24),

          secLabel('Danger Zone'),
          appCard(Column(children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                const Icon(Icons.logout_rounded, size: 20, color: AppColors.red),
                const SizedBox(width: 12),
                Text('Log Out', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.red)),
              ]),
            ),
          ])),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _linkedStudent(String name, String details, bool active) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(rMd)),
        child: const Center(child: Icon(Icons.person_rounded, color: AppColors.blue)),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text1)),
        const SizedBox(height: 2),
        Text(details, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3)),
      ])),
      if (active) appBadge('Active', bg: AppColors.greenLight, color: AppColors.green),
    ]),
  );

  Widget _toggleItem(String title, String desc, bool value, ValueChanged<bool> onChanged) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text1)),
        const SizedBox(height: 4),
        Text(desc, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3)),
      ])),
      Switch(value: value, onChanged: onChanged, activeColor: AppColors.blue),
    ]),
  );

  Widget _actionItem(IconData icon, String title, String desc) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(children: [
      Icon(icon, size: 22, color: AppColors.text3),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text1)),
        const SizedBox(height: 2),
        Text(desc, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3)),
      ])),
      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.text4),
    ]),
  );
}
