import 'package:app/notifiers/app_initializer_notifier.dart';
import 'package:app/notifiers/post_notifier.dart';
import 'package:app/notifiers/profile_notifier.dart';
import 'package:app/repositories/post_repository.dart';
import 'package:app/repositories/user_repository.dart';
import 'package:app/router/router.dart';
import 'package:app/services/post_image_service.dart';
import 'package:app/services/post_service.dart';
import 'package:app/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'repositories/auth_repository.dart';
import 'services/user_service.dart';
import 'notifiers/auth_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'http://study-supabase-20c378-167-88-45-173.traefik.me',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE3NzA5NTA3ODgsImV4cCI6MTg5MzQ1NjAwMCwicm9sZSI6ImFub24iLCJpc3MiOiJzdXBhYmFzZSJ9.xbUmbbWt1CBMd2JpnkL24A54Sa25OgRCjkcsB-odlh4',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthNotifier(AuthRepository(UserService())),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ProfileNotifier(UserRepository(UserService(), StorageService())),
        ),
        ChangeNotifierProvider(
          create: (_) => PostNotifier(
            PostRepository(PostService(), StorageService(), PostImageService()),
          ),
        ),
        ChangeNotifierProxyProvider3<
          AuthNotifier,
          ProfileNotifier,
          PostNotifier,
          AppInitializerNotifier
        >(
          create: (context) => AppInitializerNotifier(
            auth: context.read<AuthNotifier>(),
            profile: context.read<ProfileNotifier>(),
            post: context.read<PostNotifier>(),
          ),
          update: (_, auth, profile, post, initializer) {
            initializer!
              ..auth = auth
              ..profile = profile
              ..post = post;
            return initializer;
          },
        ),
      ],
      child: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.router(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
