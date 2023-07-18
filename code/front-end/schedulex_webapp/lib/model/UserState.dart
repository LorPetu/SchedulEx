import 'package:flutter/material.dart';
import 'package:schedulex_webapp/model/ProblemSessionState.dart';
import 'package:schedulex_webapp/utils.dart';
import 'package:schedulex_webapp/BackEndMethods.dart';

class UserState extends ChangeNotifier {
  late ProblemSessionState session;
  String userID = '';
  String problemSessionID = '';

  List<ProblemSession> problemSessionList = [];

  void setUserID(String id) {
    userID = id;
    debugPrint('$userID logged in');
    getSessionList().then((value) {
      problemSessionList = List<ProblemSession>.from(value);
      print(problemSessionList);
      notifyListeners();
    }).catchError((error) {
      debugPrint('Error: $error');
    });
  }

  Future<String> createSession() {
    return saveSession(
      sessionID: '',
      payload: {'userID': userID, 'status': 'NOT STARTED'},
    ).then((value) {
      problemSessionID = value['id'];
      problemSessionList.add(ProblemSession(id: problemSessionID, school: ''));
      debugPrint('new session created');
      notifyListeners();
      return problemSessionID;
    }).catchError((error) {
      debugPrint('Error: $error');
      return '';
    });
  }

  void update(Map<String, dynamic> update) {
    final index =
        problemSessionList.indexWhere((element) => element.id == update['id']);
    if (index != -1) {
      debugPrint('ProblemSessionState: update an already existing session');
      (update['school'] != null)
          ? problemSessionList[index].setSchool(update['school'])
          : null;
      (update['status'] != null)
          ? problemSessionList[index].setStatus(update['status'])
          : null;
    } else {
      debugPrint('ProblemSessionState: update a new session');
      problemSessionList.add(ProblemSession(id: update['id']));
    }

    notifyListeners();
  }

  void delete(String sessionID) {
    print('session to delete $sessionID');
    deleteSession(sessionID: sessionID).then((value) {
      problemSessionList.removeWhere((element) => element.id == sessionID);
      notifyListeners();
    });
  }
}
