import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/audio_post.dart';
import '../../../core/services/global_audio_player.dart';

class AudioPlayerSheet extends StatelessWidget {
  final AudioPost post;

  const AudioPlayerSheet({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalAudioPlayer player = Get.find<GlobalAudioPlayer>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("پست صوتی", style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            post.createdAt.toString().substring(0, 16),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          Obx(() {
            final isThisPlaying = player.currentUrl.value == post.audioUrl && player.isPlaying.value;
            return Column(
              children: [
                Icon(
                  isThisPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 80,
                  color: Colors.purple,
                ),
                const SizedBox(height: 10),
                Text(
                  isThisPlaying ? 'در حال پخش...' : 'آماده پخش',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            );
          }),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  player.play(post.audioUrl, post.id);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text("پخش"),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  player.stop();
                },
                icon: const Icon(Icons.stop),
                label: const Text("توقف"),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Obx(() => Text(
            "❤️ ${post.likes}   ▶ ${post.plays}",
            style: const TextStyle(color: Colors.white),
          )),
        ],
      ),
    );
  }
}
