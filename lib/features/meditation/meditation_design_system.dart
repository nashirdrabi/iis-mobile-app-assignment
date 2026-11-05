import 'package:flutter/material.dart';

/// Colors and typography shared by both meditation experiences.
abstract final class MeditationPalette {
  static const primary = Color(0xFF4F46E5);
  static const accent = Color(0xFF7C3AED);
  static const canvas = Color(0xFFFAF7FD);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const border = Color(0xFFF0EBF5);
  static const lavender = Color(0xFFF0E9FF);
  static const lilacWash = Color(0xFFF8F2FF);
  static const mint = Color(0xFFE0F3F1);
  static const rose = Color(0xFFFFE5F1);
}

ThemeData meditationTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'Inter',
  scaffoldBackgroundColor: MeditationPalette.canvas,
  colorScheme: ColorScheme.fromSeed(
    seedColor: MeditationPalette.primary,
    secondary: MeditationPalette.accent,
  ),
  textTheme:
      const TextTheme(
        bodyMedium: TextStyle(
          fontSize: 13,
          height: 1.5,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
          color: MeditationPalette.ink,
        ),
        bodySmall: TextStyle(
          fontSize: 11,
          height: 1.5,
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
          color: MeditationPalette.muted,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: MeditationPalette.ink,
        ),
      ).apply(
        fontFamily: 'Inter',
        fontFamilyFallback: const ['Noto Sans Devanagari', 'Noto Sans Kannada'],
      ),
);
