import 'comment_image_model.dart';
import 'user_model.dart';

class CommentModel {
  final String id;
  final String postId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Joined author
  final UserModel author;

  /// Joined images
  final List<CommentImageModel> images;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    required this.images,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      postId: json['post_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      author: UserModel.fromJson(json['users_jeremiah']),
      images:
          (json['comment_images_jeremiah'] as List?)
              ?.map((e) => CommentImageModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'author': author.toJson(),
      'images': images.map((e) => e.toJson()).toList(),
    };
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? author,
    List<CommentImageModel>? images,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      images: images ?? this.images,
    );
  }
}
