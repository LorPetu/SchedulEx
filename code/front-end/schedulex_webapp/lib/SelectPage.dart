import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class SelectPage extends StatelessWidget {
  const SelectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);

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
                // Set the ProblemSessionID in MyAppState
                appState.setProblemSessionID('');

                Navigator.pushNamed(context, '/problemSession');
                print('${appState.userID} create a new session');
              },
            ),
          ),
          Expanded(
            child: appState.problemSessionList.isEmpty
                ? const Center(
                    child: Text('No data available'),
                  )
                : ListView.builder(
                    itemCount: appState.problemSessionList.length,
                    itemBuilder: (context, index) {
                      final element = appState.problemSessionList[index];
                      return ListTile(
                        leading: (element.status == 'NOT STARTED')
                            ? const Icon(Icons.not_started,
                                color: Colors.yellow)
                            : const Icon(Icons.settings_backup_restore_outlined,
                                color: Colors.green),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            appState.deleteProblemSession(element.id);
                          },
                        ),
                        title: Text(element.school),
                        onTap: () {
                          appState.setProblemSessionID(element.id);
                          Navigator.pushNamed(context, '/problemSession');
                        },
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
