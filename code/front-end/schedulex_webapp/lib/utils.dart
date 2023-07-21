// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';

import 'package:table_calendar/table_calendar.dart';

class Unavail {
  String id;
  int type;
  List<DateTime> dates;
  String name;

  Unavail(
      {required this.id,
      required this.type,
      required this.dates,
      this.name = ''});

  void setType(newType) {
    type = newType;
  }

  void setName(newName) {
    name = newName;
  }

  void setDates(newDates) {
    dates = newDates;
  }
}

class ProblemSession {
  final String id;
  String school;
  String status;
  String description;
  String user;
  DateTime? startDate;
  DateTime? endDate;
  List<Unavail>? unavailList;

  ProblemSession(
      {required this.id,
      this.school = '',
      this.status = "NOT STARTED",
      this.description = "",
      this.user = "",
      this.startDate,
      this.endDate,
      this.unavailList});

  void setSchool(newschool) {
    school = newschool;
  }

  void setStatus(newStatus) {
    status = newStatus;
  }

  void setDescription(newDescription) {
    description = newDescription;
  }

  void setStartEndDate(start, end) {
    startDate = start;
    endDate = end;
  }
}

class Exam {
  final String id;
  final String name;
  //final String professor;
  final List<DateTime> assignedDates;

  Exam(this.id, this.name, this.assignedDates); //this.professor

  @override
  String toString() => '$id - $name';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Exam && other.name == name && other.id == id;
  }

  @override
  int get hashCode => Object.hash(id, name);
}

List<DateTime> convertStrToDateList(List<dynamic> strList) {
  List<DateTime> dateTimeList = (strList as List<dynamic>).map((dynamic item) {
    if (item is DateTime) {
      return item;
    } else if (item is String) {
      return DateTime.parse(item);
    }
    // Handle other cases if needed
    throw const FormatException('Invalid date format');
  }).toList();

  return dateTimeList;
}

// Create a map to store the exams associated with their respective date

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  List<DateTime> newDates = [];
  for (var date = first;
      date.isBefore(last.add(const Duration(days: 1)));
      date = date.add(const Duration(days: 1))) {
    newDates.add(date);
  }
  return newDates;
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

dynamic JSONExample = [
  {
    "assignedDates": ["2023-07-06", "2023-07-10"],
    "average_mark": 29,
    "cds": "ELT",
    "cfu": 5,
    "course_code": "85746",
    "course_name": "FONDAMENTI DI ELETTRONICA",
    "effortWeight": 1.71,
    "enrolled_number": 176,
    "exam_head": "ELN1",
    "location": "MI",
    "me": "M",
    "minDistanceCalls": 3,
    "minDistanceExams": 2,
    "passed_percentage": 10,
    "professor": "Carminati Marco-Langfelder Giacomo",
    "section": "A M-M ZZZZ",
    "sem": 4,
    "semester": 2,
    "timeWeight": [5.35, 10.0, 6.59],
    "unavailDates": [],
    "year": 2
  },
  {
    "assignedDates": ["2023-07-03", "2023-07-07"],
    "average_mark": 29,
    "cds": "ATM",
    "cfu": 5,
    "course_code": "88697",
    "course_name": "CALCOLO DELLE PROBABILITÀ E STATISTICA",
    "effortWeight": 1.71,
    "enrolled_number": 176,
    "exam_head": "MAT1",
    "location": "MI",
    "me": "M",
    "minDistanceCalls": 3,
    "minDistanceExams": 2,
    "passed_percentage": 10,
    "professor": "Ladelli Lucia Maria-Scarpa Luca",
    "section": "A M-M ZZZZ",
    "sem": 5,
    "semester": 1,
    "timeWeight": [10.0, 4.35, 6.59, 8.12],
    "unavailDates": [],
    "year": 3
  },
  {
    "assignedDates": ["2023-07-04", "2023-07-08"],
    "average_mark": 29,
    "cds": "ATM",
    "cfu": 5,
    "course_code": "85745",
    "course_name": "FONDAMENTI DI AUTOMATICA",
    "effortWeight": 1.71,
    "enrolled_number": 176,
    "exam_head": "ELN1",
    "location": "MI",
    "me": "M",
    "minDistanceCalls": 3,
    "minDistanceExams": 2,
    "passed_percentage": 10,
    "professor": "Tanelli Mara-Piroddi Luigi",
    "section": "A M-M ZZZZ",
    "sem": 4,
    "semester": 2,
    "timeWeight": [8.12, 5.35, 8.12, 10.0],
    "unavailDates": [],
    "year": 2
  },
  {
    "assignedDates": ["2023-07-06", "2023-07-10"],
    "average_mark": 29,
    "cds": "ATM",
    "cfu": 5,
    "course_code": "85743",
    "course_name": "SISTEMI INFORMATICI",
    "effortWeight": 1.71,
    "enrolled_number": 176,
    "exam_head": "ELN1",
    "location": "MI",
    "me": "M",
    "minDistanceCalls": 3,
    "minDistanceExams": 2,
    "passed_percentage": 10,
    "professor": "Gatti Nicola-Mottola Luca",
    "section": "A M-M ZZZZ",
    "sem": 3,
    "semester": 1,
    "timeWeight": [6.59, 6.59, 10.0, 8.12],
    "unavailDates": [],
    "year": 2
  },
  {
    "assignedDates": ["2023-07-05", "2023-07-11"],
    "average_mark": 29,
    "cds": "ATM-ELT-ELN-INF",
    "cfu": 5,
    "course_code": "82746",
    "course_name": "FONDAMENTI DI INFORMATICA",
    "effortWeight": 1.71,
    "enrolled_number": 176,
    "exam_head": "ELN1",
    "location": "MI",
    "me": "M",
    "minDistanceCalls": 3,
    "minDistanceExams": 2,
    "passed_percentage": 10,
    "professor":
        "Bolchini Cristiana-Negri Mauro-Braga Daniele Maria-Miele Antonio Rosario-Loiacono Daniele-Caglioti Vincenzo-Matera Maristella-Mirandola Raffaela",
    "section": "A BRA-BRA COM-COM FEI-FEI IMA-IMA MEZ-MEZ PEZ-PEZ SAZ-SAZ ZZZZ",
    "sem": 1,
    "semester": 1,
    "timeWeight": [4.35, 20.0, 6.59, 5.35],
    "unavailDates": [],
    "year": 1
  },
  {
    "assignedDates": ["2023-07-07", "2023-07-12"],
    "average_mark": 29,
    "cds": "ELT",
    "cfu": 5,
    "course_code": "85754",
    "course_name": "FONDAMENTI DI ROBOTICA",
    "effortWeight": 1.71,
    "enrolled_number": 176,
    "exam_head": "ELN1",
    "location": "MI",
    "me": "M",
    "minDistanceCalls": 3,
    "minDistanceExams": 2,
    "passed_percentage": 10,
    "professor": "Zanchettin Andrea Maria-Rocco Paolo",
    "section": "A M-M ZZZZ",
    "sem": 6,
    "semester": 2,
    "timeWeight": [3.53, 6.59, 10.0],
    "unavailDates": [],
    "year": 3
  }
];
