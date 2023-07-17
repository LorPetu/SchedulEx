import 'dart:math';

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
}

class ProblemSession {
  final String id;
  final String school;
  final String status;
  final String description;
  final String user;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<Unavail>? unavailList;

  ProblemSession(
      {required this.id,
      required this.school,
      this.status = "NOT STARTED",
      this.description = "",
      this.user = "",
      this.startDate,
      this.endDate,
      this.unavailList});
}
