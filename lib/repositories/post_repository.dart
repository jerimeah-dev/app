import 'dart:io';

import '../models/post_model.dart';
import '../services/post_image_service.dart';
import '../services/post_service.dart';
import '../services/storage_service.dart';

class PostRepository {
  final PostService _postService;
  final StorageService _storageService;
  final PostImageService _postImageService;

  PostRepository(
    this._postService,
    this._storageService,
    this._postImageService,
  );

  Future<List<PostModel>> fetchPosts({
    required int limit,
    required int offset,
  }) async {
    final data = await _postService.fetchPosts(limit: limit, offset: offset);

    return data.map((e) => PostModel.fromJson(e)).toList();
  }

  Future<PostModel> fetchPostById(String postId) async {
    final data = await _postService.fetchPostById(postId);
    return PostModel.fromJson(data);
  }

  Future<PostModel> createPost({
    required String authorId,
    required String title,
    required String content,
    required List<File> images,
  }) async {
    final post = await _postService.createPost(
      authorId: authorId,
      title: title,
      content: content,
    );

    final postId = post['id'] as String;

    for (final file in images) {
      final path = '$postId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final url = await _storageService.uploadFile(
        bucket: 'post-images',
        path: path,
        file: file,
      );

      await _postImageService.insertPostImage(postId: postId, url: url);
    }

    return await fetchPostById(postId);
  }

  Future<PostModel> updatePost({
    required String postId,
    required String title,
    required String content,
    List<String>? imageIdsToDelete,
    List<File>? newImages,
  }) async {
    await _postService.updatePost(postId, {'title': title, 'content': content});

    if (imageIdsToDelete != null && imageIdsToDelete.isNotEmpty) {
      final images = await _postImageService.fetchImagesByPostId(postId);

      final imagesToRemove = images
          .where((img) => imageIdsToDelete.contains(img['id']))
          .toList();

      final paths = imagesToRemove
          .map((img) {
            final url = img['url'] as String;
            final uri = Uri.parse(url);
            final segments = uri.pathSegments;
            final bucketIndex = segments.indexOf('post-images');

            if (bucketIndex == -1) return null;

            return segments.sublist(bucketIndex + 1).join('/');
          })
          .whereType<String>()
          .toList();

      if (paths.isNotEmpty) {
        await _storageService.deleteFiles(bucket: 'post-images', paths: paths);
      }

      for (final id in imageIdsToDelete) {
        await _postImageService.deleteImageById(id);
      }
    }

    if (newImages != null && newImages.isNotEmpty) {
      await Future.wait(
        newImages.map((file) async {
          final path = '$postId/${DateTime.now().millisecondsSinceEpoch}.jpg';

          final url = await _storageService.uploadFile(
            bucket: 'post-images',
            path: path,
            file: file,
          );

          await _postImageService.insertPostImage(postId: postId, url: url);
        }),
      );
    }

    return await fetchPostById(postId);
  }

  Future<void> deletePost(String postId) async {
    // 1️⃣ Fetch image records
    final images = await _postImageService.fetchImagesByPostId(postId);

    // 2️⃣ Extract storage paths
    final paths = images
        .map((img) {
          final url = img['url'] as String;
          final uri = Uri.parse(url);
          final segments = uri.pathSegments;
          final bucketIndex = segments.indexOf('post-images');

          if (bucketIndex == -1) return null;

          return segments.sublist(bucketIndex + 1).join('/');
        })
        .whereType<String>()
        .toList();

    // 3️⃣ Delete storage files
    await _storageService.deleteFiles(bucket: 'post-images', paths: paths);

    // 4️⃣ Delete post (DB cascade removes image rows)
    await _postService.deletePost(postId);
  }
}
