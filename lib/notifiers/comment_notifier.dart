import 'dart:io';
import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../repositories/comment_repository.dart';
import 'async_state.dart';

class CommentNotifier extends ChangeNotifier {
  final CommentRepository _repository;

  CommentNotifier(this._repository);

  static const int _limit = 20;

  int _offset = 0;
  bool _hasMore = true;
  bool _isFetchingMore = false;
  bool _isCreating = false;

  AsyncState<List<CommentModel>> state = const AsyncState.initial();

  final List<CommentModel> _comments = [];

  List<CommentModel> get comments => List.unmodifiable(_comments);
  bool get hasMore => _hasMore;
  bool get isFetchingMore => _isFetchingMore;
  bool get isCreating => _isCreating;

  Future<void> loadInitial(String postId) async {
    state = const AsyncState.loading();
    notifyListeners();

    try {
      _offset = 0;
      _hasMore = true;
      _comments.clear();

      final data = await _repository.fetchComments(
        postId: postId,
        limit: _limit,
        offset: _offset,
      );

      _comments.addAll(data);
      _offset += data.length;

      if (data.length < _limit) {
        _hasMore = false;
      }

      state = AsyncState.success(List.unmodifiable(_comments));
    } catch (e) {
      state = AsyncState.error(e.toString());
    }

    notifyListeners();
  }

  Future<void> loadMore(String postId) async {
    if (!_hasMore || _isFetchingMore) return;

    _isFetchingMore = true;
    notifyListeners();

    try {
      final data = await _repository.fetchComments(
        postId: postId,
        limit: _limit,
        offset: _offset,
      );

      if (data.isEmpty) {
        _hasMore = false;
      } else {
        _comments.addAll(data);
        _offset += data.length;

        if (data.length < _limit) {
          _hasMore = false;
        }

        state = AsyncState.success(List.unmodifiable(_comments));
      }
    } catch (e) {
      debugPrint("Load more error: $e");
    }

    _isFetchingMore = false;
    notifyListeners();
  }

  Future<void> createComment({
    required String postId,
    required String authorId,
    required String content,
    required List<File> files,
  }) async {
    if (_isCreating) return;

    _isCreating = true;
    notifyListeners();

    try {
      final comment = await _repository.createComment(
        postId: postId,
        authorId: authorId,
        content: content,
        images: files,
      );

      _comments.insert(0, comment);
      state = AsyncState.success(List.unmodifiable(_comments));
    } catch (e) {
      state = AsyncState.error(e.toString());
    }

    _isCreating = false;
    notifyListeners();
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _repository.deleteComment(commentId);

      _comments.removeWhere((c) => c.id == commentId);

      state = AsyncState.success(List.unmodifiable(_comments));
      notifyListeners();
    } catch (e) {
      state = AsyncState.error(e.toString());
      notifyListeners();
    }
  }

  Future<void> refresh(String postId) async {
    await loadInitial(postId);
  }
}
