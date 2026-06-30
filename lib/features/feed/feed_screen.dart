import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../map/widgets/audio_player_sheet.dart';
import 'widgets/voice_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();

    return Scaffold(
      appBar: AppBar(title: const Text("فید صداها")),
      body: FutureBuilder(
        future: service.getRankedFeed(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!;

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
                  await service.toggleLike(post.id);
                },
                onComment: () {},
              );
            },
          );
        },
      ),
    );
  }
}
