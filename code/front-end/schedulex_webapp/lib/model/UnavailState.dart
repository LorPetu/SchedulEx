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

  Future<dynamic> setCurrID(String newId) {
    if (newId.isNotEmpty) {
      return getUnavailData(
              sessionId: sessionState.selectedSessionID!, unavailID: newId)
          .then((value) {
        id = newId;
        type = value.type;
        name = value.name;
        dates = value.dates;
        sessionState.updateUnavail(
            {'id': id!, 'name': name, 'type': type, 'dates': dates});
        notifyListeners();
      }).catchError((error) {
        debugPrint('UnavailState Error: $error');
        notifyListeners();
      });
    } else {
      debugPrint('UnavailState: createUnavail');
      return createUnavail().then((value) {
        id = value['id'];
        notifyListeners();

        return null;
      });
    }
  }

  Future<dynamic> createUnavail() {
    return saveUnavailability(
        sessionID: sessionState.selectedSessionID!,
        unavailID: '',
        payload: {}).then((value) {
      print(value);
      id = value['id'];
      sessionState.updateUnavail(
          {'id': id!, 'name': name, 'type': type, 'dates': dates});
      notifyListeners();
      print(value);
      return value;
    }).catchError((error) {
      debugPrint(' Create UnavailStateError: $error');
      notifyListeners();
      return '';
    });
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
