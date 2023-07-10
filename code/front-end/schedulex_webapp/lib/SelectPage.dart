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
                // #BACKEND createSession
                //########

                //########
                // Navigate to the ProblemSession Page
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
                        title: Text(element.id),
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
