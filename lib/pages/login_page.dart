import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../notifiers/auth_notifier.dart';
import '../notifiers/app_initializer_notifier.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Consumer<AuthNotifier>(
              builder: (context, auth, _) {
                return Column(
                  children: [
                    if (auth.state.isError)
                      Text(
                        auth.state.error ?? '',
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: auth.state.isLoading
                          ? null
                          : () async {
                              await auth.login(
                                email: _email.text.trim(),
                                password: _password.text.trim(),
                              );

                              if (!context.mounted) return;

                              if (auth.isLoggedIn) {
                                context
                                    .read<AppInitializerNotifier>()
                                    .initialize();
                              }
                            },
                      child: auth.state.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Login"),
                    ),
                  ],
                );
              },
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
