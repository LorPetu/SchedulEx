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
            DateTimeListWidget(),
            ElevatedButton(
              onPressed: () {
                final Unavail newUnavail = Unavail(
                  id: unavail?.id ?? '',
                  type: type,
                  professor: name,
                  dates: [],
                );
                if (unavail != null) {
                  print(name);
                  appState.updateUnavail(newUnavail);
                  Navigator.pop(context);
                } else {
                  appState.addUnavail(newUnavail);
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
  @override
  _DateTimeListWidgetState createState() => _DateTimeListWidgetState();
}

class _DateTimeListWidgetState extends State<DateTimeListWidget> {
  List<DateTime> dateTimeList = [];

  void addSingleDay(DateTime date) {
    setState(() {
      dateTimeList.add(date);
    });
  }

  void addDateRange(DateTime startDate, DateTime endDate) {
    for (var date = startDate;
        date.isBefore(endDate);
        date = date.add(const Duration(days: 1))) {
      setState(() {
        dateTimeList.add(date);
      });
    }
  }

  void addRecurrentDaysOfWeek(List<int> daysOfWeek) {
    final currentDate = DateTime.now();
    final firstDayOfWeek =
        currentDate.subtract(Duration(days: currentDate.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));

    for (var date = firstDayOfWeek;
        date.isBefore(lastDayOfWeek);
        date = date.add(const Duration(days: 1))) {
      if (daysOfWeek.contains(date.weekday)) {
        setState(() {
          dateTimeList.add(date);
        });
      }
    }
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
                addSingleDay(currentDate);
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
                addDateRange(dateTimeRange.start, dateTimeRange.end);
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
              addRecurrentDaysOfWeek(daysOfWeek);
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
            itemCount: dateTimeList.length,
            itemBuilder: (context, index) {
              final dateTime = dateTimeList[index];
              return Text(dateTime.toString());
            },
          ),
        ),
      ],
    );
  }
}
