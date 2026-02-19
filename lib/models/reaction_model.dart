class ReactionModel {
  final String id;
  final String userId;
  final String? postId;
  final String? commentId;
  final String reactionType;
  final DateTime createdAt;

  const ReactionModel({
    required this.id,
    required this.userId,
    this.postId,
    this.commentId,
    required this.reactionType,
    required this.createdAt,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      id: json['id'],
      userId: json['user_id'],
      postId: json['post_id'],
      commentId: json['comment_id'],
      reactionType: json['reaction_type'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'comment_id': commentId,
      'reaction_type': reactionType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ReactionModel copyWith({
    String? id,
    String? userId,
    String? postId,
    String? commentId,
    String? reactionType,
    DateTime? createdAt,
  }) {
    return ReactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      commentId: commentId ?? this.commentId,
      reactionType: reactionType ?? this.reactionType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
