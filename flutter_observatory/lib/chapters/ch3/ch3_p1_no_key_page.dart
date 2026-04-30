import 'package:flutter/material.dart';

import '../../widgets/state_tracker.dart';

class Ch3P1NoKeyPage extends StatefulWidget {
  const Ch3P1NoKeyPage({super.key});

  @override
  State<Ch3P1NoKeyPage> createState() => _Ch3P1NoKeyPageState();
}

class _Ch3P1NoKeyPageState extends State<Ch3P1NoKeyPage> {
  bool reversed = false;

  @override
  Widget build(BuildContext context) {
    final labels = reversed ? ['C', 'B', 'A'] : ['A', 'B', 'C'];

    return Scaffold(
      appBar: AppBar(title: const Text('Ch3 P1: Reorder（Keyなし）')),
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
