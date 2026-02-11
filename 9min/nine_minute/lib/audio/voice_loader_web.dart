import 'dart:async';
import 'dart:html' as html;

/// Web implementation — reads voices directly from the browser's
/// SpeechSynthesis API and waits for the `voiceschanged` event
/// that Chrome fires asynchronously.
Future<List<Map<String, String>>> loadPlatformVoices() async {
  final synth = html.window.speechSynthesis;
  if (synth == null) return [];

  var voices = synth.getVoices();

  // Chrome loads voices asynchronously. If the list is empty,
  // wait for the voiceschanged event (with a timeout).
  if (voices.isEmpty) {
    final completer = Completer<void>();
    late final void Function(html.Event) listener;
    listener = (html.Event _) {
      synth.removeEventListener('voiceschanged', listener);
      if (!completer.isCompleted) completer.complete();
    };
    synth.addEventListener('voiceschanged', listener);

    try {
      await completer.future.timeout(const Duration(seconds: 3));
    } catch (_) {
      synth.removeEventListener('voiceschanged', listener);
    }
    voices = synth.getVoices();
  }

  return voices.map((v) => {
    'name': v.name ?? '',
    'locale': v.lang ?? '',
  }).where((v) => v['name']!.isNotEmpty).toList();
}
