import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme.dart';
import '../../services/app_store.dart';
import '../../services/api_service.dart';
import '../../models/role_config.dart';
import '../../widgets/builders.dart';
import '../login_screen.dart';

class ProfilePage extends StatefulWidget {
  final UserRole role;
  const ProfilePage({super.key, required this.role});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final ctx = store.profileContext;
    final role = store.detectedProfileType ?? 'user';
    final cfg = kRoles[UserRole.values.firstWhere((e) => e.name == role, orElse: () => UserRole.student)]!;
    
    final name = store.currentUserName.isNotEmpty ? store.currentUserName : 'Unknown User';
    final school = store.currentSchool.isNotEmpty ? store.currentSchool : 'Beta High';
    final email = ctx?.identity.email ?? '';
    
    final roleLabel = ctx != null && ctx.roles.isNotEmpty
        ? ctx.roles.first[0].toUpperCase() + ctx.roles.first.substring(1)
        : cfg.label;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Clean Profile Header (React-style) ────────────────────────────
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(rXl),
            boxShadow: shadowMd,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Square
              ValueListenableBuilder<String?>(
                valueListenable: store.profileImageUrl,
                builder: (_, imageUrl, __) => Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.blueLight,
                        borderRadius: BorderRadius.circular(rMd),
                      ),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(rMd),
                              child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _initials(name)),
                            )
                          : _initials(name),
                    ),
                    if (store.isRealLogin)
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: GestureDetector(
                          onTap: _uploading ? null : _pickAndUpload,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: shadowSm,
                            ),
                            child: _uploading
                                ? const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Name and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text1)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(rFull)),
                          child: Text('ACTIVE STATUS', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.blue)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.blue),
                        const SizedBox(width: 4),
                        Text(roleLabel, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.blue)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(email.isNotEmpty ? email : cfg.idLabel, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2)),
                    const SizedBox(height: 4),
                    Text(school, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
      pageTitle('Profile & Settings'),
      if (store.isRealLogin) ...[
        secLabel('Session Info'),
        appCard(Column(children: [
          _infoRow('Name', name),
          _infoRow('Email', email),
          _infoRow('School', school),
          _infoRow('Role', roleLabel),
          if (ctx != null) ...[
            if (ctx.profiles.teacher.exists) _infoRow('Teacher Profile', 'Linked'),
            if (ctx.profiles.student.exists) _infoRow('Student Profile', 'Linked'),
            if (ctx.profiles.parent.exists) _infoRow('Parent Profile', 'Linked'),
          ],
        ])),
      ],
      secLabel('Account'),
      appCard(Column(children: [
        ToggleRow(label: 'Push Notifications', desc: 'Alerts on your device', initialValue: true),
        ToggleRow(label: 'Email Digests', desc: 'Daily summary to inbox', initialValue: true),
        ToggleRow(label: 'Biometric Login', desc: 'Face ID / Fingerprint', initialValue: false),
      ])),
      secLabel('Security'),
      appCard(Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(rSm)),
            child: const Center(child: Icon(Icons.lock_outline_rounded, size: 15, color: AppColors.blue)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text('Change Password', style: GoogleFonts.plusJakartaSans(
              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1))),
          const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.text4),
        ])),
      ])),
      secLabel('Support'),
      appCard(Column(children: [
        ...[
          ('Help Center', Icons.help_outline_rounded),
          ('Terms of Service', Icons.article_outlined),
          ('Privacy Policy', Icons.privacy_tip_outlined),
        ].map((item) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 20), child: dangerBtn('Sign Out', onTap: () async {
        await AppStore.instance.clearSession();
        if (context.mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
      })),
    ]);
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16, top: 8),
    child: Row(children: [
      SizedBox(width: 110, child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text3))),
      Expanded(child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text1))),
    ]),
  );

  Widget _initials(String name) {
    final parts = name.split(' ');
    String ini = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0] : '?';
    if (parts.length > 1 && parts[1].isNotEmpty) ini += parts[1][0];
    return Center(
      child: Text(ini.toUpperCase(), style: GoogleFonts.plusJakartaSans(
        fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.blue,
      )),
    );
  }

  // ── Pick image and upload to R2 ─────────────────────────────────────────

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final fileName = picked.name;
    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
    
    String contentType = 'image/jpeg';
    if (ext == 'png') contentType = 'image/png';
    else if (ext == 'webp') contentType = 'image/webp';
    else if (ext == 'gif') contentType = 'image/gif';

    final ctx = AppStore.instance.profileContext;
    if (ctx == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No active profile context found')));
      return;
    }

    final String profileType;
    if (ctx.roles.any((r) => r.toLowerCase().contains('teacher')) || ctx.profiles.teacher.exists) {
      profileType = 'teacher';
    } else if (ctx.roles.any((r) => r.toLowerCase().contains('student')) || ctx.profiles.student.exists) {
      profileType = 'student';
    } else if (ctx.roles.any((r) => r.toLowerCase().contains('parent')) || ctx.profiles.parent.exists) {
      profileType = 'parent';
    } else {
      profileType = 'user'; // fallback
    }

    setState(() => _uploading = true);

    try {
      // 1. Get presigned URL
      final presigned = await ApiService().getProfileImageUploadUrl(
        fileName: fileName,
        contentType: contentType,
        profileType: profileType,
      );

      final uploadUrl = presigned['upload_url'];
      final filePath = presigned['file_path'];

      if (uploadUrl == null || filePath == null) {
        throw Exception('Invalid presigned URL response from server');
      }

      // 2. Upload to R2 directly
      await ApiService().uploadToR2(uploadUrl, bytes, contentType);

      // 3. Update backend profile record
      final updatedProfile = await ApiService().updateProfilePicture(
        profileType: profileType,
        filePath: filePath,
      );

      // 4. Update UI
      if (updatedProfile['profile_picture'] != null) {
        AppStore.instance.profileImageUrl.value = updatedProfile['profile_picture'];
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile picture updated successfully!'),
          backgroundColor: AppColors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to upload: $e'),
          backgroundColor: AppColors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }
}
