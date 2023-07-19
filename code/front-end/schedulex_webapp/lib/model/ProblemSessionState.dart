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

  //settings
  int? minDistanceExam;
  int? minDistanceCallsDefault;
  int? numCalls;
  int? currSemester;
  List<dynamic> exceptions = [];

  UserState get user => appState;

  void resetProblemSessionID() {
    selectedSessionID = '';
    school = 'Ing_Ind_Inf';
    sessionDates = null;
    unavailList = [];
    minDistanceExam = null;
    minDistanceCallsDefault = null;
    exceptions = [];
    numCalls = null;
    currSemester = null;

    notifyListeners();
  }

  // distance1 = minDistanceExam; distance2= minDistanceCallsDefault; Calls = numCalls; curr = currSemester;
  void updateSettings(payload) {
    if (payload['minDistanceExam'] != null) {
      minDistanceExam = int.tryParse(payload['minDistanceExam']);
    }
    if (payload['minDistanceCallsDefault'] != null) {
      minDistanceCallsDefault =
          int.tryParse(payload['minDistanceCallsDefault']);
    }
    if (payload['numCalls'] != null) {
      numCalls = int.tryParse(payload['numCalls']);
    }
    if (payload['currSemester'] != null) {
      currSemester = int.tryParse(payload['currSemester']);
    }

    // Create a new payload containing only the modified values
    Map<String, dynamic> modifiedPayload = {
      'minDistanceExam': minDistanceExam,
      'minDistanceCallsDefault': minDistanceCallsDefault,
      'numCalls': numCalls,
      'currSemester': currSemester,
    };

    setSettings(sessionID: selectedSessionID!, payload: modifiedPayload);
  }

  void setMinDistanceExam(int newdistance) {
    setSettings(
        sessionID: selectedSessionID!,
        payload: {'minDistanceExam': newdistance}).then((value) {
      notifyListeners();
      print('request done');
    });
    minDistanceExam = newdistance;
    notifyListeners();
  }

  void setMinDistanceCallsDefault(int newdistance) {
    setSettings(
        sessionID: selectedSessionID!,
        payload: {'minDistanceCalls': newdistance}).then((value) {
      minDistanceCallsDefault = newdistance;
      notifyListeners();
    });

    notifyListeners();
  }

  void insertException(String examID, int newdistance) {
    setSettings(
        sessionID: selectedSessionID!,
        payload: {'id': examID, 'distance': newdistance}).then((value) {
      notifyListeners();
      print('request done');
    });
    exceptions.add({'id': examID, 'distance': newdistance});
    print(exceptions);
    notifyListeners();
  }

  void deleteException(String id) {
    exceptions.removeWhere((element) => element['id'] == id);

    notifyListeners();
  }

  void setProblemSessionID(String id) {
    selectedSessionID = id;

    debugPrint('${user.userID} select $selectedSessionID');

    getSessionData(sessionId: id).then((value) {
      if (value['problemsession'].startDate != null &&
          value['problemsession'].endDate != null) {
        sessionDates = DateTimeRange(
            start: value['problemsession'].startDate!,
            end: value['problemsession'].endDate!);
      }

      if (!value['problemsession'].school.isEmpty) {
        school = value['problemsession'].school;
      }
      unavailList = value['problemsession'].unavailList ?? [];
      dynamic settings = value['settings'];
      print(settings);
      if (settings != null) {
        minDistanceCallsDefault = settings['minDistanceCalls']['Default'];
        minDistanceExam = settings['minDistanceExam'];
        if (settings['minDistanceCalls']['Exceptions'] != null) {
          settings['minDistanceCalls']['Exceptions'].forEach((k, v) {
            exceptions.add(v);
          });
        }
      }

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
      user.update({'id': selectedSessionID!, 'school': school});
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

  void update(Map<String, dynamic> update) {
    final index =
        unavailList.indexWhere((element) => element.id == update['id']);
    debugPrint('ProblemSessionState: update[id] ${update['id']}');
    if (index != -1) {
      debugPrint('ProblemSessionState: update an already existing session');
      (update['type'] != null)
          ? unavailList[index].setType(update['type'])
          : null;
      (update['name'] != null)
          ? unavailList[index].setName(update['name'])
          : null;
    } else {
      debugPrint('ProblemSessionState: update a new session');
      unavailList.add(Unavail(id: update['id'], type: 0, dates: []));
    }

    notifyListeners();
  }

  void addUnavail(Unavail newUnavail) {
    unavailList.add(newUnavail);
    debugPrint('ProblemSessionState: adding new');
    notifyListeners();
    //appState.updateUnavail(newUnavail);
  }

  void deleteUnavail(Unavail deletedUnavail) {
    unavailList.removeWhere((element) => element.id == deletedUnavail.id);
    deleteUnavailability(
        sessionID: selectedSessionID!, unavail: deletedUnavail);
    notifyListeners();
    //appState.deleteUnavail(deletedUnavail);
  }
}
