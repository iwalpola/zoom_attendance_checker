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
- Edit the csv file to make a list of comma separated first names (example provided). You can also add some additional text data like their surname.
- Login to the zoom web app, go to https://zoom.us/account/report/user
- Find your meeting and click the blue link in the 'participants' column to bring up the list of attendees
- Check the box to "Show Unique Users", and click "Export" button
- Save the csv file in /attendance folder as '13C.csv'
- Do the following
```sh
[root of this repo]>dart run ./bin/zoom_attendance_checker.dart -a
```

## License

MIT

**Free Software, Hell Yeah!**

