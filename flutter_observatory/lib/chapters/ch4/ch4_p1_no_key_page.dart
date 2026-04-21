import 'package:flutter/material.dart';

import '../../widgets/state_tracker.dart';

class Ch4P1NoKeyPage extends StatefulWidget {
  const Ch4P1NoKeyPage({super.key});

  @override
  State<Ch4P1NoKeyPage> createState() => _Ch4P1NoKeyPageState();
}

class _Ch4P1NoKeyPageState extends State<Ch4P1NoKeyPage> {
  bool reversed = false;

  @override
  Widget build(BuildContext context) {
    final labels = reversed ? ['C', 'B', 'A'] : ['A', 'B', 'C'];

    return Scaffold(
      appBar: AppBar(title: const Text('Ch4 P1: Reorder（Keyなし）')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => setState(() => reversed = !reversed),
            child: const Text('Reverse'),
          ),
          const Divider(),
          for (final s in labels) StateTracker(s),
        ],
      ),
    );
  }
}
