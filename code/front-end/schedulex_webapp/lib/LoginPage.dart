import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:schedulex_webapp/model/UserState.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    //var userID = context.select<UserState, void>((user) => user.userID);

    var userState = context.watch<UserState>();
    final serverURLcontroller =
        TextEditingController(text: userState.customServerUrl);

    String inputUsername = '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Username',
                  ),
                  onChanged: (value) {
                    inputUsername = value;
                  },
                  onFieldSubmitted: (value) {
                    //In this way i can press Enter to logged into the app and
                    //navigate to other page
                    userState.setUserID(inputUsername);

                    // Set the user ID in MyAppState
                    context.pushReplacement('/select');
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Get the user ID from the text field
                        //and set in the userState
                        userState.setUserID(inputUsername);
                        context.pushReplacement('/select');
                      },
                      child: const Text('Login'),
                    ),
                    IconButton(
                        onPressed: () {
                          String? customServerURL;

                          showDialog(
                              context: context,
                              builder: (ctx) {
                                return StatefulBuilder(
                                    builder: (context, setState) {
                                  return AlertDialog(
                                    title: const Text('SERVER settings'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Specify your server URL',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        TextField(
                                          controller: serverURLcontroller,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              labelText: 'url'),
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
                                          print(serverURLcontroller.text);
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Add'),
                                      ),
                                    ],
                                  );
                                });
                              });
                        },
                        icon: const Icon(Icons.settings))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
