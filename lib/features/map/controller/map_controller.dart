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
    audioService