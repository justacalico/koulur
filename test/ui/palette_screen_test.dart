import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koulur/generator.dart';
import 'package:koulur/models/palette.dart';
import 'package:koulur/ui/palette_screen.dart';

Widget _wrap(PaletteGenerator generator) => MaterialApp(
      home: PaletteScreen(generator: generator),
    );

List<String> _hexes(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data ?? '')
    .where((t) => RegExp(r'^#[0-9A-F]{6}$').hasMatch(t))
    .toList();

void main() {
  testWidgets('renders five hex swatches and all mode chips', (tester) async {
    await tester.pumpWidget(_wrap(PaletteGenerator(random: Random(1))));

    expect(_hexes(tester), hasLength(PaletteGenerator.paletteSize));
    for (final mode in HarmonyMode.values) {
      expect(find.text(mode.label), findsOneWidget);
    }
    expect(find.byIcon(Icons.shuffle), findsOneWidget);
  });

  testWidgets('tapping a swatch copies its hex code', (tester) async {
    await tester.pumpWidget(_wrap(PaletteGenerator(random: Random(2))));

    final hex = _hexes(tester).first;
    await tester.tap(find.text(hex));
    await tester.pumpAndSettle();

    expect(find.text('$hex copied'), findsOneWidget);
  });

  testWidgets('locking keeps a colour across shuffles', (tester) async {
    await tester.pumpWidget(_wrap(PaletteGenerator(random: Random(3))));

    final before = _hexes(tester);
    await tester.tap(find.byIcon(Icons.lock_open).first);
    await tester.pump();
    expect(find.byIcon(Icons.lock), findsOneWidget);

    await tester.tap(find.byIcon(Icons.shuffle));
    await tester.pump();

    expect(_hexes(tester).first, before.first);
  });

  testWidgets('unlocking lets the colour shuffle again', (tester) async {
    await tester.pumpWidget(_wrap(PaletteGenerator(random: Random(4))));

    await tester.tap(find.byIcon(Icons.lock_open).first);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.lock));
    await tester.pump();

    expect(find.byIcon(Icons.lock), findsNothing);
    expect(find.byIcon(Icons.lock_open).first, findsOneWidget);
  });

  testWidgets('switching mode regenerates the palette', (tester) async {
    await tester.pumpWidget(_wrap(PaletteGenerator(random: Random(5))));

    await tester.ensureVisible(find.text('Monochromatic'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monochromatic'));
    await tester.pump();

    final chip = tester.widget<ChoiceChip>(
      find.ancestor(
        of: find.text('Monochromatic'),
        matching: find.byType(ChoiceChip),
      ),
    );
    expect(chip.selected, isTrue);
    expect(_hexes(tester), hasLength(PaletteGenerator.paletteSize));
  });

  testWidgets('shuffle keeps five swatches', (tester) async {
    await tester.pumpWidget(_wrap(PaletteGenerator(random: Random(6))));

    await tester.tap(find.byIcon(Icons.shuffle));
    await tester.pump();

    expect(_hexes(tester), hasLength(PaletteGenerator.paletteSize));
  });
}
