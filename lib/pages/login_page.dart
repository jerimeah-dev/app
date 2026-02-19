import 'package:app/notifiers/app_initializer_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../notifiers/auth_notifier.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthNotifier>();
    final state = auth.state;

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
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
                await auth.login(
                  email: _email.text.trim(),
                  password: _password.text.trim(),
                );
                if (auth.isLoggedIn) {
                  await context.read<AppInitializerNotifier>().initialize();
                }
              },
              child: const Text("Login"),
            ),

            TextButton(
              onPressed: () => context.go('/register'),
              child: const Text("Create account"),
            ),
          ],
        ),
      ),
    );
  }
}
