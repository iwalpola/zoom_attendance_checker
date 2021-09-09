import 'package:csv/csv.dart';
import 'dart:io';
import 'package:args/args.dart';
import 'data.dart';
import 'models.dart';

final String currentDir = Directory.current.path;

final File attendanceFile = File('../attendance.csv');

//check bool
var attendanceFileExists;
//list of rows
var activeHostsRowList;

void main(List<String> arguments) {
  exitCode = 0; // presume success
  final parser = ArgParser()
    ..addFlag('attendance', negatable: false, abbr: 'a');

  var argResults = parser.parse(arguments);
  //check if attendance file exists, exit if not found
  attendanceFileExists = attendanceFile.existsSync();
  if (!attendanceFileExists) {
    stdout.writeln('Fatal: attendance file does not exist');
    exitCode = 1;
    return;
  }
  //read file
  stdout.writeln('Reading Zoom Active Hosts File...');
  activeHostsRowList =
      CsvToListConverter().convert(attendanceFile.readAsStringSync());
  activeHostsRowList.removeAt(0); //trim the headers
  stdout.writeln('Finished reading Active Hosts file');
  stdout.writeln('Processing data...');
  populateMeetings();

  dcat(showAttendance: argResults['attendance'] as bool);
}

void dcat({bool showAttendance = false}) {
  if (showAttendance == true) {
    populateAttendanceRecords();
    //saveAttendanceRecords();
  }
}

void populateMeetings() {
  for (var classSet in cohort) {
    for (var row in activeHostsRowList) {
      //check if the row belongs to that class
      if (row[1] == classSet.meetingId) {
        //add meeting to classSet if not already added
        var _meeting = addMeetingToClassSet(
            date: row[8].toString(),
            classSet: classSet); //TODO:make more efficient by checking next row
        //add attendee to meeting if not already added
        addAttendeeToMeeting(meeting: _meeting, name: row[12], email: row[13]);
        activeHostsRowList.remove(row);
      }
    }
  }
}

void populateAttendanceRecords() {
  for (var classSet in cohort) {
    for (var meeting in classSet.meetings.entries) {
      populateDates(date: meeting.value.date, classSet: classSet);
      for (var attendee in meeting.value.attendees.entries) {
        markPresent(
            attendee: attendee.value,
            classSet: classSet); //todo maybe iterate forst over students?
      }
    }
  }
}

void populateDates({required String date, required ClassSet classSet}) {
  for (var student in classSet.students.entries) {
    student.value.attendanceRecords.putIfAbsent(date, () => 'absent');
  }
}

void markPresent({required Attendee attendee, required ClassSet classSet}) {
  for (var student in classSet.students.entries) {
    if (attendee.name.toLowerCase().contains(student.value.zoomName)) {
      student.value.attendanceRecords
          .update(attendee.date, (value) => 'present');
    } else {}
  }
}

Meeting addMeetingToClassSet(
    {required String date, required ClassSet classSet}) {
  if (classSet.meetings.isNotEmpty && !classSet.meetings.containsKey(date)) {
    return classSet.meetings.putIfAbsent(
        date,
        () => Meeting(
            date: date,
            meetingId: classSet.meetingId)); //TODO:consider removing meeting id
  }
  return classSet.meetings[date]!;
}

void addAttendeeToMeeting(
    {required Meeting meeting, required String name, required String email}) {
  if (meeting.attendees.isNotEmpty && !meeting.attendees.containsKey(name)) {
    meeting.attendees.putIfAbsent(
        name, () => Attendee(name: name, email: email, date: meeting.date));
  }
}
