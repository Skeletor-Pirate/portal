import 'package:flutter/material.dart';
import '../models/role_config.dart';
import 'common/profile_page.dart';
import 'global/global_pages.dart';
import 'admin/admin_pages.dart';
import 'teacher/teacher_pages.dart';
import 'student/student_pages.dart';
import 'parent/parent_pages.dart';
import 'accountant/accountant_pages.dart';

class PageRouter extends StatelessWidget {
  final UserRole role;
  final String page;
  const PageRouter({super.key, required this.role, required this.page});

  @override
  Widget build(BuildContext context) {
    if (page == 'profile') return ProfilePage(role: role);

    switch (role) {
      case UserRole.global:
        return GlobalPages(page: page);
      case UserRole.admin:
        return AdminPages(page: page);
      case UserRole.teacher:
        return TeacherPages(page: page);
      case UserRole.student:
        return StudentPages(page: page);
      case UserRole.parent:
        return ParentPages(page: page);
      case UserRole.accountant:
        return AccountantPages(page: page);
    }
  }
}

Widget defaultPage(String id) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 18),
      child: Column(children: [
        const Icon(Icons.construction_rounded, size: 40, color: Color(0xFFAEA8CC)),
        const SizedBox(height: 12),
        Text(id[0].toUpperCase() + id.substring(1),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('This section is under construction.',
            style: TextStyle(fontSize: 13, color: Color(0xFF5A6E84))),
      ]),
    );
