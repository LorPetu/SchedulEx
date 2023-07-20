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
  final List<DateTime> assignedDates;

  Exam(this.id, this.name, this.assignedDates);

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

List<Exam> exams = [
  Exam('Exam 1', '1', [
    DateTime.utc(2023, 7, 20),
    DateTime.utc(2023, 7, 22),
    DateTime.utc(2023, 7, 25),
  ]),
  Exam('Exam 2', '2', [
    DateTime.utc(2023, 7, 21),
    DateTime.utc(2023, 7, 23),
    DateTime.utc(2023, 7, 26),
  ]),
  // Add more exams here...
];

// Create a map to store the exams associated with their respective dates

/// Example Exams.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kExams = LinkedHashMap<DateTime, List<Exam>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kExamSource);

final _kExamSource = exams.fold<Map<DateTime, List<Exam>>>(
  {}, // Start with an empty map
  (map, exam) {
    for (final assignedDate in exam.assignedDates) {
      map[assignedDate] = (map[assignedDate] ?? [])..add(exam);
    }
    return map;
  },
)..addAll({
    kToday: [
      Exam('Today\'s Exam 1', '1', [DateTime.now()]),
      Exam('Today\'s Exam 2', '2', [DateTime.now()]),
    ],
  });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
