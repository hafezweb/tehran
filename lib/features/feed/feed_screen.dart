import 'package:flutter/material.dart';

import '../../core/models/audio_post.dart';
import '../../core/services/supabase_service.dart';
import '../map/widgets/audio_player_sheet.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final SupabaseService service = SupabaseService();

  final List<AudioPost> posts = [];

  bool isLoading = false;
  bool hasMore = true;

  DateTime? lastCursor;

  @override
  void initState() {
    super.initState();
    loadFeed();
  }

  Future<void> loadFeed() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    final fetched = await service.getFeed(before: lastCursor);

    if (fetched.isEmpty) {
      hasMore = false;
    } else {
      posts.addAll(fetched);
      lastCursor = fetched.last.createdAt;
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> refreshFeed() async {
    posts.clear();
    lastCursor = null;
    hasMore = true;

    await loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshFeed,
      child: ListView.builder(
        itemCount: posts.length + 1,
        itemBuilder: (context, index) {
          if (index == posts.length) {
            if (hasMore) {
              loadFeed();

              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return const SizedBox();
          }

          final post = posts[index];

          return ListTile(
            title: Text(post.id),
            subtitle: Text(post.createdAt.toString()),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => AudioPlayerSheet(post: post),
              );
            },
          );
        },
      ),
    );
  }
}
