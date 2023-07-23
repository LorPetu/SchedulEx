import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:schedulex_webapp/model/ProblemSessionState.dart';
import 'package:schedulex_webapp/model/UnavailState.dart';
import 'package:schedulex_webapp/model/UserState.dart';
import 'package:schedulex_webapp/BackEndMethods.dart';

import 'package:schedulex_webapp/utils.dart';

class ProblemSessionPageNEW extends StatelessWidget {
  const ProblemSessionPageNEW({super.key});

  @override
  Widget build(BuildContext context) {
    final userID = context.select<UserState, String>((value) => value.userID);
    final problemSessionState = context.watch<ProblemSessionState>();
    final unavailState = context.watch<UnavailState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Page'),
        actions: [
          IconButton(
            onPressed: () {
              context.pushReplacement('/select');
              //reset value of ProblemSession selected
              problemSessionState.resetProblemSessionID();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Consumer<ProblemSessionState>(
          builder: (context, problemSessionState, _) {
        final school = problemSessionState.school;
        final sessionDates = problemSessionState.sessionDates;
        final unavailList = problemSessionState.unavailList;
        return Column(
          children: [
            DropdownButton(
                value: school.isEmpty ? 'Ing_Ind_inf' : school,
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
                  problemSessionState.setSchool(newValue!);
                }),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: (sessionDates == null)
                        ? const Text('Select Dates')
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  '${sessionDates.start.day} - ${sessionDates.start.month} - ${sessionDates.start.year}'),
                              const SizedBox(width: 20),
                              Text(
                                  '${sessionDates.end.day} - ${sessionDates.end.month} - ${sessionDates.end.year}')
                            ],
                          ),
                  ),
                  ElevatedButton(
                    child: const Text("Choose Dates"),
                    onPressed: () async {
                      final DateTimeRange? dateTimeRange =
                          await showDateRangePicker(
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
                        problemSessionState.setStartEndDate(dateTimeRange);
                      }
                    },
                  )
                ],
              ),
            ),
            Column(
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
                            print(
                                '$userID delete unavail ${unavailList[index].id}');
                            problemSessionState
                                .deleteUnavail(unavailList[index].id);
                            //context.pushReplacement('/select/unavail');
                          },
                        ),
                        title: Text(unavailList[index].name),
                        onTap: () {
                          print(
                              '$userID select unavail ${unavailList[index].id}');
                          unavailState
                              .setCurrID(unavailList[index].id)
                              .then((value) {
                            context.pushReplacement('/select/unavail');
                          });
                          //context.pushReplacement('/select/unavail');
                        },
                      );
                    },
                  ),
                ),
                FloatingActionButton.small(
                    onPressed: (problemSessionState.school.isNotEmpty &&
                            problemSessionState.sessionDates != null)
                        ? () {
                            //(problemSessionState.status != 'NOT STARTED') ? null :

                            debugPrint('new unavail to be created');
                            unavailState.setCurrID('').then((value) {
                              context.pushReplacement('/select/unavail');
                            });
                          }
                        : null,
                    child: const Icon(Icons.add)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () =>
                          context.pushReplacement('/select/settings'),
                      child: const Icon(Icons.settings)),
                  const SizedBox(
                    width: 15,
                  ),
                  ElevatedButton(
                      onPressed: (problemSessionState.status == 'STARTED')
                          ? null
                          : () {
                              if (problemSessionState.school.isNotEmpty &&
                                  problemSessionState.sessionDates != null &&
                                  problemSessionState.numCalls != null &&
                                  problemSessionState.currSemester != null &&
                                  problemSessionState.minDistanceExams !=
                                      null &&
                                  problemSessionState.minDistanceCallsDefault !=
                                      null) {
                                startOptimization(
                                        sessionID: problemSessionState
                                            .selectedSessionID!)
                                    .then((value) => context
                                        .pushReplacement('/select/calendar'));

                                problemSessionState.showToast(
                                    context, 'Optimization started');
                              } else if (problemSessionState.school.isEmpty) {
                                problemSessionState.showToast(
                                    context, 'School is not defined');
                              } else if (problemSessionState.sessionDates ==
                                  null) {
                                problemSessionState.showToast(context,
                                    'Start and End date are not defined');
                              } else {
                                print(problemSessionState.currSemester);
                                problemSessionState.showToast(
                                    context, 'Please define session settings');
                              }

                              print('startOptimization triggered');
                            },
                      child: const Text('start')),
                ],
              ),
            )
          ],
        );
      }),
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
              debugPrint('new unavail to be created');
              //context.pushReplacement('/select/unavail');
            }),
      ],
    );
  }
}
