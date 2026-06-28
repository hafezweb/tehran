import 'package:record/record.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  Future<void> startRecording() async {
    try {
      if (_isRecording) return;

      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        throw Exception('Microphone permission denied');
      }

      await _recorder.start();

      _isRecording = true;
    } catch (e) {
      _isRecording = false;
      rethrow;
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;

      final path = await _recorder.stop();

      _isRecording = false;

      if (path == null || path.isEmpty) {
        return null;
      }

      return path;
    } catch (e) {
      _isRecording = false;
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (_isRecording) {
      await _recorder.stop();
      _isRecording = false;
    }

    await _recorder.dispose();
  }
}