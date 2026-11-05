import 'package:flutter/material.dart';

import '../meditation_design_system.dart';

/// Consistent elevated surface used for meditation cards and audio rows.
class MeditationSurface extends StatelessWidget {
  const MeditationSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = 16,
    this.color = MeditationPalette.surface,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: MeditationPalette.border, width: .7),
      boxShadow: const [
        BoxShadow(
          color: Color(0x080F0820),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}
