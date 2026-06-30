import 'package:flutter/material.dart';

class VoicePin extends StatelessWidget {
  const VoicePin({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(Icons.mic, color: Colors.white),
    );
  }
}
