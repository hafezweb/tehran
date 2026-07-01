import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/repositories/audio_repository.dart';
import '../../core/models/audio_post.dart';
import 'widgets/voice_card.dart';

class FeedScreen extends StatelessWidget {
  FeedScreen({super.key});

  final AudioRepository repository = Get.find<AudioRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<AudioPost>>(
        stream: repository.watchFeed(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "خطا در بارگذاری فید",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!;

          if (posts.isEmpty) {
            return const Center(
              child: Text(
                "هنوز صدایی ثبت نشده",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff0A0A0D),
                  Color(0xff1B0B1A),
                  Color(0xff31162B),
                  Color(0xff0A0A0D),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  left: -50,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withOpacity(.14),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Positioned(
                  top: 220,
                  right: -80,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent.withOpacity(.10),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Positioned(
                  bottom: 140,
                  left: -70,
                  child: Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(.10),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                SafeArea(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      top: 28,
                      left: 8,
                      right: 8,
                      bottom: 160,
                    ),
                    itemCount: posts.length,
                    itemBuilder: (_, index) {
                      final post = posts[index];

                      return VoiceCard(
                        post: post,
                        onPlay: () async {
                          await repository.playAudio(post.audioUrl);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
