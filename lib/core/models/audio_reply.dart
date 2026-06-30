class AudioReply {
  final String id;
  final String commentId;
  final String userId;
  final String text;
  final DateTime createdAt;

  const AudioReply({
    required this.id,
    required this.commentId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  factory AudioReply.fromMap(Map<String, dynamic> map) {
    return AudioReply(
      id: map['id'] ?? '',
      commentId: map['comment_id'] ?? '',
      userId: map['user_id'] ?? '',
      text: map['text'] ?? '',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
