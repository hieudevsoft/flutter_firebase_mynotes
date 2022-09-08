import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/controller/firebase/auth.dart';

import '../../utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email here',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              obscureText: true,
              controller: _password,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Enter your password here',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
                onPressed: () async {
                  try {
                    final credentinal = await signInWithEmailAndPassword(
                      _email.text,
                      _password.text,
                    );
                    if (!mounted) return;
                    if (credentinal.user != null) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/notes',
                        (route) => false,
                      );
                    }
                    FocusManager.instance.primaryFocus?.unfocus();
                  } on FirebaseAuthException catch (e) {
                    if (!mounted) return;
                    await showErrorDialog(context, e.code);
                  }
                },
                child: const Text("Login")),
            TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/register', (route) => false);
                },
                child: const Text('Not registered? Register here!'))
          ],
        ),
      ),
    );
  }
}
