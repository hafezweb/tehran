import 'dart:async';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();

  String? _recordPath;
  bool isRecording = false;

  Timer? _timer;

  Future<bool> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return false;

    final dir = await getTemporaryDirectory();

    _recordPath =
        '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: _recordPath!,
    );

    isRecording = true;

    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 90), () async {
      if (isRecording) {
        await stopRecording();
      }
    });

    return true;
  }

  Future<String?> stopRecording() async {
    _timer?.cancel();

    final path = await _recorder.stop();

    isRecording = false;
    return path;
  }

  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
  }
}
