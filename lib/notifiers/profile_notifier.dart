import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import 'async_state.dart';

class ProfileNotifier extends ChangeNotifier {
  final UserRepository _repository;

  ProfileNotifier(this._repository);

  AsyncState<UserModel?> state = const AsyncState.initial();
  UserModel? _user;

  UserModel? get user => _user;

  bool _isAvatarUploading = false;
  bool get isAvatarUploading => _isAvatarUploading;
  Future<void> initialize(UserModel currentUser) async {
    state = const AsyncState.loading();
    notifyListeners();

    _user = currentUser;

    state = AsyncState.success(_user);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String displayName,
    required String bio,
  }) async {
    if (_user == null) return;

    state = const AsyncState.loading();
    notifyListeners();

    try {
      final updated = await _repository.updateProfile(
        userId: _user!.id,
        displayName: displayName,
        bio: bio,
      );

      _user = updated;
      state = AsyncState.success(updated);
    } catch (e) {
      state = AsyncState.error(e.toString());
    }

    notifyListeners();
  }

  Future<void> updateAvatar(File file) async {
    if (_user == null) return;

    _isAvatarUploading = true;
    notifyListeners();

    try {
      final url = await _repository.uploadAvatar(userId: _user!.id, file: file);

      _user = _user!.copyWith(avatarUrl: url);
    } catch (e) {
      debugPrint(e.toString());
    }

    _isAvatarUploading = false;
    notifyListeners();
  }
}
