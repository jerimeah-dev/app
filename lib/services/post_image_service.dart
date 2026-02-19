import 'supabase_client.dart';

class PostImageService {
  final _client = SupabaseClientProvider.client;

  Future<void> insertPostImage({
    required String postId,
    required String url,
  }) async {
    await _client.from('posts_image').insert({'post_id': postId, 'url': url});
  }

  Future<void> deleteImagesByPostId(String postId) async {
    await _client.from('posts_image').delete().eq('post_id', postId);
  }

  Future<List<Map<String, dynamic>>> fetchImagesByPostId(String postId) async {
    final response = await _client
        .from('posts_image')
        .select('id, post_id, url')
        .eq('post_id', postId);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> deleteImageById(String id) async {
    await _client.from('posts_image').delete().eq('id', id);
  }
}
