import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/repositories/audio_repository.dart';

class FeedScreen extends StatelessWidget {
  FeedScreen({super.key});

  final AudioRepository repository = Get.find<AudioRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("فید صداها"), centerTitle: true),
      body: const Center(child: Text("فید در حال توسعه...")),
    );
  }
}
