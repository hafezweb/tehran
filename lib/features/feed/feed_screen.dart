import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../map/controller/map_controller.dart';
import '../../../core/models/audio_post.dart';

class FeedScreen extends StatelessWidget {
  FeedScreen({super.key});

  final MapControllerX controller = Get.find<MapControllerX>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("فید صداها"), centerTitle: true),
      body: Obx(() {
        if (controller.audioPosts.isEmpty) {
          return const Center(child: Text("هنوز هیچ صدایی ثبت نشده"));
        }

        return RefreshIndicator(
          onRefresh: () async => await controller.loadFeed(),
          child: ListView.builder(
            itemCount: controller.audioPosts.length,
            itemBuilder: (context, index) {
              final post = controller.audioPosts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: IconButton(
                    icon: const Icon(Icons.play_circle, color: Colors.green, size: 40),
                    onPressed: () => controller.playAudio(post.audioUrl, post.id),
                  ),
                  title: const Text("پست صوتی"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.createdAt.toString().substring(0, 16)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => controller.toggleLike(post.id),
                            icon: const Icon(Icons.favorite_border),
                          ),
                          Text("${post.likes}"),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.graphic_eq, color: Colors.purple),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
