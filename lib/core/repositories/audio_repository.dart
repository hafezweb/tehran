import 'dart:io';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../models/audio_post.dart';
import '../services/supabase_service.dart';
import '../services/location_service.dart';
import '../services/audio_service.dart';
import '../services/global_audio_player.dart';

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
    try {
      final audioPath = await stopRecording();
      if (audioPath == null) return null;

      final position = await getCurrentLocation();
      if (position == null) return null;

      final file = File(audioPath);

      final uploadedUrl = await _supabaseService.uploadAudio(file);
      if (uploadedUrl == null) return null;

      final postId = await _supabaseService.createAudioPost(
        audioUrl: uploadedUrl,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return postId;
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

  Future<List<AudioPost>> getFeed() async {
    try {
      final data = await _supabaseService.getFeed();
      return data.map((e) => AudioPost.fromJson(e)).toList();
    } catch (e) {
      print("Feed Error: $e");
      return [];
    }
  }

  Future<List<AudioPost>> getMyPosts() async {
    try {
      final data = await _supabaseService.getMyPosts();
      return data.map((e) => AudioPost.fromJson(e)).toList();
    } catch (e) {
      print("My Posts Error: $e");
      return [];
    }
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
      print("Bounds Error: $e");
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

  Future<void> toggleLike(String postId) {
    return _supabaseService.toggleLike(postId);
  }
}
