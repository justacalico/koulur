import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:koulur/generator.dart';
import 'package:koulur/models/palette.dart';

void main() {
  late PaletteGenerator generator;

  setUp(() => generator = PaletteGenerator(random: Random(7)));

  double hueDistance(double a, double b) => ((b - a) % 360 + 360) % 360;

  group('generate', () {
    for (final mode in HarmonyMode.values) {
      test('$mode produces ${PaletteGenerator.paletteSize} valid colours', () {
        final entries = generator.generate(mode);
        expect(entries, hasLength(PaletteGenerator.paletteSize));
        for (final e in entries) {
          expect(e.hsv.hue, inInclusiveRange(0, 360));
          expect(e.hsv.saturation, inInclusiveRange(0, 1));
          expect(e.hsv.value, inInclusiveRange(0, 1));
          expect(e.locked, isFalse);
        }
      });
    }

    test('analogous hues stay within a tight band', () {
      final entries = generator.generate(HarmonyMode.analogous);
      for (var i = 1; i < entries.length; i++) {
        final d = hueDistance(entries[i - 1].hsv.hue, entries[i].hsv.hue);
        expect(d, inInclusiveRange(16, 40));
      }
    });

    test('complementary alternates hues ~180 apart', () {
      final entries = generator.generate(HarmonyMode.complementary);
      for (var i = 1; i < entries.length; i += 2) {
        final d = hueDistance(entries[i - 1].hsv.hue, entries[i].hsv.hue);
        expect(d, inInclusiveRange(168, 192));
      }
    });

    test('triadic includes hues ~120 apart', () {
      final entries = generator.generate(HarmonyMode.triadic);
      expect(
        hueDistance(entries[0].hsv.hue, entries[1].hsv.hue),
        inInclusiveRange(108, 132),
      );
      expect(
        hueDistance(entries[0].hsv.hue, entries[2].hsv.hue),
        inInclusiveRange(228, 252),
      );
    });

    test('tetradic includes hues ~90 apart', () {
      final entries = generator.generate(HarmonyMode.tetradic);
      expect(
        hueDistance(entries[0].hsv.hue, entries[1].hsv.hue),
        inInclusiveRange(78, 102),
      );
      expect(
        hueDistance(entries[0].hsv.hue, entries[3].hsv.hue),
        inInclusiveRange(258, 282),
      );
    });

    test('monochromatic is a saturation ramp on one hue', () {
      final entries = generator.generate(HarmonyMode.monochromatic);
      for (var i = 1; i < entries.length; i++) {
        var d = hueDistance(entries[0].hsv.hue, entries[i].hsv.hue);
        if (d > 180) d = 360 - d;
        expect(d, lessThan(12));
        expect(
          entries[i].hsv.saturation,
          lessThan(entries[i - 1].hsv.saturation),
        );
      }
    });

    test('locked entries survive regeneration', () {
      final first = generator.generate(HarmonyMode.random);
      first[1].locked = true;
      first[3].locked = true;
      final second = generator.generate(HarmonyMode.random, current: first);
      expect(identical(second[1], first[1]), isTrue);
      expect(identical(second[3], first[3]), isTrue);
      expect(identical(second[0], first[0]), isFalse);
    });

    test('size controls the number of colours', () {
      for (final mode in HarmonyMode.values) {
        expect(generator.generate(mode, size: 3), hasLength(3));
        expect(generator.generate(mode, size: 8), hasLength(8));
      }
    });

    test('locked entries survive a resize', () {
      final first = generator.generate(HarmonyMode.random);
      first[1].locked = true;

      final shrunk =
          generator.generate(HarmonyMode.random, size: 3, current: first);
      expect(shrunk, hasLength(3));
      expect(identical(shrunk[1], first[1]), isTrue);

      final grown =
          generator.generate(HarmonyMode.random, size: 8, current: first);
      expect(grown, hasLength(8));
      expect(identical(grown[1], first[1]), isTrue);
    });

    test('unlocked entries are regenerated on resize', () {
      final short = [PaletteEntry(const HSVColor.fromAHSV(1, 0, 0, 0))];
      final entries =
          generator.generate(HarmonyMode.random, current: short);
      expect(entries, hasLength(PaletteGenerator.paletteSize));
      expect(identical(entries[0], short[0]), isFalse);
    });
  });
}
