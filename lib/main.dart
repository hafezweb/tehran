import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app_shell.dart';
import 'features/map/controller/map_controller.dart';
import 'core/services/global_audio_player.dart';
import 'core/repositories/audio_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yxspmdfbprhdcfeicbpi.supabase.co',
    anonKey: 'sb_publishable_Heto8IH3Xs9sbdxML35VHA_Y-bDMXnD',
  );

  print(
    "CURRENT USER: ${Supabase.instance.client.auth.currentUser}",
  );

  // Register controllers
  Get.put(MapControllerX());
  Get.put(GlobalAudioPlayer());
  Get.put(AudioRepository()); // Central repository

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
