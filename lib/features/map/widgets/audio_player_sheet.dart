import 'package:flutter/material.dart';

import '../../../core/models/audio_post.dart';
import '../../../core/services/global_audio_player.dart';

class AudioPlayerSheet extends StatefulWidget {
  final AudioPost post;

  const AudioPlayerSheet({super.key, required this.post});

  @override
  State<AudioPlayerSheet> createState() => _AudioPlayerSheetState();
}

class _AudioPlayerSheetState extends State<AudioPlayerSheet> {
  final GlobalAudioPlayer player = GlobalAudioPlayer();

  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    player.positionStream.listen((position) {
      if (!mounted) return;

      setState(() {
        currentPosition = position;
        totalDuration = player.duration ?? Duration.zero;
      });
    });
  }

  Future<void> togglePlay() async {
    if (player.currentUrl == widget.post.audioUrl && player.isPlaying) {
      await player.pause();
    } else {
      await player.play(widget.post.audioUrl);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final max = totalDuration.inMilliseconds == 0
        ? 1
        : totalDuration.inMilliseconds;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: currentPosition.inMilliseconds.toDouble(),
            min: 0,
            max: max.toDouble(),
            onChanged: (value) async {
              await player.seek(Duration(milliseconds: value.toInt()));
            },
          ),
          IconButton(
            onPressed: togglePlay,
            icon: Icon(
              player.isPlaying && player.currentUrl == widget.post.audioUrl
                  ? Icons.pause
                  : Icons.play_arrow,
            ),
          ),
        ],
      ),
    );
  }
}
