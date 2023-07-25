// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

const String FOLDER_PATH = r'C:\Users\lopet\OneDrive\Desktop\new';

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
  final String cds;
  //final String professor;
  final List<DateTime> assignedDates;

  Exam(this.id, this.name, this.cds, this.assignedDates); //this.professor

  @override
  String toString() => '$id - $name';

  //This method is used for
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
  List<DateTime> dateTimeList = (strList).map((dynamic item) {
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
