import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';
import '../../../core/models/audio_post.dart';
import '../../../core/services/global_audio_player.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("پروفایل من"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.myPosts.isEmpty) {
          return const Center(
            child: Text("هنوز صدایی ثبت نکردی", style: TextStyle(fontSize: 18)),
          );
        }

        return ListView.builder(
          itemCount: controller.myPosts.length,
          itemBuilder: (context, index) {
            final post = controller.myPosts[index];
            final globalPlayer = Get.find<GlobalAudioPlayer>();

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                leading: Obx(() {
                  final isPlaying = globalPlayer.currentUrl.value == post.audioUrl && 
                                   globalPlayer.isPlaying.value;
                  return IconButton(
                    icon: Icon(isPlaying ? Icons.stop_circle : Icons.play_circle, size: 40),
                    onPressed: () {
                      if (isPlaying) {
                        globalPlayer.stop();
                      } else {
                        globalPlayer.play(post.audioUrl, post.id);
                      }
                    },
                  );
                }),
                title: const Text("پست صوتی من"),
                subtitle: Text(post.createdAt.toString().substring(0, 16)),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () => controller.toggleLike(post.id),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
