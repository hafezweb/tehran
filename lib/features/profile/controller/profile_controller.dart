import 'package:get/get.dart';
import '../../../core/repositories/audio_repository.dart';
import '../../../core/models/audio_post.dart';
import '../../../core/services/global_audio_player.dart';

class ProfileController extends GetxController {
  final AudioRepository repository = Get.find<AudioRepository>();
  final GlobalAudioPlayer globalPlayer = Get.find<GlobalAudioPlayer>();

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
      // For now use a simple query - can be extended in repository
      final res = await repository._supabaseService.client // temporary, better to add method to repo
          .from('audio_posts')
          .select()
          .eq('user_id', repository._supabaseService.userId)
          .order('created_at', ascending: false);

      myPosts.value = res.map((e) => AudioPost.fromJson(e)).toList();
    } catch (e) {
      SnackbarHelper.error('خطا در بارگذاری پست‌ها');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLike(String postId) async {
    await repository.toggleLike(postId);
    await loadMyPosts(); // refresh
  }
}
