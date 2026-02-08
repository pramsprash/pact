import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/session_timer.dart';
import '../widgets/breath_circle.dart';
import '../theme.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _breathController;
  late final SessionTimer _sessionTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _sessionTimer = SessionTimer()..start();
    _sessionTimer.addListener(_onTimerTick);
  }

  void _onTimerTick() {
    if (_sessionTimer.isComplete && !_navigated) {
      _navigated = true;
      Navigator.pushReplacementNamed(context, '/complete');
    }
  }

  @override
  void dispose() {
    _sessionTimer.removeListener(_onTimerTick);
    _sessionTimer.dispose();
    _breathController.dispose();
    super.dispose();
  }

  String get _phaseLabel {
    // forward = inhale (value going 0→1), reverse = exhale (value going 1→0)
    if (_breathController.status == AnimationStatus.forward) {
      return 'Breathe in';
    }
    return 'Breathe out';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Breath circle
                  AnimatedBuilder(
                    animation: _breathController,
                    builder: (context, _) {
                      return BreathCircle(
                        animationValue: _breathController.value,
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  // Phase label
                  AnimatedBuilder(
                    animation: _breathController,
                    builder: (context, _) {
                      return Text(
                        _phaseLabel,
                        style: Theme.of(context).textTheme.headlineMedium,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Timer display
                  ListenableBuilder(
                    listenable: _sessionTimer,
                    builder: (context, _) {
                      return Text(
                        _sessionTimer.formattedTime,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontFeatures: [
                                const FontFeature.tabularFigures()
                              ],
                            ),
                      );
                    },
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
            // Exit button
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  color: AppTheme.textSecondary.withOpacity(0.6),
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
