import 'package:flutter/material.dart';

enum HarmonyMode {
  random('Random'),
  analogous('Analogous'),
  complementary('Complementary'),
  triadic('Triadic'),
  tetradic('Tetradic'),
  monochromatic('Monochromatic');

  const HarmonyMode(this.label);

  final String label;
}

class PaletteEntry {
  PaletteEntry(this.hsv, {this.locked = false});

  final HSVColor hsv;
  bool locked;

  Color get color => hsv.toColor();

  String get hex {
    final argb = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${argb.substring(2).toUpperCase()}';
  }

  bool get isDark =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark;
}
