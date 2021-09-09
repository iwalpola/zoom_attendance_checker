class ClassSet {
  final String meetingId, displayName;
  final Map<String, Student> students;
  ClassSet(
      {required this.meetingId,
      required this.displayName,
      required this.students});

  Map<String, Meeting> meetings = {};
}

class Student {
  final String fullName, zoomName, extraData;
  Map<String, String> attendanceRecords = {};
  Student(
      {required this.fullName, required this.zoomName, this.extraData = ''});
}

class Meeting {
  final String date, meetingId;
  Map<String, Attendee> attendees = {};
  Meeting({required this.date, required this.meetingId});
}

class Attendee {
  final String name, email, date;
  Attendee({required this.name, required this.email, required this.date});
}
