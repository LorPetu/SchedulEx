// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:schedulex_webapp/BackEndMethods.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:schedulex_webapp/model/ProblemSessionState.dart';
import 'dart:convert';
import 'dart:async';

//import '../utils.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  String serverResponse = 'No response yet';
  late Timer _pollingTimer;

  @override
  void initState() {
    super.initState();
    final session = context.read<ProblemSessionState>();
    getStatus(sessionID: session.selectedSessionID!); // Initial fetch
    _pollingTimer = Timer.periodic(const Duration(seconds: 10),
        (_) => getStatus(sessionID: session.selectedSessionID!));
  }

  // Method to stop the polling
  void stopPolling() {
    _pollingTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ProblemSessionState>();
    bool status = false; // Replace this with your status logic
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
        actions: [
          IconButton(
            onPressed: () {
              stopPolling();
              context.pushReplacement('/select/session');
              //reset value of ProblemSession selected
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: status
          ? TableResults(stopPolling: stopPolling)
          : Center(child: Text('Server Response: $serverResponse')),
    );
  }
}

class TableResults extends StatefulWidget {
  final Function stopPolling;

  TableResults({required this.stopPolling});

  @override
  _TableResultsState createState() => _TableResultsState();
}

class _TableResultsState extends State<TableResults> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ProblemSessionState>();
    return TableCalendar(
      firstDay: DateTime.now(), //session.sessionDates!.start,
      lastDay: DateTime(2024), //session.sessionDates!.end,
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
      },
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
    );
  }
}
