import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedulex_webapp/LoginPage.dart';
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
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        //builder: FToastBuilder(),
        title: 'SchedulEx',
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/select': (context) => const SelectPage(),
          '/problemSession': (context) => const ProblemSessionPage(),
          '/unavail': (context) => const UnavailPage()
        },
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  //Tracker States
  String userID = '';
  String problemSessionID = '';
  String currUnavailID = '';

  //SelectpageSession
  List<ProblemSession> problemSessionList = [];

  //unavailPage
  DateTimeRange? sessionDates;
  String? school;
  List<Unavail> unavailList = [];

  void setUserID(String id) {
    userID = id;
    debugPrint('Main: setUserID: $userID logged in');
  }

  void setProblemSessionID(String id) {
    if (id.isEmpty) {
      saveSession(
              sessionID: '',
              payload: {'userID': userID, 'status': 'NOT STARTED'})
          .then((value) => problemSessionID = value['id']);
      problemSessionList.add(ProblemSession(id: problemSessionID, school: ''));
    } else {
      problemSessionID = id;
      debugPrint('Main: setProblemSessionID: $userID select $problemSessionID');
      getSessionData(sessionId: id).then((value) {
        unavailList = value;
        notifyListeners();
      }).catchError((error) {
        // Handle any error that occurred during the Future execution
        debugPrint('Error: $error');
      });
      saveUserID(sessionID: problemSessionID, userID: userID);

      //#####
    }
    notifyListeners();
  }

  void setcurrUnavailID(String id) {
    if (id.isEmpty) {
      // new unavail created
      saveUnavailability(
          sessionID: problemSessionID, unavailID: '', payload: {}).then((data) {
        currUnavailID = data['id'];
        unavailList.add(Unavail(id: data['id'], type: 0, dates: []));
        notifyListeners();
      });
    } else {
      currUnavailID = id;
      debugPrint('$userID select $currUnavailID');
      getUnavailData(sessionId: problemSessionID, unavailID: currUnavailID)
          .then((value) {
        notifyListeners();
      }).catchError((error) {
        // Handle any error that occurred during the Future execution
        debugPrint('Error: $error');
      });
      saveUserID(sessionID: problemSessionID, userID: userID);

      //#####
    }
    notifyListeners();
  }

  void setSchool(selectedSchool) {
    saveSession(
        sessionID: problemSessionID, payload: {'school': selectedSchool});

    debugPrint(selectedSchool);
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

  void updateUnavail(String unavailID, payload) {
    final index = unavailList.indexWhere((element) => element.id == unavailID);
    if (index != -1) {
      saveUnavailability(
              sessionID: problemSessionID,
              unavailID: unavailID,
              payload: payload)
          .then((data) {
        List<DateTime> dates = List<DateTime>.from(data['values']['dates']
            .map((dateString) => DateTime.parse(dateString)));
        unavailList[index] = Unavail(
            id: data['value']['id'], type: data['value']['type'], dates: dates);
      });
      //unavailList[index] = updatedUnavail;
    } else {
      //print('unavail${updatedUnavail.id} added ');
    }
    notifyListeners();
    //print(unavailList[index].professor);
  }

  void deleteUnavail(Unavail deletedUnavail) {
    unavailList.removeWhere((element) => element.id == deletedUnavail.id);
    deleteUnavailability(sessionID: problemSessionID, unavail: deletedUnavail);
    notifyListeners();
  }

  void deleteProblemSession(sessionID) {
    debugPrint('session to delete $sessionID');
    deleteSession(sessionID: sessionID);
    problemSessionList.removeWhere((element) => element.id == sessionID);

    notifyListeners();
  }

  void showToast(BuildContext context, String text) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        content: Text(text),
      ),
    );
  }
}

class ProblemSessionPage extends StatefulWidget {
  const ProblemSessionPage({super.key});

  @override
  State<ProblemSessionPage> createState() => _ProblemSessionPageState();
}

