import 'package:csv/csv.dart';
import 'dart:io';

final Directory currentDir = Directory.current;
final classes = ['9C', '10A', '10D', '13A', '12K'];
final File dataFile = File('./data.dart');

void main() async {
  var fileString = "import 'models.dart';\n\n";
  for (final className in classes) {
    fileString += 'final Map<String, Student> _$className = {\n';
    var studentsFile = File('../students/' + className + '.csv');
    //check if attendance file exists
    var studentsFileExists = await studentsFile.exists();
    var dataFileExists = await dataFile.exists();
    if (!studentsFileExists) {
      stdout.writeln(
          'Skipped ' + className + ' because students file does not exist');
    } else if (!dataFileExists) {
      stdout.writeln('Fatal Error, data.dart file not found in bin folder');
      break;
    } else {
      var studentCsvString = await studentsFile.readAsString();
      var studentsCsvList = CsvToListConverter().convert(studentCsvString);
      for (var student in studentsCsvList) {
        String fullName = student[0];
        var zoomName = student[1].toString().toLowerCase();
        String extraData = student[2];
        fileString +=
            "\t'$zoomName':Student(fullName: '$fullName', zoomName: '$zoomName', extraData: '$extraData'),\n";
      }
      fileString += '};\n';
    }
  }
  File('./studentData.dart').writeAsStringSync(fileString);
}
