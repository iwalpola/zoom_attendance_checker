import 'models.dart';

final bool showDebugMessages = true;

// final Map<String, ClassSet> cohort = {
//   '<meeting-id for class>':
//       ClassSet(meetingId: '<meeting-id for class>', displayName: '<text>', students: <name_of_map>),
//   '822 3710 5298':
//       ClassSet(meetingId: '<meeting-id for class>', displayName: '<text>', students: <name_of_map>)
// };
final Map<String, ClassSet> cohort = {
  '678 9798 7688': ClassSet(
      meetingId: '678 9798 7688', displayName: 'class1', students: students_1),
  '822 3710 5298': ClassSet(
      meetingId: '822 3710 5298', displayName: 'class2', students: students_2)
};

//final List<Student> map_name = [
//   Student(fullName: '<Last, First>', zoomName: '<unique text that appears in their zoom records>', extraData: '<text>'),
//   Student(
//       fullName: '<Last, First >',
//       zoomName: '<unique text that appears in their zoom records>',
//       extraData: '<text>'),
// ];
final List<Student> students_2 = [
  Student(fullName: 'Smith, jane ', zoomName: 'janesmith', extraData: 'I'),
  Student(fullName: 'Stoner, Jane ', zoomName: 'stoner', extraData: 'M'),
];
final List<Student> students_1 = [
  Student(fullName: 'Obama, Malaika', zoomName: 'obama', extraData: 'K'),
  Student(fullName: 'Arif, Aslan', zoomName: 'aslan', extraData: 'K'),
];
