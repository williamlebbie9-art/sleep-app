import 'package:audioplayers/audioplayers.dart';

enum BackgroundAudioType { story, sound }

class BackgroundAudioService {
  BackgroundAudioService._();

  static final BackgroundAudioService instance = BackgroundAudioService._();

  final AudioPlayer _player = AudioPlayer();
  String? _currentAssetPath;
  BackgroundAudioType? _currentType;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;
  String? get currentAssetPath => _currentAssetPath;
  BackgroundAudioType? get currentType => _currentType;

  Stream<PlayerState> get playerStateStream => _player.onPlayerStateChanged;

  bool isCurrent(String assetPath, BackgroundAudioType type) {
    return _currentAssetPath == assetPath && _currentType == type;
  }

  Future<void> playStory(String assetPath) {
    return _playAsset(assetPath: assetPath, type: BackgroundAudioType.story);
  }

  Future<void> playSound(String assetPath) {
    return _playAsset(assetPath: assetPath, type: BackgroundAudioType.sound);
  }

  Future<void> _playAsset({
    required String assetPath,
    required BackgroundAudioType type,
  }) async {
    if (isCurrent(assetPath, type)) {
      if (_isPlaying) {
        return;
      }
      try {
        await _player.resume();
        _isPlaying = true;
        return;
      } catch (_) {
        // If resume fails (for example after app lifecycle changes), restart.
      }
    }

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource(assetPath));

    _currentAssetPath = assetPath;
    _currentType = type;
    _isPlaying = true;
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _currentAssetPath = null;
    _currentType = null;
  }
}
