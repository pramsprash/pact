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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('9Minute', style: Theme.of(context).textTheme.headlineLarge),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    ),
                    icon: const Icon(Icons.history,
                        color: AppTheme.textSecondary, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your flow',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              ...kPresets.asMap().entries.map(
                (e) => _PresetCard(preset: e.value, glow: e.key == 0),
              ),
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
                      color: AppTheme.accentCyan.withOpacity(0.08),
                      blurRadius: 24,
                      spreadRadius: 2,
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
                  fontWeight: FontWeight.w400,
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
