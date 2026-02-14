import 'package:flutter/material.dart';
import 'probe.dart';

class P3MoveParentPage extends StatefulWidget {
  const P3MoveParentPage({super.key});

  @override
  State<P3MoveParentPage> createState() => _P3MoveParentPageState();
}

class _P3MoveParentPageState extends State<P3MoveParentPage> {
  bool toLeft = true;

  @override
  Widget build(BuildContext context) {
    final child = const Probe('P');

    return Scaffold(
      appBar: AppBar(title: const Text('P3: Move Between Parents')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => setState(() => toLeft = !toLeft),
            child: Text(toLeft ? 'Move to Right' : 'Move to Left'),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ParentBox(title: 'Left', child: toLeft ? child : null),
              _ParentBox(title: 'Right', child: !toLeft ? child : null),
            ],
          ),
        ],
      ),
    );
  }
}

class _ParentBox extends StatelessWidget {
  const _ParentBox({required this.title, required this.child});

  final String title;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          child ?? const Text('(empty)'),
        ],
      ),
    );
  }
}
