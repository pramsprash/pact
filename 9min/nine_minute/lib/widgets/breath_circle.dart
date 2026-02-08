import 'package:flutter/material.dart';
import '../theme.dart';

class BreathCircle extends StatelessWidget {
  final double animationValue;

  const BreathCircle({super.key, required this.animationValue});

  @override
  Widget build(BuildContext context) {
    final minSize = 120.0;
    final maxSize = 240.0;
    final size = minSize + (maxSize - minSize) * animationValue;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppTheme.accentCyan.withOpacity(0.6),
            AppTheme.primaryTeal.withOpacity(0.3),
            AppTheme.primaryTeal.withOpacity(0.05),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentCyan.withOpacity(0.15 * animationValue),
            blurRadius: 40 * animationValue,
            spreadRadius: 10 * animationValue,
          ),
        ],
      ),
    );
  }
}
