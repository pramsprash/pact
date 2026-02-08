import 'package:flutter/material.dart';
import '../models/flow_models.dart';
import '../theme.dart';
import 'player_screen.dart';

class PreviewScreen extends StatelessWidget {
  final FlowPreset preset;
  const PreviewScreen({super.key, required this.preset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Back button ──
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, left: 4),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: AppTheme.textSecondary),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero image ──
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppTheme.surface, AppTheme.primaryTeal],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Title + tagline ──
                    Text(preset.title, style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      '3 movements · repeated 3 times · 9 minutes',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    // ── Description ──
                    if (preset.description != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        preset.description!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // ── Movements ──
                    ...preset.steps.map((step) => _StepRow(step: step)),
                  ],
                ),
              ),
            ),

            // ── Start button ──
            Padding(
              padding: const EdgeInsets.only(bottom: 40, top: 12),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PlayerScreen(preset: preset)),
                ),
                child: const Text('Start'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final FlowStep step;
  const _StepRow({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentCyan,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (step.brief != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    step.brief!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
