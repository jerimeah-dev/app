import 'dart:io';
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../repositories/post_repository.dart';
import 'async_state.dart';

class PostNotifier extends ChangeNotifier {
  final PostRepository _repository;

  PostNotifier(this._repository);

  static const int _limit = 10;

  int _offset = 0;
  bool _hasMore = true;
  bool _isFetchingMore = false;
  bool _isCreating = false;

  AsyncState<List<PostModel>> state = const AsyncState.initial();

  final List<PostModel> _posts = [];

  List<PostModel> get posts => _posts;
  bool get hasMore => _hasMore;
  bool get isFetchingMore => _isFetchingMore;
  bool get isCreating => _isCreating;

  Future<void> loadInitial() async {
    state = const AsyncState.loading();
    notifyListeners();
    try {
      _offset = 0;
      _hasMore = true;
      _posts.clear();

      final data = await _repository.fetchPosts(limit: _limit, offset: _offset);

      _posts.addAll(data);
      _offset += data.length;

      if (data.length < _limit) {
        _hasMore = false;
      }

      state = AsyncState.success(_posts);
    } catch (e) {
      state = AsyncState.error(e.toString());
    }

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isFetchingMore) return;

    _isFetchingMore = true;
    notifyListeners();

    try {
      final data = await _repository.fetchPosts(limit: _limit, offset: _offset);

      if (data.isEmpty) {
        _hasMore = false;
      } else {
        _posts.addAll(data);
        _offset += data.length;

        if (data.length < _limit) {
          _hasMore = false;
        }

        state = AsyncState.success(List.unmodifiable(_posts));
      }
    } catch (e) {
      // Do NOT wipe entire feed on loadMore error
      debugPrint("Load more error: $e");
    }

    _isFetchingMore = false;
    notifyListeners();
  }

  // =====================================================
  // CREATE POST
  // =====================================================
  Future<void> createPost({
    required String authorId,
    required String title,
    required String content,
    required List<File> files,
  }) async {
    if (_isCreating) return;

    _isCreating = true;
    notifyListeners();

    try {
      final newPost = await _repository.createPost(
        authorId: authorId,
        title: title,
        content: content,
        images: files,
      );

      // Insert at top (DO NOT modify offset)
      _posts.insert(0, newPost);

      state = AsyncState.success(_posts);
    } catch (e) {
      state = AsyncState.error(e.toString());
    }

    _isCreating = false;
    notifyListeners();
  }

  // =====================================================
  // DELETE POST
  // =====================================================
  Future<void> deletePost(String postId) async {
    try {
      await _repository.deletePost(postId);

      _posts.removeWhere((p) => p.id == postId);

      state = AsyncState.success(List.unmodifiable(_posts));
      notifyListeners();
    } catch (e) {
      state = AsyncState.error(e.toString());
      notifyListeners();
    }
  }

  // =====================================================
  // REFRESH
  // =====================================================
  Future<void> refresh() async {
    await loadInitial();
  }
}
