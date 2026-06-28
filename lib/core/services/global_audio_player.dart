import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class GlobalAudioPlayer extends GetxController {
  static GlobalAudioPlayer get instance => Get.find<GlobalAudioPlayer>();

  final AudioPlayer _player = AudioPlayer();
  final currentUrl = ''.obs;
  final isPlaying = false.obs;
  String? currentPostId;

  Future<void> play(String url, String postId) async {
    try {
      await stop();
      currentUrl.value = url;
      currentPostId = postId;
      isPlaying.value = true;
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      print("Player Error: $e");
    }
  }

  Future<void> stop() async {
    await _player.stop();
    currentUrl.value = '';
    currentPostId = null;
    isPlaying.value = false;
  }
}
