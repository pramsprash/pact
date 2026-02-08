import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/flow_models.dart';

enum TimerState { idle, running, paused, completed }

class TimerEngine extends ChangeNotifier {
  final List<Segment> _segments;
  final int _totalMs;

  /// Cumulative end time in ms for each segment.
  /// _cumulativeMs[i] = sum of durations for segments 0..i
  final List<int> _cumulativeMs;

  TimerState _state = TimerState.idle;

  /// Total milliseconds elapsed in previous running stretches.
  int _accumulatedMs = 0;

  /// Timestamp when the current running stretch began.
  DateTime? _resumeTimestamp;

  /// Periodic timer that drives UI updates (does NOT track time).
  Timer? _ticker;

  TimerEngine(FlowPreset preset)
      : _segments = preset.buildSegments(),
        _totalMs = preset.buildSegments().fold(
              0,
              (sum, s) => sum + s.durationSec * 1000,
            ),
        _cumulativeMs = _buildCumulativeMs(preset.buildSegments());

  static List<int> _buildCumulativeMs(List<Segment> segments) {
    final list = <int>[];
    var sum = 0;
    for (final s in segments) {
      sum += s.durationSec * 1000;
      list.add(sum);
    }
    return list;
  }

  // ---------------------------------------------------------------------------
  // Derived state
  // ---------------------------------------------------------------------------

  TimerState get state => _state;

  int get _elapsedMs {
    if (_resumeTimestamp == null) return _accumulatedMs;
    final now = DateTime.now();
    return _accumulatedMs +
        now.difference(_resumeTimestamp!).inMilliseconds;
  }

  int get _clampedElapsedMs => _elapsedMs.clamp(0, _totalMs);

  int get _currentIndex {
    final elapsed = _clampedElapsedMs;
    for (var i = 0; i < _cumulativeMs.length; i++) {
      if (elapsed < _cumulativeMs[i]) return i;
    }
    return _segments.length - 1;
  }

  int _segmentStartMs(int index) {
    if (index <= 0) return 0;
    return _cumulativeMs[index - 1];
  }

  String get currentSegmentLabel {
    if (_state == TimerState.idle) return _segments.first.label;
    if (_state == TimerState.completed) return _segments.last.label;
    return _segments[_currentIndex].label;
  }

  SegmentType get currentSegmentType {
    if (_state == TimerState.idle) return _segments.first.type;
    if (_state == TimerState.completed) return _segments.last.type;
    return _segments[_currentIndex].type;
  }

  int get remainingInSegmentSec {
    if (_state == TimerState.idle) return _segments.first.durationSec;
    if (_state == TimerState.completed) return 0;
    final idx = _currentIndex;
    final endMs = _cumulativeMs[idx];
    final remaining = endMs - _clampedElapsedMs;
    return (remaining / 1000).ceil();
  }

  int get totalRemainingSec {
    if (_state == TimerState.idle) return _totalMs ~/ 1000;
    if (_state == TimerState.completed) return 0;
    final remaining = _totalMs - _clampedElapsedMs;
    return (remaining / 1000).ceil();
  }

  /// 0.0 = segment just started, 1.0 = segment finished.
  double get progressInSegment {
    if (_state == TimerState.idle) return 0.0;
    if (_state == TimerState.completed) return 1.0;
    final idx = _currentIndex;
    final startMs = _segmentStartMs(idx);
    final durationMs = _segments[idx].durationSec * 1000;
    if (durationMs == 0) return 1.0;
    final elapsed = _clampedElapsedMs - startMs;
    return (elapsed / durationMs).clamp(0.0, 1.0);
  }

  int get currentSegmentIndex {
    if (_state == TimerState.idle) return 0;
    if (_state == TimerState.completed) return _segments.length - 1;
    return _currentIndex;
  }

  List<Segment> get segments => List.unmodifiable(_segments);

  // ---------------------------------------------------------------------------
  // Controls
  // ---------------------------------------------------------------------------

  void start() {
    if (_state == TimerState.running) return;
    _accumulatedMs = 0;
    _resumeTimestamp = DateTime.now();
    _state = TimerState.running;
    _startTicker();
    notifyListeners();
  }

  void pause() {
    if (_state != TimerState.running) return;
    // Freeze elapsed time.
    _accumulatedMs = _elapsedMs;
    _resumeTimestamp = null;
    _state = TimerState.paused;
    _stopTicker();
    notifyListeners();
  }

  void resume() {
    if (_state != TimerState.paused) return;
    _resumeTimestamp = DateTime.now();
    _state = TimerState.running;
    _startTicker();
    notifyListeners();
  }

  void stop() {
    _stopTicker();
    _accumulatedMs = 0;
    _resumeTimestamp = null;
    _state = TimerState.idle;
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  void _startTicker() {
    _stopTicker();
    // Tick every 200ms — enough for smooth countdown, low overhead.
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_clampedElapsedMs >= _totalMs) {
        _complete();
        return;
      }
      notifyListeners();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _complete() {
    _stopTicker();
    _accumulatedMs = _totalMs;
    _resumeTimestamp = null;
    _state = TimerState.completed;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
