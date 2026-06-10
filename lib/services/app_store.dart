// ─────────────────────────────────────────────────────────────────────────────
// APP STORE  —  session-scoped in-memory state
// All create/edit/save actions write here.
// All list pages listen here via ValueListenableBuilder so UI updates instantly.
// Data lives for the duration of the app session (no persistence needed for demo).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'api_service.dart';

// ── Data models ──────────────────────────────────────────────────────────────

class Assignment {
  final String id;
  String sub;
  String title;
  String due;
  String className;
  int submitted;
  int total;
  String color; // hex-style label for routing to AppColors

  Assignment({
    required this.id,
    required this.sub,
    required this.title,
    required this.due,
    required this.className,
    this.submitted = 0,
    this.total     = 28,
    this.color     = 'blue',
  });
}

class Exam {
  final String id;
  String sub;
  String title;
  String dateStr;
  String room;
  String status;
  String type;

  Exam({
    required this.id,
    required this.sub,
    required this.title,
    required this.dateStr,
    required this.room,
    this.status = 'Upcoming',
    this.type   = 'Written',
  });
}

class StudentRecord {
  final String id;
  String name;
  String grade;
  String roll;
  String att;

  StudentRecord({
    required this.id,
    required this.name,
    required this.grade,
    required this.roll,
    this.att = '—',
  });
}

class TeacherRecord {
  final String id;
  String name;
  String subject;

  TeacherRecord({required this.id, required this.name, required this.subject});
}

class ParentRecord {
  final String id;
  String name;
  String linkedStudent;

  ParentRecord({required this.id, required this.name, required this.linkedStudent});
}

// Attendance status map: classIndex → studentName → status
typedef AttendanceMap = Map<int, Map<String, String>>;

// ── Announcement model ───────────────────────────────────────────────────────

class Announcement {
  final String id;
  String audience;
  String message;
  String time;

  Announcement({
    required this.id,
    required this.audience,
    required this.message,
    required this.time,
  });
}

// ── Store singleton ──────────────────────────────────────────────────────────

class AppStore {
  AppStore._();
  static final AppStore instance = AppStore._();

  // ── SESSION STATE ────────────────────────────────────────────────────────
  // Populated after successful real login; null when using DevAuth
  AuthMe?         _authMe;
  ProfileContext? _profileContext;
  bool            _isDevMode = false;

  AuthMe?         get authMe         => _authMe;
  ProfileContext? get profileContext  => _profileContext;
  bool            get isDevMode      => _isDevMode;
  bool            get isRealLogin    => _authMe != null && !_isDevMode;

  /// The currently logged-in user's display name
  String get currentUserName {
    if (_profileContext != null) return _profileContext!.identity.fullName;
    if (_authMe != null) return _authMe!.fullName;
    return '';
  }

  /// The current user's email
  String get currentUserEmail {
    if (_profileContext != null) return _profileContext!.identity.email;
    if (_authMe != null) return _authMe!.email;
    return '';
  }

  /// The school name for the current user
  String get currentSchool {
    if (_authMe?.schoolName != null) return _authMe!.schoolName!;
    return '';
  }

  /// The user's roles from backend
  List<String> get currentRoles {
    if (_profileContext != null) return _profileContext!.roles;
    return [];
  }

  /// The user's student profile ID (if they have one)
  String? get studentProfileId => _profileContext?.profiles.student.id;

  /// The user's teacher profile ID (if they have one)
  String? get teacherProfileId => _profileContext?.profiles.teacher.id;

  /// The user's parent profile ID (if they have one)
  String? get parentProfileId  => _profileContext?.profiles.parent.id;

  /// Initialize session after real login — call after successful ApiService().login()
  Future<void> initSession() async {
    _isDevMode = false;
    try {
      _authMe = await ApiService().getMe();
    } catch (_) {}
    try {
      _profileContext = await ApiService().getProfileContext();
    } catch (_) {}

    // Fetch attendance to calculate global average
    try {
      final attRes = await ApiService().getAttendance(page: 1);
      if (attRes.results.isNotEmpty) {
        int present = attRes.results.where((e) => e.status.toLowerCase() == 'present').length;
        globalAttendanceInt.value = (present * 100 / attRes.results.length).round();
      } else {
        globalAttendanceInt.value = 0;
      }
    } catch (_) {
      globalAttendanceInt.value = 0;
    }

    // Clear dummy seeds — real data comes from API
    students.value = [];
    teachers.value = [];
    parents.value = [];
    recentActivity.value = [];
  }

