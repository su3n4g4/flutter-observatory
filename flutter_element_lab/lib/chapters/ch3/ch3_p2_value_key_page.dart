import 'package:flutter/material.dart';

import '../../widgets/state_tracker.dart';

class Ch3P2ValueKeyPage extends StatefulWidget {
  const Ch3P2ValueKeyPage({super.key});

  @override
  State<Ch3P2ValueKeyPage> createState() => _Ch3P2ValueKeyPageState();
}

class _Ch3P2ValueKeyPageState extends State<Ch3P2ValueKeyPage> {
  bool reversed = false;

  @override
  Widget build(BuildContext context) {
    final labels = reversed ? ['C', 'B', 'A'] : ['A', 'B', 'C'];

    return Scaffold(
      appBar: AppBar(title: const Text('Chapter 3 Part 2: 並べ替え（ValueKey）')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => setState(() => reversed = !reversed),
            child: const Text('Reverse'),
          ),
          const Divider(),
          for (final s in labels) StateTracker(s, key: ValueKey(s)),
        ],
      ),
    );
  }
}
