import 'package:app/notifiers/app_initializer_notifier.dart';
import 'package:app/notifiers/auth_notifier.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/pages/login_page.dart';
import 'package:app/pages/profile_page.dart';
import 'package:app/pages/register_page.dart';
import 'package:app/widgets/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    final auth = context.read<AuthNotifier>();
    final initializer = context.read<AppInitializerNotifier>();

    return GoRouter(
      refreshListenable: Listenable.merge([auth, initializer]),
      initialLocation: '/login',
      redirect: (context, state) {
        final isLoggedIn = auth.isLoggedIn;
        final isInitialized = initializer.isReady;

        final isAuthRoute =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        final isSplashRoute = state.matchedLocation == '/splash';

        if (!isLoggedIn && !isAuthRoute) return '/login';

        if (isLoggedIn && !isInitialized) return '/splash';

        if (isLoggedIn && isInitialized && isSplashRoute) return '/home';

        if (isLoggedIn && isInitialized && isAuthRoute) return '/home';

        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
        GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
        GoRoute(
          path: '/home',
          builder: (_, _) => const HomePage(),
          routes: [
            GoRoute(
              path: 'profile',
              builder: (_, _) => const ProfilePage(),
              name: 'profile',
            ),
          ],
        ),
      ],
    );
  }
}
