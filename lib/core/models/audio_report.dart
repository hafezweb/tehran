class AudioReport {
  final String id;
  final String postId;
  final String userId;
  final String reason;
  final DateTime createdAt;

  const AudioReport({
    required this.id,
    required this.postId,
    required this.userId,
    required this.reason,
    required this.createdAt,
  });

  factory AudioReport.fromMap(Map<String, dynamic> map) {
    return AudioReport(
      id: map['id'] ?? '',
      postId: map['post_id'] ?? '',
      userId: map['user_id'] ?? '',
      reason: map['reason'] ?? '',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
