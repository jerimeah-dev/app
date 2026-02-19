import 'supabase_client.dart';

class CommentService {
  final _client = SupabaseClientProvider.client;

  static const String _selectQuery = '''
    id,
    post_id,
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
    comment_images_jeremiah (
      id,
      comment_id,
      url
    )
  ''';

  // =========================================================
  // READ - Paginated
  // =========================================================
  Future<List<Map<String, dynamic>>> fetchComments({
    required String postId,
    required int limit,
    required int offset,
  }) async {
    final response = await _client
        .from('comments_jeremiah')
        .select(_selectQuery)
        .eq('post_id', postId)
        .order('created_at', ascending: false)
        .order('id', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> fetchCommentById(String id) async {
    final response = await _client
        .from('comments_jeremiah')
        .select(_selectQuery)
        .eq('id', id)
        .single();

    return response;
  }

  Future<Map<String, dynamic>> createComment({
    required String postId,
    required String authorId,
    required String content,
  }) async {
    final response = await _client
        .from('comments_jeremiah')
        .insert({'post_id': postId, 'author_id': authorId, 'content': content})
        .select()
        .single();

    return response;
  }

  Future<void> updateComment(String id, Map<String, dynamic> data) async {
    await _client.from('comments_jeremiah').update(data).eq('id', id);
  }

  Future<void> deleteComment(String id) async {
    await _client.from('comments_jeremiah').delete().eq('id', id);
  }
}
