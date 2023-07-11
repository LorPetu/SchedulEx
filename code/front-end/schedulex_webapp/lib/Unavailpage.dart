import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'utils.dart';

class UnavailPage extends StatefulWidget {
  const UnavailPage({Key? key});

  @override
  State<UnavailPage> createState() => _UnavailPageState();
}

class _UnavailPageState extends State<UnavailPage> {
  int type = 0;
  String name = '';
  List<DateTime> dates = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final appState = Provider.of<MyAppState>(context, listen: false);
    final Unavail? unavail =
        ModalRoute.of(context)?.settings.arguments as Unavail?;

    if (unavail != null) {
      setState(() {
        type = unavail.type;
        name = unavail.professor;
        dates = unavail.dates;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);
    final Unavail? unavail =
        ModalRoute.of(context)?.settings.arguments as Unavail?;

    return Scaffold(
      appBar: AppBar(title: const Text('UnavailPage')),
      body: Padding(
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
                });
                print(type);
              },
              hint: const Text('Select Type'),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: AutoCompleteProfessor(
                name: unavail?.professor,
                onNameSelected: (String selection) {
                  setState(() {
                    name = selection;
                  });
                },
              ),
            ),
            DateTimeListWidget(
                dateTimeList: dates,
                onDatesChange: (newdates) {
                  setState(() {
                    print(newdates);
                    dates = newdates;
                  });
                }),
            ElevatedButton(
              onPressed: () {
                final Unavail newUnavail = Unavail(
                  id: unavail?.id ?? '',
                  type: type,
                  professor: name,
                  dates: dates,
                );
                if (unavail != null) {
                  print(newUnavail.dates);
                  appState.addUnavail(newUnavail);
                  //appState.updateUnavail(newUnavail);
                  Navigator.pop(context);
                } else {
                  appState.addUnavail(newUnavail);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

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
    final initialValue = name != null ? TextEditingValue(text: name!) : null;

    return Autocomplete<String>(
      initialValue: initialValue,
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

class DateTimeListWidget extends StatefulWidget {
  final Function(List<DateTime> newdates) onDatesChange;
  final List<DateTime> dateTimeList;

  const DateTimeListWidget({
    Key? key,
    required this.dateTimeList,
    required this.onDatesChange,
  }) : super(key: key);

  @override
  _DateTimeListWidgetState createState() => _DateTimeListWidgetState();
}

class _DateTimeListWidgetState extends State<DateTimeListWidget> {
  void addSingleDay(DateTime date) {
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
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(
            onPressed: () async {
              final DateTime? currentDate = await showDatePicker(
                context: context,
                initialDate: appState.sessionDates!.start,
                firstDate: appState.sessionDates!.start,
                lastDate: appState.sessionDates!.end,
              );
              if (currentDate != null) {
                setState(() {
                  addSingleDay(currentDate);
                });
              }
            },
            child: const Text('Single Day'),
          ),
          ElevatedButton(
            onPressed: () async {
              final DateTimeRange? dateTimeRange = await showDateRangePicker(
                context: context,
                firstDate: appState.sessionDates!.start,
                lastDate: appState.sessionDates!.end,
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
                  addDateRange(dateTimeRange.start, dateTimeRange.end);
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
                addRecurrentDaysOfWeek(daysOfWeek);
              });
            },
            child: const Text('Recurrent Day'),
          ),
        ]),
        const SizedBox(height: 16),
        Text('DateTime List:'),
        Container(
          height: 200,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.dateTimeList.length,
            itemBuilder: (context, index) {
              final dateTime = widget.dateTimeList[index];
              return Row(
                children: [
                  Text(
                      '${dateTime.day} - ${dateTime.month} - ${dateTime.year}'),
                  SizedBox(width: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          List<DateTime> newDates =
                              List.from(widget.dateTimeList);
                          newDates.removeAt(index);
                          widget.onDatesChange(newDates);
                        });
                      },
                      child: Icon(Icons.delete_outlined),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
