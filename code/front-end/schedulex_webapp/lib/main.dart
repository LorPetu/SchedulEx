import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
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
        initialRoute: '/',
        routes: {
          '/': (context) => Homepage(),
          '/unavail': (context) => UnavailPage(),
        },
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  List<Unavail> unavailList = generateRandomUnavailList(10);
  final userID = '123ABC';

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

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
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

List<Unavail> generateRandomUnavailList(int count) {
  final random = Random();
  List<Unavail> unavailList = [];

  for (int i = 0; i < count; i++) {
    String id = 'Unavail-${i + 1}';
    int type = random.nextInt(3); // Generates random type: 0, 1, or 2
    List<DateTime> dates = [
      DateTime.now().add(Duration(
          days: random.nextInt(30))), // Random date within the next 30 days
      DateTime.now().add(Duration(days: random.nextInt(30))),
    ];
    String professor = 'Professor ${i + 1}';

    Unavail unavail = Unavail(
      id: id,
      type: type,
      dates: dates,
      professor: professor,
    );

    unavailList.add(unavail);
  }

  return unavailList;
}
