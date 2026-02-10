import 'package:flutter/material.dart';
import '../data/presets.dart';
import '../models/flow_models.dart';
import '../theme.dart';
import 'history_screen.dart';
import 'flow_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                ClipOval(
                  child: Image.asset(
                    'assets/logo/9minute_logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    isAntiAlias: true,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '9 Minutes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 36),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Choose your flow',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HistoryScreen()),
                      ),
                      icon: const Icon(Icons.history,
                          color: AppTheme.textSecondary, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...kPresets.asMap().entries.map(
                  (e) => _PresetCard(preset: e.value, glow: e.key == 0),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  final FlowPreset preset;
  final bool glow;
  const _PresetCard({required this.preset, this.glow = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FlowDetailScreen(preset: preset)),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: glow
                ? [
                    BoxShadow(
                      color: AppTheme.textPrimary.withOpacity(0.15),
                      blurRadius: 22,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                preset.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                preset.tagline,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
