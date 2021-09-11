class ClassSet {
  final String meetingId, displayName;
  final List<Student> students;
  ClassSet(
      {required this.meetingId,
      required this.displayName,
      required this.students});
  Map<String, int> meetings = {};
}

class Student {
  final String fullName, zoomName, extraData;
  Map<String, String> attendanceRecords = {};
  Student(
      {required this.fullName, required this.zoomName, this.extraData = ''});
}
