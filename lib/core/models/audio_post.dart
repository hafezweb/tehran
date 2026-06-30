class AudioPost {
  final String id;
  final String userId;
  final String audioUrl;
  final double latitude;
  final double longitude;
  final int duration;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isAnonymous;
  final String city;
  final double score;
  final DateTime createdAt;

  const AudioPost({
    required this.id,
    required this.userId,
    required this.audioUrl,
    required this.latitude,
    required this.longitude,
    required this.duration,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.isAnonymous,
    required this.city,
    required this.score,
    required this.createdAt,
  });

  factory AudioPost.fromMap(Map<String, dynamic> map) {
    return AudioPost(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      audioUrl: map['audio_url']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      duration: (map['duration'] as num?)?.toInt() ?? 0,
      likesCount: (map['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (map['comments_count'] as num?)?.toInt() ?? 0,
      isLiked: map['is_liked'] ?? false,
      isAnonymous: map['is_anonymous'] ?? true,
      city: map['city']?.toString() ?? '',
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
