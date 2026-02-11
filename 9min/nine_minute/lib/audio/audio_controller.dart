import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tts_service.dart';

class AudioController {
  // Three independent players — ambient, voice announcements, breath cues.
  final AudioPlayer _ambient = AudioPlayer();
  final AudioPlayer _voice = AudioPlayer();
  final AudioPlayer _breath = AudioPlayer();

  final TtsService _tts = TtsService();
  TtsService get ttsService => _tts;

  // Ambient is the loudest layer; voice sits just underneath.
  static const _ambientVolume = 0.50;
  static const _voiceVolume = 0.40;
  static const _breathVolume = 0.40;

  bool _muted = false;
  bool get muted => _muted;

  bool _voiceEnabled = true;
  bool get voiceEnabled => _voiceEnabled;

  static const _mutePrefKey = 'ambient_muted';
  static const _voicePrefKey = 'voice_enabled';

  // ---------------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------------

  Future<void> start() async {
    final prefs = await SharedPreferences.getInstance();
    _muted = prefs.getBool(_mutePrefKey) ?? false;
    _voiceEnabled = prefs.getBool(_voicePrefKey) ?? true;
    await _voice.setVolume(_voiceVolume);
    await _breath.setVolume(_breathVolume);
    await _ambient.setVolume(_muted ? 0.0 : _ambientVolume);
    await _tts.init();
  }

  // ---------------------------------------------------------------------------
  // Ambient loop
  // ---------------------------------------------------------------------------

  Future<void> startAmbientLoop(String assetPath) async {
    if (_muted) return;
    try {
      await _ambient.setAsset(assetPath);
      await _ambient.setLoopMode(LoopMode.one);
      await _ambient.setVolume(_ambientVolume);
      _ambient.play(); // fire-and-forget
    } catch (_) {}
  }

  Future<void> stopAmbientLoop({bool fade = false}) async {
    if (fade) {
      // Quick 500 ms linear fade.
      const steps = 10;
      final current = _ambient.volume;
      for (var i = steps; i >= 0; i--) {
        await _ambient.setVolume(current * i / steps);
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
    await _ambient.stop();
  }

  // ---------------------------------------------------------------------------
  // Voice announcements
  // ---------------------------------------------------------------------------

  /// Play a voice clip by key → assets/voice/<key>.wav.
  /// Stops any prior clip first (no overlap). Fire-and-forget.
  Future<void> playVoiceKey(String key) async {
    if (_muted || !_voiceEnabled) return;
    if (_tts.isActive) {
      await _tts.speak(key);
      return;
    }
    try {
      await _voice.stop();
      await _voice.setAsset('assets/voice/$key.wav');
      await _voice.setVolume(_voiceVolume);
      await _voice.play();
    } catch (_) {}
  }

  /// Immediately stop any active voice playback.
  Future<void> stopVoice() async {
    await _voice.stop();
    await _tts.stop();
  }

  // ---------------------------------------------------------------------------
  // Breath cues
  // ---------------------------------------------------------------------------

  Future<void> playInhale() async {
    if (_muted || !_voiceEnabled) return;
    if (_tts.isActive) {
      await _tts.speak('inhale');
      return;
    }
    try {
      await _breath.stop();
      await _breath.setAsset('assets/voice/inhale.wav');
      await _breath.setVolume(_breathVolume);
      _breath.play(); // fire-and-forget
    } catch (_) {}
  }

  Future<void> playExhale() async {
    if (_muted || !_voiceEnabled) return;
    if (_tts.isActive) {
      await _tts.speak('exhale');
      return;
    }
    try {
      await _breath.stop();
      await _breath.setAsset('assets/voice/exhale.wav');
      await _breath.setVolume(_breathVolume);
      _breath.play(); // fire-and-forget
    } catch (_) {}
  }

  /// Immediately stop any playing breath clip (called by BreathScheduler).
  Future<void> stopBreath() async {
    await _breath.stop();
    await _tts.stop();
  }

  // ---------------------------------------------------------------------------
  // Transport
  // ---------------------------------------------------------------------------

  Future<void> fadeOutAndStop() async {
    await stopAmbientLoop(fade: true);
    await _voice.stop();
    await _breath.stop();
    await _tts.stop();
  }

  Future<void> pause() async {
    await _ambient.pause();
    await _voice.stop();
    await _breath.stop();
    await _tts.stop();
  }

  Future<void> resume() async {
    if (!_muted) {
      _ambient.play(); // resume loop if it was loaded
    }
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    if (_muted) {
      await _ambient.setVolume(0.0);
      await _voice.stop();
      await _breath.stop();
      await _tts.stop();
    } else {
      await _ambient.setVolume(_ambientVolume);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mutePrefKey, _muted);
  }

  Future<void> toggleVoice() async {
    _voiceEnabled = !_voiceEnabled;
    if (!_voiceEnabled) {
      await _voice.stop();
      await _breath.stop();
      await _tts.stop();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_voicePrefKey, _voiceEnabled);
  }

  Future<void> dispose() async {
    await _ambient.stop();
    await _voice.stop();
    await _breath.stop();
    await _tts.dispose();
    await _ambient.dispose();
    await _voice.dispose();
    await _breath.dispose();
  }
}
