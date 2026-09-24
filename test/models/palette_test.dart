import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koulur/models/palette.dart';

void main() {
  group('PaletteEntry', () {
    test('defaults to unlocked', () {
      final entry = PaletteEntry(const HSVColor.fromAHSV(1, 0, 1, 1));
      expect(entry.locked, isFalse);
    });

    test('hex is uppercase #RRGGBB', () {
      expect(PaletteEntry(const HSVColor.fromAHSV(1, 0, 1, 1)).hex, '#FF0000');
      expect(PaletteEntry(const HSVColor.fromAHSV(1, 0, 0, 0)).hex, '#000000');
      expect(PaletteEntry(const HSVColor.fromAHSV(1, 0, 0, 1)).hex, '#FFFFFF');
    });

    test('color round-trips through hsv', () {
      const hsv = HSVColor.fromAHSV(1, 210, 0.5, 0.7);
      expect(PaletteEntry(hsv).color, hsv.toColor());
    });

    test('isDark reflects brightness', () {
      expect(
        PaletteEntry(const HSVColor.fromAHSV(1, 0, 0, 0.05)).isDark,
        isTrue,
      );
      expect(
        PaletteEntry(const HSVColor.fromAHSV(1, 0, 0, 0.95)).isDark,
        isFalse,
      );
    });
  });

  group('HarmonyMode', () {
    test('every mode has a label', () {
      for (final mode in HarmonyMode.values) {
        expect(mode.label, isNotEmpty);
      }
    });
  });
}
