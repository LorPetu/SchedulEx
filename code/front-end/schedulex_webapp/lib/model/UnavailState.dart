import 'package:flutter/material.dart';
import 'package:schedulex_webapp/BackEndMethods.dart';
import 'package:schedulex_webapp/model/ProblemSessionState.dart';
import 'package:schedulex_webapp/model/UserState.dart';
import 'package:schedulex_webapp/utils.dart';

class UnavailState extends ChangeNotifier {
  late ProblemSessionState sessionState;

  String? id;
  int type = 0;
  String name = '';
  List<DateTime> dates = [];

  void reset() {
    id = null;
    type = 0;
    name = '';
    dates = [];
  }

  Future<dynamic> setCurrID(String newId) {
    if (newId.isNotEmpty) {
      return getUnavailData(
              sessionId: sessionState.selectedSessionID!, unavailID: newId)
          .then((value) {
        id = newId;
        type = value.type;
        name = value.name;
        dates = value.dates;
        sessionState
            .addUnavail(Unavail(id: id!, name: name, type: type, dates: dates));
        notifyListeners();
      }).catchError((error) {
        debugPrint('UnavailState Error: $error');
        notifyListeners();
      });
    } else {
      return createUnavail().then((value) {
        id = value['id'];
        return null; // Return null explicitly
      });
    }
  }

  Future<dynamic> createUnavail() {
    return saveUnavailability(
        sessionID: sessionState.selectedSessionID!,
        unavailID: '',
        payload: {}).then((value) {
      print(value);
      sessionState
          .addUnavail(Unavail(id: value['id'], type: type, dates: dates));
      notifyListeners();
      print(value);
      return value;
    }).catchError((error) {
      debugPrint(' Create UnavailStateError: $error');
      notifyListeners();
      return '';
    });
    //return Future(() => Unavail(id: id, type: type, dates: dates));
  }

  void setType(int newtype) {
    saveUnavailability(
        sessionID: sessionState.selectedSessionID!,
        unavailID: id!,
        payload: {'type': newtype}).then((value) {
      type = newtype;
      notifyListeners();
    });
  }

  void setName(String newName) {
    //TODO:
    saveUnavailability(
        sessionID: sessionState.selectedSessionID!,
        unavailID: id!,
        payload: {'name': newName}).then((value) {
      name = newName;
      notifyListeners();
    });
  }

  void addDates(List<DateTime> dates) {
    //TODO:
  }
}
