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

  ProblemSession(
      {required this.id,
      required this.school,
      this.status = "NOT STARTED",
      this.description = "",
      this.user = ""});
}

List<ProblemSession> generateRandomProblemSessionList(int count) {
  final random = Random();
  final List<String> schools = ['School A', 'School B', 'School C'];
  final List<String> availableUsers = ['User A', 'User B', 'User C'];

  List<ProblemSession> problemSessions = [];

  for (int i = 0; i < count; i++) {
    String id = 'Session-${i + 1}';
    String school = schools[random.nextInt(schools.length)];
    String user = "pippo";

    int numUsers = random.nextInt(availableUsers.length +
        1); // Random number of users (0 to availableUsers.length)

    ProblemSession problemSession = ProblemSession(
      id: id,
      school: school,
      user: user,
    );

    problemSessions.add(problemSession);
  }

  return problemSessions;
}

List<Unavail> generateRandomUnavailList(int count) {
  final random = Random();
  List<Unavail> unavailList = [];

  for (int i = 0; i < count; i++) {
    String id = 'Unavail-${i + 1}';
    //var types = ['Professor, Politecnico'];
    int type = random.nextInt(2); // Generates random type: 0, 1, or 2
    List<DateTime> dates = [
      DateTime.now().add(Duration(
          days: random.nextInt(30))), // Random date within the next 30 days
      DateTime.now().add(Duration(days: random.nextInt(30))),
    ];
    String professor = 'Professor ${i + 1}';

    Unavail unavail = Unavail(
      id: id,
      type: type,
      dates: dates,
      name: professor,
    );

    unavailList.add(unavail);
  }

  return unavailList;
}
