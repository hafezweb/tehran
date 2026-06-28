class AudioPost {
  final String id;
  final String audioUrl;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  const AudioPost({
    required this.id,
    required this.audioUrl,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory AudioPost.fromMap(Map<String, dynamic> map) {
    return AudioPost(
      id: map['id']?.toString() ?? '',
      audioUrl: map['audio_url']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
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
      'created_at': createdAt.toIso8601String(),
    };
  }

  AudioPost copyWith({
    String? id,
    String? audioUrl,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return AudioPost(
      id: id ?? this.id,
      audioUrl: audioUrl ?? this.audioUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
