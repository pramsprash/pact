import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioController {
  final AudioPlayer _voice = AudioPlayer();

  bool _muted = false;
  bool get muted => _muted;

  bool _voiceEnabled = true;
  bool get voiceEnabled => _voiceEnabled;

  static const _voiceVolume = 0.85;
  static const _mutePrefKey = 'ambient_muted';
  static const _voicePrefKey = 'voice_enabled';

  Future<void> start() async {
    final prefs = await SharedPreferences.getInstance();
    _muted = prefs.getBool(_mutePrefKey) ?? false;
    _voiceEnabled = prefs.getBool(_voicePrefKey) ?? true;
    await _voice.setVolume(_voiceVolume);
  }

  /// Play a voice clip by audioKey. Stops any prior clip first.
  Future<void> playVoice(String audioKey) async {
    if (_muted || !_voiceEnabled) return;
    try {
      await _voice.stop();
      await _voice.setAsset('assets/voice/$audioKey.wav');
      await _voice.setVolume(_voiceVolume);
      await _voice.play();
    } catch (_) {
      // Asset missing — fail silently.
    }
  }

  Future<void> stopVoice() async {
    await _voice.stop();
  }

  // ---------------------------------------------------------------------------
  // Transport
  // ---------------------------------------------------------------------------

  Future<void> fadeOutAndStop() async {
    await _voice.stop();
  }

  Future<void> pause() async {
    await _voice.stop();
  }

  Future<void> resume() async {
    // No ambient to resume — voice only plays on segment boundaries.
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    if (_muted) await _voice.stop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mutePrefKey, _muted);
  }

  Future<void> toggleVoice() async {
    _voiceEnabled = !_voiceEnabled;
    if (!_voiceEnabled) await _voice.stop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_voicePrefKey, _voiceEnabled);
  }

  Future<void> dispose() async {
    await _voice.stop();
    await _voice.dispose();
  }
}
