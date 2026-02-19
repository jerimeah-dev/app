class CommentImageModel {
  final String id;
  final String commentId;
  final String url;

  const CommentImageModel({
    required this.id,
    required this.commentId,
    required this.url,
  });

  factory CommentImageModel.fromJson(Map<String, dynamic> json) {
    return CommentImageModel(
      id: json['id'],
      commentId: json['comment_id'] ?? '',
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'comment_id': commentId, 'url': url};
  }

  CommentImageModel copyWith({String? id, String? commentId, String? url}) {
    return CommentImageModel(
      id: id ?? this.id,
      commentId: commentId ?? this.commentId,
      url: url ?? this.url,
    );
  }
}
