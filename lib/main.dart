import 'package:flutter/material.dart';

import 'ui/palette_screen.dart';

void main() {
  runApp(const KoulurApp());
}

class KoulurApp extends StatelessWidget {
  const KoulurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'koulur',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const PaletteScreen(),
    );
  }
}
