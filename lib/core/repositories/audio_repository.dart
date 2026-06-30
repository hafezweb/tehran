import 'dart:io';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../models/audio_post.dart';
import '../models/audio_comment.dart';
import '../services/supabase_service.dart';
import '../services/location_service.dart';
import '../services/audio_service.dart';
import '../services/global_audio_player.dart';
import '../utils/snackbar_helper.dart';

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

  SupabaseService get supabaseService => _supabaseService;

  Future<bool> startRecording() => _audioService.startRecording();
  Future<String?> stopRecording() => _audioService.stopRecording();
  Future<Position?> getCurrentLocation() => _locationService.getCurrent();

  Future<String?> createAudioPost() async {
    final filePath = await stopRecording();
    if (filePath == null) return null;

    final file = File(filePath);
    if (!await file.exists()) return null;

    final position = await getCurrentLocation();
    if (position == null) return null;

    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    final audioUrl = await _supabaseService.uploadAudio(file, fileName);
    if (audioUrl == null) return null;

    final result = await _supabaseService.createAudioPost(
      audioUrl: audioUrl,
      lat: position.latitude,
      lng: position.longitude,
    );

    if (result == null) {
      await _supabaseService.deleteAudio(fileName);
      return null;
    }

    SnackbarHelper.showSuccess("صدا با موفقیت ثبت شد.");
    return result['id']?.toString();
  }

  Future<List<AudioPost>> getFeed({DateTime? before, int limit = 20}) {
    return _supabaseService.getFeed(before: before, limit: limit);
  }

  Future<List<AudioPost>> getMyPosts() {
    return _supabaseService.getMyPosts();
  }

  Future<void> playAudio(String url) async {
    final player = GlobalAudioPlayer();
    await player.play(url);
  }

  Future<void> stopAudio() async {
    final player = GlobalAudioPlayer();
    await player.stop();
  }

  Future<void> toggleLike(String postId) {
    return _supabaseService.toggleLike(postId);
  }

  Future<void> createComment({required String postId, required String text}) {
    return _supabaseService.addComment(postId: postId, text: text);
  }

  Future<List<AudioComment>> fetchComments(String postId) {
    return _supabaseService.getComments(postId);
  }
}
