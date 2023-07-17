// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:schedulex_webapp/utils.dart';
import 'package:schedulex_webapp/model/UserState.dart';
import 'package:schedulex_webapp/BackEndMethods.dart';

class ProblemSessionState extends ChangeNotifier {
  late UserState appState;
  String? selectedSessionID;
  DateTimeRange? sessionDates;
  String school = 'Ing_Ind_Inf';
  List<Unavail> unavailList = [];

  UserState get user => appState;

  void setProblemSessionID(String id) {
    selectedSessionID = id;
    String catalog = user.userID;
    print('$catalog select $selectedSessionID');
    getSessionData(sessionId: id).then((value) {
      unavailList = value;
      notifyListeners();
    }).catchError((error) {
      // Handle any error that occurred during the Future execution
      print('Error: $error');
    });
    //#####
  }

  void setSchool(selectedSchool) {
    debugPrint(selectedSessionID);
    saveSession(
        sessionID: selectedSessionID!,
        payload: {'school': selectedSchool}).then((value) {
      //
      print(selectedSchool);
      school = selectedSchool;

      notifyListeners();
      //
    });
  }

  void setStartEndDate(daterange) {
    sessionDates = daterange;
    if (sessionDates != null) {
      saveStartEndDate(
              sessionID: selectedSessionID!,
              startDate: sessionDates!.start.toString(),
              endDate: sessionDates!.end.toString())
          .then((value) {
        //
        notifyListeners();
        //
      });
    }
  }
}
