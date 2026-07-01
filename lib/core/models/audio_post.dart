class AudioPost {
  final String id;
  final String audioUrl;
  final double latitude;
  final double longitude;
  final String city;
  final int duration;

  /// new fields
  final String title;
  final String creatorName;
  final String coverImage;

  /// optional/future-safe
  final int likes;
  final int comments;
  final DateTime createdAt;

  AudioPost({
    required this.id,
    required this.audioUrl,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.duration,
    required this.title,
    required this.creatorName,
    required this.coverImage,
    this.likes = 0,
    this.comments = 0,
    required this.createdAt,
  });

  factory AudioPost.fromMap(Map<String, dynamic> map) {
    return AudioPost(
      id: (map['id'] ?? '').toString(),

      audioUrl: (map['audio_url'] ?? '').toString(),

      latitude: map['latitude'] == null
          ? 0.0
          : (map['latitude'] as num).toDouble(),

      longitude: map['longitude'] == null
          ? 0.0
          : (map['longitude'] as num).toDouble(),

      city: (map['city'] ?? '').toString(),

      duration: map['duration'] == null ? 0 : (map['duration'] as num).toInt(),

      title: (map['title'] ?? 'بدون عنوان').toString(),

      creatorName: (map['creator_name'] ?? 'ناشناس').toString(),

      coverImage: (map['cover_image'] ?? '').toString(),

      likes: map['likes'] == null ? 0 : (map['likes'] as num).toInt(),

      comments: map['comments'] == null ? 0 : (map['comments'] as num).toInt(),

      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'audio_url': audioUrl,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'duration': duration,
      'title': title,
      'creator_name': creatorName,
      'cover_image': coverImage,
      'likes': likes,
      'comments': comments,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  AudioPost copyWith({
    String? id,
    String? audioUrl,
    double? latitude,
    double? longitude,
    String? city,
    int? duration,
    String? title,
    String? creatorName,
    String? coverImage,
    int? likes,
    int? comments,
    DateTime? createdAt,
  }) {
    return AudioPost(
      id: id ?? this.id,
      audioUrl: audioUrl ?? this.audioUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      duration: duration ?? this.duration,
      title: title ?? this.title,
      creatorName: creatorName ?? this.creatorName,
      coverImage: coverImage ?? this.coverImage,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
