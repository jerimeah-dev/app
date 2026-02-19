import 'dart:io';
import 'package:uuid/uuid.dart';

import '../models/comment_model.dart';
import '../services/comment_service.dart';
import '../services/comment_image_service.dart';
import '../services/storage_service.dart';

class CommentRepository {
  final CommentService _commentService;
  final StorageService _storageService;
  final CommentImageService _commentImageService;

  CommentRepository(
    this._commentService,
    this._storageService,
    this._commentImageService,
  );

  final _uuid = const Uuid();

  // =========================================================
  // READ
  // =========================================================
  Future<List<CommentModel>> fetchComments({
    required String postId,
    required int limit,
    required int offset,
  }) async {
    final data = await _commentService.fetchComments(
      postId: postId,
      limit: limit,
      offset: offset,
    );

    return data.map(CommentModel.fromJson).toList();
  }

  Future<CommentModel> fetchCommentById(String id) async {
    final data = await _commentService.fetchCommentById(id);
    return CommentModel.fromJson(data);
  }

  // =========================================================
  // CREATE
  // =========================================================
  Future<CommentModel> createComment({
    required String postId,
    required String authorId,
    required String content,
    required List<File> images,
  }) async {
    final comment = await _commentService.createComment(
      postId: postId,
      authorId: authorId,
      content: content,
    );

    final commentId = comment['id'] as String;

    if (images.isNotEmpty) {
      await Future.wait(
        images.map((file) async {
          final path = '$commentId/${_uuid.v4()}.jpg';

          final url = await _storageService.uploadFile(
            bucket: 'comment-images',
            path: path,
            file: file,
          );

          await _commentImageService.insertCommentImage(
            commentId: commentId,
            url: url,
          );
        }),
      );
    }

    return fetchCommentById(commentId);
  }

  // =========================================================
  // UPDATE (Partial Image Support)
  // =========================================================
  Future<CommentModel> updateComment({
    required String commentId,
    required String content,
    List<String>? imageIdsToDelete,
    List<File>? newImages,
  }) async {
    await _commentService.updateComment(commentId, {'content': content});

    // Delete selected images
    if (imageIdsToDelete != null && imageIdsToDelete.isNotEmpty) {
      final images = await _commentImageService.fetchImagesByCommentId(
        commentId,
      );

      final imagesToRemove = images
          .where((img) => imageIdsToDelete.contains(img['id']))
          .toList();

      final paths = imagesToRemove
          .map((img) {
            final url = img['url'] as String;
            final uri = Uri.parse(url);
            final segments = uri.pathSegments;
            final bucketIndex = segments.indexOf('comment-images');
            if (bucketIndex == -1) return null;
            return segments.sublist(bucketIndex + 1).join('/');
          })
          .whereType<String>()
          .toList();

      if (paths.isNotEmpty) {
        await _storageService.deleteFiles(
          bucket: 'comment-images',
          paths: paths,
        );
      }

      for (final id in imageIdsToDelete) {
        await _commentImageService.deleteImageById(id);
      }
    }

    // Add new images
    if (newImages != null && newImages.isNotEmpty) {
      await Future.wait(
        newImages.map((file) async {
          final path = '$commentId/${_uuid.v4()}.jpg';

          final url = await _storageService.uploadFile(
            bucket: 'comment-images',
            path: path,
            file: file,
          );

          await _commentImageService.insertCommentImage(
            commentId: commentId,
            url: url,
          );
        }),
      );
    }

    return fetchCommentById(commentId);
  }

  // =========================================================
  // DELETE
  // =========================================================
  Future<void> deleteComment(String commentId) async {
    final images = await _commentImageService.fetchImagesByCommentId(commentId);

    final paths = images
        .map((img) {
          final url = img['url'] as String;
          final uri = Uri.parse(url);
          final segments = uri.pathSegments;
          final bucketIndex = segments.indexOf('comment-images');
          if (bucketIndex == -1) return null;
          return segments.sublist(bucketIndex + 1).join('/');
        })
        .whereType<String>()
        .toList();

    if (paths.isNotEmpty) {
      await _storageService.deleteFiles(bucket: 'comment-images', paths: paths);
    }

    await _commentImageService.deleteImagesByCommentId(commentId);
    await _commentService.deleteComment(commentId);
  }
}
