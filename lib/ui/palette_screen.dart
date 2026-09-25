import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../generator.dart';
import '../models/palette.dart';

class PaletteScreen extends StatefulWidget {
  const PaletteScreen({super.key, this.generator});

  final PaletteGenerator? generator;

  @override
  State<PaletteScreen> createState() => _PaletteScreenState();
}

class _PaletteScreenState extends State<PaletteScreen> {
  late final PaletteGenerator _generator =
      widget.generator ?? PaletteGenerator();

  HarmonyMode _mode = HarmonyMode.analogous;
  int _size = PaletteGenerator.paletteSize;
  late List<PaletteEntry> _entries = _generator.generate(_mode);

  void _shuffle() {
    setState(() =>
        _entries = _generator.generate(_mode, size: _size, current: _entries));
  }

  void _setMode(HarmonyMode mode) {
    setState(() {
      _mode = mode;
      _entries = _generator.generate(mode, size: _size);
    });
  }

  void _setSize(int size) {
    setState(() {
      _size = size;
      _entries = _generator.generate(_mode, size: size, current: _entries);
    });
  }

  void _toggleLock(int index) {
    setState(() => _entries[index].locked = !_entries[index].locked);
  }

  void _copy(PaletteEntry entry) {
    unawaited(Clipboard.setData(ClipboardData(text: entry.hex)));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('${entry.hex} copied'),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            for (var i = 0; i < _entries.length; i++)
              Expanded(
                child: _ColourTile(
                  entry: _entries[i],
                  onTap: () => _copy(_entries[i]),
                  onToggleLock: () => _toggleLock(i),
                ),
              ),
            _ControlBar(
              mode: _mode,
              size: _size,
              onModeChanged: _setMode,
              onSizeChanged: _setSize,
              onShuffle: _shuffle,
            ),
          ],
        ),
      ),
    );
  }
}

class _ColourTile extends StatelessWidget {
  const _ColourTile({
    required this.entry,
    required this.onTap,
    required this.onToggleLock,
  });

  final PaletteEntry entry;
  final VoidCallback onTap;
  final VoidCallback onToggleLock;

  @override
  Widget build(BuildContext context) {
    final fg = entry.isDark ? Colors.white : Colors.black;
    return GestureDetector(
      onTap: onTap,
      child: ColoredBox(
        color: entry.color,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Text(
                entry.hex,
                style: TextStyle(
                  color: fg,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onToggleLock,
                icon: Icon(
                  entry.locked ? Icons.lock : Icons.lock_open,
                  color: fg,
                ),
                tooltip: entry.locked ? 'Unlock' : 'Lock',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.mode,
    required this.size,
    required this.onModeChanged,
    required this.onSizeChanged,
    required this.onShuffle,
  });

  final HarmonyMode mode;
  final int size;
  final ValueChanged<HarmonyMode> onModeChanged;
  final ValueChanged<int> onSizeChanged;
  final VoidCallback onShuffle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final m in HarmonyMode.values)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ChoiceChip(
                          label: Text(m.label),
                          selected: mode == m,
                          onSelected: (_) => onModeChanged(m),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: size > PaletteGenerator.minPaletteSize
                  ? () => onSizeChanged(size - 1)
                  : null,
              icon: const Icon(Icons.remove),
              tooltip: 'Fewer colours',
            ),
            Text('$size'),
            IconButton(
              onPressed: size < PaletteGenerator.maxPaletteSize
                  ? () => onSizeChanged(size + 1)
                  : null,
              icon: const Icon(Icons.add),
              tooltip: 'More colours',
            ),
            IconButton.filled(
              onPressed: onShuffle,
              icon: const Icon(Icons.shuffle),
              tooltip: 'Generate',
            ),
          ],
        ),
      ),
    );
  }
}
