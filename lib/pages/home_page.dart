import 'package:app/notifiers/app_initializer_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../notifiers/auth_notifier.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ready = context.select<AppInitializerNotifier, bool>(
      (i) => i.isReady,
    );

    if (!ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final auth = context.read<AuthNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: () async {
              await auth.logout();
              context.read<AppInitializerNotifier>().reset();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.pushNamed('profile'),
          child: const Text("Go to Profile"),
        ),
      ),
    );
  }
}
