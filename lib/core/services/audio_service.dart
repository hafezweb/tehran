import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();

  String? _recordPath;

  bool isRecording = false;

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
    return true;
  }

  Future<String?> stopRecording() async {
    final path = await _recorder.stop();

    print("RECORDED FILE PATH: $path");

    isRecording = false;
    return path;
  }

  void dispose() {
    _recorder.dispose();
  }
}
