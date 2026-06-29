import 'dart:io';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../models/audio_post.dart';
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

  // Getter عمومی - چون فایل‌های دیگر (map_controller.dart, profile_controller.dart)
  // نمی‌توانند مستقیماً به _supabaseService (که library-private است) دسترسی داشته باشند.
  SupabaseService get supabaseService => _supabaseService;

  Future<bool> startRecording() => _audioService.startRecording();
  Future<String?> stopRecording() => _audioService.stopRecording();
  Future<Position?> getCurrentLocation() => _locationService.getCurrent();

  /// ضبط را متوقف می‌کند، فایل را به Supabase Storage آپلود می‌کند،
  /// موقعیت فعلی را می‌گیرد و یک ردیف جدید در audio_posts ثبت می‌کند.
  /// خروجی: id پست تازه‌ساخته‌شده، یا null اگر مرحله‌ای fail شود.
  /// هر مرحله‌ی fail‌شده، یک Snackbar قابل‌خواندن روی صفحه نشان می‌دهد
  /// تا بدون logcat هم بتوان مشکل را تشخیص داد.
  Future<String?> createAudioPost() async {
    // ۱. توقف ضبط و گرفتن مسیر فایل لوکال
    final filePath = await stopRecording();
    if (filePath == null) {
      print("createAudioPost: مسیر فایل ضبط‌شده null است.");
      SnackbarHelper.showError("ضبط صدا ناموفق بود (فایل ساخته نشد).");
      return null;
    }

    final file = File(filePath);
    if (!await file.exists()) {
      print("createAudioPost: فایل ضبط‌شده روی دیسک پیدا نشد: $filePath");
      SnackbarHelper.showError("فایل صوتی روی دیسک پیدا نشد.");
      return null;
    }

    // ۲. گرفتن موقعیت فعلی کاربر
    final position = await getCurrentLocation();
    if (position == null) {
      print("createAudioPost: موقعیت مکانی در دسترس نیست.");
      SnackbarHelper.showError(
        "موقعیت مکانی در دسترس نیست. GPS گوشی را روشن کنید.",
      );
      return null;
    }

    // ۳. آپلود فایل صوتی به باکت 'audio_posts' در Supabase Storage
    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final audioUrl = await _supabaseService.uploadAudio(file, fileName);
    if (audioUrl == null) {
      print("createAudioPost: آپلود فایل صوتی fail شد.");
      SnackbarHelper.showError(
        "آپلود فایل صوتی ناموفق بود (اتصال یا دسترسی Storage را چک کنید).",
      );
      return null;
    }

    // ۴. ثبت ردیف جدید در audio_posts.
    // SupabaseService.createAudioPost خودش user_id را از کاربر فعلی
    // (anonymous یا واقعی) می‌خواند؛ اگر کاربری نباشد null برمی‌گرداند.
    final result = await _supabaseService.createAudioPost(
      audioUrl: audioUrl,
      lat: position.latitude,
      lng: position.longitude,
    );

    if (result == null) {
      print("createAudioPost: ثبت ردیف در دیتابیس fail شد.");
      SnackbarHelper.showError(
        "ثبت پست در دیتابیس ناموفق بود (لاگین/دسترسی را چک کنید).",
      );
      return null;
    }

    SnackbarHelper.showSuccess("صدا با موفقیت ثبت شد.");
    return result['id']?.toString();
  }

  /// فید پست‌ها برای نقشه و صفحه‌ی فید. چون تابع RPC مربوط به
  /// getNearbyPosts هنوز روی Supabase ساخته نشده، فعلاً از getFeed
  /// (آخرین پست‌ها، بدون فیلتر جغرافیایی) استفاده می‌شود.
  Future<List<AudioPost>> getFeed({DateTime? before, int limit = 20}) {
    return _supabaseService.getFeed(before: before, limit: limit);
  }

  Future<List<AudioPost>> getMyPosts() {
    return _supabaseService.getMyPosts();
  }

  // توجه: GlobalAudioPlayer یک GetxController نیست (singleton معمولی
  // است)، پس با GlobalAudioPlayer() مستقیم به همان instance می‌رسیم،
  // نه با Get.find.
  Future<void> playAudio(String url) async {
    final player = GlobalAudioPlayer();
    await player.play(url);
  }

  Future<void> stopAudio() async {
    final player = GlobalAudioPlayer();
    await player.stop();
  }

  Future<void> toggleLike(String postId) => _supabaseService.toggleLike(postId);
}
