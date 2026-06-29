import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/audio_post.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // قضیه‌ی OTP/Kavenegar فعلاً کنار گذاشته شده (تصمیم فعلی پروژه).
  // برای اینکه createAudioPost بتواند user_id را پر کند، از Anonymous
  // Auth استفاده می‌شود. این متد در main.dart صدا زده می‌شود.
  // پیش‌نیاز: "Allow anonymous sign-ins" باید در پنل Supabase فعال باشد.
  Future<void> signInAnonymouslyIfNeeded() async {
    if (_supabase.auth.currentSession == null) {
      try {
        await _supabase.auth.signInAnonymously();
        print("Anonymous sign-in موفق بود. user_id: $userId");
      } catch (e) {
        print("Anonymous sign-in ناموفق بود: $e");
      }
    }
  }

  String? get userId => _supabase.auth.currentUser?.id;

  Future<String?> uploadAudio(File file, String fileName) async {
    try {
      if (!file.existsSync()) {
        return null;
      }

      await _supabase.storage.from('audio_posts').upload(fileName, file);

      return _supabase.storage.from('audio_posts').getPublicUrl(fileName);
    } catch (e) {
      print("uploadAudio Error: $e");
      return null;
    }
  }

  /// ثبت پست جدید. user_id به‌صورت خودکار از کاربر فعلی (anonymous یا
  /// واقعی) خوانده می‌شود؛ اگر کاربری لاگین نباشد null برمی‌گرداند تا
  /// داده‌ی orphan ساخته نشود.
  Future<Map<String, dynamic>?> createAudioPost({
    required String audioUrl,
    required double lat,
    required double lng,
  }) async {
    final uid = userId;
    if (uid == null) {
      print("createAudioPost: کاربر لاگین نیست (نه anonymous، نه واقعی).");
      return null;
    }

    try {
      final response = await _supabase
          .from('audio_posts')
          .insert({
            'user_id': uid,
            'audio_url': audioUrl,
            'latitude': lat,
            'longitude': lng,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print("createAudioPost Error: $e");
      return null;
    }
  }

  Future<void> deleteAudio(String fileName) async {
    try {
      await _supabase.storage.from('audio_posts').remove([fileName]);
    } catch (_) {}
  }

  // فعلاً استفاده نمی‌شود چون تابع SQL مربوطه روی Supabase ساخته نشده.
  // برای نمایش پین‌های نقشه به‌جایش از getFeed() استفاده می‌شود.
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
    } catch (e) {
      print("getFeed Error: $e");
      return [];
    }
  }

  /// پست‌های متعلق به کاربر فعلی (برای صفحه‌ی پروفایل).
  Future<List<AudioPost>> getMyPosts() async {
    final uid = userId;
    if (uid == null) return [];

    try {
      final response = await _supabase
          .from('audio_posts')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);

      return (response as List).map((item) => AudioPost.fromMap(item)).toList();
    } catch (e) {
      print("getMyPosts Error: $e");
      return [];
    }
  }

  /// لایک/آن‌لایک یک پست برای کاربر فعلی. جدول audio_likes با ستون‌های
  /// user_id و post_id.
  Future<void> toggleLike(String postId) async {
    final uid = userId;
    if (uid == null) return;

    try {
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
    } catch (e) {
      print("toggleLike Error: $e");
    }
  }
}
