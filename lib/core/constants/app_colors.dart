// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors
  static const Color lightPrimary = Color(0xFF6C63FF);
  static const Color lightSecondary = Color(0xFFFF6584);
  static const Color lightAccent = Color(0xFF00D9FF);
  static const Color lightBackground = Color(0xFFF8F9FE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF2D3142);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightSuccess = Color(0xFF10B981);
  static const Color lightWarning = Color(0xFFF59E0B);
  static const Color lightError = Color(0xFFEF4444);

  // Dark Mode Colors
  static const Color darkPrimary = Color(0xFF8B7FFF);
  static const Color darkSecondary = Color(0xFFFF7A94);
  static const Color darkAccent = Color.fromARGB(97, 0, 229, 255);
  static const Color darkBackground = Color(0xFF0F0E17);
  static const Color darkSurface = Color(0xFF1C1B29);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB4B4C6);
  static const Color darkCard = Color(0xFF252437);
  static const Color darkBorder = Color(0xFF3A3850);
  static const Color darkSuccess = Color(0xFF34D399);
  static const Color darkWarning = Color(0xFFFBBF24);
  static const Color darkError = Color(0xFFF87171);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6C63FF),
    Color(0xFF8B7FFF),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFFFF6584),
    Color(0xFFFF8FA3),
  ];

  static const List<Color> accentGradient = [
    Color.fromARGB(153, 0, 217, 255),
    Color.fromARGB(91, 0, 245, 229),
  ];

  static const List<Color> darkGradient = [
    Color(0xFF1C1B29),
    Color(0xFF2A2940),
  ];
}
