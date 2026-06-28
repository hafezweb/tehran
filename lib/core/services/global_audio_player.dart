import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class GlobalAudioPlayer extends GetxController {
  static GlobalAudioPlayer get instance => Get.find();

  final AudioPlayer _player = AudioPlayer();
  final currentUrl = ''.obs;
  final isPlaying = false.obs;
  String? currentPostId;

  Future<void> play(String url, String postId) async {
    try {
      if (currentUrl.value == url && isPlaying.value) {
        await stop();
        return;
      }

      await stop(); // Stop any previous playback

      currentUrl.value = url;
      currentPostId = postId;
      isPlaying.value = true;

      await _player.setUrl(url);
      await _player.play();

      // Auto stop listener
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          stop();
        }
      });
    } catch (e) {
      print("Global Player Error: $e");
      stop();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    currentUrl.value = '';
    currentPostId = null;
    isPlaying.value = false;
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}
