import 'supabase_client.dart';

class CommentImageService {
  final _client = SupabaseClientProvider.client;

  // =========================================================
  // READ
  // =========================================================
  Future<List<Map<String, dynamic>>> fetchImagesByCommentId(
    String commentId,
  ) async {
    final response = await _client
        .from('comment_images_jeremiah')
        .select('id, comment_id, url')
        .eq('comment_id', commentId)
        .order('id', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  // =========================================================
  // CREATE
  // =========================================================
  Future<void> insertCommentImage({
    required String commentId,
    required String url,
  }) async {
    await _client.from('comment_images_jeremiah').insert({
      'comment_id': commentId,
      'url': url,
    });
  }

  // =========================================================
  // DELETE - By Comment
  // =========================================================
  Future<void> deleteImagesByCommentId(String commentId) async {
    await _client
        .from('comment_images_jeremiah')
        .delete()
        .eq('comment_id', commentId);
  }

  // =========================================================
  // DELETE - Single
  // =========================================================
  Future<void> deleteImageById(String imageId) async {
    await _client.from('comment_images_jeremiah').delete().eq('id', imageId);
  }
}
