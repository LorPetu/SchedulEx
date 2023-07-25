
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:schedulex_webapp/model/ProblemSessionState.dart';
import 'package:schedulex_webapp/model/UserState.dart';

class SelectPage extends StatefulWidget {
  const SelectPage({Key? key}) : super(key: key);

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  //When the widget is build the AnimationController is intialized
  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // This will make the animation loop infinitely.
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Connect to upper-level state
    final userState = context.watch<UserState>();
    final problemSessionState = context.watch<ProblemSessionState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              //New session button
              child: const SizedBox(
                width: 100,
                child: Row(
                  children: [Icon(Icons.add), Text('new session')],
                ),
              ),
              onPressed: () {
                // Set the ProblemSessionID in userState
                userState.createSession().then((value) {
                  problemSessionState.setProblemSessionID(value);
                  context.pushReplacement('/select/session');
                  print('${userState.userID} create a new session');
                });
              },
            ),
          ),
          Consumer<UserState>(builder: (context, userState, _) {
            final problemSessionList = userState.problemSessionList;
            return Expanded(
              child: problemSessionList.isEmpty
                  ? const Center(
                      child: Text('No data available'),
                    )
                  : ListView.builder(
                      itemCount: problemSessionList.length,
                      itemBuilder: (context, index) {
                        final element = problemSessionList[index];
                        final DateFormat formatter = DateFormat('dd/MM/yy');
                        return ListTile(
                          leading: (() {
                            switch (element.status) {
                              case 'NOT STARTED':
                                return const Icon(Icons.not_started_outlined,
                                    color: Colors.yellow);
                              case 'STARTED':
                                return RotationTransition(
                                  turns: _rotationController,
                                  child: const Icon(Icons.rotate_right_outlined,
                                      color: Colors.blue),
                                );
                              case 'SOLVED':
                                return const Icon(
                                    Icons.check_circle_outline_outlined,
                                    color: Colors.green);
                              case 'NOT SOLVED':
                                return const Icon(Icons.not_interested_outlined,
                                    color: Colors.red);
                              default:
                                return null;
                            }
                          })(),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              userState.delete(element.id);
                            },
                          ),
                          title: element.school.isNotEmpty
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        element.school,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Flexible(
                                      child: Tooltip(
                                        message: element.description,
                                        child: Text(
                                          element.description,
                                          overflow: TextOverflow.fade,
                                          maxLines: 1,
                                          softWrap: false,
                                          style: const TextStyle(
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              : const Text('School not selected'),
                          subtitle: (element.startDate != null &&
                                  element.endDate != null)
                              ? Text(
                                  'From: ${formatter.format(element.startDate!)}     To: ${formatter.format(element.endDate!)}')
                              : null,
                          onTap: () {
                            problemSessionState
                                .setProblemSessionID(element.id)
                                .then((value) {
                              if (element.status == 'STARTED' ||
                                  element.status == 'SOLVED') {
                                context.pushReplacement('/select/calendar');
                              } else {
                                context.pushReplacement('/select/session');
                              }
                            });
                          },
                        );
                      },
                    ),
            );
          })
        ],
      ),
    );
  }
}
