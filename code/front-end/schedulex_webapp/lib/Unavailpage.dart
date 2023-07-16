import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedulex_webapp/BackEndMethods.dart';
import 'main.dart';
import 'utils.dart';

class UnavailPage extends StatefulWidget {
  const UnavailPage({super.key});

  @override
  State<UnavailPage> createState() => _UnavailPageState();
}

class _UnavailPageState extends State<UnavailPage> {
  int type = 0;
  String name = '';
  List<DateTime> dates = [];
  //String? currUnavailID;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);
    String currUnavailID = appState.currUnavailID;

    return Scaffold(
        appBar: AppBar(title: const Text('UnavailPage')),
        body: FutureBuilder<dynamic>(
            future: getUnavailData(
              sessionId: appState.problemSessionID,
              unavailID: currUnavailID!,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Display a loading indicator while fetching data
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                // Handle any error that occurred during data retrieval
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                // Data retrieval successful, build the widget tree
                Unavail unavailData = snapshot.data!;

                // Update the widget state with the retrieved data
                type = unavailData.type;
                name = unavailData.name;
                dates = unavailData.dates;

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DropdownButton<int>(
                        value: type,
                        items: const [
                          DropdownMenuItem(
                            value: 0,
                            child: Text('Professor'),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text('Politecnico'),
                          ),
                        ],
                        onChanged: (newValue) {
                          setState(() {
                            type = newValue!;
                            saveUnavailability(
                                    sessionID: appState.problemSessionID,
                                    unavailID: currUnavailID,
                                    payload: {'type': type})
                                .then((value) => currUnavailID = value['id']);
                          });
                          print(currUnavailID);
                        },
                        hint: const Text('Select Type'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AutoCompleteProfessor(
                          name: name,
                          onNameSelected: (String selection) {
                            setState(() {
                              name = selection;

                              saveUnavailability(
                                      sessionID: appState.problemSessionID,
                                      unavailID: currUnavailID,
                                      payload: {'name': name})
                                  .then((value) => print('new unavail $value'));
                            });
                          },
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final DateTime? currentDate =
                                    await showDatePicker(
                                  context: context,
                                  initialDate: appState.sessionDates!.start,
                                  firstDate: appState.sessionDates!.start,
                                  lastDate: appState.sessionDates!.end,
                                );
                                if (currentDate != null) {}
                              },
                              child: const Text('Single Day'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final DateTimeRange? dateTimeRange =
                                    await showDateRangePicker(
                                  context: context,
                                  firstDate: appState.sessionDates!.start,
                                  lastDate: appState.sessionDates!.end,
                                  builder: (context, child) {
                                    return Column(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 50.0),
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
                                    //addDateRange(dateTimeRange.start, dateTimeRange.end);
                                  });
                                }
                              },
                              child: const Text('Date Range'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final daysOfWeek = [
                                  DateTime.monday,
                                  DateTime.wednesday,
                                  DateTime.friday
                                ];
                                setState(() {
                                  //addRecurrentDaysOfWeek(daysOfWeek);
                                });
                              },
                              child: const Text('Recurrent Day'),
                            ),
                          ]),
                      Expanded(
                        child: dates.isEmpty
                            ? const Center(
                                child: Text('No data available'),
                              )
                            : ListView.builder(
                                itemCount: dates.length,
                                itemBuilder: (context, index) {
                                  final element = dates[index];
                                  return ListTile(
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        print('delete this date');
                                      },
                                    ),
                                    title: Text(
                                        '${element.day} - ${element.month} - ${element.year}'),
                                  );
                                },
                              ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final Unavail newUnavail = Unavail(
                            id: currUnavailID ?? '',
                            type: type,
                            name: name,
                            dates: dates,
                          );
                          if (currUnavailID != null) {
                            print(newUnavail.dates);
                            appState.updateUnavail(currUnavailID!,
                                {'type': type, 'name': name, 'dates': dates});
                            //appState.updateUnavail(newUnavail);
                            appState.showToast(context, 'Add new unavail');
                            Navigator.pop(context);
                          } else {
                            appState.updateUnavail('',
                                {'type': type, 'name': name, 'dates': dates});
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Save'),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            print(name);
                            getUnavailData(
                                    sessionId: appState.problemSessionID,
                                    unavailID: currUnavailID!)
                                .then((value) => print(value.id));
                          },
                          child: Text('data'))
                    ],
                  ),
                );
              }
            }));
  } //Widget build
} //Widget class
////////////

class AutoCompleteProfessor extends StatelessWidget {
  final String? name;
  final void Function(String) onNameSelected;

  const AutoCompleteProfessor({
    Key? key,
    this.name,
    required this.onNameSelected,
  }) : super(key: key);

  static const List<String> _profList = <String>[
    'aardvark',
    'bobcat',
    'chameleon',
  ];

  @override
  Widget build(BuildContext context) {
    //final initialValue = name != null ? TextEditingValue(text: name!) : null;

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: name!),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return _profList.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        debugPrint('You just selected $selection');
        onNameSelected(selection);
      },
    );
  }
}

/*void addSingleDay(DateTime date) {
    List<DateTime> newDates = List.from(widget.dateTimeList);
    newDates.add(date);
    widget.onDatesChange(newDates);
  }

  void addDateRange(DateTime startDate, DateTime endDate) {
    List<DateTime> newDates = List.from(widget.dateTimeList);
    for (var date = startDate;
        date.isBefore(endDate);
        date = date.add(const Duration(days: 1))) {
      newDates.add(date);
    }
    widget.onDatesChange(newDates);
  }

  void addRecurrentDaysOfWeek(List<int> daysOfWeek) {
    List<DateTime> newDates = List.from(widget.dateTimeList);
    final currentDate = DateTime.now();
    final firstDayOfWeek =
        currentDate.subtract(Duration(days: currentDate.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));

    for (var date = firstDayOfWeek;
        date.isBefore(lastDayOfWeek);
        date = date.add(const Duration(days: 1))) {
      if (daysOfWeek.contains(date.weekday)) {
        newDates.add(date);
      }
    }
    widget.onDatesChange(newDates);
  }*/
