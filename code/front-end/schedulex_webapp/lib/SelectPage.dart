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
      body: ListView.builder(
        itemCount: appState.ProblemSessionList.length,
        itemBuilder: (context, index) {
          final element = appState.ProblemSessionList[index];

          return ListTile(
            title: Text(element.id),
            onTap: () {
              // Set the ProblemSessionID in MyAppState
              appState.setProblemSessionID(element.id);

              // Navigate to the ProblemSession Page
              Navigator.pushNamed(context, '/problemSession');
            },
          );
        },
      ),
    );
  }
}
