import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/audio_post.dart';
import '../models/audio_comment.dart';
import '../models/audio_reply.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  String? get userId => _supabase.auth.currentUser?.id;

  /*
  -------------------------
  AUTH
  -------------------------
  */

  Future<void> signInAnonymouslyIfNeeded() async {
    if (_supabase.auth.currentSession == null) {
      await _supabase.auth.signInAnonymously();
    }
  }

  /*
  -------------------------
  STORAGE
  -------------------------
  */

  Future<String?> uploadAudio(File file, String fileName) async {
    try {
      await signInAnonymouslyIfNeeded();

      await _supabase.storage.from('audio_posts').upload(fileName, file);

      return _supabase.storage.from('audio_posts').getPublicUrl(fileName);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteAudio(String fileName) async {
    await _supabase.storage.from('audio_posts').remove([fileName]);
  }

  /*
  -------------------------
  POSTS
  -------------------------
  */

  Future<Map<String, dynamic>?> createAudioPost({
    required String audioUrl,
    required double lat,
    required double lng,
  }) async {
    await signInAnonymouslyIfNeeded();

    try {
      final response = await _supabase
          .from('audio_posts')
          .insert({
            'user_id': userId,
            'audio_url': audioUrl,
            'latitude': lat,
            'longitude': lng,
            'duration': 90,
            'likes_count': 0,
            'comments_count': 0,
            'is_liked': false,
            'is_saved': false,
            'is_anonymous': true,
            'city': 'Tehran',
            'score': 0,
            'trust_score': 100,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (_) {
      return null;
    }
  }

  Future<List<AudioPost>> getRankedFeed() async {
    final response = await _supabase
        .from('audio_posts')
        .select()
        .gte('trust_score', 50)
        .order('score', ascending: false);

    return (response as List).map((e) => AudioPost.fromMap(e)).toList();
  }

  Stream<List<AudioPost>> watchFeed() {
    return _supabase
        .from('audio_posts')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((rows) => rows.map((e) => AudioPost.fromMap(e)).toList());
  }

  Future<List<AudioPost>> getMyPosts() async {
    await signInAnonymouslyIfNeeded();

    final response = await _supabase
        .from('audio_posts')
        .select()
        .eq('user_id', userId!)
        .order('created_at', ascending: false);

    return (response as List).map((e) => AudioPost.fromMap(e)).toList();
  }

  /*
  -------------------------
  RATE LIMIT
  -------------------------
  */

  Future<bool> canUpload() async {
    await signInAnonymouslyIfNeeded();

    final response = await _supabase
        .from('audio_posts')
        .select()
        .eq('user_id', userId!)
        .gte(
          'created_at',
          DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        );

    return (response as List).length < 3;
  }

  /*