import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../notifiers/auth_notifier.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _displayName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthNotifier>();
    final state = auth.state;

    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _displayName,
              decoration: const InputDecoration(labelText: "Display Name"),
            ),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            if (state.isLoading) const CircularProgressIndicator(),

            if (state.isError)
              Text(
                state.error ?? '',
                style: const TextStyle(color: Colors.red),
              ),

            ElevatedButton(
              onPressed: () async {
                await auth.register(
                  email: _email.text.trim(),
                  password: _password.text.trim(),
                  displayName: _displayName.text.trim(),
                );
              },
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
