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
  String color;

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

typedef AttendanceMap = Map<int, Map<String, String>>;

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
  AuthMe?         _authMe;
  ProfileContext? _profileContext;
  String?         _detectedProfileType;

  final profileImageUrl = ValueNotifier<String?>(null);

  AuthMe?         get authMe         => _authMe;
  ProfileContext? get profileContext  => _profileContext;
  bool            get isRealLogin    => _authMe != null;

  String get currentUserName {
    if (_profileContext != null) return _profileContext!.identity.fullName;
    if (_authMe != null) return _authMe!.fullName;
    return '';
  }

  String get currentUserEmail {
    if (_profileContext != null) return _profileContext!.identity.email;
    if (_authMe != null) return _authMe!.email;
    return '';
  }

  String get currentSchool {
    if (_authMe?.schoolName != null) return _authMe!.schoolName!;
    return '';
  }

  List<String> get currentRoles {
    if (_profileContext != null) return _profileContext!.roles;
    return [];
  }

  String? get studentProfileId => _profileContext?.profiles.student.id;
  String? get teacherProfileId => _profileContext?.profiles.teacher.id;
  String? get parentProfileId  => _profileContext?.profiles.parent.id;

  Future<void> initSession() async {
    try {
      _authMe = await ApiService().getMe();
    } catch (_) {}
    try {
      _profileContext = await ApiService().getProfileContext();
    } catch (_) {}

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

    students.value = [];
    teachers.value = [];
    parents.value = [];
    recentActivity.value = [];
    assignments.value = [];
    exams.value = [];
    studentAssignments.value = [];
    announcements.value = [];

    _detectedProfileType = _detectProfileType();
    if (_detectedProfileType != null) {
      try {
        final picData = await ApiService().fetchProfilePictureUrl(_detectedProfileType!);
        if (picData['has_picture'] == true && picData['url'] != null) {
          profileImageUrl.value = picData['url'] as String;
        } else {
          profileImageUrl.value = null;
        }
      } catch (_) {
        profileImageUrl.value = null;
      }
    }
  }

  Future<void> clearSession() async {
    _authMe = null;
    _profileContext = null;
    _detectedProfileType = null;
    profileImageUrl.value = null;
    await TokenStore.clear();
  }

  String? get detectedProfileType => _detectedProfileType;

  String? _detectProfileType() {
    if (_profileContext == null) return null;
    final roles = _profileContext!.roles.map((r) => r.toLowerCase()).toList();
    final profiles = _profileContext!.profiles;
    if (profiles.teacher.exists || roles.any((r) => r.contains('teacher'))) return 'teacher';
    if (profiles.student.exists || roles.any((r) => r.contains('student'))) return 'student';
    if (profiles.parent.exists  || roles.any((r) => r.contains('parent')))  return 'parent';
    if (roles.any((r) => r.contains('admin'))) return 'parent'; // admins fallback
    return null;
  }

  // ── Teacher: Assignments ─────────────────────────────────────────────────
  final assignments = ValueNotifier<List<Assignment>>([]);
  void addAssignment(Assignment a) { assignments.value = [a, ...assignments.value]; }

  // ── Teacher: Exams ───────────────────────────────────────────────────────
  final exams = ValueNotifier<List<Exam>>([]);
  void addExam(Exam e) { exams.value = [e, ...exams.value]; }

  // ── Teacher: Attendance ──────────────────────────────────────────────────
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
  void addAnnouncement(Announcement a) { announcements.value = [a, ...announcements.value]; }

  // ── Student: Assignments ────────────────────────────────────────────
  final studentAssignments = ValueNotifier<List<Map<String, dynamic>>>([]);
  void submitStudentAssignment(String title) {
    final updated = studentAssignments.value.map((a) {
      if (a['title'] == title) return {...a, 'status': 'Submitted'};
      return a;
    }).toList();
    studentAssignments.value = updated;
  }
  void addAssignmentToStudent(String sub, String title, String due) {
    final updated = [
      {'sub': sub, 'title': title, 'due': due, 'color': 'blue', 'status': 'Pending'},
      ...studentAssignments.value,
    ];
    studentAssignments.value = updated;
  }

  // ── Admin: Students ──────────────────────────────────────────────────────
  final students = ValueNotifier<List<StudentRecord>>([]);
  void addStudent(StudentRecord s) { students.value = [s, ...students.value]; }

  // ── Admin: Teachers ──────────────────────────────────────────────────────
  final teachers = ValueNotifier<List<TeacherRecord>>([]);
  void addTeacher(TeacherRecord t) { teachers.value = [t, ...teachers.value]; }

  // ── Admin: Parents ───────────────────────────────────────────────────────
  final parents = ValueNotifier<List<ParentRecord>>([]);
  void addParent(ParentRecord p) { parents.value = [p, ...parents.value]; }

  // ── Admin: Recent Activity ─────────────────────────────────────
  final recentActivity = ValueNotifier<List<Map<String, String>>>([]);
  void prependActivity(String title, String sub) {
    recentActivity.value = [
      {'title': title, 'sub': sub, 'time': 'Just now'},
      ...recentActivity.value,
    ];
  }

  // ── Session Wide Stats ───────────────────────────────────────────────────
  final globalAttendanceInt = ValueNotifier<int>(0);

  static int _idCounter = 100;
  static String nextId() => 'id${_idCounter++}';
}
