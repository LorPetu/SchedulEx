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
  String userID = '';
  String problemSessionID = '';

  //SelectpageSession
  List<ProblemSession> problemSessionList = generateRandomProblemSessionList(5);

  //unavailPage states
  DateTimeRange? sessionDates;
  String school = 'Option 1';
  List<Unavail> unavailList = generateRandomUnavailList(10);

  void setUserID(String id) {
    userID = id;
    print('$userID logged in');
    notifyListeners();
  }

  void setProblemSessionID(String id) {
    if (id.isEmpty) {
      print('no problemSessionID');
      //#####
      //Backend call to set all the other information
      //#####
    } else {
      problemSessionID = id;
      print('$userID select $problemSessionID');

      //#####
      saveUserID(sessionID: problemSessionID, userID: userID);
      //#####
      //var data = getSessionData(sessionId: problemSessionID);
    }
    notifyListeners();
  }

  void setSchool(selectedeSchool) {
    print(selectedeSchool);
    school = selectedeSchool;
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

  void addUnavail(Unavail unavail) {
    print("this is new");
    int newlenght = unavailList.length + 1;
    unavail.id = "Unavail-" + newlenght.toString();
    saveUnavailability(sessionID: problemSessionID, unavail: unavail);
    unavailList.add(unavail);

    notifyListeners();
  }

  void updateUnavail(Unavail updatedUnavail) {
    final index =
        unavailList.indexWhere((element) => element.id == updatedUnavail.id);
    if (index != -1) {
      print(updatedUnavail.dates);
      //saveUnavailability(sessionID: problemSessionID, unavail: updatedUnavail);
      unavailList[index] = updatedUnavail;
    } else {
      print('unavail' + updatedUnavail.id + 'not found ');
    }
    notifyListeners();
    //print(unavailList[index].professor);
  }

  void deleteUnavail(id) {
    unavailList.removeWhere((element) => element.id == id);

    void createProblemSession() {}

    void deleteProblemSession(problemSessionID) {}

    notifyListeners();
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
              value: appState.school,
              items: const [
                DropdownMenuItem(
                  value: 'Option 1',
                  child: Text('Option 1'),
                ),
                DropdownMenuItem(
                  value: 'Option 2',
                  child: Text('Option 2'),
                ),
                DropdownMenuItem(
                  value: 'Option 3',
                  child: Text('Option 3'),
                ),
              ],
              onChanged: (newValue) {
                appState.setSchool(newValue);
              }),
          MainDateSelector(),
          UnavailViewer(
              unavailList: unavailList,
              onItemClick: (unavail) {
                print('${appState.userID}select unavail ${unavail.id}');
                Navigator.pushNamed(context, '/unavail', arguments: unavail);
              }),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
                onPressed: () => {
                      startOptimization(sessionID: appState.problemSessionID),
                      print('startOptimization triggered')
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
                        child: Container(
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

  const UnavailViewer({
    super.key,
    required this.unavailList,
    required this.onItemClick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: unavailList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(unavailList[index].professor),
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
              Navigator.pushNamed(context, '/unavail');
            }),
      ],
    );
  }
}
