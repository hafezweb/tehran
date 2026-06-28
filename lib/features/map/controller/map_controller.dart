import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import '../../../core/repositories/audio_repository.dart';
import '../../../core/models/audio_post.dart';
import '../../../core/utils/debouncer.dart';
import '../../../core/utils/snackbar_helper.dart';

class MapControllerX extends GetxController {
  final AudioRepository _repository = AudioRepository();
  final MapController mapController = MapController();
  final LatLng tehranCenter = const LatLng(35.6892, 51.3890);

  final isLoading = false.obs;
  final isRecordingAudio = false.obs;
  final audioPosts = <AudioPost>[].obs;

  StreamSubscription? _feedSubscription;
  LatLngBounds? currentBounds;

  late final Debouncer _boundsDebouncer;

  @override
  void onInit() {
    super.onInit();
    _boundsDebouncer = Debouncer(delay: const Duration(milliseconds: 800));
    listenToFeed();
    loadInitialFeed(); // Initial load
  }

  @override
  void onClose() {
    _feedSubscription?.cancel();
    _repository.disposeIfNeeded(); // Will be implemented in repository
    super.onClose();
  }

  Future<void> loadInitialFeed() async {
    isLoading.value = true;
    try {
      // TODO: Implement bounds-aware later
      final res = await _repository.getPostsInBounds(
        north: 36.0,
        south: 35.0,
        east: 52.0,
        west: 51.0,
      );
      audioPosts.assignAll(res);
    } finally {
      isLoading.value = false;
    }
  }

  void updateBounds(LatLngBounds bounds) {
    currentBounds = bounds;
    _boundsDebouncer.run(() async {
      if (currentBounds == null) return;

      isLoading.value = true;
      try {
        final res = await _repository.getPostsInBounds(
          north: currentBounds!.north,
          south: currentBounds!.south,
          east: currentBounds!.east,
          west: currentBounds!.west,
        );
        audioPosts.assignAll(res);
        SnackbarHelper.showSuccess('صداها به‌روزرسانی شدند (${res.length} مورد)');
      } catch (e) {
        SnackbarHelper.showError('خطا در بارگذاری صداها');
      } finally {
        isLoading.value = false;
      }
    });
  }

  Future<void> goToUserLocation() async {
    try {
      final pos = await _repository.getCurrentLocation();
      if (pos == null) {
        SnackbarHelper.showError('موقعیت مکانی در دسترس نیست');
        return;
      }

      print("LOCATION: ${pos.latitude}, ${pos.longitude}");

      mapController.move(LatLng(pos.latitude, pos.longitude), 15);
      SnackbarHelper.showSuccess('به موقعیت شما منتقل شدید');
    } catch (e) {
      SnackbarHelper.showError('خطا در دریافت موقعیت');
    }
  }

  Future<void> startAudioRecording() async {
    final started = await _repository.startRecording();
    if (!started) {
      SnackbarHelper.showError('دسترسی به میکروفون داده نشد');
      return;
    }
    isRecordingAudio.value = true;
    SnackbarHelper.showSuccess('ضبط صدا شروع شد...');
  }

  Future<void> stopAudioRecording() async {
    isLoading.value = true;
    try {
      final postId = await _repository.createAudioPost();
      if (postId != null) {
        SnackbarHelper.showSuccess('صدای شما با موفقیت ثبت شد!');
      } else {
        SnackbarHelper.showError('خطا در ثبت صدا');
      }
    } catch (e) {
      SnackbarHelper.showError('خطا در ذخیره‌سازی صدا');
    } finally {
      isRecordingAudio.value = false;
      isLoading.value = false;
    }
  }

  Future<void> playAudio(String url, String postId) async {
    await _repository.playAudio(url, postId);
  }

  Future<void> stopAudio() async {
    await _repository.stopAudio();
  }

  void listenToFeed() {
    _feedSubscription = _repository.watchAllPosts().listen((posts) {
      audioPosts.assignAll(posts);
    });
  }

  void updateZoom(double zoom) {}
}
