import 'package:csv/csv.dart';
import 'dart:io';
import 'package:args/args.dart';
import 'data.dart';
import 'models.dart';

final File attendanceFile = File('../activehosts.csv');

//check bool
var attendanceFileExists;
//List of meetingblock, which is list of rows
//A row is a list containin comma separated strings
List<List<List>> meetingBlocks = [];

void main(List<String> arguments) {
  exitCode = 0; // presume success
  final parser = ArgParser()
    ..addFlag('attendance', negatable: false, abbr: 'a');

  var argResults = parser.parse(arguments);
  //check if attendance file exists, exit if not found
  attendanceFileExists = attendanceFile.existsSync();
  if (!attendanceFileExists) {
    showDebugMessages
        ? stdout.writeln('Fatal: attendance file does not exist')
        : () {};
    exitCode = 1;
    return;
  }

  splitActiveHostsFile();
  processMeetingBlocks();

  dcat(showAttendance: argResults['attendance'] as bool);
}

void dcat({bool showAttendance = false}) {
  if (showAttendance == true) {
    saveAttendanceRecords();
  }
}

void splitActiveHostsFile() {
  var activeHostsRowList =
      CsvToListConverter().convert(attendanceFile.readAsStringSync().trim());
  activeHostsRowList[0] = [0]; //blank the headings
  activeHostsRowList.add([0]); //add blank row to end
  showDebugMessages
      ? stdout.writeln('Finished reading Active Hosts file')
      : () {};
  showDebugMessages ? stdout.writeln('Processing data...') : () {};
  //find blank rows
  var blockSeparators = <int>[];
  for (var i = 0; i < activeHostsRowList.length; i++) {
    if (activeHostsRowList[i].length < 2) {
      blockSeparators.add(i);
      stdout.writeln('$i is a blank row (separator)');
    }
  }
  if (meetingBlocks.isNotEmpty) {
    stdout.writeln('error not empty');
    return;
  }
  //separate the meeting blocks
  for (var i = 0; i < (blockSeparators.length - 1); i++) {
    //we are ading 1 to the blank row's index because sublist is inclusive of firstindex
    var startIndex = blockSeparators[i] + 1;
    //index of next blank row, sublist is exclusive of endIndex
    var endIndex = blockSeparators[i + 1];
    var meetingBlock = activeHostsRowList.sublist(
        startIndex, endIndex); //fills the row before blank line also
    meetingBlocks.add(meetingBlock);
  }
  stdout.writeln(
      'found ' + meetingBlocks.length.toString() + ' meeting blocks in file');
}

void processMeetingBlocks() {
  for (var meetingBlock in meetingBlocks) {
    var firstRow = meetingBlock.first;
    var meetingId = firstRow[1];
    var date = firstRow[8];
    //check if this meetingId belongs to a class
    if (cohort.containsKey(meetingId)) {
      //if it belongs
      var classSet = cohort[meetingId]!;
      stdout.writeln('$meetingId belongs to ' + classSet.displayName);
      //fil attendance records with absent value
      initializeRecords(date: date, classSet: classSet);
      checkAttendanceInBlock(
          meetingBlock: meetingBlock, classSet: classSet, date: date);
    } else {
      stdout.writeln('$meetingId does not belong to a clasSet');
    }
  }
}

void initializeRecords({required String date, required ClassSet classSet}) {
  classSet.meetings.putIfAbsent(date, () => 0); //init set to 0.
  for (var student in classSet.students) {
    //stdout.writeln('adding ' + student.value.fullName + ' blank date record');
    student.attendanceRecords.putIfAbsent(date, () => 'absent');
  }
}

void checkAttendanceInBlock(
    {required List<List> meetingBlock,
    required ClassSet classSet,
    required String date}) {
  for (var student in classSet.students) {
    stdout.writeln('meetingblock size: ' + meetingBlock.length.toString());
    // for each student
    //initialize a duration counter
    var durationJoinedMins = 0;
    //row indexes for deletion
    var deletionIndexes = <int>[];
    //search the entire meeting block and add up durations
    //also queue the index for deletion
    for (var i = 0; i < meetingBlock.length; i++) {
      //foor each row in the updated meetingBlock
      var row = meetingBlock[i];
      if (row[12].toLowerCase().contains(student.zoomName)) {
        //increment duration joined
        var minutes = row[16].toString();
        durationJoinedMins += int.parse(minutes);
        //queue for deletion
        deletionIndexes.add(i);
      }
      if (row[12].toLowerCase().contains('(host)')) {
        deletionIndexes.add(i);
      }
    }
    stdout
        .writeln('rows:' + deletionIndexes.toString() + ' queued for deletion');
    //reverse to delte last to first, index is not valid
    //delete rows queued for deletion
    deletionIndexes.reversed.forEach((index) {
      meetingBlock.removeAt(index);
    });
    //check if joined for more than 30 minutes
    if (durationJoinedMins > 30) {
      //increment present count
      classSet.meetings.update(date, (value) => (value + 1));
      student.attendanceRecords.update(date, (value) => 'present');
    }
  }
  var anomalies = meetingBlock.isNotEmpty
      ? ListToCsvConverter().convert(meetingBlock)
      : null;
  if (anomalies != null) {
    var filename =
        date.replaceAll('/', '.').replaceAll(':', '.').replaceAll(' ', '.');
    //delete files
    if (File('../manual_review/$filename.csv').existsSync()) {
      File('../manual_review/$filename.csv').deleteSync();
    }

    File('../manual_review/$filename.csv').createSync();
    //write to file
    File('../manual_review/$filename.csv').writeAsStringSync(anomalies);
  }
}

void saveAttendanceRecords() {
  //concatenate columnheadingsrow with dates list
  //save main sheets for each classSet
  for (var classSet in cohort.entries) {
    //delete if exists
    if (File('../generated_csv/' + classSet.value.displayName + '.csv')
        .existsSync()) {
      File('../generated_csv/' + classSet.value.displayName + '.csv')
          .deleteSync();
    }
    var columnHeadingsRow = ['Full Name', 'Form Class'];
    var csvRowList = <List<dynamic>>[];
    for (var meetingDate in classSet.value.meetings.entries) {
      //add date to heading row
      columnHeadingsRow.add(meetingDate.key);
    }
    csvRowList.add(columnHeadingsRow);
    //for each student, create a row
    for (var student in classSet.value.students) {
      //start student's row
      var csvStudentRow = [];
      csvStudentRow.add(student.fullName);
      csvStudentRow.add(student.extraData);
      //for each meeting date, add an entry to the row
      for (var record in student.attendanceRecords.entries) {
        csvStudentRow.add(record.value);
      }
      csvRowList.add(csvStudentRow);
    }
    //add footer with numPresent
    var columnFooterRow = [
      'NA',
      'NA',
    ];
    for (var meetingDate in classSet.value.meetings.entries) {
      columnFooterRow.add(meetingDate.value.toString()); //presentcount
    }
    //add footer to CSV
    csvRowList.add(columnFooterRow);
    //convert to Csv String
    final res = const ListToCsvConverter().convert(csvRowList);
    //create file
    File('../generated_csv/' + classSet.value.displayName + '.csv')
        .createSync();
    //write to file
    File('../generated_csv/' + classSet.value.displayName + '.csv')
        .writeAsStringSync(res);
  }
}
