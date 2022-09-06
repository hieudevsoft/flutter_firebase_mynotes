import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../controller/firebase/auth.dart';
import '../../firebase_options.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: const Text('Register'),
      ),
      body: Center(
        child: Container(
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
              TextButton(
                  onPressed: () async {
                    final credential = await registerWithEmailAndPassword(
                        _email.text, _password.text);
                    print(credential);
                  },
                  child: const Text("Register")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                  child: const Text('Already account? Login here!'))
            ],
          ),
        ),
      ),
    );
  }
}
