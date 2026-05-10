import 'package:flutter/material.dart';

import '../../widgets/state_tracker.dart';

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
      appBar: AppBar(title: const Text('Chapter 1 Part 2: 条件付き挿入・削除')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => setState(() => showX = !showX),
              child: Text(showX ? 'Remove X' : 'Insert X'),
            ),
            const Divider(),
            const StateTracker('A'),
            if (showX) const StateTracker('X'),
            const StateTracker('B'),
            const StateTracker('C'),
          ],
        ),
      ),
    );
  }
}