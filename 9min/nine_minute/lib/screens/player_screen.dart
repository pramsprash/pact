import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../audio/audio_controller.dart';
import '../audio/breath_scheduler.dart';
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
  late final BreathScheduler _breathScheduler;

  // ── Segment tracking (dedup guard) ──
  int _lastSegmentIndex = -1;

  // ── Pose image ──
  /// Path persists across segment changes so the fade-out can render.
  String _poseImagePath = '';
  bool _poseVisible = false;

  // ── Transition voice sequencing ──
  Timer? _transitionVoiceTimer;
  bool _comingFromOpening = false;

  // ── Label fade ──
  String _lastLabel = '';
  bool _labelBright = true;
  Timer? _fadeTimer;

  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _breathScheduler = BreathScheduler(_audio);
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

  // ---------------------------------------------------------------------------
  // Engine listener
  // ---------------------------------------------------------------------------

  void _onEngineUpdate() {
    // ── Completion ──
    if (_engine.state == TimerState.completed && !_completed) {
      _completed = true;
      _uiTicker.stop();
      _breathScheduler.stop();
      _transitionVoiceTimer?.cancel();
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

    // ── Pause / Resume sync ──
    if (_engine.state == TimerState.running && !_uiTicker.isAnimating) {
      _uiTicker.repeat();
      _audio.resume();
      _breathScheduler.resume();
    } else if (_engine.state != TimerState.running && _uiTicker.isAnimating) {
      _uiTicker.stop();
      _transitionVoiceTimer?.cancel();
      _breathScheduler.pause();
      _audio.stopVoice();
      _audio.pause();
    }

    // ── Segment change (dedup by index) ──
    final idx = _engine.currentSegmentIndex;
    if (idx != _lastSegmentIndex) {
      _lastSegmentIndex = idx;
      final seg = _engine.segments[idx];
      _transitionVoiceTimer?.cancel();

      switch (seg.type) {
        case SegmentType.work:
          _onWorkSegment(seg);
          break;
        case SegmentType.transition:
          _onTransitionSegment(seg);
          break;
        case SegmentType.opening:
          _onOpeningSegment(seg);
          break;
        case SegmentType.rest:
          _onRestSegment();
          break;
      }
    }

    // ── Label fade ──
    final label = _engine.currentSegmentLabel;
    if (label != _lastLabel) {
      _lastLabel = label;
      _fadeTimer?.cancel();
      setState(() => _labelBright = true);
      _fadeTimer = Timer(const Duration(milliseconds: 3000), () {
        if (mounted) setState(() => _labelBright = false);
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Segment handlers
  // ---------------------------------------------------------------------------

  void _onWorkSegment(Segment seg) {
    final step = seg.step!;
    // Skip voice if the opening segment already announced this movement.
    // On iOS, rapid stop→setAsset→play on the same key fails silently.
    if (!_comingFromOpening) {
      _audio.playVoiceKey(step.moveVoiceKey);
    }
    _comingFromOpening = false;
    setState(() {
      _poseImagePath = step.stepImageAsset;
      _poseVisible = true;
    });
    _breathScheduler.startForSegment(seg, DateTime.now(), seg.durationSec);
  }

  void _onTransitionSegment(Segment seg) {
    _breathScheduler.stop();
    setState(() => _poseVisible = false);
    _audio.playVoiceKey('transition');
    if (seg.nextStep != null) {
      _transitionVoiceTimer = Timer(
        const Duration(milliseconds: 1500),
        () {
          if (mounted) _audio.playVoiceKey(seg.nextStep!.moveVoiceKey);
        },
      );
    }
  }

  void _onOpeningSegment(Segment seg) {
    _breathScheduler.stop();
    _comingFromOpening = true;
    setState(() => _poseVisible = false);
    if (seg.audioKey != null) {
      _audio.playVoiceKey(seg.audioKey!);
    }
    // Pre-announce the first movement, just like transitions do.
    // Longer delay than transitions — gives "Get Ready" time to finish.
    if (seg.nextStep != null) {
      _transitionVoiceTimer = Timer(
        const Duration(milliseconds: 2500),
        () {
          if (mounted) _audio.playVoiceKey(seg.nextStep!.moveVoiceKey);
        },
      );
    }
  }

  void _onRestSegment() {
    _breathScheduler.stop();
    setState(() => _poseVisible = false);
  }

  // ---------------------------------------------------------------------------
  // Exit
  // ---------------------------------------------------------------------------

  Future<void> _confirmExit() async {
    _engine.pause();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Exit flow?',
            style: TextStyle(color: AppTheme.textPrimary)),
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
      _breathScheduler.stop();
      _transitionVoiceTimer?.cancel();
      await _audio.fadeOutAndStop();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (mounted) {
      _engine.resume();
    }
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _fadeTimer?.cancel();
    _transitionVoiceTimer?.cancel();
    _breathScheduler.stop();
    _engine.removeListener(_onEngineUpdate);
    _engine.dispose();
    _uiTicker.dispose();
    _audio.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return Scaffold(
        body: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 800),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('9 minutes.', style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.textPrimary,
                )),
                const SizedBox(height: 10),
                Text('Done.', style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.textPrimary.withOpacity(0.8),
                )),
              ],
            ),
          ),
        ),
      );
    }

    final seg = _engine.state != TimerState.idle
        ? _engine.segments[_engine.currentSegmentIndex]
        : _engine.segments.first;

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
                      foregroundColor:
                          AppTheme.textSecondary.withOpacity(0.45),
                      textStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w400),
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

            const Spacer(flex: 2),

            // ── Pose image (centered above ring, fades on change) ──
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: _poseVisible && _poseImagePath.isNotEmpty
                  ? Center(
                      key: ValueKey(_poseImagePath),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.55,
                        height: MediaQuery.of(context).size.height * 0.22,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.asset(
                            _poseImagePath,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(
                      key: ValueKey('empty'),
                      height: 40,
                    ),
            ),

            const SizedBox(height: 20),

            // ── Smooth ring ──
            AnimatedBuilder(
              animation: _uiTicker,
              builder: (context, _) {
                return SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(220, 220),
                        painter: _RingPainter(
                          progress: _engine.progressInSegment,
                        ),
                      ),
                      Text(
                        _formatTime(_engine.remainingInSegmentSec),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 44,
                          fontWeight: FontWeight.w200,
                          color: AppTheme.textPrimary,
                          letterSpacing: 2,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ── Movement label ──
            AnimatedOpacity(
              opacity: _labelBright ? 1.0 : 0.6,
              duration: const Duration(milliseconds: 800),
              child: _buildLabelText(seg),
            ),

            const SizedBox(height: 12),

            // ── Total time ──
            ListenableBuilder(
              listenable: _engine,
              builder: (context, _) => Text(
                _formatTime(_engine.totalRemainingSec),
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
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
                        ? Icons.pause_circle_outlined
                        : Icons.play_circle_outlined,
                    color: AppTheme.textSecondary.withOpacity(0.5),
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

  /// Centred label text — layout never changes width, preventing jumps.
  Widget _buildLabelText(Segment seg) {
    final label = _engine.currentSegmentLabel;

    if (seg.type == SegmentType.transition && seg.nextStep != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Next: ${seg.nextStep!.name}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w300,
              color: AppTheme.textSecondary.withOpacity(0.6),
            ),
          ),
        ],
      );
    }

    return Text(label, style: Theme.of(context).textTheme.headlineMedium);
  }

}

// ---------------------------------------------------------------------------
// Ring painter (unchanged)
// ---------------------------------------------------------------------------

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 6.0;

    final trackPaint = Paint()
      ..color = AppTheme.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final arcPaint = Paint()
      ..color = AppTheme.textPrimary
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
