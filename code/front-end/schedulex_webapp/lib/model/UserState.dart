import 'package:flutter/material.dart';
//import 'package:schedulex_webapp/utils.dart';

class UserState extends ChangeNotifier {
  String userID = 'esempio';
  String problemSessionID = '';

  void setUserID(String id) {
    userID = id;
    print('$userID logged in');
    // getSessionList().then((value) {
    //   problemSessionList = value;

    // });
    // print(problemSessionList);
    notifyListeners();
  }
}
