import 'package:csv/csv.dart';
import 'dart:io';
import 'package:args/args.dart';
import 'data.dart';
import 'models.dart';

//TODO: remove blank rows and then parse to get a clean list without []
// this will break the function that compares rows
final File attendanceFile = File('../activehosts.csv');

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
  populateMeetingsInClassSets();

  dcat(showAttendance: argResults['attendance'] as bool);
}

void dcat({bool showAttendance = false}) {
  if (showAttendance == true) {
    populateAttendanceRecords();
    saveAttendanceRecords();
  }
}

void populateMeetingsInClassSets() {
  for (var classSet in cohort) {
    stdout.writeln('Entering class' + classSet.displayName);
    for (var i = 0; i < activeHostsRowList.length; i++) {
      stdout.writeln('running iteration ' + i.toString());

      //check if the row belongs to that class
      List activeHostsRow = activeHostsRowList[i];
      List prevRow = i > 0 ? activeHostsRowList[i - 1] : [];
      stdout.writeln('row: ' + activeHostsRow.toString());
      //workaround for blanks
      if (activeHostsRow.length < 2) {
        stdout.writeln('breaking on loop i = ' + i.toString());
        continue;
      } else if (activeHostsRow[1] != classSet.meetingId) {
        continue;
      }
      //find out whether this is first row of a meeting block
      var isFirstRowOfThisMeeting;
      if (prevRow.length < 2 || i == 0) {
        isFirstRowOfThisMeeting = true;
      } else {
        isFirstRowOfThisMeeting = false;
      }
      //add meeting to classSet if not already added
      stdout.writeln('isFirstrow: ' + isFirstRowOfThisMeeting.toString());
      var _meeting = isFirstRowOfThisMeeting
          ? addMeetingToClassSet(
              date: activeHostsRow[8].toString(), classSet: classSet)
          : classSet.meetings[activeHostsRow[8].toString()];
      stdout.writeln('activeHostsRow[8]: ' + activeHostsRow[8].toString());
      //add attendee to meeting if not already added
      addAttendeeToMeeting(
          meeting: _meeting!,
          name: activeHostsRow[12],
          email: activeHostsRow[13]);
      //activeHostsRowList.remove(activeHostsRow);
      stdout.writeln(activeHostsRow[12]);
    }
  }
}

Meeting addMeetingToClassSet(
    {required String date, required ClassSet classSet}) {
  stdout.writeln('triny to add meeting to classSet');
  if (classSet.meetings.isEmpty || !classSet.meetings.containsKey(date)) {
    return classSet.meetings.putIfAbsent(date, () => Meeting(date: date));
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

void populateAttendanceRecords() {
  for (var classSet in cohort) {
    //for each meeting, add a absent record to each student
    for (var meeting in classSet.meetings.entries) {
      populateDates(
          date: meeting.key, //is the date
          classSet: classSet);
    }
    //check attendance of each student
    for (var student in classSet.students.entries) {
      for (var meeting in classSet.meetings.entries) {
        //consider adding a set of recorded dates to not run this unnecessarily
        for (var attendee in meeting.value.attendees.entries) {
          markPresent(attendee: attendee.value, student: student.value);
          meeting.value.attendees.remove(attendee.key);
        }
      }
    }
  }
}

void populateDates({required String date, required ClassSet classSet}) {
  for (var student in classSet.students.entries) {
    student.value.attendanceRecords.putIfAbsent(date, () => 'absent');
  }
}

void markPresent({required Attendee attendee, required Student student}) {
  if (attendee.name.toLowerCase().contains(student.zoomName)) {
    student.attendanceRecords.update(attendee.date, (value) => 'present');
  } else {}
}

void saveAttendanceRecords() {
  //concatenate columnheadingsrow with dates list
  //save main sheets for each classSet
  for (var classSet in cohort) {
    //add dates list to double check
    var meetingDates = [];
    var columnHeadingsRow = ['Full Name', 'Form Class'];
    //populate meetingDates list
    for (var meeting in classSet.meetings.entries) {
      //concatenate columnheadingsrow with dates list
      meetingDates.add(meeting.value.date);
      columnHeadingsRow.add(meeting.value.date);
    }
    List<List<dynamic>> csvRowList = [];
    csvRowList.add(columnHeadingsRow);
    //for each student, create a row
    for (var student in classSet.students.entries) {
      //start student's row
      var csvStudentRow = [];
      csvStudentRow.add(student.value.fullName);
      csvStudentRow.add(student.value.extraData);
      //for each meeting date, add an entry to the row
      for (var meetingDate in meetingDates) {
        var attendanceStatus = student.value.attendanceRecords[meetingDate];
        csvStudentRow.add(attendanceStatus);
      }
      csvRowList.add(csvStudentRow);
    }
    //convert to Csv String
    final res = const ListToCsvConverter().convert(csvRowList);
    //create file
    File('../generated_csv/' + classSet.displayName + '.csv').create();
    //write to file
    File('../generated_csv/' + classSet.displayName + '.csv')
        .writeAsStringSync(res);
  }
}
