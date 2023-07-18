
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
