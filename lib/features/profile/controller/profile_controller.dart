import 'package:get/get.dart';

import '../../../core/repositories/audio_repository.dart';
import '../../../core/models/audio_post.dart';

class ProfileController extends GetxController {
  final AudioRepository repository = Get.find<AudioRepository>();

  final myPosts = <AudioPost>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMyPosts();
  }

  Future<void> loadMyPosts() async {
    try {
      isLoading.value = true;

      final posts = await repository.getMyPosts();
      myPosts.assignAll(posts);
    } catch (e) {
      print("Profile Load Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLike(String postId) async {
    await repository.toggleLike(postId);
    await loadMyPosts();
  }
}
