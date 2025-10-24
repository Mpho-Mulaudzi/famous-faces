import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  // ────────── Singleton pattern ──────────
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();
  final AudioPlayer _bgm = AudioPlayer(playerId: 'bgm')
    ..setReleaseMode(ReleaseMode.loop)
    ..setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none, // keep playing through focus loss
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers}, // ← Set, not List
        ),
      ),
    );
  // leave this one untouched
  final AudioPlayer _sfx = AudioPlayer();

  bool _musicOn = true;
  bool _sfxOn = true;
  double _musicVolume = 0.25;
  bool _isBgmPlaying = false;

  // ────────── Background Music ──────────
  Future<void> playBgm() async {
    if (!_musicOn || _isBgmPlaying) return;
    try {
      await _bgm.play(AssetSource('sounds/theme.mp3'), volume: _musicVolume);
      _isBgmPlaying = true;
    } catch (e) {
      // ignore audio load errors silently
    }

    // 👇 optional safeguard for Huawei / aggressive OEMs:
    _bgm.onPlayerComplete.listen((_) {
      if (_musicOn) {
        _bgm.play(AssetSource('sounds/theme.mp3'), volume: _musicVolume);
      }
    });
  }

  Future<void> stopBgm() async {
    await _bgm.stop();
    _isBgmPlaying = false;
  }

  Future<void> setMusicVolume(double v) async {
    _musicVolume = v.clamp(0, 1);
    await _bgm.setVolume(_musicVolume);
  }

  void toggleMusic(bool on) {
    _musicOn = on;
    if (on) {
      playBgm();
    } else {
      stopBgm();
    }
  }

  bool get isMusicOn => _musicOn;
  double get musicVolume => _musicVolume;

  // ────────── Sound Effects ──────────
  Future<void> playSfx(String name) async {
    if (!_sfxOn) return;
    try {
      await _sfx.play(AssetSource('sounds/$name.mp3'));
    } catch (_) {}
  }

  void toggleSfx(bool on) => _sfxOn = on;
  bool get isSfxOn => _sfxOn;

  // ────────── Cleanup ──────────
  Future<void> dispose() async {
    await _bgm.dispose();
    await _sfx.dispose();
  }

  Future<void> pauseBgm() async {
    if (_isBgmPlaying) {
      await _bgm.pause();
      _isBgmPlaying = false;
    }
  }

  Future<void> resumeBgm() async {
    if (_musicOn && !_isBgmPlaying) {
      await _bgm.resume();
      _isBgmPlaying = true;
    }
  }
}