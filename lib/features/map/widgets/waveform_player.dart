import 'package:flutter/material.dart';

class WaveformPlayer extends StatelessWidget {
  final bool isPlaying;

  const WaveformPlayer({super.key, this.isPlaying = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(40, (index) {
          final height = isPlaying 
              ? (20 + (index % 5) * 8.0) 
              : 8.0 + (index % 3) * 4.0;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 4,
            height: height,
            decoration: BoxDecoration(
              color: isPlaying ? Colors.purple : Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
