import 'package:get/get.dart';
import '../../../core/repositories/audio_repository.dart';
import '../../../core/models/audio_post.dart';

class ProfileController extends GetxController {
  final AudioRepository repository = Get.find<AudioRepository>();

  final myPosts = <AudioPost>[].obs;
  final isLoading = false.obs;
  final trustScore = 100.obs;

  @override
  void onInit() {
    super.onInit();
    loadMyPosts();
  }

  Future<void> loadMyPosts() async {
    try {
      isLoading.value = true;
      // قبلاً: repository._supabaseService.client.from(...) -> ارور کامپایل
      // (دسترسی به فیلد library-private از فایل دیگر) و client/userId هم
      // در SupabaseService واقعی وجود نداشت.
      // الان: از طریق متد عمومی repository.getMyPosts()
      final res = await repository.getMyPosts();
      myPosts.assignAll(res);
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