  /// Mark as dev mode (dummy data stays populated)
  void activateDevMode() {
    _isDevMode = true;
    _authMe = null;
    _profileContext = null;
    _seedDummyData();
  }

  /// Clear session on logout
  void clearSession() {
    _authMe = null;
    _profileContext = null;
    _isDevMode = false;
    TokenStore.clear();
  }

  /// Seed dummy data for dev mode
  void _seedDummyData() {
    students.value = [
      StudentRecord(id: 's1', name: 'Maya Johnson',    grade: 'Grade 10B', roll: '042', att: '96'),
      StudentRecord(id: 's2', name: 'Arjun Mehta',     grade: 'Grade 10A', roll: '018', att: '88'),
      StudentRecord(id: 's3', name: 'Zara Williams',   grade: 'Grade 11C', roll: '067', att: '92'),
      StudentRecord(id: 's4', name: 'Leo Chen',        grade: 'Grade 9A',  roll: '005', att: '100'),
      StudentRecord(id: 's5', name: 'Sofia Rodriguez', grade: 'Grade 12B', roll: '091', att: '84'),
    ];
    teachers.value = [
      TeacherRecord(id: 't1', name: 'Dr. Elena Vance', subject: 'Science'),
      TeacherRecord(id: 't2', name: 'Mr. James Hoang', subject: 'Mathematics'),
      TeacherRecord(id: 't3', name: 'Ms. Sarah Kim',   subject: 'English'),
      TeacherRecord(id: 't4', name: 'Mr. David Osei',  subject: 'History'),
    ];
    parents.value = [
      ParentRecord(id: 'p1', name: 'Priya Mehta',      linkedStudent: 'Arjun Mehta'),
      ParentRecord(id: 'p2', name: 'John Carter',       linkedStudent: 'Ben Carter'),
      ParentRecord(id: 'p3', name: 'Alexander Pierce',  linkedStudent: 'Alex Rivers'),
      ParentRecord(id: 'p4', name: 'Aiko Tanaka',       linkedStudent: 'Yuki Tanaka'),
    ];
    recentActivity.value = [
      {'title': 'Student Enrolled',         'sub': 'Aisha Okonkwo — Grade 10B',      'time': '5m ago'},
      {'title': 'Teacher Profile Updated',  'sub': 'Mr. James Hoang — Math',          'time': '22m ago'},
      {'title': 'Academic Year Configured', 'sub': 'Term 2 activated',                'time': '1h ago'},
      {'title': 'Role Permissions Updated', 'sub': 'Parent role — grades view added', 'time': '3h ago'},
    ];
    assignments.value = [
      Assignment(id: 'a1', sub: 'PHYSICS',   title: 'Chapter 5: Forces & Motion', due: 'Apr 15', className: 'Physics 11-B', submitted: 22, total: 28, color: 'teal'),
      Assignment(id: 'a2', sub: 'SCIENCE',   title: 'Ecosystem Lab Report',        due: 'Apr 18', className: 'Science 10-A', submitted: 0,  total: 28, color: 'blue'),
      Assignment(id: 'a3', sub: 'CHEMISTRY', title: 'Periodic Table — Module 4',   due: 'Apr 16', className: 'Chemistry 12',  submitted: 18, total: 24, color: 'navy'),
    ];
    exams.value = [
      Exam(id: 'e1', sub: 'PHYSICS',   title: 'Mid-Term Examination',  dateStr: 'Apr 22 · 10:00 AM', room: 'Lab 2',    status: 'Upcoming'),
      Exam(id: 'e2', sub: 'SCIENCE',   title: 'Unit 3 Test',           dateStr: 'Apr 18 · 09:00 AM', room: 'Room 204', status: 'Upcoming'),
      Exam(id: 'e3', sub: 'CHEMISTRY', title: 'Practical Assessment',  dateStr: 'Mar 28',             room: 'Lab 3',    status: 'Completed'),
    ];
    studentAssignments.value = [
      {'sub':'MATHEMATICS','title':'Quadratic Equations Set B','due':'Tomorrow','color':'blue',  'status':'Pending'},
      {'sub':'ENGLISH',    'title':'Essay: The Great Gatsby',  'due':'Apr 20',  'color':'navy',  'status':'Pending'},
      {'sub':'PHYSICS',    'title':'Chapter 4 Problems',       'due':'Mar 30',  'color':'teal',  'status':'Submitted'},
      {'sub':'HISTORY',    'title':'WWII Analysis Essay',      'due':'Mar 25',  'color':'green', 'status':'Graded · A'},
      {'sub':'CHEMISTRY',  'title':'Lab Safety Report',        'due':'Apr 22',  'color':'amber', 'status':'Pending'},
    ];
  }

