import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/repositories/audio_repository.dart';
import '../../core/models/audio_post.dart';
import '../map/widgets/audio_player_sheet.dart';
import 'widgets/comment_sheet.dart';
import 'widgets/voice_card.dart';

class FeedScreen extends StatelessWidget {
  FeedScreen({super.key});

  final AudioRepository repository = Get.find<AudioRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("فید صداها")),
      body: StreamBuilder<List<AudioPost>>(
        stream: repository.watchFeed(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("خطا در بارگذاری فید: ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.reversed.toList();

          if (posts.isEmpty) {
            return const Center(child: Text("هنوز صدایی ثبت نشده"));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (_, index) {
              final post = posts[index];

              return VoiceCard(
                post: post,
                onPlay: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => AudioPlayerSheet(post: post),
                  );
                },
                onLike: () async {
                  await repository.toggleLike(post.id);
                },
                onComment: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: CommentSheet(postId: post.id),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
