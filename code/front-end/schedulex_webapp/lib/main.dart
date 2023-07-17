import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:schedulex_webapp/LoginPage.dart';
import 'package:schedulex_webapp/SessionPage.dart';
import 'package:schedulex_webapp/model/ProblemSessionState.dart';
import 'package:schedulex_webapp/model/UnavailState.dart';
import 'package:schedulex_webapp/model/UserState.dart';
import 'SelectPage.dart';

import 'utils.dart';

import 'Unavailpage.dart';
import 'BackEndMethods.dart';

void main() {
  runApp(const MyApp());
}

//Main widget that contains all, in here we defined the routing of our webapp
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserState>(
          create: (context) => UserState(),
        ),
        ChangeNotifierProxyProvider<UserState, ProblemSessionState>(
          create: (_) => ProblemSessionState(),
          update: (context, appState, problemSessionState) {
            if (problemSessionState == null)
              throw ArgumentError.notNull('problemSessionState');
            problemSessionState.appState = appState;
            return problemSessionState;
          },
        ),
        ChangeNotifierProxyProvider<ProblemSessionState, UnavailState>(
          create: (context) => UnavailState(),
          update: (context, session, unavailState) {
            if (unavailState == null)
              throw ArgumentError.notNull('unavailState');
            unavailState.sessionState = session;
            return unavailState;
          },
        ),
      ],
      //create: (context) => MyAppState(),
      child: MaterialApp.router(
        title: 'SchedulEx',
        routerConfig: router(),
      ),
    );
  }
}

GoRouter router() {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/select',
        builder: (context, state) => const SelectPage(),
        routes: [
          GoRoute(
            path: 'session',
            builder: (context, state) => const ProblemSessionPageNEW(),
          ),
          GoRoute(
            path: 'unavail',
            builder: (context, state) => const UnavailPageNEW(),
          ),
        ],
      ),
    ],
  );
}

class MyAppState extends ChangeNotifier {
  String userID = '';
  String problemSessionID = '';

  //SelectpageSession
  List<ProblemSession> problemSessionList = [];

  //unavailPage states
  DateTimeRange? sessionDates;
  String school = 'Ing_Ind_Inf';
  List<Unavail> unavailList = [];

  void setSchool(selectedSchool) {
    print(problemSessionID);
    saveSession(
        sessionID: problemSessionID, payload: {'school': selectedSchool});

    print(selectedSchool);
    school = selectedSchool;

    notifyListeners();
  }

  void setStartEndDate(daterange) {
    sessionDates = daterange;
    if (sessionDates != null) {
      saveStartEndDate(
          sessionID: problemSessionID,
          startDate: sessionDates!.start.toString(),
          endDate: sessionDates!.end.toString());
    }
    notifyListeners();
  }

  void updateUnavail(Unavail updatedUnavail) {
    /*final index =
        unavailList.indexWhere((element) => element.id == updatedUnavail.id);
    if (index != -1) {
      print(updatedUnavail.dates);
      saveUnavailability(sessionID: problemSessionID, unavail: updatedUnavail);
      unavailList[index] = updatedUnavail;
    } else {
      saveUnavailability(sessionID: problemSessionID, unavail: updatedUnavail)
          .then((value) => updatedUnavail.id = value['id']);
      unavailList.add(updatedUnavail);
      print('unavail' + updatedUnavail.id + ' added ');
    }*/
    notifyListeners();
    //print(unavailList[index].professor);
  }

  void deleteUnavail(Unavail deletedUnavail) {
    unavailList.removeWhere((element) => element.id == deletedUnavail.id);
    deleteUnavailability(sessionID: problemSessionID, unavail: deletedUnavail);
    notifyListeners();
  }
}