class _ProblemSessionPageState extends State<ProblemSessionPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var unavailList = appState.unavailList;

    return Scaffold(
      appBar: AppBar(title: const Text('Homepage')),
      body: Column(
        children: [
          DropdownButton(
              value: appState.school ?? 'Ing_Ind_Inf',
              items: const [
                DropdownMenuItem(
                  value: 'AUIC',
                  child: Text('AUIC'),
                ),
                DropdownMenuItem(
                  value: 'Ing_Ind_Inf',
                  child: Text('Ing Ind Inf'),
                ),
                DropdownMenuItem(
                  value: 'ICAT',
                  child: Text('ICAT'),
                ),
                DropdownMenuItem(
                  value: 'Design',
                  child: Text('Design'),
                ),
              ],
              onChanged: (newValue) {
                appState.setSchool(newValue);
              }),
          const MainDateSelector(),
          UnavailViewer(
              unavailList: unavailList,
              onItemClick: (unavail) {
                debugPrint(
                    'Main: ${appState.userID} select unavail ${unavail.id}');
                appState.setcurrUnavailID(unavail.id);

                Navigator.pushNamed(context, '/unavail');
              },
              onItemDelete: (unavail) {
                debugPrint(
                    'Main: ${appState.userID} delete unavail ${unavail.id}');
                appState.deleteUnavail(unavail);
              }),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
                onPressed: () {
                  if (appState.school != null &&
                      appState.sessionDates != null) {
                    startOptimization(sessionID: appState.problemSessionID);
                    saveSession(
                        sessionID: appState.problemSessionID,
                        payload: {'status': 'STARTED'});
                    appState.showToast(context, 'Optimization started');
                  } else if (appState.school == null) {
                    appState.showToast(context, 'School is not defined');
                  } else if (appState.sessionDates == null) {
                    appState.showToast(
                        context, 'Start and End date are not defined');
                  }

                  debugPrint('startOptimization triggered');
                },
                child: const Text('start')),
          ),
        ],
      ),
    );
  }
}

class MainDateSelector extends StatefulWidget {
  const MainDateSelector({super.key});

  @override
  _MainDateSelectorState createState() => _MainDateSelectorState();
}

class _MainDateSelectorState extends State<MainDateSelector> {
  DateTimeRange selectedDates =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    '${selectedDates.start.day} - ${selectedDates.start.month} - ${selectedDates.start.year}'),
                const SizedBox(width: 20),
                Text(
                    '${selectedDates.end.day} - ${selectedDates.end.month} - ${selectedDates.end.year}')
              ],
            ),
          ),
          ElevatedButton(
            child: const Text("Choose Dates"),
            onPressed: () async {
              final DateTimeRange? dateTimeRange = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: SizedBox(
                          height: 450,
                          width: 500,
                          child: child,
                        ),
                      ),
                    ],
                  );
                },
              );
              if (dateTimeRange != null) {
                setState(() {
                  selectedDates = dateTimeRange;
                  //Back-end call
                  appState.setStartEndDate(selectedDates);
                });
              }
            },
          )
        ],
      ),
    );
  }
}

class UnavailViewer extends StatelessWidget {
  final List<Unavail> unavailList;
  final Function(Unavail) onItemClick;
  final Function(Unavail) onItemDelete;

  const UnavailViewer(
      {super.key,
      required this.unavailList,
      required this.onItemClick,
      required this.onItemDelete});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: unavailList.length,
            itemBuilder: (context, index) {
              return ListTile(
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    onItemDelete(unavailList[index]);
                  },
                ),
                title: Text(unavailList[index].name),
                onTap: () {
                  onItemClick(unavailList[index]);
                },
              );
            },
          ),
        ),
        FloatingActionButton.small(
            child: const Icon(Icons.add),
            onPressed: () {
              if (appState.school != null && appState.sessionDates != null) {
                appState.setcurrUnavailID('');
                Navigator.pushNamed(context, '/unavail');
                appState.showToast(context, 'Create a new unavailability');
              } else if (appState.school == null) {
                appState.showToast(context, 'School is not defined');
              } else if (appState.sessionDates == null) {
                appState.showToast(
                    context, 'Start and End date are not defined');
              }
            }),
      ],
    );
  }
}
