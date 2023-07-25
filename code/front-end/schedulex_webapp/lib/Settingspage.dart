import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:schedulex_webapp/model/ProblemSessionState.dart';
import 'package:schedulex_webapp/utils.dart';
import 'package:schedulex_webapp/BackEndMethods.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final problemSessionState = context.watch<ProblemSessionState>();

    final numCallsController = TextEditingController(
      text: problemSessionState.numCalls.toString(),
    );
    final currSemestercontroller = TextEditingController(
      text: problemSessionState.minDistanceExams.toString(),
    );
    final minDistanceExamController = TextEditingController(
      text: problemSessionState.minDistanceExams.toString(),
    );

    final defaultDistanceController = TextEditingController(
      text: problemSessionState.minDistanceCallsDefault.toString(),
    );

    void addException() {
      String exId = '';
      TextEditingController exDistanceController = TextEditingController();

      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Add Exception'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Insert name of the exam:',
                  style: TextStyle(fontSize: 14),
                ),
                AutoCompleteExams(onNameSelected: (value) {
                  exId = value;
                }),
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
        'minDistanceExams': minDistanceExamController.text,
        'currSemester': currSemestercontroller.text,
        'numCalls': numCallsController.text
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
        //final school = session.school;

        return Column(
          children: [
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
                const SizedBox(
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
                        const InputDecoration(labelText: 'minDistanceExams'),
                    onSubmitted: (value) {
                      // Optionally, handle the submitted value if needed
                    },
                  ),
                ),
                const SizedBox(
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
                saveForm();
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

class AutoCompleteExams extends StatefulWidget {
  final String? name;
  final void Function(String) onNameSelected;

  const AutoCompleteExams({
    Key? key,
    this.name,
    required this.onNameSelected,
  }) : super(key: key);

  @override
  State<AutoCompleteExams> createState() => _AutoCompleteExamsState();
}

class _AutoCompleteExamsState extends State<AutoCompleteExams> {
  static List<Exam> _examList = [];

  @override
  void initState() {
    super.initState();
    if (_examList.isEmpty) {
      // Fetch the exam list only if _examList is empty
      getExamList().then((value) {
        setState(() {
          _examList = value;
        });
      });
    }
  }

  static String _displayStringForOption(Exam option) => option.id;

  @override
  Widget build(BuildContext context) {
    final initialValue =
        widget.name != null ? TextEditingValue(text: widget.name!) : null;

    return Autocomplete<Exam>(
      initialValue: initialValue,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<Exam>.empty();
        }
        return _examList.where((Exam option) {
          return option.name
              .toString()
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (Exam selection) {
        debugPrint('You just selected ${_displayStringForOption(selection)}');
        widget.onNameSelected(selection.id);
      },
    );
  }
}
