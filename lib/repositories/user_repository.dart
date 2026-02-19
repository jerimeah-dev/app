import 'dart:io';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/storage_service.dart';

class UserRepository {
  final UserService _userService;
  final StorageService _storageService;

  UserRepository(this._userService, this._storageService);

  Future<UserModel> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
  }) async {
    await _userService.updateUser(userId, {
      if (displayName != null) 'display_name': displayName,
      if (bio != null) 'bio': bio,
    });

    final updated = await _userService.getUserById(userId);
    return UserModel.fromJson(updated!);
  }

  Future<String> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    final path = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final url = await _storageService.uploadFile(
      bucket: 'avatars',
      path: path,
      file: file,
    );

    await _userService.updateUser(userId, {'avatar_url': url});

    return url;
  }
}
