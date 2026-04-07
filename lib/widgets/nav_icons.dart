import 'package:flutter/material.dart';

IconData navIcon(String name) {
  switch (name) {
    case 'dashboard':    return Icons.grid_view_rounded;
    case 'schools':      return Icons.account_balance_rounded;
    case 'domains':      return Icons.language_rounded;
    case 'sysconfig':    return Icons.settings_rounded;
    case 'profile':      return Icons.manage_accounts_rounded;
    case 'academic':     return Icons.calendar_month_rounded;
    case 'users':        return Icons.verified_user_rounded;
    case 'students':     return Icons.school_rounded;
    case 'teachers':     return Icons.menu_book_rounded;
    case 'parents':      return Icons.group_rounded;
    case 'mapping':      return Icons.share_rounded;
    case 'grading':      return Icons.star_rounded;
    case 'attendance':   return Icons.fact_check_rounded;
    case 'assignments':  return Icons.description_rounded;
    case 'grades':       return Icons.bar_chart_rounded;
    case 'exams':        return Icons.edit_rounded;
    case 'timetable':    return Icons.schedule_rounded;
    case 'analytics':    return Icons.trending_up_rounded;
    case 'subjects':     return Icons.bookmark_rounded;
    case 'materials':    return Icons.folder_open_rounded;
    case 'childoverview':return Icons.child_care_rounded;
    case 'payments':     return Icons.credit_card_rounded;
    case 'insights':     return Icons.auto_awesome_rounded;
    case 'invoices':     return Icons.receipt_long_rounded;
    case 'feestructure': return Icons.currency_rupee_rounded;
    case 'reconcile':    return Icons.sync_rounded;
    case 'manualpay':    return Icons.edit_note_rounded;
    case 'authorize':    return Icons.lock_open_rounded;
    case 'reports':      return Icons.pie_chart_rounded;
    default:             return Icons.circle_rounded;
  }
}
