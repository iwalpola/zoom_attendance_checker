import 'package:csv/csv.dart';
import 'dart:io';

import 'package:args/args.dart';

final String current = Directory.current.path;
final classes = ['9C', '10A', '10D', '13A'];
final Directory studentsDir = Directory('$current/students/');
final Directory attendanceDir = Directory('$current/attendance/');
const attendance = 'attendance';

void main(List<String> arguments) {
  exitCode = 0; // presume success
  final parser = ArgParser()..addFlag(attendance, negatable: false, abbr: 'a');

  var argResults = parser.parse(arguments);

  dcat(showAttendance: argResults[attendance] as bool);
}

Future<void> dcat({bool showAttendance = false}) async {
  if (showAttendance == true) {
    for (final className in classes) {
      //check if attendance file exists
      var studentsFileExists =
          await File(studentsDir.path + className + '.csv').exists();
      var attendanceFileExists =
          await File(attendanceDir.path + className + '.csv').exists();
      if (!studentsFileExists) {
        stdout.writeln(
            'Skipped ' + className + ' because students file does not exist');
      } else if (!attendanceFileExists) {
        stdout.writeln(
            'Skipped ' + className + ' because attendance file does not exist');
      } else {
        var presentCount = 0;
        var studentCsvString =
            await File(studentsDir.path + className + '.csv').readAsString();
        var attendanceCsvString =
            await File(attendanceDir.path + className + '.csv').readAsString();
        var studentsList = CsvToListConverter().convert(studentCsvString);
        var attendanceList = CsvToListConverter().convert(attendanceCsvString);
        attendanceList.removeAt(0); //trim the headers
        stdout.writeln('Results for ' + className);
        for (var student in studentsList) {
          student.add('absent'); //sets everyone to absent
          for (var record in attendanceList) {
            if (record[0].toLowerCase().contains(student[0].toLowerCase())) {
              student[2] = 'present';
              presentCount++;
              attendanceList.remove(record);
              break;
            }
          }
          if (student[2] == 'absent') stdout.writeln(student);
        }
        stdout.writeln('$className has ' +
            studentsList.length.toString() +
            ' students, out of which $presentCount are present');
        stdout.writeln('unaccounted attendees' + attendanceList.toString());
      }
    }
  }
}
