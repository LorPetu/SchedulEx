import 'package:flutter/material.dart';
import 'package:schedulex_webapp/model/ProblemSessionState.dart';
import 'package:schedulex_webapp/utils.dart';
import 'package:schedulex_webapp/BackEndMethods.dart';

class UserState extends ChangeNotifier {
  late ProblemSessionState session;
  String userID = 'esempio';
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

  void deleteProblemSession(sessionID) {
    print('session to delete $sessionID');
    deleteSession(sessionID: sessionID).then((value) {
      problemSessionList.removeWhere((element) => element.id == sessionID);
      notifyListeners();
    });
  }
}
