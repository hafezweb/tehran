import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/global_audio_player.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final player = GlobalAudioPlayer();

  StreamSubscription? sub;
  Duration current = Duration.zero;
  Duration total = Duration.zero;

  @override
  void initState() {
    super.initState();

    sub = player.positionStream.listen((position) {
      if (!mounted) return;

      setState(() {
        current = position;
        total = player.duration ?? Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (player.currentUrl == null) {
      return const SizedBox();
    }

    final progress = total.inMilliseconds == 0
        ? 0.0
        : current.inMilliseconds / total.inMilliseconds;

    return Positioned(
      bottom: 82,
      left: 14,
      right: 14,
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.08),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white.withOpacity(.15)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                if (player.isPlaying) {
                  await player.pause();
                } else {
                  await player.player.play();
                }

                setState(() {});
              },
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  player.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(value: progress, minHeight: 5),
              ),
            ),

            const SizedBox(width: 14),

            const Icon(Icons.favorite_border, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
