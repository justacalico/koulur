import 'dart:math';

import 'package:flutter/material.dart';

import 'models/palette.dart';

class PaletteGenerator {
  PaletteGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const paletteSize = 5;
  static const minPaletteSize = 2;
  static const maxPaletteSize = 10;

  List<PaletteEntry> generate(
    HarmonyMode mode, {
    int size = paletteSize,
    List<PaletteEntry>? current,
  }) {
    assert(size >= minPaletteSize && size <= maxPaletteSize);
    final colors = _colorsFor(mode, size);
    final entries = [for (final c in colors) PaletteEntry(c)];
    if (current == null) return entries;
    return [
      for (var i = 0; i < size; i++)
        i < current.length && current[i].locked ? current[i] : entries[i],
    ];
  }

  double _range(double min, double max) =>
      min + _random.nextDouble() * (max - min);

  double _jitter(double amount) => (_random.nextDouble() * 2 - 1) * amount;

  List<HSVColor> _colorsFor(HarmonyMode mode, int size) {
    final base = _random.nextDouble() * 360;

    HSVColor pick(double hue, [double? s, double? v]) => HSVColor.fromAHSV(
          1,
          hue % 360,
          s ?? _range(0.45, 0.85),
          v ?? _range(0.55, 0.95),
        );

    switch (mode) {
      case HarmonyMode.random:
        return [
          for (var i = 0; i < size; i++) pick(_random.nextDouble() * 360),
        ];
      case HarmonyMode.analogous:
        return [
          for (var i = 0; i < size; i++)
            pick(base + (i - (size - 1) / 2) * 28 + _jitter(6)),
        ];
      case HarmonyMode.complementary:
        return [
          for (var i = 0; i < size; i++)
            pick(base + (i.isEven ? 0 : 180) + _jitter(6)),
        ];
      case HarmonyMode.triadic:
        return [
          for (var i = 0; i < size; i++)
            pick(base + (i % 3) * 120 + _jitter(4)),
        ];
      case HarmonyMode.tetradic:
        return [
          for (var i = 0; i < size; i++)
            pick(base + (i % 4) * 90 + _jitter(4)),
        ];
      case HarmonyMode.monochromatic:
        final steps = size > 1 ? size - 1 : 1;
        return [
          for (var i = 0; i < size; i++)
            pick(
              base + _jitter(4),
              0.85 - 0.5 * i / steps,
              0.35 + 0.55 * i / steps,
            ),
        ];
    }
  }
}
