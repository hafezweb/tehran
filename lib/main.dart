import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app_shell.dart';
import 'features/map/controller/map_controller.dart';
import 'core/repositories/audio_repository.dart';
import 'core/services/global_audio_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yxspmdfbprhdcfeicbpi.supabase.co',
    anonKey: 'sb_publishable_Heto8IH3Xs9sbdxML35VHA_Y-bDMXnD',
  );

  // قضیه‌ی OTP/Kavenegar فعلاً کنار گذاشته شده (تصمیم فعلی پروژه).
  // برای اینکه user_id همیشه یک مقدار واقعی و معتبر در auth.users باشد
  // (نه placeholder ساختگی که با foreign key تصادم می‌کند)،
  // در صورت نبود session، یک ورود anonymous انجام می‌شود.
  // پیش‌نیاز: "Allow anonymous sign-ins" باید در پنل Supabase فعال باشد.
  final client = Supabase.instance.client;
  if (client.auth.currentSession == null) {
    try {
      await client.auth.signInAnonymously();
      print(
        "Anonymous sign-in موفق بود. user_id: ${client.auth.currentUser?.id}",
      );
    } catch (e) {
      print("Anonymous sign-in ناموفق بود: $e");
      // اپ همچنان بالا می‌آید، ولی createAudioPost بعداً به دلیل نبود
      // userId با خطا fail می‌شود تا داده‌ی orphan ساخته نشود.
    }
  }

  Get.put(AudioRepository());
  Get.put(GlobalAudioPlayer());
  Get.put(MapControllerX());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tehran Sound (Test Mode)',
      theme: ThemeData.dark(),
      home: const AppShell(),
    );
  }
}
