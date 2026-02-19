class PostImageModel {
  final String id;
  final String postId;
  final String url;

  const PostImageModel({
    required this.id,
    required this.postId,
    required this.url,
  });

  factory PostImageModel.fromJson(Map<String, dynamic> json) {
    return PostImageModel(
      id: json['id'],
      postId: json['post_id'] ?? '',
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'post_id': postId, 'url': url};
  }

  PostImageModel copyWith({String? id, String? postId, String? url}) {
    return PostImageModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      url: url ?? this.url,
    );
  }
}
