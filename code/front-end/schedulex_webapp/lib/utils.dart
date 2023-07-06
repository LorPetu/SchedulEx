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
