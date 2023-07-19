import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:schedulex_webapp/model/ProblemSessionState.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    //final userID = context.select<UserState, String>((value) => value.userID);
    final problemSessionState = context.watch<ProblemSessionState>();

    final numCallsController = TextEditingController(
      text: problemSessionState.numCalls.toString(),
    );
    final currSemestercontroller = TextEditingController(
      text: problemSessionState.minDistanceExam.toString(),
    );
    final minDistanceExamController = TextEditingController(
      text: problemSessionState.minDistanceExam.toString(),
    );

    final defaultDistanceController = TextEditingController(
      text: problemSessionState.minDistanceCallsDefault.toString(),
    );

    void addException() {
      TextEditingController exIdController = TextEditingController();
      TextEditingController exDistanceController = TextEditingController();

      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Add Exception'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: exIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'ID'),
                ),
                TextField(
                  controller: exDistanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Distance'),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  String exId = exIdController.text;
                  int exDistance = int.tryParse(exDistanceController.text) ?? 0;

                  // Check if both values are provided before adding the exception
                  if (exId.isNotEmpty && exDistance > 0) {
                    problemSessionState.insertException(exId, exDistance);
                  }

                  Navigator.of(context).pop();
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    }

    void saveForm() {
      problemSessionState.updateSettings({
        'minDistanceCallsDefault': defaultDistanceController.text,
        'minDistanceExam': minDistanceExamController.text,
        'currSemester': numCallsController.text,
        'numCalls': currSemestercontroller.text
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Page'),
        actions: [
          IconButton(
            onPressed: () {
              context.pushReplacement('/select/session');
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Consumer<ProblemSessionState>(builder: (context, session, _) {
        final school = session.school;

        return Column(
          children: [
            Text(
                'You select settings for ${session.selectedSessionID} school: $school'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: numCallsController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'number of calls'),
                    onSubmitted: (value) {
                      // Optionally, handle the submitted value if needed
                    },
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: currSemestercontroller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'select current semester'),
                    onSubmitted: (value) {
                      // Optionally, handle the submitted value if needed
                    },
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: minDistanceExamController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'minDistanceExam'),
                    onSubmitted: (value) {
                      // Optionally, handle the submitted value if needed
                    },
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: defaultDistanceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Default'),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ElevatedButton(
                onPressed: () {
                  saveForm();
                  addException();
                },
                child: const Text('Add Exception'),
              ),
            ),
            SizedBox(
              height: 200,
              child: session.exceptions.isEmpty
                  ? const Center(
                      child: Text('No Exceptions'),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: session.exceptions.length,
                      itemBuilder: (context, index) {
                        final item = session.exceptions[index];
                        return ListTile(
                          trailing: const Icon(Icons.delete_outlined),
                          title: Row(
                            children: [
                              Text('Exam: ${item['id']}'),
                              const SizedBox(
                                width: 30,
                              ),
                              Text('custom distance: ${item['distance']} '),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveForm(); // Call the _saveForm method to save the entered values
              },
              child: const Text('Save'),
            ),
          ],
        );
      }),
    );
  }
}



/*Autocomplete<String>(
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
    ) */