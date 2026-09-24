import 'package:flutter_test/flutter_test.dart';
import 'package:koulur/main.dart' as app;
import 'package:koulur/ui/palette_screen.dart';

void main() {
  testWidgets('main boots into the palette screen', (tester) async {
    app.main();
    await tester.pump();

    expect(find.byType(PaletteScreen), findsOneWidget);
    expect(find.text('Random'), findsOneWidget);
  });
}

