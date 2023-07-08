import 'dart:math';

class Unavail {
  final String id;
  final int type;
  final List<DateTime> dates;
  final String professor;
  final List<String> classroom;

  Unavail({
    required this.id,
    required this.type,
    required this.dates,
    this.professor = '',
    this.classroom = const [],
  });
}

class ProblemSession {
  final String id;
  final String school;
  final String status;
  final String description;
  final List<String> users;

  ProblemSession(
      {required this.id,
      required this.school,
      this.status = "NOT STARTED",
      this.description = "",
      this.users = const []});
}

class FakeElement {
  final String id;

  FakeElement(this.id);
}

List<FakeElement> generateRandomElementList(int count) {
  final List<FakeElement> elements = [];

  for (int i = 0; i < count; i++) {
    final id = 'Element ${i + 1}';
    final element = FakeElement(id);
    elements.add(element);
  }

  return elements;
}

List<ProblemSession> generateRandomProblemSessionList(int count) {
  final random = Random();
  final List<String> schools = ['School A', 'School B', 'School C'];
  final List<String> availableUsers = ['User A', 'User B', 'User C'];

  List<ProblemSession> problemSessions = [];

  for (int i = 0; i < count; i++) {
    String id = 'Session-${i + 1}';
    String school = schools[random.nextInt(schools.length)];
    List<String> users = [];

    int numUsers = random.nextInt(availableUsers.length +
        1); // Random number of users (0 to availableUsers.length)

    for (int j = 0; j < numUsers; j++) {
      users.add(availableUsers[random.nextInt(availableUsers.length)]);
    }

    ProblemSession problemSession = ProblemSession(
      id: id,
      school: school,
      users: users,
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
    int type = random.nextInt(3); // Generates random type: 0, 1, or 2
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
      professor: professor,
    );

    unavailList.add(unavail);
  }

  return unavailList;
}
