import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../audio/audio_controller.dart';
import '../data/history_repo.dart';
import '../engine/timer_engine.dart';
import '../models/flow_models.dart';
import '../theme.dart';

class PlayerScreen extends StatefulWidget {
  final FlowPreset preset;
  const PlayerScreen({super.key, required this.preset});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late final TimerEngine _engine;
  late final AnimationController _uiTicker;
  final AudioController _audio = AudioController();

  String _lastLabel = '';
  int _lastSegmentIndex = -1;
  bool _labelBright = true;
  bool _completed = false;
  Timer? _fadeTimer;

  @override
  void initState() {
    super.initState();
    _uiTicker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _engine = TimerEngine(widget.preset);
    _engine.addListener(_onEngineUpdate);
    _uiTicker.repeat();
    // Ensure audio is ready before starting the engine,
    // so the first segment announcement doesn't race.
    _audio.start().then((_) {
      if (mounted) _engine.start();
    });
  }

  void _onEngineUpdate() {
    if (_engine.state == TimerState.completed && !_completed) {
      _completed = true;
      _uiTicker.stop();
      _audio.fadeOutAndStop();
      HistoryRepo.log(widget.preset.title);
      setState(() {});
      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
      return;
    }

    // Sync ticker to engine state.
    if (_engine.state == TimerState.running && !_uiTicker.isAnimating) {
      _uiTicker.repeat();
      _audio.resume();
    } else if (_engine.state != TimerState.running && _uiTicker.isAnimating) {
      _uiTicker.stop();
      _audio.pause();
    }

    // Detect segment change — play voice clip + set breath pattern.
    final idx = _engine.currentSegmentIndex;
    if (idx != _lastSegmentIndex) {
      _lastSegmentIndex = idx;
      final seg = _engine.segments[idx];
      if (seg.audioKey != null) {
        _audio.playVoice(seg.audioKey!);
      }
      if (_engine.currentSegmentType == SegmentType.work) {
        _audio.setBreathPattern(_engine.currentSegmentLabel);
      } else {
        _audio.clearBreathPattern();
      }
    }

    // Check breath cue phase from elapsed time (drift-free).
    if (_engine.currentSegmentType == SegmentType.work) {
      final seg = _engine.segments[_engine.currentSegmentIndex];
      final elapsed = _engine.progressInSegment * seg.durationSec;
      _audio.checkBreathCue(elapsed);
    }

    // Label fade logic.
    final label = _engine.currentSegmentLabel;
    if (label != _lastLabel) {
      _lastLabel = label;
      _fadeTimer?.cancel();
      setState(() => _labelBright = true);
      _fadeTimer = Timer(const Duration(milliseconds: 2500), () {
        if (mounted) setState(() => _labelBright = false);
      });
    }
  }

  Future<void> _confirmExit() async {
    _engine.pause();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Exit flow?', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Your session will end.',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _engine.stop();
      await _audio.fadeOutAndStop();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (mounted) {
      _engine.resume();
    }
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    _engine.removeListener(_onEngineUpdate);
    _engine.dispose();
    _uiTicker.dispose();
    _audio.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('9 minutes.', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text('Done.', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: exit + voice/mute ──
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 4, right: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _confirmExit,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary.withOpacity(0.45),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Exit'),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () async {
                          await _audio.toggleVoice();
                          setState(() {});
                        },
                        icon: Icon(
                          _audio.voiceEnabled
                              ? Icons.record_voice_over
                              : Icons.voice_over_off,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                          size: 22,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await _audio.toggleMute();
                          setState(() {});
                        },
                        icon: Icon(
                          _audio.muted ? Icons.volume_off : Icons.volume_up,
                          color: AppTheme.textSecondary.withOpacity(0.6),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(flex: 3),

            // ── Smooth ring ──
            AnimatedBuilder(
              animation: _uiTicker,
              builder: (context, _) {
                return SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(260, 260),
                        painter: _RingPainter(
                          progress: _engine.progressInSegment,
                        ),
                      ),
                      Text(
                        _formatTime(_engine.remainingInSegmentSec),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w200,
                          color: AppTheme.textPrimary,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // ── Label ──
            AnimatedOpacity(
              opacity: _labelBright ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 800),
              child: Text(
                _engine.currentSegmentLabel,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),

            const SizedBox(height: 12),

            // ── Total time ──
            ListenableBuilder(
              listenable: _engine,
              builder: (context, _) => Text(
                _formatTime(_engine.totalRemainingSec),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            const Spacer(flex: 3),

            // ── Pause / Resume ──
            ListenableBuilder(
              listenable: _engine,
              builder: (context, _) {
                final isRunning = _engine.state == TimerState.running;
                return IconButton(
                  iconSize: 56,
                  onPressed: isRunning ? _engine.pause : _engine.resume,
                  icon: Icon(
                    isRunning
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: AppTheme.accentCyan,
                    size: 56,
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 6.0;

    final trackPaint = Paint()
      ..color = AppTheme.textSecondary.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final arcPaint = Paint()
      ..color = AppTheme.accentCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
