import 'package:flutter/material.dart';
import 'custom_color.dart';

class AppTextStyles {
  // Headline styles
  static const TextStyle headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: CustomColors.textPrimary,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: CustomColors.textPrimary,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: CustomColors.textPrimary,
  );
static const TextStyle headline3white = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: CustomColors.background,
  );

  static const TextStyle headline4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: CustomColors.textPrimary,
  );

  static const TextStyle headline4Light = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: CustomColors.background,
  );

  // Body text styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    color: CustomColors.textPrimary,
  );
static const TextStyle bodyLargewhite = TextStyle(
    fontSize: 18,
    color: CustomColors.background,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    color: CustomColors.textPrimary,
  );
static const TextStyle bodyMediumwhite = TextStyle(
    fontSize: 16,
    color: CustomColors.background,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    color: CustomColors.textPrimary,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: CustomColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: CustomColors.textPrimary,
  );
static const TextStyle labelMediumlight = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: CustomColors.background,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: CustomColors.textPrimary,
  );

  static TextStyle labelGrey = TextStyle(
    fontSize: 14,
    color: Colors.grey[600],
  );

  // Button text styles
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: CustomColors.textPrimary,
  );

  static const TextStyle buttonTextLight = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: CustomColors.background,
  );

  // Status text styles
  static TextStyle successText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.green[700],
  );

  static TextStyle errorText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.red[700],
  );

  // Helper functions to modify existing styles
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}
