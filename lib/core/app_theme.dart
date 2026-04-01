import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBackground = Color(0xFF121212);
  static const Color cardGrey = Color(0xFF1E1E1E);
  static const Color solAmber = Color(0xFFD4AF37);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.dark(
        primary: solAmber,
        surface: cardGrey,
        onPrimary: Colors.black,
        secondary: solAmber.withValues(alpha: 0.8),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: solAmber,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardGrey,
        selectedItemColor: solAmber,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
