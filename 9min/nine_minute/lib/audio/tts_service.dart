import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'voice_loader.dart' if (dart.library.html) 'voice_loader_web.dart';

/// Thin wrapper around FlutterTts for voice-cue playback.
///
/// When a TTS voice is selected the service speaks the human-readable text
/// that corresponds to each voice-key (e.g. `'cloud_sweep'` → `'Cloud Sweep'`).
/// When no voice is selected (`isActive == false`) the caller should fall back
/// to the bundled WAV files.
class TtsService {
  final FlutterTts _tts = FlutterTts();

  static const _prefVoiceName = 'tts_voice_name';
  static const _prefVoiceLocale = 'tts_voice_locale';

  String? _selectedVoiceName;
  String? _selectedVoiceLocale;

  /// `true` when a TTS voice has been chosen (null = Original / WAV mode).
  bool get isActive => _selectedVoiceName != null;

  String? get selectedVoiceName => _selectedVoiceName;

  // ---------------------------------------------------------------------------
  // Voice-key → spoken text map (all 23 WAV keys)
  // ---------------------------------------------------------------------------

  static const Map<String, String> voiceKeyText = {
    'get_ready': 'Get Ready',
    'transition': 'Transition',
    'cloud_sweep': 'Cloud Sweep',
    'hip_rounds': 'Hip Rounds',
    'lift_stillness': 'Lift Stillness',
    'cat_cow': 'Cat Cow',
    'side_bends': 'Side Bends',
    'wave_bridge': 'Wave Bridge',
    'supine_twist': 'Supine Twist',
    'knee_curl': 'Knee Curl',
    'child_pose': 'Child Pose',
    'inhale': 'Inhale',
    'exhale': 'Exhale',
    'transition_to_cloud_sweep': 'Transition to Cloud Sweep',
    'transition_to_hip_rounds': 'Transition to Hip Rounds',
    'transition_to_lift_stillness': 'Transition to Lift Stillness',
    'transition_to_cat_cow': 'Transition to Cat Cow',
    'transition_to_side_bends': 'Transition to Side Bends',
    'transition_to_wave_bridge': 'Transition to Wave Bridge',
    'transition_to_supine_twist': 'Transition to Supine Twist',
    'transition_to_knee_curl': 'Transition to Knee Curl',
    'transition_to_child_pose': 'Transition to Child Pose',
    'transition_to_rest': 'Transition to Rest',
  };

  // ---------------------------------------------------------------------------
  // Init — loads saved preference
  // ---------------------------------------------------------------------------

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedVoiceName = prefs.getString(_prefVoiceName);
    _selectedVoiceLocale = prefs.getString(_prefVoiceLocale);

    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);

    if (_selectedVoiceName != null) {
      await _applyVoice();
    }
  }

  // ---------------------------------------------------------------------------
  // Voice listing & selection
  // ---------------------------------------------------------------------------

  /// Returns system TTS voices as a list of `{name, locale}` maps.
  /// On web, reads directly from the browser SpeechSynthesis API
  /// (flutter_tts's getVoices doesn't wait for Chrome's async voice loading).
  /// On native, uses flutter_tts. English voices preferred; falls back to all.
  Future<List<Map<String, String>>> getAvailableVoices() async {
    // Try the web-specific loader first (no-op stub on native).
    var all = await loadPlatformVoices();

    // Fall back to flutter_tts (works on iOS / Android).
    if (all.isEmpty) {
      all = await _getVoicesFromPlugin();
    }

    // Prefer English voices; fall back to everything if none match.
    final english = all
        .where((v) => v['locale']!.toLowerCase().startsWith('en'))
        .toList();
    final voices = english.isNotEmpty ? english : all;

    voices.sort((a, b) => a['name']!.compareTo(b['name']!));
    return voices;
  }

  /// Read voices via the flutter_tts plugin (native platforms).
  Future<List<Map<String, String>>> _getVoicesFromPlugin() async {
    try {
      final raw = await _tts.getVoices;
      if (raw == null || raw is! List || raw.isEmpty) return [];

      final voices = <Map<String, String>>[];
      for (final v in raw) {
        try {
          if (v is! Map) continue;
          final name = v['name']?.toString() ?? '';
          final locale = v['locale']?.toString() ?? '';
          if (name.isEmpty) continue;
          voices.add({'name': name, 'locale': locale});
        } catch (_) {
          continue;
        }
      }
      return voices;
    } catch (_) {
      return [];
    }
  }

  /// Select a TTS voice. Pass `null` for both params to revert to Original.
  Future<void> selectVoice(String? name, String? locale) async {
    _selectedVoiceName = name;
    _selectedVoiceLocale = locale;

    final prefs = await SharedPreferences.getInstance();
    if (name == null) {
      await prefs.remove(_prefVoiceName);
      await prefs.remove(_prefVoiceLocale);
    } else {
      await prefs.setString(_prefVoiceName, name);
      await prefs.setString(_prefVoiceLocale, locale ?? '');
      await _applyVoice();
    }
  }

  Future<void> _applyVoice() async {
    if (_selectedVoiceName != null) {
      await _tts.setVoice({
        'name': _selectedVoiceName!,
        'locale': _selectedVoiceLocale ?? '',
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Speak & preview
  // ---------------------------------------------------------------------------

  /// Speak the text that corresponds to the given voice key.
  Future<void> speak(String voiceKey) async {
    final text = voiceKeyText[voiceKey];
    if (text == null) return;
    await _tts.speak(text);
  }

  /// Speak a sample phrase in the given voice (for the picker).
  Future<void> preview(String name, String locale) async {
    await _tts.setVoice({'name': name, 'locale': locale});
    await _tts.speak('Inhale. Exhale.');
    // Restore previously selected voice (if any) after preview.
    if (_selectedVoiceName != null) {
      await _applyVoice();
    }
  }

  // ---------------------------------------------------------------------------
  // Stop / dispose
  // ---------------------------------------------------------------------------

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}
