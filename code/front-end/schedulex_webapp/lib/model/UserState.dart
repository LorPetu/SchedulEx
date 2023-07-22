import 'package:flutter/material.dart';
import 'package:schedulex_webapp/utils.dart';
import 'package:schedulex_webapp/BackEndMethods.dart';

class UserState extends ChangeNotifier {
  String userID = '';
  String problemSessionID = '';

  List<ProblemSession> problemSessionList = [];

  //Set the value of user and get all the sessions
  void setUserID(String id) {
    userID = id;
    //Backend call to retrieve all the sessions
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
      problemSessionList.add(ProblemSession(
          id: problemSessionID, school: '', status: 'NOT STARTED'));
      debugPrint('new session created');
      notifyListeners();
      return problemSessionID;
    }).catchError((error) {
      debugPrint('Error: $error');
      return '';
    });
  }

  //This function responsible only of the updating to visualize the element
  // without refereshing the page

  void update(Map<String, dynamic> update) {
    final index =
        problemSessionList.indexWhere((element) => element.id == update['id']);
    if (index != -1) {
      //update an already existing session
      (update['school'] != null)
          ? problemSessionList[index].setSchool(update['school'])
          : null;
      (update['status'] != null)
          ? problemSessionList[index].setStatus(update['status'])
          : null;
    } else {
      //add the new session to the list
      problemSessionList.add(ProblemSession(id: update['id']));
    }

    notifyListeners();
  }

  //Delete a session

  void delete(String sessionID) {
    //Backend Call to the delete the specified session from the database
    deleteSession(sessionID: sessionID).then((value) {
      problemSessionList.removeWhere((element) => element.id == sessionID);
      notifyListeners();
    });
  }
}
