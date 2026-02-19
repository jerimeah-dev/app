import 'package:app/notifiers/auth_notifier.dart';
import 'package:app/notifiers/post_notifier.dart';
import 'package:app/notifiers/profile_notifier.dart';
import 'package:flutter/material.dart';

class AppInitializerNotifier extends ChangeNotifier {
  AuthNotifier auth;
  ProfileNotifier profile;
  PostNotifier post;

  bool _isReady = false;
  bool get isReady => _isReady;

  AppInitializerNotifier({
    required this.auth,
    required this.profile,
    required this.post,
  });

  Future<void> initialize() async {
    if (!auth.isLoggedIn) return;

    _isReady = false;
    notifyListeners();

    await Future.wait([
      profile.initialize(auth.currentUser!),
      post.loadInitial(),
    ]);

    if (!hasListeners) return; // safety guard

    _isReady = true;
    notifyListeners();
  }

  void reset() {
    _isReady = false;
    notifyListeners();
  }
}
