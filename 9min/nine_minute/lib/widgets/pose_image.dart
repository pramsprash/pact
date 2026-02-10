import 'package:flutter/material.dart';
import '../theme.dart';

class PoseImage extends StatelessWidget {
  final String imagePath;
  const PoseImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      alignment: Alignment.center,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
