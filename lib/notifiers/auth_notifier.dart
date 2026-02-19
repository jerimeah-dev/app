import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';
import 'async_state.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthRepository _repository;

  AuthNotifier(this._repository);

  AsyncState<UserModel?> state = const AsyncState.initial();

  UserModel? get currentUser => _repository.currentUser;

  bool get isLoggedIn => state.isSuccess && currentUser != null;

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncState.loading();
    notifyListeners();

    try {
      final user = await _repository.register(
        email: email,
        password: password,
        displayName: displayName,
      );

      state = AsyncState.success(user);
    } catch (e) {
      state = AsyncState.error(e.toString());
    }

    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncState.loading();
    notifyListeners();

    try {
      final user = await _repository.login(email: email, password: password);

      state = AsyncState.success(user);
      notifyListeners();
    } catch (e) {
      state = AsyncState.error(e.toString());
    }

    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncState.initial();
    notifyListeners();
  }
}
