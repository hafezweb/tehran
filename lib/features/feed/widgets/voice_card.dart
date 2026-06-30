import 'package:flutter/material.dart';
import '../../../core/models/audio_post.dart';
import '../../../core/utils/time_format.dart';

class VoiceCard extends StatelessWidget {
  final AudioPost post;
  final VoidCallback onPlay;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const VoiceCard({
    super.key,
    required this.post,
    required this.onPlay,
    required this.onLike,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.graphic_eq)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.city, style: const TextStyle(fontSize: 16)),
                      Text(
                        timeAgoFa(post.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text("${post.duration}s"),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow),
                ),
                IconButton(
                  onPressed: onLike,
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                  ),
                ),
                IconButton(
                  onPressed: onComment,
                  icon: const Icon(Icons.comment),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
