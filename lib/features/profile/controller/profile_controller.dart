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
      final uid = repository._supabaseService.userId; // temporary
      if (uid == null) return;

      final res = await repository._supabaseService.client
          .from('audio_posts')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);

      myPosts.value = res.map((e) => AudioPost.fromJson(e)).toList();
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
