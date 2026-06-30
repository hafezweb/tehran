import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark = ThemeData(
    scaffoldBackgroundColor: const Color(0xff0F1115),
    cardColor: const Color(0xff1B1E24),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff0F1115),
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xffFF6B6B),
      secondary: Color(0xff4ECDC4),
    ),
  );
}
