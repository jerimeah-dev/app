import 'supabase_client.dart';

class ReactionService {
  final _client = SupabaseClientProvider.client;

  Future<void> addReaction({
    required String userId,
    String? postId,
    String? commentId,
    required String reactionType,
  }) async {
    await _client.from('reactions_jeremiah').insert({
      'user_id': userId,
      'post_id': postId,
      'comment_id': commentId,
      'reaction_type': reactionType,
    });
  }

  Future<void> removeReaction({
    required String userId,
    String? postId,
    String? commentId,
  }) async {
    var query = _client
        .from('reactions_jeremiah')
        .delete()
        .eq('user_id', userId);

    if (postId != null) {
      query = query.eq('post_id', postId);
    }

    if (commentId != null) {
      query = query.eq('comment_id', commentId);
    }

    await query;
  }
}
