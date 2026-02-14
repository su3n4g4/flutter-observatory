import 'package:flutter/material.dart';
import 'probe.dart';

class P1ReorderNoKeyPage extends StatefulWidget {
  const P1ReorderNoKeyPage({super.key});

  @override
  State<P1ReorderNoKeyPage> createState() => _P1ReorderNoKeyPageState();
}

class _P1ReorderNoKeyPageState extends State<P1ReorderNoKeyPage> {
  bool reversed = false;

  @override
  Widget build(BuildContext context) {
    final labels = reversed ? ['C', 'B', 'A'] : ['A', 'B', 'C'];

    return Scaffold(
      appBar: AppBar(title: const Text('P1: Reorder（Keyなし）')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => setState(() => reversed = !reversed),
            child: const Text('Reverse'),
          ),
          const Divider(),
          for (final s in labels) Probe(s),
        ],
      ),
    );
  }
}
