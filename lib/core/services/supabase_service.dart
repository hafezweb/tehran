import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/audio_post.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> uploadAudio(File file, String fileName) async {
    try {
      if (!file.existsSync()) {
        return null;
      }

      await _supabase.storage.from('audio_posts').upload(fileName, file);

      return _supabase.storage.from('audio_posts').getPublicUrl(fileName);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> createAudioPost({
    required String audioUrl,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _supabase
          .from('audio_posts')
          .insert({
            'audio_url': audioUrl,
            'latitude': lat,
            'longitude': lng,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteAudio(String fileName) async {
    try {
      await _supabase.storage.from('audio_posts').remove([fileName]);
    } catch (_) {}
  }

  Future<List<AudioPost>> getNearbyPosts({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_nearby_audio_posts',
        params: {
          'user_lat': latitude,
          'user_lng': longitude,
          'radius_km': radius,
        },
      );

      return (response as List).map((item) => AudioPost.fromMap(item)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<AudioPost>> getFeed({DateTime? before, int limit = 20}) async {
    try {
      var query = _supabase
          .from('audio_posts')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      if (before != null) {
        query = query.lt('created_at', before.toIso8601String());
      }

      final response = await query;

      return (response as List).map((item) => AudioPost.fromMap(item)).toList();
    } catch (_) {
      return [];
    }
  }
}
