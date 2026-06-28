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

  // Getter عمومی - چون فایل‌های دیگر (map_controller.dart, profile_controller.dart)
  // نمی‌توانند مستقیماً به _supabaseService (که library-private است) دسترسی داشته باشند.
  SupabaseService get supabaseService => _supabaseService;

  Future<bool> startRecording() => _audioService.startRecording();
  Future<String?> stopRecording() => _audioService.stopRecording();
  Future<Position?> getCurrentLocation() => _locationService.getCurrent();

  /// ضبط را متوقف می‌کند، فایل را به Supabase Storage آپلود می‌کند،
  /// موقعیت فعلی را می‌گیرد و یک ردیف جدید در audio_posts ثبت می‌کند.
  /// خروجی: شناسه‌ی پست تازه‌ساخته‌شده، یا null اگر مرحله‌ای fail شود.
  Future<String?> createAudioPost() async {
    // ۱. توقف ضبط و گرفتن مسیر فایل لوکال
    final filePath = await stopRecording();
    if (filePath == null) {
      print("createAudioPost: مسیر فایل ضبط‌شده null است.");
      return null;
    }

    final file = File(filePath);
    if (!await file.exists()) {
      print("createAudioPost: فایل ضبط‌شده روی دیسک پیدا نشد: $filePath");
      return null;
    }

    // ۲. گرفتن موقعیت فعلی کاربر
    final position = await getCurrentLocation();
    if (position == null) {
      print("createAudioPost: موقعیت مکانی در دسترس نیست.");
      return null;
    }

    // ۳. اطمینان از وجود یک کاربر (Anonymous Auth).
    // قضیه‌ی OTP/Kavenegar فعلاً کنار گذاشته شده؛ اینجا فقط چک می‌کنیم
    // که main.dart قبلاً signInAnonymously زده باشد.
    final userId = _supabaseService.userId;
    if (userId == null) {
      print("createAudioPost: کاربر لاگین نیست (نه anonymous، نه واقعی).");
      return null;
    }

    try {
      // ۴. آپلود فایل صوتی به Supabase Storage
      final fileName =
          'audio_${userId}_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final audioUrl = await _supabaseService.uploadAudio(fileName, file);

      // ۵. ثبت ردیف جدید در جدول audio_posts
      final postId = await _supabaseService.insertAudioPost(
        userId: userId,
        audioUrl: audioUrl,
        lat: position.latitude,
        lng: position.longitude,
      );

      return postId;
    } catch (e) {
      print("createAudioPost Error: $e");
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

  Future<void> toggleLike(String postId) => _supabaseService.toggleLike(postId);
}
