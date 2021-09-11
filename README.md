# Zoom Attendance Checker
## Search zoom active hosts report CSV

This is a tool to compare a comma separated list of your students with zoom active hosts CSV file

## Features

- Can handle multiple class rooms
- Easy to reuse student lists

## Bugs

- two students cannot have the same first name

## How to use
 In this example, the class name is '13C'
- Clone this repo
- run 'dart pub get' to download packages
```sh
[root of this repo]>dart pub get
```
- In the /students folder, make a new file called '13C.csv'
- Edit the data.dart file, (sample provided in data.sample.dart). You can also add some additional text data like their surname.
- (you can also use generateStudentsFromCsv.dart along with some sc data in /students (sample provided))
- Login to the zoom web app, go to https://zoom.us/account/report/user
- Select a date range and export meeting list with details
- Download and copy the csv file in the root folder (same place as activehosts.sample.csv)
- Change line 7 of the zoom_attendance_checker.dart file
- Do the followingS
```sh
[bin folder]>dart run zoom_attendance_checker.dart -a
```

## License

MIT

**Free Software, Hell Yeah!**

