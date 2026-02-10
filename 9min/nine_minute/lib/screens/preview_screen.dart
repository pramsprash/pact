import 'package:flutter/material.dart';
import '../models/flow_models.dart';
import '../theme.dart';
import '../widgets/pose_image.dart';
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
                  icon: const Icon(Icons.arrow_back,
                      color: AppTheme.textSecondary),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Title ──
            Text(preset.title,
                style: Theme.of(context).textTheme.headlineMedium),

            const SizedBox(height: 32),

            // ── Pose images ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: preset.steps.map((step) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: PoseImage(imagePath: step.stepImageAsset),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // ── Start button ──
            Padding(
              padding: const EdgeInsets.only(bottom: 40, top: 12),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PlayerScreen(preset: preset)),
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
