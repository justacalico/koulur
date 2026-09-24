import 'dart:math';

import 'package:flutter/material.dart';

import 'models/palette.dart';

class PaletteGenerator {
  PaletteGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const paletteSize = 5;

  List<PaletteEntry> generate(HarmonyMode mode, [List<PaletteEntry>? current]) {
    final colors = _colorsFor(mode);
    final entries = [for (final c in colors) PaletteEntry(c)];
    if (current == null || current.length != paletteSize) return entries;
    return [
      for (var i = 0; i < paletteSize; i++)
        current[i].locked ? current[i] : entries[i],
    ];
  }

  double _range(double min, double max) =>
      min + _random.nextDouble() * (max - min);

  double _jitter(double amount) => (_random.nextDouble() * 2 - 1) * amount;

  List<HSVColor> _colorsFor(HarmonyMode mode) {
    final base = _random.nextDouble() * 360;

    HSVColor pick(double hue, [double? s, double? v]) => HSVColor.fromAHSV(
          1,
          hue % 360,
          s ?? _range(0.45, 0.85),
          v ?? _range(0.55, 0.95),
        );

    switch (mode) {
      case HarmonyMode.random:
        return [for (var i = 0; i < paletteSize; i++) pick(_random.nextDouble() * 360)];
      case HarmonyMode.analogous:
        return [
          for (var i = 0; i < paletteSize; i++)
            pick(base + (i - 2) * 28 + _jitter(6)),
        ];
      case HarmonyMode.complementary:
        return [
          pick(base + _jitter(6)),
          pick(base + _jitter(6)),
          pick(base + 180 + _jitter(6)),
          pick(base + 180 + _jitter(6)),
          pick(base + 90 + _jitter(6)),
        ];
      case HarmonyMode.triadic:
        return [
          pick(base),
          pick(base + 120),
          pick(base + 240),
          pick(base + _jitter(10), null, _range(0.8, 0.95)),
          pick(base + 120 + _jitter(10), _range(0.3, 0.5)),
        ];
      case HarmonyMode.tetradic:
        return [
          pick(base),
          pick(base + 90),
          pick(base + 180),
          pick(base + 270),
          pick(base + _jitter(10), _range(0.3, 0.5), _range(0.8, 0.95)),
        ];
      case HarmonyMode.monochromatic:
        return [
          for (var i = 0; i < paletteSize; i++)
            pick(base + _jitter(4), 0.85 - i * 0.12, 0.35 + i * 0.14),
        ];
    }
  }
}
