import 'package:flutter/material.dart';
import '../repositories/reaction_repository.dart';

class ReactionNotifier extends ChangeNotifier {
  final ReactionRepository _repository;

  ReactionNotifier(this._repository);

  Future<void> reactToPost({
    required String userId,
    required String postId,
    required String type,
  }) async {
    await _repository.togglePostReaction(
      userId: userId,
      postId: postId,
      reactionType: type,
    );

    notifyListeners();
  }

  Future<void> reactToComment({
    required String userId,
    required String commentId,
    required String type,
  }) async {
    await _repository.toggleCommentReaction(
      userId: userId,
      commentId: commentId,
      reactionType: type,
    );

    notifyListeners();
  }
}
