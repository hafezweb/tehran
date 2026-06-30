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
  -------------------------
  SOCIAL
  -------------------------
  */

  Future<void> toggleLike(String postId) async {
    await _supabase.rpc('toggle_audio_like', params: {'p_post_id': postId});
  }

  Future<void> toggleSave(String postId) async {
    await _supabase.rpc('toggle_audio_save', params: {'p_post_id': postId});
  }

  Future<List<AudioComment>> getComments(String postId) async {
    final response = await _supabase
        .from('audio_comments')
        .select()
        .eq('post_id', postId)
        .order('created_at');

    return (response as List).map((e) => AudioComment.fromMap(e)).toList();
  }

  Future<void> addComment({
    required String postId,
    required String text,
  }) async {
    await _supabase.from('audio_comments').insert({
      'post_id': postId,
      'user_id': userId,
      'text': text,
    });
  }

  Future<List<AudioReply>> getReplies(String commentId) async {
    final response = await _supabase
        .from('audio_replies')
        .select()
        .eq('comment_id', commentId)
        .order('created_at');

    return (response as List).map((e) => AudioReply.fromMap(e)).toList();
  }

  Future<void> addReply({
    required String commentId,
    required String text,
  }) async {
    await _supabase.from('audio_replies').insert({
      'comment_id': commentId,
      'user_id': userId,
      'text': text,
    });
  }

  /*
  -------------------------
  TRUST
  -------------------------
  */

  Future<void> reportAudio({
    required String postId,
    required String reason,
  }) async {
    await _supabase.from('audio_reports').insert({
      'post_id': postId,
      'user_id': userId,
      'reason': reason,
    });
  }

  Future<void> blockUser(String blockedUserId) async {
    await _supabase.from('user_blocks').insert({
      'user_id': userId,
      'blocked_user_id': blockedUserId,
    });
  }
}