  // ── Teacher: Assignments ─────────────────────────────────────────────────
  final assignments = ValueNotifier<List<Assignment>>([
    Assignment(id: 'a1', sub: 'PHYSICS',   title: 'Chapter 5: Forces & Motion', due: 'Apr 15', className: 'Physics 11-B', submitted: 22, total: 28, color: 'teal'),
    Assignment(id: 'a2', sub: 'SCIENCE',   title: 'Ecosystem Lab Report',        due: 'Apr 18', className: 'Science 10-A', submitted: 0,  total: 28, color: 'blue'),
    Assignment(id: 'a3', sub: 'CHEMISTRY', title: 'Periodic Table — Module 4',   due: 'Apr 16', className: 'Chemistry 12',  submitted: 18, total: 24, color: 'navy'),
  ]);

  void addAssignment(Assignment a) {
    assignments.value = [a, ...assignments.value];
  }

  // ── Teacher: Exams ───────────────────────────────────────────────────────
  final exams = ValueNotifier<List<Exam>>([
    Exam(id: 'e1', sub: 'PHYSICS',   title: 'Mid-Term Examination',  dateStr: 'Apr 22 · 10:00 AM', room: 'Lab 2',    status: 'Upcoming'),
    Exam(id: 'e2', sub: 'SCIENCE',   title: 'Unit 3 Test',           dateStr: 'Apr 18 · 09:00 AM', room: 'Room 204', status: 'Upcoming'),
    Exam(id: 'e3', sub: 'CHEMISTRY', title: 'Practical Assessment',  dateStr: 'Mar 28',             room: 'Lab 3',    status: 'Completed'),
  ]);

  void addExam(Exam e) {
    exams.value = [e, ...exams.value];
  }

  // ── Teacher: Attendance ──────────────────────────────────────────────────
  // Map of classIndex → studentName → status
  // Saved when teacher hits "Save Attendance"
  final savedAttendance = ValueNotifier<AttendanceMap>({});

  void saveAttendance(int classIdx, Map<String, String> statuses) {
    final updated = Map<int, Map<String, String>>.from(savedAttendance.value);
    updated[classIdx] = Map<String, String>.from(statuses);
    savedAttendance.value = updated;
  }

  String? getAttendanceStatus(int classIdx, String studentName) {
    return savedAttendance.value[classIdx]?[studentName];
  }

  // ── Teacher: Announcements ───────────────────────────────────────────────
  final announcements = ValueNotifier<List<Announcement>>([]);

  void addAnnouncement(Announcement a) {
    announcements.value = [a, ...announcements.value];
  }

  // ── Student: Assignments (visible to student) ────────────────────────────
  // Student sees their own + teacher-created ones (shared reference)
  final studentAssignments = ValueNotifier<List<Map<String, dynamic>>>([
    {'sub':'MATHEMATICS','title':'Quadratic Equations Set B','due':'Tomorrow','color':'blue',  'status':'Pending'},
    {'sub':'ENGLISH',    'title':'Essay: The Great Gatsby',  'due':'Apr 20',  'color':'navy',  'status':'Pending'},
    {'sub':'PHYSICS',    'title':'Chapter 4 Problems',       'due':'Mar 30',  'color':'teal',  'status':'Submitted'},
    {'sub':'HISTORY',    'title':'WWII Analysis Essay',      'due':'Mar 25',  'color':'green', 'status':'Graded · A'},
    {'sub':'CHEMISTRY',  'title':'Lab Safety Report',        'due':'Apr 22',  'color':'amber', 'status':'Pending'},
  ]);

