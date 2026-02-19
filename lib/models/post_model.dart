import 'post_image_model.dart';
import 'user_model.dart';

class PostModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Joined author
  final UserModel author;

  /// Joined images
  final List<PostImageModel> images;

  const PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    required this.images,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      author: UserModel.fromJson(json['users_jeremiah']),
      images:
          (json['posts_image'] as List?)
              ?.map((e) => PostImageModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'author': author.toJson(),
      'images': images.map((e) => e.toJson()).toList(),
    };
  }

  PostModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? author,
    List<PostImageModel>? images,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      images: images ?? this.images,
    );
  }
}
