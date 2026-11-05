import 'package:flutter/material.dart';
import '../../features/meditation/meditation_design_system.dart';

class SanctuaryBackdrop extends StatelessWidget {
  const SanctuaryBackdrop({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(.8, -.8),
        radius: 1.5,
        colors: [
          Color(0xFFF0E5FF),
          MeditationPalette.canvas,
          Color(0xFFFDFBFF),
        ],
      ),
    ),
    child: child,
  );
}

class SanctuaryBrand extends StatelessWidget {
  const SanctuaryBrand({super.key, this.large = false});
  final bool large;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: large ? 96 : 48,
        height: large ? 96 : 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [MeditationPalette.primary, MeditationPalette.accent],
          ),
          borderRadius: BorderRadius.circular(large ? 30 : 16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x304F46E5),
              blurRadius: 28,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Icon(
          Icons.spa_outlined,
          size: large ? 52 : 27,
          color: Colors.white,
        ),
      ),
      SizedBox(height: large ? 26 : 16),
      Text(
        'Sanctuary',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: large ? 32 : 21,
          fontWeight: FontWeight.w600,
          letterSpacing: -.7,
          color: MeditationPalette.ink,
        ),
      ),
      const SizedBox(height: 7),
      const Text(
        'PRANIC HEALING & MINDFUL LIVING',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
          color: MeditationPalette.accent,
        ),
      ),
    ],
  );
}

class SanctuarySplash extends StatelessWidget {
  const SanctuarySplash({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: MeditationPalette.canvas,
    body: SanctuaryBackdrop(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SanctuaryBrand(large: true),
                const SizedBox(height: 18),
                const Text(
                  'A little stillness. A deeper connection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 1.5,
                    color: MeditationPalette.muted,
                  ),
                ),
                const SizedBox(height: 40),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: MeditationPalette.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
