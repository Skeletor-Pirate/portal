import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../models/role_config.dart';
import '../../widgets/builders.dart';
import '../../services/app_store.dart';
import '../../services/api_service.dart';

class ProfilePage extends StatelessWidget {
  final UserRole role;
  const ProfilePage({super.key, required this.role});
  @override
  Widget build(BuildContext context) {
    final cfg = kRoles[role]!;
    final store = AppStore.instance;
    final name   = store.currentUserName.isNotEmpty ? store.currentUserName : cfg.name;
    final email  = store.currentUserEmail.isNotEmpty ? store.currentUserEmail : '';
    final school = store.currentSchool.isNotEmpty ? store.currentSchool : cfg.school;
    final roleLabel = store.currentRoles.isNotEmpty
        ? store.currentRoles.join(', ')
        : cfg.label;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      heroPortrait(cfg.avatarAsset, school),
      profileInfo(name, roleLabel, email.isNotEmpty ? email : cfg.idLabel),
      pageTitle('Profile & Settings'),
      if (store.isRealLogin) ...[
        secLabel('Session Info'),
        appCard(Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Name', name),
            if (email.isNotEmpty) _infoRow('Email', email),
            _infoRow('School', school),
            _infoRow('Role', roleLabel),
            if (store.studentProfileId != null) _infoRow('Student Profile', 'Linked'),
            if (store.teacherProfileId != null) _infoRow('Teacher Profile', 'Linked'),
            if (store.parentProfileId  != null) _infoRow('Parent Profile',  'Linked'),
          ],
        ))),
      ],
      secLabel('Account'),
      appCard(Column(children: [
        ToggleRow(label: 'Push Notifications', desc: 'Alerts on your device', initialValue: true),
        ToggleRow(label: 'Email Digests',       desc: 'Daily summary to inbox', initialValue: true),
        ToggleRow(label: 'Biometric Login',     desc: 'Face ID / Fingerprint'),
      ])),
      secLabel('Security'),
      appCard(Column(children: [
        ...[
          ('Change Password',  Icons.key_rounded),
          ('Two-Factor Auth',  Icons.verified_user_rounded),
          ('Active Sessions',  Icons.monitor_rounded),
          ('Privacy Settings', Icons.lock_rounded),
        ].map((item) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(rSm)),
              child: Center(child: Icon(item.$2, size: 15, color: AppColors.blue)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(item.$1, style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1))),
            const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.text4),
          ]),
        )),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 20), child: dangerBtn('Sign Out', onTap: () {
        TokenStore.clear();
        AppStore.instance.clearSession();
        Navigator.of(context).popUntil((route) => route.isFirst);
      })),
    ]);
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      SizedBox(width: 110, child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text3))),
      Expanded(child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text1))),
    ]),
  );
}
