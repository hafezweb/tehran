import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/repositories/audio_repository.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/models/audio_post.dart';
import 'dart:async';

class MapControllerX extends GetxController {
  final AudioRepository repository = Get.find<AudioRepository>();
  final LocationService locationService = LocationService();
  final AudioService audioService = AudioService();

  final MapController mapController = MapController();
  final LatLng tehranCenter = const LatLng(35.6892, 51.3890);

  final isLoading = false.obs;
  final isRecordingAudio = false.obs;
  final audioPosts = <AudioPost>[].obs;

  StreamSubscription? _feedSubscription;
  LatLngBounds? currentBounds;

  @override
  void onInit() {
    super.onInit();
    listenToFeed();
  }

  @override
  void onClose() {
    _feedSubscription?.cancel();
    audioService.dispose();
    super.onClose();
  }

  Future<void> loadInitialFeed() async {
    isLoading.value = true;
    try {
      final res = await repository._supabaseService.getFeed();
      audioPosts.assignAll(res.map((e) => AudioPost.fromJson(e)).toList());
    } catch (e) {
      print("Load Feed Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBounds(LatLngBounds bounds) async {
    currentBounds = bounds;
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
        await loadInitialFeed();
      }
    } catch (e) {
      print("Stop Recording Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> playAudio(String url, String postId) async {
    await repository.playAudio(url, postId);
  }

  Future<void> stopAudio() async {
    await repository.stopAudio();
  }

  void listenToFeed() {
    _feedSubscription = repository.watchAllPosts().listen((posts) {
      audioPosts.assignAll(posts);
    });
  }

  void updateZoom(double zoom) {}
}
