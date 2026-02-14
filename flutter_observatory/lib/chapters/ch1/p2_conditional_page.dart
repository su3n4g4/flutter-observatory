import 'package:flutter/material.dart';
import 'probe.dart';

class P2ConditionalPage extends StatefulWidget {
  const P2ConditionalPage({super.key});

  @override
  State<P2ConditionalPage> createState() => _P2ConditionalPageState();
}

class _P2ConditionalPageState extends State<P2ConditionalPage> {
  bool showX = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('P2: Conditional Insert/Remove')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => setState(() => showX = !showX),
            child: Text(showX ? 'Remove X' : 'Insert X'),
          ),
          const Divider(),
          const Probe('A'),
          if (showX) const Probe('X'),
          const Probe('B'),
          const Probe('C'),
        ],
      ),
    );
  }
}
