import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/audio_post.dart';
import '../models/audio_comment.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signInAnonymouslyIfNeeded() async {
    if (_supabase.auth.currentSession == null) {
      await _supabase.auth.signInAnonymously();
    }
  }

  String? get userId => _supabase.auth.currentUser?.id;

  Future<String?> uploadAudio(File file, String fileName) async {
    try {
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
    var uid = userId;

    if (uid == null) {
      final authResponse = await _supabase.auth.signInAnonymously();
      uid = authResponse.user?.id;
    }

    if (uid == null) return null;

    try {
      final response = await _supabase
          .from('audio_posts')
          .insert({
            'user_id': uid,
            'audio_url': audioUrl,
            'latitude': lat,
            'longitude': lng,
            'duration': 90,
            'likes_count': 0,
            'comments_count': 0,
            'is_liked': false,
            'is_anonymous': true,
            'city': 'Tehran',
            'score': 0,
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
    await _supabase.storage.from('audio_posts').remove([fileName]);
  }

  Future<List<AudioPost>> getFeed({DateTime? before, int limit = 20}) async {
    final filterBuilder = _supabase.from('audio_posts').select();

    final response =
        await (before != null
                ? filterBuilder.lt('created_at', before.toIso8601String())
                : filterBuilder)
            .order('created_at', ascending: false)
            .limit(limit);

    return (response as List).map((item) => AudioPost.fromMap(item)).toList();
  }

  Stream<List<AudioPost>> watchFeed() {
    return _supabase
        .from('audio_posts')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) => data.map((item) => AudioPost.fromMap(item)).toList());
  }

  Future<List<AudioPost>> getMyPosts() async {
    final uid = userId;
    if (uid == null) return [];

    final response = await _supabase
        .from('audio_posts')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false);

    return (response as List).map((item) => AudioPost.fromMap(item)).toList();
  }

  Future<void> toggleLike(String postId) async {
    final uid = userId;
    if (uid == null) return;

    final exists = await _supabase
        .from('audio_likes')
        .select('id')
        .eq('user_id', uid)
        .eq('post_id', postId);

    if ((exists as List).isEmpty) {
      await _supabase.from('audio_likes').insert({
        'user_id': uid,
        'post_id': postId,
      });
    } else {
      await _supabase
          .from('audio_likes')
          .delete()
          .eq('user_id', uid)
          .eq('post_id', postId);
    }
  }

  Future<List<AudioComment>> getComments(String postId) async {
    final response = await _supabase
        .from('audio_comments')
        .select()
        .eq('post_id', postId)
        .order('created_at');

    return (response as List)
        .map((item) => AudioComment.fromMap(item))
        .toList();
  }

  Future<void> addComment({
    required String postId,
    required String text,
  }) async {
    final uid = userId;
    if (uid == null) return;

    await _supabase.from('audio_comments').insert({
      'post_id': postId,
      'user_id': uid,
      'text': text,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<AudioPost>> getRankedFeed() async {
    final response = await _supabase
        .from('audio_posts')
        .select()
        .order('likes_count', ascending: false);

    return (response as List).map((item) => AudioPost.fromMap(item)).toList();
  }

  Future<List<AudioPost>> getNearbyFeed({
    required double lat,
    required double lng,
    required double radius,
  }) async {
    final response = await _supabase.rpc(
      'get_nearby_audio_posts',
      params: {'user_lat': lat, 'user_lng': lng, 'radius_km': radius},
    );

    return (response as List).map((item) => AudioPost.fromMap(item)).toList();
  }
}
