import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedulex_webapp/BackEndMethods.dart';
import 'main.dart';

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  Future<dynamic>? sessionList_data;

  @override
  void initState() {
    sessionList_data = getSessionList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Page'),
      ),
      body: FutureBuilder<dynamic>(
          future: sessionList_data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Display a loading indicator while fetching data
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              // Handle any error that occurred during data retrieval
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              dynamic SessionList = snapshot.data!;

              return Column(
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
                        debugPrint(
                            'SelectPage: ${appState.userID} create a new session');
                      },
                    ),
                  ),
                  Expanded(
                    child: SessionList.isEmpty
                        ? const Center(
                            child: Text('No data available'),
                          )
                        : ListView.builder(
                            itemCount: SessionList.length,
                            itemBuilder: (context, index) {
                              final element = SessionList[index];
                              return ListTile(
                                leading: (element.status == 'NOT STARTED')
                                    ? const Icon(Icons.not_started,
                                        color: Colors.yellow)
                                    : const Icon(
                                        Icons.settings_backup_restore_outlined,
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
                                  Navigator.pushNamed(
                                      context, '/problemSession');
                                },
                              );
                            },
                          ),
                  )
                ],
              );
            }
          }),
    );
  }
}
