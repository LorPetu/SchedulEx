import 'main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _userIDController;

  @override
  void initState() {
    super.initState();
    _userIDController = TextEditingController();
  }

  @override
  void dispose() {
    _userIDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                TextField(
                  controller: _userIDController,
                  decoration: const InputDecoration(
                    labelText: 'User ID',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Get the user ID from the text field
                    final userID = _userIDController.text;

                    // Set the user ID in MyAppState
                    Provider.of<MyAppState>(context, listen: false)
                        .setUserID(userID);

                    // Navigate to the Select Page
                    Navigator.pushNamed(context, '/select');
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
