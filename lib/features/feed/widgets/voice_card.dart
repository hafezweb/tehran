import 'package:flutter/material.dart';
import '../../../core/models/audio_post.dart';

class VoiceCard extends StatelessWidget {
  final AudioPost post;
  final VoidCallback onPlay;

  const VoiceCard({super.key, required this.post, required this.onPlay});

  String formatDuration(int sec) {
    final minutes = sec ~/ 60;
    final seconds = sec % 60;

    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPlay,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: post.coverImage.isNotEmpty
                  ? Image.network(
                      post.coverImage,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 72,
                      height: 72,
                      color: Colors.white10,
                      child: const Icon(Icons.graphic_eq, size: 30),
                    ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.creatorName,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            Text(
              formatDuration(post.duration),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
