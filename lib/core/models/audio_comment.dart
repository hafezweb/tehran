class AudioComment {
  final String id;
  final String postId;
  final String userId;
  final String text;
  final DateTime createdAt;

  const AudioComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  factory AudioComment.fromMap(Map<String, dynamic> map) {
    return AudioComment(
      id: map['id']?.toString() ?? '',
      postId: map['post_id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
