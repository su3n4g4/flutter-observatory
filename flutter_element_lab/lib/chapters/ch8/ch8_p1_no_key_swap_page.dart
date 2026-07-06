import 'package:flutter/material.dart';

import '../ch6/counter_tracker.dart';

class Ch8P1NoKeySwapPage extends StatefulWidget {
  const Ch8P1NoKeySwapPage({super.key});

  @override
  State<Ch8P1NoKeySwapPage> createState() => _Ch8P1NoKeySwapPageState();
}

class _Ch8P1NoKeySwapPageState extends State<Ch8P1NoKeySwapPage> {
  bool _swapped = false;

  void _swap() {
    debugPrint('[ACTION] swap（子リストの順序を入れ替え）');
    setState(() => _swapped = !_swapped);
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      CounterTracker('A'),
      CounterTracker('B'),
    ];
    final ordered = _swapped ? children.reversed.toList() : children;

    return Scaffold(
      appBar: AppBar(title: const Text('Chapter 8 Part 1: Keyなしで順序を入れ替え')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Aを+1してからswapしてください。\n'
              'Keyがないため、Stateはリスト位置に紐付いたまま引き継がれます。',
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
