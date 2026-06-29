import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/repositories/audio_repository.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/models/audio_post.dart';

class MapControllerX extends GetxController {
  final AudioRepository repository = Get.find<AudioRepository>();
  final LocationService locationService = LocationService();
  final AudioService audioService = AudioService();

  final MapController mapController = MapController();
  final LatLng tehranCenter = const LatLng(35.6892, 51.3890);

  final isLoading = false.obs;
  final isRecordingAudio = false.obs;
  final audioPosts = <AudioPost>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFeed();
  }

  @override
  void onClose() {
    audioService.dispose();
    super.onClose();
  }

  /// چون نقشه فعلاً realtime نیست (SupabaseService stream ندارد)،
  /// این متد بعد از هر ضبط جدید و در ابتدای باز شدن صفحه صدا زده می‌شود.
  Future<void> loadFeed() async {
    isLoading.value = true;
    try {
      final res = await repository.getFeed();
      audioPosts.assignAll(res);
    } catch (e) {
      print("Load Feed Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> goToUserLocation() async {
    try {
      final pos = await locationService.getCurrent();
      if (pos == null) return;
      mapController.move(LatLng(pos.latitude, pos.longitude), 15);
    } catch (e) {
      print("Location Error: $e");
    }
  }

  Future<void> startAudioRecording() async {
    final started = await repository.startRecording();
    if (started) {
      isRecordingAudio.value = true;
    }
  }

  Future<void> stopAudioRecording() async {
    isRecordingAudio.value = false;
    isLoading.value = true;
    try {
      final postId = await repository.createAudioPost();
      if (postId != null) {
        await loadFeed();
      }
    } catch (e) {
      print("Stop Recording Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> playAudio(String url) async {
    await repository.playAudio(url);
  }

  Future<void> stopAudio() async {
    await repository.stopAudio();
  }
}
