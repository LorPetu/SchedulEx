import 'package:flutter/material.dart';
import 'package:schedulex_webapp/BackEndMethods.dart';
import 'package:schedulex_webapp/model/ProblemSessionState.dart';

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
    notifyListeners();
  }

  //Set the id of the current Unavail that the user is viewing
  Future<void> setCurrID(String newID) async {
    if (newID.isNotEmpty) {
      dynamic value = await getUnavailData(
          sessionID: sessionState.selectedSessionID!, unavailID: newID);
      id = newID;
      type = value.type;
      name = value.name;
      dates = value.dates;
      sessionState.updateUnavail(
          {'id': id!, 'name': name, 'type': type, 'dates': dates});
      notifyListeners();
    } else {
      debugPrint('UnavailState: createUnavail');
      return createUnavail().then((value) {
        id = value['id'];
        notifyListeners();

        return null;
      });
    }
  }

  //Create a new Unavail and await for the results
  Future<dynamic> createUnavail() async {
    dynamic value = await saveUnavailability(
        sessionID: sessionState.selectedSessionID!, unavailID: '', payload: {});
    id = value['id'];
    sessionState
        .updateUnavail({'id': id!, 'name': name, 'type': type, 'dates': dates});

    notifyListeners();
    return value;
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
    saveUnavailability(
        sessionID: sessionState.selectedSessionID!,
        unavailID: id!,
        payload: {'name': newName}).then((value) {
      name = newName;
      sessionState.updateUnavail({'id': id!, 'name': name});
      notifyListeners();
    });
  }

  void addDates(List<DateTime> newdates) async {
    addDatesToUnavail(
      sessionID: sessionState.selectedSessionID!,
      unavailID: id!,
      newDates: newdates,
    ).then((value) {
      print(value);
      dates = value;

      //dates = value['value']['dates'];
      notifyListeners();
    });
  }

  void deleteDate(DateTime dateTodelete) {
    deleteDateToUnavail(
            sessionID: sessionState.selectedSessionID!,
            unavailID: id!,
            datetoDelete: dateTodelete)
        .then((value) {
      dates.remove(dateTodelete);
      notifyListeners();
    });
  }
}
