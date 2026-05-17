import 'package:flutter/material.dart';

import '../../widgets/state_tracker.dart';

class P3MoveParentPage extends StatefulWidget {
  const P3MoveParentPage({super.key});

  @override
  State<P3MoveParentPage> createState() => _P3MoveParentPageState();
}

class _P3MoveParentPageState extends State<P3MoveParentPage> {
  bool toLeft = true;

  @override
  Widget build(BuildContext context) {
    const child = StateTracker('P');

    return Scaffold(
      appBar: AppBar(title: const Text('Chapter 1 Part 3: 親の切り替え')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '同じ StateTracker("P") を Left / Right の親ボックス間で移動させます。',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => setState(() => toLeft = !toLeft),
              icon: Icon(toLeft ? Icons.arrow_forward : Icons.arrow_back),
              label: Text(
                toLeft ? 'StateTracker を Right へ移動' : 'StateTracker を Left へ移動',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ParentBox(
                  title: 'Left',
                  active: toLeft,
                  child: toLeft ? child : null,
                ),
                _ParentBox(
                  title: 'Right',
                  active: !toLeft,
                  child: !toLeft ? child : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentBox extends StatelessWidget {
  const _ParentBox({
    required this.title,
    required this.active,
    required this.child,
  });

  final String title;
  final bool active;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: active
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300,
          width: active ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
          ),
          const SizedBox(height: 12),
          child ??
              Text(
                '（空）',
                style: TextStyle(color: Colors.grey.shade400),
              ),
        ],
      ),
    );
  }
}