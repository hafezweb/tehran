import 'dart:io';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../models/audio_post.dart';
import '../services/supabase_service.dart';
import '../services/location_service.dart';
import '../services/audio_service.dart';
import 'global_audio_player.dart'; // مهم

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
    /* همان کد قبلی */
    // (کپی از پیام‌های قبل)
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
    // کد قبلی
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
