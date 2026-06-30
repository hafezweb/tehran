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
  final bool isSaved;
  final bool isAnonymous;
  final String city;
  final double score;
  final int trustScore;
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
    required this.isSaved,
    required this.isAnonymous,
    required this.city,
    required this.score,
    required this.trustScore,
    required this.createdAt,
  });

  factory AudioPost.fromMap(Map<String, dynamic> map) {
    return AudioPost(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      audioUrl: map['audio_url'] ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      duration: map['duration'] ?? 0,
      likesCount: map['likes_count'] ?? 0,
      commentsCount: map['comments_count'] ?? 0,
      isLiked: map['is_liked'] ?? false,
      isSaved: map['is_saved'] ?? false,
      isAnonymous: map['is_anonymous'] ?? true,
      city: map['city'] ?? '',
      score: (map['score'] as num?)?.toDouble() ?? 0,
      trustScore: map['trust_score'] ?? 100,
      createdAt: DateTime.parse(map['created_at']).toUtc(),
    );
  }
}
