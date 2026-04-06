import 'package:flutter/material.dart';

IconData navIcon(String name) {
  switch (name) {
    case 'dashboard': return Icons.grid_view_rounded;
    case 'schools': return Icons.home_work_rounded;
    case 'domains': return Icons.language_rounded;
    case 'sysconfig': return Icons.settings_rounded;
    case 'profile': return Icons.person_rounded;
    case 'academic': return Icons.calendar_month_rounded;
    case 'users': return Icons.lock_rounded;
    case 'students': return Icons.school_rounded;
    case 'teachers': return Icons.menu_book_rounded;
    case 'parents': return Icons.people_rounded;
    case 'mapping': return Icons.share_rounded;
    case 'grading': return Icons.star_rounded;
    case 'attendance': return Icons.check_box_rounded;
    case 'assignments': return Icons.assignment_rounded;
    case 'grades': return Icons.bar_chart_rounded;
    case 'exams': return Icons.edit_rounded;
    case 'timetable': return Icons.calendar_today_rounded;
    case 'analytics': return Icons.show_chart_rounded;
    case 'subjects': return Icons.book_rounded;
    case 'materials': return Icons.folder_rounded;
    case 'childoverview': return Icons.child_care_rounded;
    case 'payments': return Icons.credit_card_rounded;
    case 'insights': return Icons.lightbulb_rounded;
    case 'invoices': return Icons.receipt_rounded;
    case 'feestructure': return Icons.attach_money_rounded;
    case 'reconcile': return Icons.sync_rounded;
    case 'manualpay': return Icons.edit_note_rounded;
    case 'authorize': return Icons.lock_open_rounded;
    case 'reports': return Icons.leaderboard_rounded;
    default: return Icons.circle_rounded;
  }
}
