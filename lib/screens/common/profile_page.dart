import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../models/role_config.dart';
import '../../widgets/builders.dart';

class ProfilePage extends StatelessWidget {
  final UserRole role;
  const ProfilePage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final cfg = kRoles[role]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heroPortrait(cfg.avatarAsset, cfg.school),
        profileInfo(cfg.name, cfg.label, cfg.idLabel),
        pageTitle('Profile & Settings'),
        secLabel('Account'),
        appCard(Column(children: [
          ToggleRow(label: 'Push Notifications', desc: 'Alerts on your device', initialValue: true),
          ToggleRow(label: 'Email Digests', desc: 'Daily summary to inbox', initialValue: true),
          ToggleRow(label: 'Biometric Login', desc: 'Face ID / Fingerprint'),
        ])),
        secLabel('Security'),
        appCard(Column(children: [
          ...[
            'Change Password', 'Two-Factor Auth',
            'Active Sessions', 'Privacy Settings'
          ].map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(item,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
              const Icon(Icons.chevron_right, color: AppColors.text4),
            ]),
          )),
        ])),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
          child: dangerBtn('Sign Out'),
        ),
      ],
    );
  }
}
