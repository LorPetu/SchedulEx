import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'utils.dart';

class UnavailPage extends StatelessWidget {
  TextEditingController idController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController datesController = TextEditingController();
  TextEditingController professorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);
    final unavailList = appState.unavailList;
    final Unavail? unavail =
        ModalRoute.of(context)?.settings.arguments as Unavail?;

    if (unavail != null) {
      idController.text = unavail.id;
      typeController.text = unavail.type.toString();
      datesController.text = unavail.dates.toString();
      professorController.text = unavail.professor;
    }

    return Scaffold(
      appBar: AppBar(title: Text('UnavailPage')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: idController,
              decoration: InputDecoration(labelText: 'ID'),
            ),
            TextField(
              controller: typeController,
              decoration: InputDecoration(labelText: 'Type'),
            ),
            TextField(
              controller: datesController,
              decoration: InputDecoration(labelText: 'Dates'),
            ),
            TextField(
              controller: professorController,
              decoration: InputDecoration(labelText: 'Professor'),
            ),
            ElevatedButton(
              onPressed: () {
                final Unavail newUnavail = Unavail(
                  id: idController.text,
                  type: int.tryParse(typeController.text) ?? 0,
                  dates: [],
                  professor: professorController.text,
                );
                if (unavail != null) {
                  print('modify');
                } else {
                  appState.addUnavail(newUnavail);
                  print('new');
                }

                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
