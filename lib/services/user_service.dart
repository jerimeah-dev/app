import 'supabase_client.dart';

class UserService {
  final _client = SupabaseClientProvider.client;

  static const String _selectFields = '''
    id,
    email,
    password_hash,
    display_name,
    avatar_url,
    bio,
    created_at,
    updated_at
  ''';

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final response = await _client
        .from('users_jeremiah')
        .select(_selectFields)
        .eq('email', email)
        .maybeSingle();

    return response;
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final response = await _client
        .from('users_jeremiah')
        .select(_selectFields)
        .eq('id', id)
        .maybeSingle();

    return response;
  }

  Future<Map<String, dynamic>> createUser({
    required String email,
    required String passwordHash,
    required String displayName,
  }) async {
    final response = await _client
        .from('users_jeremiah')
        .insert({
          'email': email,
          'password_hash': passwordHash,
          'display_name': displayName,
        })
        .select(_selectFields)
        .single();

    return response;
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _client.from('users_jeremiah').update(data).eq('id', id);
  }

  Future<void> deleteUser(String id) async {
    await _client.from('users_jeremiah').delete().eq('id', id);
  }
}
