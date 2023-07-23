import 'package:flutter/material.dart';
import 'package:schedulex_webapp/BackEndMethods.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:schedulex_webapp/model/ProblemSessionState.dart';
import 'package:schedulex_webapp/utils.dart';
import 'dart:async';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  String serverResponse = 'No response yet';
  late Timer _pollingTimer;
  DateTime? firstDay;
  DateTime? lastDay;

  @override
  void initState() {
    super.initState();
    final session = context.read<ProblemSessionState>();
    firstDay = session.sessionDates!.start ?? kFirstDay;
    lastDay = session.sessionDates!.end ?? kLastDay;

    getStatus(sessionID: session.selectedSessionID!).then((value) {
      setState(() {
        session.setStatus(value?['status']);
        print(session.status);
        serverResponse = value?['progress'];
      });
    }); // Initial fetch
    _pollingTimer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => getStatus(sessionID: session.selectedSessionID!).then((value) {
              setState(() {
                session.setStatus(value?['status']);
                if (value?['status'] != 'STARTED') {
                  stopPolling();
                }
                serverResponse = value?['progress'];
              });
            }));
  }

  // Method to stop the polling
  void stopPolling() {
    _pollingTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ProblemSessionState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            onPressed: () {
              stopPolling();
              context.pushReplacement('/select/session');
              print(session.status);
              //reset value of ProblemSession selected
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: ((session.status ?? 'STARTED') == 'SOLVED')
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ElevatedButton(
                      onPressed: () {
                        downloadExcel(session.selectedSessionID!).then(
                            (value) => session.showToast(context, value!));
                      },
                      child: const SizedBox(
                        width: 140,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('download Excel'),
                            SizedBox(
                              width: 15,
                            ),
                            Icon(Icons.download)
                          ],
                        ),
                      )),
                ),
                Expanded(
                    child: TableResults(
                  firstDay: firstDay!,
                  lastDay: lastDay!,
                  sessionID: session.selectedSessionID!,
                )),
              ],
            )
          : Center(child: (() {
              switch (session.status) {
                case 'NOT SOLVED':
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child:
                            Icon(Icons.dangerous_outlined, color: Colors.red),
                      ),
                      Text('The scheduling problem is not feasible'),
                    ],
                  );
                default:
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                      Text('Server Response: $serverResponse'),
                    ],
                  );
              }
            })()),
    );
  }
}

class TableResults extends StatefulWidget {
  final DateTime firstDay; // First day of the calendar
  final DateTime lastDay; // Last day of the calendar
  final String sessionID;

  const TableResults({
    required this.firstDay,
    required this.lastDay,
    required this.sessionID,
    Key? key,
  }) : super(key: key);

  @override
  _TableResultsState createState() => _TableResultsState();
}

class _TableResultsState extends State<TableResults> {
  late final ValueNotifier<List<Exam>> _selectedExams;
  dynamic JSONResults;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  late DateTime _focusedDay = widget.firstDay;
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    getJsonResults(widget.sessionID).then((value) => JSONResults = value);
    print('widget.firstdday ${widget.firstDay}');
    _selectedDay = _focusedDay;
    print('selected day $_selectedDay');
    print('focusedDay $_focusedDay');
    _selectedExams = ValueNotifier(_getExamsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedExams.dispose();
    super.dispose();
  }

  List<Exam> _getExamsForDay(DateTime day) {
    // Implementation example
    List<Exam> examsInaDay = [];
    if (JSONResults != null) {
      for (dynamic exam in JSONResults) {
        for (DateTime call in convertStrToDateList(exam['assignedDates'])) {
          if (isSameDay(day, call)) {
            examsInaDay.add(Exam(exam['course_code'], exam['course_name'],
                exam['cds'], convertStrToDateList(exam['assignedDates'])));
          }
        }
      }
    }

    return examsInaDay;
  }

  List<Exam> _getExamsForRange(DateTime start, DateTime end) {
    // get all days between start and end date
    final days = daysInRange(start, end);
    //for each of them obtain the Exam that are in this day
    return [
      for (final d in days) ..._getExamsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedExams.value = _getExamsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedExams.value = _getExamsForRange(start, end);
    } else if (start != null) {
      _selectedExams.value = _getExamsForDay(start);
    } else if (end != null) {
      _selectedExams.value = _getExamsForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Exam>(
          firstDay: widget.firstDay,
          lastDay: widget.lastDay,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
          rangeStartDay: _rangeStart,
          rangeEndDay: _rangeEnd,
          calendarFormat: _calendarFormat,
          rangeSelectionMode: _rangeSelectionMode,
          eventLoader: _getExamsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: const CalendarStyle(
            // Use `CalendarStyle` to customize the UI
            outsideDaysVisible: false,
          ),
          onDaySelected: _onDaySelected,
          onRangeSelected: _onRangeSelected,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<Exam>>(
            valueListenable: _selectedExams,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      onTap: () => print('${value[index]}'),
                      title: Text('${value[index]}'),
                      subtitle: Text(value[index]
                          .assignedDates
                          .map((dateTime) =>
                              '${dateTime.day}/${dateTime.month}/${dateTime.year}')
                          .join(', ')),
                      trailing: Text(value[index].cds),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
