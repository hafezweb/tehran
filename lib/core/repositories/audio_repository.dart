import 'dart:io';
import 'package:geolocator/geolocator.dart';

import '../models/audio_post.dart';
import '../models/audio_comment.dart';
import '../models/audio_reply.dart';
import '../services/audio_service.dart';
import '../services/location_service.dart';
import '../services/global_audio_player.dart';
import '../services/supabase_service.dart';

class AudioRepository {
  final SupabaseService _supabaseService;
  final AudioService _audioService;
  final LocationService _locationService;

  AudioRepository({
    SupabaseService? supabaseService,
    AudioService? audioService,
    LocationService? locationService,
  }) : _supabaseService = supabaseService ?? SupabaseService(),
       _audioService = audioService ?? AudioService(),
       _locationService = locationService ?? LocationService();

  /*
  -------------------------
  RECORDING LAYER
  -------------------------
  */

  Future<bool> startRecording() async {
    return _audioService.startRecording();
  }

  Future<String?> stopRecording() async {
    return _audioService.stopRecording();
  }

  Future<Position?> getCurrentLocation() async {
    return _locationService.getCurrent();
  }

  Future<String?> createAudioPost() async {
    final allowed = await _supabaseService.canUpload();
    if (!allowed) {
      throw Exception('Upload rate limit reached');
    }

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

    return result['id']?.toString();
  }

  /*
  -------------------------
  FEED
  -------------------------
  */

  Future<List<AudioPost>> getFeed() {
    return _supabaseService.getRankedFeed();
  }

  Stream<List<AudioPost>> watchFeed() {
    return _supabaseService.watchFeed();
  }

  Future<List<AudioPost>> getMyPosts() {
    return _supabaseService.getMyPosts();
  }

  /*
  -------------------------
  AUDIO PLAYER
  -------------------------
  */

  Future<void> playAudio(String url) async {
    final player = GlobalAudioPlayer();
    await player.play(url);
  }

  Future<void> stopAudio() async {
    final player = GlobalAudioPlayer();
    await player.stop();
  }

  /*
  -------------------------
  SOCIAL
  -------------------------
  */

  Future<void> toggleLike(String postId) {
    return _supabaseService.toggleLike(postId);
  }

  Future<void> toggleSave(String postId) {
    return _supabaseService.toggleSave(postId);
  }

  Future<List<AudioComment>> fetchComments(String postId) {
    return _supabaseService.getComments(postId);
  }

  Future<void> createComment({required String postId, required String text}) {
    return _supabaseService.addComment(postId: postId, text: text);
  }

  Future<List<AudioReply>> fetchReplies(String commentId) {
    return _supabaseService.getReplies(commentId);
  }

  Future<void> createReply({required String commentId, required String text}) {
    return _supabaseService.addReply(commentId: commentId, text: text);
  }

  /*
  -------------------------
  TRUST
  -------------------------
  */

  Future<void> reportAudio({required String postId, required String reason}) {
    return _supabaseService.reportAudio(postId: postId, reason: reason);
  }

  Future<void> blockUser(String userId) {
    return _supabaseService.blockUser(userId);
  }

  Future<bool> canUpload() {
    return _supabaseService.canUpload();
  }
}
