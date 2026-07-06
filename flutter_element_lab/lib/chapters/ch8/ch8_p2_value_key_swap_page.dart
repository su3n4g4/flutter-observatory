import 'package:flutter/material.dart';

import '../ch6/counter_tracker.dart';

class Ch8P2ValueKeySwapPage extends StatefulWidget {
  const Ch8P2ValueKeySwapPage({super.key});

  @override
  State<Ch8P2ValueKeySwapPage> createState() => _Ch8P2ValueKeySwapPageState();
}

class _Ch8P2ValueKeySwapPageState extends State<Ch8P2ValueKeySwapPage> {
  bool _swapped = false;

  void _swap() {
    debugPrint('[ACTION] swap');
    setState(() => _swapped = !_swapped);
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      CounterTracker('A', key: const ValueKey('A')),
      CounterTracker('B', key: const ValueKey('B')),
    ];
    final ordered = _swapped ? children.reversed.toList() : children;

    return Scaffold(
      appBar: AppBar(title: const Text('Chapter 8 Part 2: ValueKeyで順序を入れ替え')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Aを+1してからswapしてください。\n'
              'ValueKeyがあるため、Stateはラベルに紐付いて一緒に移動します。',
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _swap,
              child: const Text('swap（順序を入れ替え）'),
            ),
            const Divider(height: 24),
            ...ordered,
          ],
        ),
      ),
    );
  }
}
