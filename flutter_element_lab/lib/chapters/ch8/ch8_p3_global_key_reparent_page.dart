import 'package:flutter/material.dart';

import '../ch6/counter_tracker.dart';

class Ch8P3GlobalKeyReparentPage extends StatefulWidget {
  const Ch8P3GlobalKeyReparentPage({super.key});

  @override
  State<Ch8P3GlobalKeyReparentPage> createState() =>
      _Ch8P3GlobalKeyReparentPageState();
}

class _Ch8P3GlobalKeyReparentPageState
    extends State<Ch8P3GlobalKeyReparentPage> {
  bool _onRight = false;
  final GlobalKey _probeKey = GlobalKey(debugLabel: 'GLOBAL-KEYED-G');

  void _toggle() {
    debugPrint(_onRight ? '[ACTION] 左の枠へ移動' : '[ACTION] 右の枠へ移動');
    setState(() => _onRight = !_onRight);
  }

  @override
  Widget build(BuildContext context) {
    Widget probe() => CounterTracker('G', key: _probeKey);

    return Scaffold(
      appBar: AppBar(title: const Text('Chapter 8 Part 3: GlobalKeyで親をまたいで移動')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '+1してから枠を移動してください。\n'
              '親が変わりネスト深さも変わりますが、GlobalKeyがあるためStateは維持されます。',
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _toggle,
              child: Text(_onRight ? '左の枠へ移動' : '右の枠へ移動'),
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _LeftFrame(child: _onRight ? null : probe()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RightFrame(child: _onRight ? probe() : null),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LeftFrame extends StatelessWidget {
  const _LeftFrame({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Left（Column直下）'),
            const SizedBox(height: 8),
            child ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class _RightFrame extends StatelessWidget {
  const _RightFrame({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Right（Container→Padding→Padding→Column配下）'),
              const SizedBox(height: 8),
              child ?? const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
