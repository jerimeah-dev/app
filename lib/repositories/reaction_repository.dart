import '../services/reaction_service.dart';

class ReactionRepository {
  final ReactionService _reactionService;

  ReactionRepository(this._reactionService);

  Future<void> togglePostReaction({
    required String userId,
    required String postId,
    required String reactionType,
  }) async {
    await _reactionService.addReaction(
      userId: userId,
      postId: postId,
      reactionType: reactionType,
    );
  }

  Future<void> toggleCommentReaction({
    required String userId,
    required String commentId,
    required String reactionType,
  }) async {
    await _reactionService.addReaction(
      userId: userId,
      commentId: commentId,
      reactionType: reactionType,
    );
  }
}
