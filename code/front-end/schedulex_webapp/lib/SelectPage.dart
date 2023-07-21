import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:schedulex_webapp/model/ProblemSessionState.dart';
import 'package:schedulex_webapp/model/UserState.dart';

class SelectPage extends StatefulWidget {
  const SelectPage({Key? key}) : super(key: key);

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(
          seconds: 2), // You can adjust the duration as per your preference.
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
    final userState = context.watch<UserState>();
    final problemSessionState = context.watch<ProblemSessionState>();
    /*context.select<ProblemSessionState, String>(
        (session) => session.selectedSessionID! );
        final problemSessionState_set = context.select<ProblemSessionState, void>(
        (session) {session.setProblemSessionID(id)} );*/

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
              child: const SizedBox(
                width: 100,
                child: Row(
                  children: [Icon(Icons.add), Text('new session')],
                ),
              ),
              onPressed: () {
                // Set the ProblemSessionID in MyuserState
                userState.createSession().then((value) {
                  problemSessionState.setProblemSessionID(value);
                  context.pushReplacement('/select/session');
                  print('${userState.userID} create a new session');
                });
                //context.pushReplacement('/Session');
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
                              case 'PENDING':
                                return const Icon(
                                    Icons.pause_circle_outline_rounded,
                                    color: Colors.orange);
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
                              ? Text(element.school)
                              : const Text('School not selected'),
                          onTap: () {
                            problemSessionState.setProblemSessionID(element.id);
                            if (element.status == 'STARTED' ||
                                element.status == 'SOLVED') {
                              context.pushReplacement('/select/calendar');
                            } else {
                              context.pushReplacement('/select/session');
                            }
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
