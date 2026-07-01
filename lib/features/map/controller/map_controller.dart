import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/repositories/audio_repository.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/global_audio_player.dart';
import '../../../core/models/audio_post.dart';

class MapControllerX extends GetxController {
  final AudioRepository repository = Get.find<AudioRepository>();
  final LocationService locationService = LocationService();
  final AudioService audioService = AudioService();
  final GlobalAudioPlayer player = GlobalAudioPlayer();

  final MapController mapController = MapController();
  final LatLng tehranCenter = const LatLng(35.6892, 51.3890);

  final isLoading = false.obs;
  final isRecordingAudio = false.obs;
  final audioPosts = <AudioPost>[].obs;

  StreamSubscription? feedSubscription;

  bool get hasActivePlayer => player.currentUrl != null;

  @override
  void onInit() {
    super.onInit();
    bindFeed();
  }

  void bindFeed() {
    feedSubscription?.cancel();

    feedSubscription = repository.watchFeed().listen((posts) {
      audioPosts.assignAll(posts);
    });
  }

  @override
  void onClose() {
    feedSubscription?.cancel();
    audioService.dispose();
    super.onClose();
  }

  Future<void> goToUserLocation() async {
    final pos = await locationService.getCurrent();
    if (pos == null) return;

    mapController.move(LatLng(pos.latitude, pos.longitude), 15);
  }

  Future<void> startAudioRecording() async {
    final started = await repository.startRecording();

    if (started) {
      isRecordingAudio.value = true;
    }
  }

  Future<void> stopAudioRecording() async {
    isRecordingAudio.value = false;
    await repository.createAudioPost();
  }

  Future<void> playAudio(String url) async {
    await repository.playAudio(url);
  }

  Future<void> stopAudio() async {
    await repository.stopAudio();
  }
}
