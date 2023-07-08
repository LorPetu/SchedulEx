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
          '/login': (context) => LoginPage(),
          '/select': (context) => SelectPage(),
          '/problemSession': (context) => ProblemSessionPage(),
          '/unavail': (context) => UnavailPage()
        },
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  String userID = '';
  String problemSessionID = '';

  //SelectpageSession
  List<ProblemSession> ProblemSessionList = generateRandomProblemSessionList(5);

  //unavailPage states
  DateTime? startDate;
  DateTime? endDate;
  String school = 'Option 1';
  List<Unavail> unavailList = generateRandomUnavailList(10);

  void setUserID(String id) {
    userID = id;
    print(userID + ' logged in');
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
      print(userID + ' select ' + problemSessionID);

      //#####
      //Backend call to set all the other information
      //#####
    }

    notifyListeners();
  }

  void setSchool(selectedeSchool) {
    print(selectedeSchool);
    school = selectedeSchool;
    notifyListeners();
  }

  void addUnavail(unavail) {
    unavailList.add(unavail);
    print("this is new");
    notifyListeners();
  }

  void modifyUnavail(Unavail unavail) {
    var index = unavailList.indexOf(unavail);
    print(index);
  }

  void deleteUnavail(id) {
    //functionality
  }
}

class ProblemSessionPage extends StatefulWidget {
  const ProblemSessionPage({super.key});

  @override
  State<ProblemSessionPage> createState() => _ProblemSessionPageState();
}

class _ProblemSessionPageState extends State<ProblemSessionPage> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var unavailList = appState.unavailList;

    return Scaffold(
      appBar: AppBar(title: Text('Homepage')),
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
                Navigator.pushNamed(context, '/unavail', arguments: unavail);
              }),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
                onPressed: () => {
                      startOptimization(appState.userID),
                      print('startOptimization triggered')
                    },
                child: Text('start')),
          ),
        ],
      ),
    );
  }
}

class MainDateSelector extends StatefulWidget {
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
                SizedBox(width: 20),
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
              );
              if (dateTimeRange != null) {
                setState(() {
                  selectedDates = dateTimeRange;
                  //Back-end call
                  print(appState.userID);

                  saveStartDate(
                      userId: appState.userID,
                      startDate: selectedDates.start.toString(),
                      endDate: selectedDates.end.toString());
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
                title: Text('${unavailList[index].professor}'),
                onTap: () {
                  onItemClick(unavailList[index]);
                  //print(unavailList.map((e) => e.professor));
                },
              );
            },
          ),
        ),
        FloatingActionButton.small(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/unavail');
            }),
      ],
    );
  }
}
