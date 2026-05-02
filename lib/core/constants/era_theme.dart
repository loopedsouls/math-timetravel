import 'package:flutter/material.dart';
import 'math_eras.dart';

/// UI theme metadata for each [MathEra]. Kept separate so [MathEra] stays
/// pure-Dart (no Flutter imports) and can be reused in tests / server code.
class EraTheme {
  final Color seedColor;
  final IconData icon;

  const EraTheme({required this.seedColor, required this.icon});

  static const Map<String, EraTheme> _themes = {
    'babylonian': EraTheme(
      seedColor: Color(0xFFD4A574), // sand / clay tablet
      icon: Icons.calculate,
    ),
    'greek': EraTheme(
      seedColor: Color(0xFF1976D2), // Aegean blue
      icon: Icons.architecture,
    ),
    'islamic': EraTheme(
      seedColor: Color(0xFF00897B), // teal/green tilework
      icon: Icons.functions,
    ),
    'renaissance': EraTheme(
      seedColor: Color(0xFFB71C1C), // Florentine red
      icon: Icons.brush,
    ),
    'modern': EraTheme(
      seedColor: Color(0xFF455A64), // industrial steel
      icon: Icons.show_chart,
    ),
    'digital': EraTheme(
      seedColor: Color(0xFF00ACC1), // neon cyan
      icon: Icons.memory,
    ),
  };

  /// Returns the theme for [era], with a sensible fallback.
  static EraTheme of(MathEra era) =>
      _themes[era.id] ??
      const EraTheme(seedColor: Colors.deepPurple, icon: Icons.history_edu);
}
