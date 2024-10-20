import 'package:flutter/material.dart';

/// Different color palettes for theme purposes.  Inspired by colorhunt.co

class ThemeColors {
  static const Palette palette1 = Palette(
    primary: Color(0xFFF28B82),
    secondary: Color(0xFFF7B733),
    accent: Color(0xFF66BFBF),
    background: Color(0xFFF2F2F2),
  );

  static const Palette palette2 = Palette(
    primary: Color(0xFF4A6572),
    secondary: Color(0xFF66A61E),
    accent: Color(0xFFE9C46A),
    background: Color(0xFFF5F5F5),
  );

  static const Palette palette3 = Palette(
    primary: Color(0xFFA3B18A),
    secondary: Color(0xFFD06B64),
    accent: Color(0xFFD9B310),
    background: Color(0xFFF8F8F8),
  );

  static const Palette palette4 = Palette(
    primary: Color(0xFF344955),
    secondary: Color(0xFFE6B8AF),
    accent: Color(0xFFD980FA),
    background: Color(0xFFF0F0F0),
  );

  static const Palette palette5 = Palette(
    primary: Color(0xFF001F3F),
    secondary: Color(0xFF3A6D8C),
    accent: Color(0xFF6A9AB0),
    background: Color(0xFFEAD8B1),
  );

  static const Palette palette6 = Palette(
    primary: Color(0xFF7C93C3),
    secondary: Color(0xFF55679C),
    accent: Color(0xFF1E2A5E),
    background: Color(0xFFE1D7B7),
  );

  static const Palette palette7 = Palette(
    primary: Color(0xFF789DBC),
    secondary: Color(0xFFFFE3E3),
    accent: Color(0xFFFEF9F2),
    background: Color(0xFFC9E9D2),
  );

  static const Palette palette8 = Palette(
    primary: Color(0xFF37AFE1),
    secondary: Color(0xFF4CC9FE),
    accent: Color(0xFFF5F4B3),
    background: Color(0xFFFFFECB),
  );
}

class Palette {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;

  const Palette({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
  });

  Color getTextColor() {
    // Calculate luminance using relative luminance formula
    double luminance = 0.2126 * background.red +
        0.7152 * background.green +
        0.0722 * background.blue;
    return luminance > 128 ? Colors.black : Colors.white;
  }
}
