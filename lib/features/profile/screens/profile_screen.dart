import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("پروفایل")),
      body: Obx(() {
        return Column(
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(radius: 45, child: Icon(Icons.person)),
            const SizedBox(height: 12),
            const Text("کاربر ناشناس"),
            const SizedBox(height: 12),
            Text("Trust Score: ${controller.trustScore.value}"),
            Expanded(
              child: ListView.builder(
                itemCount: controller.myPosts.length,
                itemBuilder: (_, index) {
                  final post = controller.myPosts[index];

                  return ListTile(
                    title: Text(post.city),
                    subtitle: Text("City: ${post.city}"),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
