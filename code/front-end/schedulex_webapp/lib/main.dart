import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedulex_webapp/LoginPage.dart';
import 'SelectPage.dart';

import 'utils.dart';

import 'Unavailpage.dart';
import 'DatabaseMethods.dart';

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
        title: 'Namer App',
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
  List<Unavail> unavailList = generateRandomUnavailList(10);
  List<ProblemSession> ProblemSessionList = generateRandomProblemSessionList(3);
  List<FakeElement> elements = generateRandomElementList(10);
  String problemSessionID = '';
  String userID = '';

  void setUserID(String id) {
    userID = id;
    print(userID);
    notifyListeners();
  }

  void setProblemSessionID(String id) {
    problemSessionID = id;
    print(userID + ' has clicked ' + problemSessionID);
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

//******HOMEPAGE*******/
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var problemSessionList = appState.ProblemSessionList;
    //return Placeholder();
    return Column(
      children: [
        ProblemSessionViewer(
          ProblemSessionList: problemSessionList,
          onItemClick: () {
            print('test');
          },
        ),
      ],
    );
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

class ProblemSessionViewer extends StatelessWidget {
  final List<ProblemSession> ProblemSessionList;
  final Function() onItemClick;

  const ProblemSessionViewer({
    required this.ProblemSessionList,
    required this.onItemClick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: ProblemSessionList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(ProblemSessionList[index].school),
                onTap: onItemClick,
              );
            },
          ),
        ),
        FloatingActionButton.small(
          child: Icon(Icons.add),
          onPressed: () {
            print('FLOAT PRESSED');
          },
        ),
      ],
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
            child: const Text("Choose Date"),
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
                  saveStartDate(appState.userID, selectedDates.start.toString(),
                      selectedDates.end.toString());
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
