import 'package:flutter/material.dart';

class WaveformBar extends StatelessWidget {
  const WaveformBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        20,
        (index) => Container(
          width: 4,
          height: (index % 5 + 1) * 8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
