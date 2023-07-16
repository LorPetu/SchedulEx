import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:schedulex_webapp/model/UserState.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    var userID = context.select<UserState, void>((user) => user.userID);
    var userState = context.watch<UserState>();
    String inputUsername = '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
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
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Get the user ID from the text field
                    //debugPrint(userID);
                    userState.setUserID(inputUsername);
                    //debugPrint(userID);

                    // Set the user ID in MyAppState
                    context.pushReplacement('/select');

                    // Navigate to the Select Page
                    //Navigator.pushNamed(context, '/select');
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
