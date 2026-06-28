class AudioPost {
  final String id;
  final String userId;
  final String audioUrl;
  final double lat;
  final double lng;
  final int likes;
  final int plays;
  final DateTime createdAt;

  AudioPost({
    required this.id,
    required this.userId,
    required this.audioUrl,
    required this.lat,
    required this.lng,
    required this.likes,
    required this.plays,
    required this.createdAt,
  });

  factory AudioPost.fromJson(Map<String, dynamic> json) {
    return AudioPost(
      id: json['id'],
      userId: json['user_id'],
      audioUrl: json['audio_url'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      likes: json['likes'] ?? 0,
      plays: json['plays'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
