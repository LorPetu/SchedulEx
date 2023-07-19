import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:schedulex_webapp/model/ProblemSessionState.dart';
import 'package:schedulex_webapp/model/UnavailState.dart';

class UnavailPageNEW extends StatelessWidget {
  const UnavailPageNEW({super.key});

  @override
  Widget build(BuildContext context) {
    final sessiondates = context.select<ProblemSessionState, DateTimeRange>(
        (value) => value.sessionDates!);
    final unavailState = context.watch<UnavailState>();

    void addSingleDay(DateTime date) {
      unavailState.addDates([date]);
    }

    void addDateRange(DateTime startDate, DateTime endDate) {
      List<DateTime> newDates = [];
      for (var date = startDate;
          date.isBefore(endDate.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        newDates.add(date);
      }
      print('newdates $newDates');
      unavailState.addDates(newDates);
    }

    void addRecurrentDaysOfWeek(
        DateTime startDate, DateTime endDate, int dayOfWeek) {
      List<DateTime> newDates = [];

      unavailState.addDates(newDates);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('UnavailPage')),
      body: Consumer<UnavailState>(builder: (context, unavail, _) {
        final type = unavail.type;
        final name = unavail.name;
        final dates = unavail.dates;
        return Column(
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
                unavailState.setType(newValue!);
              },
              hint: const Text('Select Type'),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: AutoCompleteProfessor(
                name: name,
                onNameSelected: (String selection) {
                  unavailState.setName(selection);
                },
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton(
                    //SELECT SINGLE DAY
                    onPressed: () async {
                      final DateTime? currentDate = await showDatePicker(
                        context: context,
                        initialDate: sessiondates.start,
                        firstDate: sessiondates.start,
                        lastDate: sessiondates.end,
                      );
                      if (currentDate != null) {
                        addSingleDay(currentDate);
                      }
                    },
                    child: const Text('Single Day'),
                  ),
                  ElevatedButton(
                    //SELECT A DATE RANGE PERIOD
                    onPressed: () async {
                      final DateTimeRange? dateTimeRange =
                          await showDateRangePicker(
                        context: context,
                        firstDate: sessiondates.start,
                        lastDate: sessiondates.end,
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

                      addRecurrentDaysOfWeek(
                          sessiondates.start, sessiondates.end, daysOfWeek[0]);
                    },
                    child: const Text('Recurrent Day'),
                  ),
                ]),
                const SizedBox(height: 16),
                const Text('DateTime List:'),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: dates.length,
                    itemBuilder: (context, index) {
                      final dateTime = dates[index];
                      return ListTile(
                        trailing: const Icon(Icons.delete_outlined),
                        title: Text(
                            '${dateTime.day} - ${dateTime.month} - ${dateTime.year}'),
                      );
                    },
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                unavailState.reset();
                context.pushReplacement('/select/session');
              },
              child: const Text('Save'),
            ),
          ],
        );
      }),
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
