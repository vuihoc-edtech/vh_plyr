import 'package:flutter/material.dart';

final theme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: const Color(0xFF0F0F1A),
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFFFF6B35),
    primaryContainer: const Color(0xFFE55A28),
    surface: const Color(0xFF1A1A2E),
    surfaceContainerHighest: const Color(0xFF252540),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1A1A2E),
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1A1A2E),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
