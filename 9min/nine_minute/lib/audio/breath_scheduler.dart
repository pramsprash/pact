import 'dart:async';
import '../models/flow_models.dart';
import 'audio_controller.dart';

/// Timestamp-driven inhale / exhale scheduler for work segments.
///
/// Uses wall-clock timestamps so cue timing never drifts, regardless of
/// how often the caller ticks or how long UI frames take.
///
/// Timing rules (from breathProfile on the segment's FlowStep):
///   "dynamic" → 4 s inhale / 4 s exhale  (8 s cycle)
///   "hold"    → 4 s inhale / 6 s exhale  (10 s cycle)
///
/// The first cue is delayed by [_announcementDelayMs] so the movement-name
/// voice clip can finish without overlap.
class BreathScheduler {
  final AudioController _audio;

  BreathScheduler(this._audio);

  // ── Breath timing (set per-segment) ──────────────────────────────────────
  double _inhaleSec = 4;
  double _exhaleSec = 4;
  double get _cycleMs => (_inhaleSec + _exhaleSec) * 1000;
  double get _inhaleMs => _inhaleSec * 1000;

  /// Delay before first cue so the movement-name announcement can play.
  static const _announcementDelayMs = 4000;

  // ── Timestamp tracking (drift-free) ──────────────────────────────────────
  /// Wall-clock time when the current running stretch began (null = paused).
  DateTime? _resumeTimestamp;

  /// Milliseconds elapsed in previous running stretches (frozen on pause).
  int _accumulatedMs = 0;

  /// Total duration of the current segment in ms.
  int _segmentDurationMs = 0;

  Timer? _pending;
  bool _active = false;
  String? _lastPhase;

  /// Current elapsed ms within the segment, accounting for pauses.
  int get _elapsedMs {
    if (_resumeTimestamp == null) return _accumulatedMs;
    return _accumulatedMs +
        DateTime.now().difference(_resumeTimestamp!).inMilliseconds;
  }

  // ── Public API ───────────────────────────────────────────────────────────

  /// Begin scheduling breath cues for [segment].
  ///
  /// [segmentStartTime] is the wall-clock instant the segment began (so we
  /// can account for any time already elapsed if called slightly late).
  /// [segmentDurationSec] caps cues — none fire after the segment ends.
  ///
  /// Only schedules for [SegmentType.work] segments that carry a FlowStep.
  void startForSegment(
    Segment segment,
    DateTime segmentStartTime,
    int segmentDurationSec,
  ) {
    stop();

    if (segment.type != SegmentType.work || segment.step == null) return;

    // Choose pattern from breathProfile.
    final profile = segment.step!.breathProfile;
    if (profile == 'dynamic') {
      _inhaleSec = 4;
      _exhaleSec = 4;
    } else {
      // "hold" or any future profile
      _inhaleSec = 4;
      _exhaleSec = 6;
    }

    _segmentDurationMs = segmentDurationSec * 1000;

    // Account for time already elapsed since the segment actually started.
    _accumulatedMs = DateTime.now()
        .difference(segmentStartTime)
        .inMilliseconds
        .clamp(0, _segmentDurationMs);
    _resumeTimestamp = DateTime.now();
    _active = true;
    _lastPhase = null;

    _scheduleNextCue();
  }

  /// Cancel all scheduling and silence any playing breath clip.
  void stop() {
    _active = false;
    _pending?.cancel();
    _pending = null;
    _lastPhase = null;
  }

  /// Freeze the schedule and stop any playing breath clip.
  void pause() {
    if (!_active) return;
    // Freeze elapsed time.
    _accumulatedMs = _elapsedMs;
    _resumeTimestamp = null;
    _pending?.cancel();
    _pending = null;
    _audio.stopBreath();
  }

  /// Resume the schedule from where it was paused.
  /// Does NOT replay the movement-name announcement.
  void resume() {
    if (!_active) return;
    _resumeTimestamp = DateTime.now();
    _scheduleNextCue();
  }

  // ── Internal scheduling ──────────────────────────────────────────────────

  void _scheduleNextCue() {
    if (!_active) return;

    final elapsed = _elapsedMs;
    if (elapsed >= _segmentDurationMs) {
      stop();
      return;
    }

    // Still inside the announcement delay — wait for it to end.
    if (elapsed < _announcementDelayMs) {
      final waitMs = _announcementDelayMs - elapsed;
      _pending = Timer(Duration(milliseconds: waitMs), _onTimerFire);
      return;
    }

    // Compute position within the breath cycle.
    final breathElapsed = (elapsed - _announcementDelayMs).toDouble();
    final posInCycle = breathElapsed % _cycleMs;

    String phase;
    int msToNextBoundary;

    if (posInCycle < _inhaleMs) {
      phase = 'inhale';
      msToNextBoundary = (_inhaleMs - posInCycle).ceil();
    } else {
      phase = 'exhale';
      msToNextBoundary = (_cycleMs - posInCycle).ceil();
    }

    // Fire immediately if we haven't announced this phase yet.
    if (phase != _lastPhase) {
      _fireCue(phase);
    }

    // Clamp so we don't schedule past the segment end.
    final remaining = _segmentDurationMs - elapsed;
    if (msToNextBoundary > remaining) {
      // No more cues in this segment.
      _pending = Timer(Duration(milliseconds: remaining), stop);
      return;
    }

    _pending = Timer(Duration(milliseconds: msToNextBoundary), _onTimerFire);
  }

  void _onTimerFire() {
    if (!_active) return;

    final elapsed = _elapsedMs;
    if (elapsed >= _segmentDurationMs) {
      stop();
      return;
    }
    if (elapsed < _announcementDelayMs) {
      _scheduleNextCue();
      return;
    }

    final breathElapsed = (elapsed - _announcementDelayMs).toDouble();
    final posInCycle = breathElapsed % _cycleMs;
    final phase = posInCycle < _inhaleMs ? 'inhale' : 'exhale';

    _fireCue(phase);
    _scheduleNextCue();
  }

  void _fireCue(String phase) {
    if (phase == _lastPhase) return;
    _lastPhase = phase;
    if (phase == 'inhale') {
      _audio.playInhale();
    } else {
      _audio.playExhale();
    }
  }
}
