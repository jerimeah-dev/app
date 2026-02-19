import 'supabase_client.dart';

class PostService {
  final _client = SupabaseClientProvider.client;

  // =========================================================
  // READ - Multiple posts (pagination)
  // =========================================================
  Future<List<Map<String, dynamic>>> fetchPosts({
    required int limit,
    required int offset,
  }) async {
    final response = await _client
        .from('posts_jeremiah')
        .select(_postSelectQuery)
        .order('created_at', ascending: false)
        .order('id', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  // =========================================================
  // READ - Single post (MISSING BEFORE)
  // =========================================================
  Future<Map<String, dynamic>> fetchPostById(String id) async {
    final response = await _client
        .from('posts_jeremiah')
        .select(_postSelectQuery)
        .eq('id', id)
        .single();

    return response;
  }

  // =========================================================
  // CREATE
  // =========================================================
  Future<Map<String, dynamic>> createPost({
    required String authorId,
    required String title,
    required String content,
  }) async {
    final response = await _client
        .from('posts_jeremiah')
        .insert({'author_id': authorId, 'title': title, 'content': content})
        .select()
        .single();

    return response;
  }

  // =========================================================
  // UPDATE
  // =========================================================
  Future<void> updatePost(String id, Map<String, dynamic> data) async {
    await _client.from('posts_jeremiah').update(data).eq('id', id);
  }

  // =========================================================
  // DELETE
  // =========================================================
  Future<void> deletePost(String id) async {
    await _client.from('posts_jeremiah').delete().eq('id', id);
  }

  // =========================================================
  // Shared Select Query (CLEANER)
  // =========================================================
  static const String _postSelectQuery = '''
    id,
    title,
    content,
    created_at,
    updated_at,
    users_jeremiah (
      id,
      email,
      display_name,
      avatar_url,
      bio,
      created_at,
      updated_at
    ),
    posts_image (
      id,
      post_id,
      url
    )
  ''';
}
