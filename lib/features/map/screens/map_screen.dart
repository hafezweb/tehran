import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

import '../controller/map_controller.dart';
import '../widgets/audio_player_sheet.dart';

class MapScreen extends StatelessWidget {
  MapScreen({super.key});

  final MapControllerX controller = Get.find<MapControllerX>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return Stack(
          children: [
            FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: controller.tehranCenter,
                initialZoom: 11,
                onPositionChanged: (position, hasGesture) {
                  if (position.zoom != null) {
                    controller.updateZoom(position.zoom!);
                  }
                  if (position.bounds != null) {
                    controller.updateBounds(position.bounds!);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.tehransound.app',
                ),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 90,
                    size: const Size(40, 40),
                    zoomToBoundsOnClick: true,
                    spiderfyCluster: true,
                    markers: controller.audioPosts.map((post) {
                      return Marker(
                        point: LatLng(post.lat, post.lng),
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => AudioPlayerSheet(
                                post: post,
                                onPlay: () => controller.playAudio(
                                  post.audioUrl,
                                  post.id,
                                ),
                                onStop: () => controller.stopAudio(),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.graphic_eq,
                            color: Colors.purple,
                            size: 35,
                          ),
                        ),
                      );
                    }).toList(),
                    builder: (context, markers) {
                      return Container(
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            if (controller.isLoading.value)
              const Center(child: CircularProgressIndicator()),
          ],
        );
      }),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "loc",
            onPressed: controller.goToUserLocation,
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 10),
          Obx(
            () => FloatingActionButton(
              heroTag: "rec",
              backgroundColor: controller.isRecordingAudio.value
                  ? Colors.red
                  : Colors.orange,
              onPressed: () async {
                if (controller.isRecordingAudio.value) {
                  await controller.stopAudioRecording();
                } else {
                  await controller.startAudioRecording();
                }
              },
              child: Icon(
                controller.isRecordingAudio.value ? Icons.stop : Icons.mic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