  void submitStudentAssignment(String title) {
    final updated = studentAssignments.value.map((a) {
      if (a['title'] == title) return {...a, 'status': 'Submitted'};
      return a;
    }).toList();
    studentAssignments.value = updated;
  }

  // When teacher creates assignment → also appears in student view
  void addAssignmentToStudent(String sub, String title, String due) {
    final updated = [
      {'sub': sub, 'title': title, 'due': due, 'color': 'blue', 'status': 'Pending'},
      ...studentAssignments.value,
    ];
    studentAssignments.value = updated;
  }

  // ── Admin: Students ──────────────────────────────────────────────────────
  final students = ValueNotifier<List<StudentRecord>>([
    StudentRecord(id: 's1', name: 'Maya Johnson',    grade: 'Grade 10B', roll: '042', att: '96'),
    StudentRecord(id: 's2', name: 'Arjun Mehta',     grade: 'Grade 10A', roll: '018', att: '88'),
    StudentRecord(id: 's3', name: 'Zara Williams',   grade: 'Grade 11C', roll: '067', att: '92'),
    StudentRecord(id: 's4', name: 'Leo Chen',        grade: 'Grade 9A',  roll: '005', att: '100'),
    StudentRecord(id: 's5', name: 'Sofia Rodriguez', grade: 'Grade 12B', roll: '091', att: '84'),
  ]);

  void addStudent(StudentRecord s) {
    students.value = [s, ...students.value];
  }

  // ── Admin: Teachers ──────────────────────────────────────────────────────
  final teachers = ValueNotifier<List<TeacherRecord>>([
    TeacherRecord(id: 't1', name: 'Dr. Elena Vance', subject: 'Science'),
    TeacherRecord(id: 't2', name: 'Mr. James Hoang', subject: 'Mathematics'),
    TeacherRecord(id: 't3', name: 'Ms. Sarah Kim',   subject: 'English'),
    TeacherRecord(id: 't4', name: 'Mr. David Osei',  subject: 'History'),
  ]);

  void addTeacher(TeacherRecord t) {
    teachers.value = [t, ...teachers.value];
  }

  // ── Admin: Parents ───────────────────────────────────────────────────────
  final parents = ValueNotifier<List<ParentRecord>>([
    ParentRecord(id: 'p1', name: 'Priya Mehta',      linkedStudent: 'Arjun Mehta'),
    ParentRecord(id: 'p2', name: 'John Carter',       linkedStudent: 'Ben Carter'),
    ParentRecord(id: 'p3', name: 'Alexander Pierce',  linkedStudent: 'Alex Rivers'),
    ParentRecord(id: 'p4', name: 'Aiko Tanaka',       linkedStudent: 'Yuki Tanaka'),
  ]);

  void addParent(ParentRecord p) {
    parents.value = [p, ...parents.value];
  }

  // ── Admin: Recent Activity timeline ─────────────────────────────────────
  final recentActivity = ValueNotifier<List<Map<String, String>>>([
    {'title': 'Student Enrolled',         'sub': 'Aisha Okonkwo — Grade 10B',      'time': '5m ago'},
    {'title': 'Teacher Profile Updated',  'sub': 'Mr. James Hoang — Math',          'time': '22m ago'},
    {'title': 'Academic Year Configured', 'sub': 'Term 2 activated',                'time': '1h ago'},
    {'title': 'Role Permissions Updated', 'sub': 'Parent role — grades view added', 'time': '3h ago'},
  ]);

  void prependActivity(String title, String sub) {
    recentActivity.value = [
      {'title': title, 'sub': sub, 'time': 'Just now'},
      ...recentActivity.value,
    ];
  }

  // ── Session Wide Stats ───────────────────────────────────────────────────
  final globalAttendanceInt = ValueNotifier<int>(91);

  // ── Utility: generate a unique ID ────────────────────────────────────────
  static int _idCounter = 100;
  static String nextId() => 'id${_idCounter++}';
}
