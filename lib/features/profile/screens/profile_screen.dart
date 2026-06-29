import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';
import '../../../core/services/global_audio_player.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    // قبلاً: Get.find<GlobalAudioPlayer>() -> GlobalAudioPlayer دیگر GetxController
    // نیست (یک کلاس singleton معمولی است)، پس باید مستقیم نمونه‌سازی شود.
    final GlobalAudioPlayer globalPlayer = GlobalAudioPlayer();

    return Scaffold(
      appBar: AppBar(title: const Text("پروفایل من"), centerTitle: true),
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

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                // قبلاً: globalPlayer.currentUrl.value, globalPlayer.isPlaying.value
                // (فرض GetX .obs) -> این‌ها در GlobalAudioPlayer واقعی getter
                // معمولی هستند (String?, bool)، نه Rx.
                leading: StatefulBuilder(
                  builder: (context, setLocalState) {
                    final isPlaying =
                        globalPlayer.currentUrl == post.audioUrl &&
                        globalPlayer.isPlaying;
                    return IconButton(
                      icon: Icon(
                        isPlaying ? Icons.stop_circle : Icons.play_circle,
                        size: 40,
                      ),
                      onPressed: () async {
                        if (isPlaying) {
                          await globalPlayer.stop();
                        } else {
                          await globalPlayer.play(post.audioUrl);
                        }
                        setLocalState(() {});
                      },
                    );
                  },
                ),
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
