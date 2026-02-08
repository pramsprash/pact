import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BreathPattern {
  final double inhaleSec;
  final double exhaleSec;
  double get cycleSec => inhaleSec + exhaleSec;
  const BreathPattern({required this.inhaleSec, required this.exhaleSec});
}

class AudioController {
  final AudioPlayer _voice = AudioPlayer();
  final AudioPlayer _breath = AudioPlayer();

  bool _muted = false;
  bool get muted => _muted;

  bool _voiceEnabled = true;
  bool get voiceEnabled => _voiceEnabled;

  static const _voiceVolume = 0.85;
  static const _breathVolume = 0.7;
  static const _mutePrefKey = 'ambient_muted';
  static const _voicePrefKey = 'voice_enabled';

  /// Breath cue patterns for each movement.
  static const breathPatterns = <String, BreathPattern>{
    // Ground to Rise
    'Cloud Sweep': BreathPattern(inhaleSec: 4, exhaleSec: 6),
    'Hip Rounds': BreathPattern(inhaleSec: 4, exhaleSec: 6),
    'Lift & Stillness': BreathPattern(inhaleSec: 4, exhaleSec: 6),
    // Spine & Strength
    'Gentle Cat–Cow': BreathPattern(inhaleSec: 4, exhaleSec: 6),
    'Tabletop Lift': BreathPattern(inhaleSec: 4, exhaleSec: 6),
    'Wave Bridge': BreathPattern(inhaleSec: 4, exhaleSec: 6),
    // Length & Release
    'Supine Twist': BreathPattern(inhaleSec: 4, exhaleSec: 8),
    'Spine Curl': BreathPattern(inhaleSec: 4, exhaleSec: 6),
    'Child Pose': BreathPattern(inhaleSec: 4, exhaleSec: 8),
  };

  BreathPattern? _activePattern;
  String? _lastBreathPhase;

  Future<void> start() async {
    final prefs = await SharedPreferences.getInstance();
    _muted = prefs.getBool(_mutePrefKey) ?? false;
    _voiceEnabled = prefs.getBool(_voicePrefKey) ?? true;
    await _voice.setVolume(_voiceVolume);
    await _breath.setVolume(_breathVolume);
  }

  /// Play a voice clip by audioKey. Stops any prior clip first.
  /// Does NOT await play() — fire-and-forget so it never blocks the caller
  /// or races with subsequent calls.
  Future<void> playVoice(String audioKey) async {
    if (_muted || !_voiceEnabled) return;
    try {
      await _voice.stop();
      await _voice.setAsset('assets/voice/$audioKey.wav');
      await _voice.setVolume(_voiceVolume);
      await _voice.seek(Duration.zero);
      _voice.play(); // fire-and-forget — don't await
    } catch (_) {
      // Asset missing — fail silently.
    }
  }

  Future<void> stopVoice() async {
    await _voice.stop();
  }

  // ---------------------------------------------------------------------------
  // Breath cues — driven by elapsed time, played via offline clips.
  // ---------------------------------------------------------------------------

  void setBreathPattern(String segmentLabel) {
    _activePattern = breathPatterns[segmentLabel];
    _lastBreathPhase = null;
  }

  void clearBreathPattern() {
    _activePattern = null;
    _lastBreathPhase = null;
  }

  /// Skip breath cues for the first 4 seconds so the movement name
  /// announcement can finish without overlap.
  static const _breathDelaySeconds = 4.0;

  void checkBreathCue(double elapsedInSegmentSec) {
    if (_muted || !_voiceEnabled || _activePattern == null) return;
    if (elapsedInSegmentSec < _breathDelaySeconds) return;

    final p = _activePattern!;
    final adjusted = elapsedInSegmentSec - _breathDelaySeconds;
    final cyclePos = adjusted % p.cycleSec;
    final phase = cyclePos < p.inhaleSec ? 'inhale' : 'exhale';

    if (phase != _lastBreathPhase) {
      _lastBreathPhase = phase;
      _playBreathClip(phase);
    }
  }

  Future<void> _playBreathClip(String phase) async {
    try {
      await _breath.stop();
      final asset = phase == 'inhale'
          ? 'assets/voice/inhale.wav'
          : 'assets/voice/exhale.wav';
      await _breath.setAsset(asset);
      await _breath.setVolume(_breathVolume);
      await _breath.play();
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Transport
  // ---------------------------------------------------------------------------

  Future<void> fadeOutAndStop() async {
    clearBreathPattern();
    await _voice.stop();
    await _breath.stop();
  }

  Future<void> pause() async {
    await _voice.stop();
    await _breath.stop();
  }

  Future<void> resume() async {
    // Voice only plays on segment boundaries — nothing to resume.
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    if (_muted) {
      await _voice.stop();
      await _breath.stop();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mutePrefKey, _muted);
  }

  Future<void> toggleVoice() async {
    _voiceEnabled = !_voiceEnabled;
    if (!_voiceEnabled) {
      await _voice.stop();
      await _breath.stop();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_voicePrefKey, _voiceEnabled);
  }

  Future<void> dispose() async {
    clearBreathPattern();
    await _voice.stop();
    await _breath.stop();
    await _voice.dispose();
    await _breath.dispose();
  }
}
