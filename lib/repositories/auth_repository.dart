import 'package:bcrypt/bcrypt.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class AuthRepository {
  final UserService _userService;

  UserModel? _currentUser;

  AuthRepository(this._userService);

  UserModel? get currentUser => _currentUser;

  // =====================================================
  // REGISTER
  // =====================================================
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final existing = await _userService.getUserByEmail(email);

    if (existing != null) {
      throw Exception('Email already registered');
    }

    final hash = BCrypt.hashpw(password, BCrypt.gensalt());

    final response = await _userService.createUser(
      email: email,
      passwordHash: hash,
      displayName: displayName,
    );

    final user = UserModel.fromJson(response);

    _currentUser = user;

    return user;
  }

  // =====================================================
  // LOGIN
  // =====================================================
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _userService.getUserByEmail(email);

    if (response == null) {
      throw Exception('User not found');
    }

    final passwordHash = response['password_hash'] as String;

    final isValid = BCrypt.checkpw(password, passwordHash);

    if (!isValid) {
      throw Exception('Invalid credentials');
    }

    // Fetch full fresh user from DB
    final userId = response['id'] as String;
    final fullUser = await _userService.getUserById(userId);

    if (fullUser == null) {
      throw Exception('User data missing');
    }

    final user = UserModel.fromJson(fullUser);

    _currentUser = user;

    return user;
  }

  // =====================================================
  // LOGOUT
  // =====================================================
  Future<void> logout() async {
    _currentUser = null;
  }
}
