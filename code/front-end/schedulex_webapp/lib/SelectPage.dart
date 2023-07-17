import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:schedulex_webapp/model/ProblemSessionState.dart';
import 'package:schedulex_webapp/model/UserState.dart';

class SelectPage extends StatelessWidget {
  const SelectPage({Key? key}) : super(key: key);
  //final String selected;
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
                userState.createSession();

                //context.pushReplacement('/Session');
                print('${userState.userID} create a new session');
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
                          leading: (element.status == 'NOT STARTED')
                              ? const Icon(Icons.not_started,
                                  color: Colors.yellow)
                              : const Icon(
                                  Icons.settings_backup_restore_outlined,
                                  color: Colors.green),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              userState.deleteProblemSession(element.id);
                            },
                          ),
                          title: Text(element.school),
                          onTap: () {
                            problemSessionState.setProblemSessionID(element.id);
                            context.pushReplacement('/select/session');
                            //Navigator.pushNamed(context, '/problemSession');
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
