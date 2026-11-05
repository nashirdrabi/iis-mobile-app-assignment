import 'package:flutter/material.dart';
import '../../../core/theme/layout.dart';
import '../../meditation/meditation_design_system.dart';

ThemeData authTheme() => meditationTheme().copyWith(
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFFCFAFF),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    labelStyle: const TextStyle(fontSize: 13, color: MeditationPalette.muted),
    prefixIconColor: MeditationPalette.primary,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.input),
      borderSide: const BorderSide(color: Color(0xFFE7DFF6)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.input),
      borderSide: const BorderSide(color: Color(0xFFE7DFF6)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.input),
      borderSide: const BorderSide(
        color: MeditationPalette.primary,
        width: 1.5,
      ),
    ),
  ),
);
