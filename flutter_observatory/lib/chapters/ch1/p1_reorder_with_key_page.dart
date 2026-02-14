import 'package:flutter/material.dart';
import 'probe.dart';

class P1ReorderWithKeyPage extends StatefulWidget {
  const P1ReorderWithKeyPage({super.key});

  @override
  State<P1ReorderWithKeyPage> createState() => _P1ReorderWithKeyPageState();
}

class _P1ReorderWithKeyPageState extends State<P1ReorderWithKeyPage> {
  bool reversed = false;

  @override
  Widget build(BuildContext context) {
    final labels = reversed ? ['C', 'B', 'A'] : ['A', 'B', 'C'];

    return Scaffold(
      appBar: AppBar(title: const Text('P1: Reorder（Keyあり）')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => setState(() => reversed = !reversed),
            child: const Text('Reverse'),
          ),
          const Divider(),
          for (final s in labels) Probe(s, key: ValueKey(s)),
        ],
      ),
    );
  }
}
