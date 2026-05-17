import 'package:flutter/material.dart';

class ColorPalette {
  Color primaryColor;
  Color primaryVariantColor;
  Color secondaryColor;
  Color backgroundColor;
  Color surfaceColor;
  Color accentColor;

  ColorPalette({
    required this.primaryColor,
    required this.primaryVariantColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.accentColor,
  });

  // Example: default palette
  static ColorPalette defaultPalette = ColorPalette(
    primaryColor: Color(0xFF6200EE),
    primaryVariantColor: Color(0xFF3700B3),
    secondaryColor: Color(0xFF03DAC6),
    backgroundColor: Color(0xFFF5F5F5),
    surfaceColor: Color(0xFFFFFFFF),
    accentColor: Color(0xFFFF5722),
  );
}