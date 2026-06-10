void bulkRecordAttendance({required List<Map<String, dynamic>> records}) {
  print("Success");
}

void main() {
  var _enrollments = ['1', '2'];
  var _statuses = {'1': 'Present', '2': 'Absent'};
  
  final records = _enrollments.map((e) => {
    'student_id': e,
    'status':     _statuses[e] ?? 'Present',
    'remarks':    '',
  }).toList();
  
  try {
    bulkRecordAttendance(records: records);
  } catch (e) {
    print("Error: $e");
  }
}
