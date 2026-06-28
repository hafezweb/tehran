import 'package:just_audio/just_audio.dart';

class GlobalAudioPlayer {
  static final GlobalAudioPlayer _instance = GlobalAudioPlayer._internal();

  factory GlobalAudioPlayer() => _instance;

  GlobalAudioPlayer._internal();

  final AudioPlayer _player = AudioPlayer();

  String? _currentUrl;

  AudioPlayer get player => _player;

  String? get currentUrl => _currentUrl;

  bool get isPlaying => _player.playing;

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Duration? get duration => _player.duration;

  Future<void> play(String url) async {
    if (_currentUrl != url) {
      await _player.stop();
      await _player.setUrl(url);
      _currentUrl = url;
    }

    await _player.play();
  }

  Future<void> pause() async {
    if (_player.playing) {
      await _player.pause();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _currentUrl = null;
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }
}
