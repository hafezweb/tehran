import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app_shell.dart';
import 'features/map/controller/map_controller.dart';
import 'core/repositories/audio_repository.dart';
import 'core/services/global_audio_player.dart';
import 'core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yxspmdfbprhdcfeicbpi.supabase.co',
    anonKey: 'sb_publishable_Heto8IH3Xs9sbdxML35VHA_Y-bDMXnD',
  );

  // قضیه‌ی OTP/Kavenegar فعلاً کنار گذاشته شده (تصمیم فعلی پروژه).
  // برای اینکه user_id همیشه یک مقدار واقعی و معتبر در auth.users باشد،
  // در صورت نبود session یک ورود anonymous انجام می‌شود.
  await SupabaseService().signInAnonymouslyIfNeeded();

  Get.put(AudioRepository());
  Get.put(MapControllerX());
  // توجه: GlobalAudioPlayer دیگر GetxController نیست (singleton معمولی
  // است)، پس دیگر نیازی به Get.put برایش نیست؛ با GlobalAudioPlayer()
  // در هر فایل به همان instance دسترسی پیدا می‌کنید.

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
