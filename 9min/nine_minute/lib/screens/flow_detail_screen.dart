import 'package:flutter/material.dart';
import '../models/flow_models.dart';
import '../theme.dart';
import 'player_screen.dart';

class FlowDetailScreen extends StatelessWidget {
  final FlowPreset preset;
  const FlowDetailScreen({super.key, required this.preset});

  static const _labels = ['a', 'b', 'c'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Back ──
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back,
                              color: AppTheme.textSecondary),
                        ),
                      ),

                      // ── Card ──
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Hero image ──
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20)),
                              child: Image.asset(
                                preset.heroImageAsset,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 200,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.surface,
                                        AppTheme.primaryTeal,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Title + tagline ──
                                  Text(
                                    preset.title,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w300,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    preset.tagline,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: AppTheme.accentCyan,
                                    ),
                                  ),

                                  // ── Description ──
                                  const SizedBox(height: 16),
                                  Text(
                                    preset.description,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: AppTheme.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),

                                  // ── Meta lines ──
                                  const SizedBox(height: 14),
                                  Text(
                                    '3 movements · repeated 3 times · 9 minutes',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                      color: AppTheme.textSecondary
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '50 s move / 10 s transition',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                      color: AppTheme.textSecondary
                                          .withOpacity(0.6),
                                    ),
                                  ),

                                  // ── Divider ──
                                  const SizedBox(height: 28),
                                  Divider(
                                    color:
                                        AppTheme.textSecondary.withOpacity(0.12),
                                    height: 1,
                                  ),

                                  // ── Movements ──
                                  const SizedBox(height: 28),
                                  const Text(
                                    'Movements',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: AppTheme.textSecondary,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ...List.generate(preset.steps.length, (i) {
                                    final step = preset.steps[i];
                                    final label = i < _labels.length
                                        ? _labels[i]
                                        : '${i + 1}';
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 24),
                                      child: _MovementTile(
                                          step: step, label: label),
                                    );
                                  }),

                                  // ── Divider ──
                                  Divider(
                                    color:
                                        AppTheme.textSecondary.withOpacity(0.12),
                                    height: 1,
                                  ),

                                  // ── Benefits ──
                                  const SizedBox(height: 28),
                                  const Text(
                                    'Benefits',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: AppTheme.textSecondary,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...preset.benefits.map(
                                    (b) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 7),
                                            child: Container(
                                              width: 4,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppTheme.textSecondary
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              b,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w300,
                                                color: AppTheme.textSecondary,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Sticky bottom bar ──
          Container(
            color: AppTheme.background,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PlayerScreen(preset: preset)),
                  ),
                  child: const Text('Start'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  final FlowStep step;
  final String label;
  const _MovementTile({required this.step, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Letter label ──
        SizedBox(
          width: 24,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.accentCyan.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // ── Content ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                step.detail,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: AppTheme.textSecondary.withOpacity(0.08),
                ),
                child: Text(
                  step.breathProfile == 'hold'
                      ? 'Hold & breathe'
                      : 'Dynamic breathing',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
