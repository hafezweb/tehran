import 'dart:io';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../models/audio_post.dart';
import '../services/supabase_service.dart';
import '../services/location_service.dart';
import '../services/audio_service.dart';

class AudioRepository {
  final SupabaseService _supabaseService;
  final LocationService _locationService;
  final AudioService _audioService;

  AudioRepository({
    SupabaseService? supabaseService,
    LocationService? locationService,
    AudioService? audioService,
  }) : _supabaseService = supabaseService ?? SupabaseService(),
       _locationService = locationService ?? LocationService(),
       _audioService = audioService ?? AudioService();

  Future<bool> startRecording() => _audioService.startRecording();

  Future<String?> stopRecording() => _audioService.stopRecording();

  Future<Position?> getCurrentLocation() => _locationService.getCurrent();

  Future<String?> createAudioPost() async {
    final path = await stopRecording();
    if (path == null) return null;

    try {
      final pos = await getCurrentLocation();
      if (pos == null) return null;

      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final url = await _supabaseService.uploadAudio(fileName, File(path));

      final response = await _supabaseService.client
          .from('audio_posts')
          .insert({
            'user_id': _supabaseService.userId,
            'audio_url': url,
            'lat': pos.latitude,
            'lng': pos.longitude,
            'likes': 0,
            'plays': 0,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response['id'] as String?;
    } catch (e) {
      print("Create Audio Post Error: $e");
      return null;
    }
  }

  Stream<List<AudioPost>> watchAllPosts() {
    return _supabaseService.streamAudioPosts().map(
      (data) => data.map((e) => AudioPost.fromJson(e)).toList(),
    );
  }

  Future<List<AudioPost>> getPostsInBounds({
    required double north,
    required double south,
    required double east,
    required double west,
  }) async {
    try {
      final data = await _supabaseService.getPostsInBounds(
        north: north,
        south: south,
        east: east,
        west: west,
      );
      return data.map((e) => AudioPost.fromJson(e)).toList();
    } catch (e) {
      print("Bounds Query Error: $e");
      return [];
    }
  }

  Future<void> playAudio(String url, String postId) async {
    final player = Get.find<GlobalAudioPlayer>();
    await player.play(url, postId);
    await _supabaseService.incrementPlay(postId);
  }

  Future<void> stopAudio() async {
    final player = Get.find<GlobalAudioPlayer>();
    await player.stop();
  }

  Future<void> toggleLike(String postId) => _supabaseService.toggleLike(postId);
}
