// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:schedulex_webapp/BackEndMethods.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:schedulex_webapp/model/ProblemSessionState.dart';
import 'package:schedulex_webapp/utils.dart';
import 'dart:async';

//import '../utils.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  String serverResponse = 'No response yet';
  late Timer _pollingTimer;
  bool? isSolved;

  @override
  void initState() {
    super.initState();
    final session = context.read<ProblemSessionState>();
    getStatus(sessionID: session.selectedSessionID!).then((value) {
      setState(() {
        print(value);
        isSolved = (value?['status'] == 'SOLVED');
        serverResponse = value?['progress'];
      });
    }); // Initial fetch
    _pollingTimer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => getStatus(sessionID: session.selectedSessionID!).then((value) {
              setState(() {
                print(value);
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
      body: ((session.status ?? 'STARTED') != 'STARTED') // isSolved ??
          ? const TableResults()
          : Center(child: Text('Server Response: $serverResponse')),
    );
  }
}

class TableResults extends StatefulWidget {
  const TableResults({super.key});

  @override
  _TableResultsState createState() => _TableResultsState();
}

class _TableResultsState extends State<TableResults> {
  late final ValueNotifier<List<Exam>> _selectedExams;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedExams = ValueNotifier(_getExamsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedExams.dispose();
    super.dispose();
  }

  List<Exam> _getExamsForDay(DateTime day) {
    // Implementation example
    return kExams[day] ?? [];
  }

  List<Exam> _getExamsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

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
          firstDay: kFirstDay,
          lastDay: kLastDay,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
