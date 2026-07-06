import 'package:flutter/material.dart';

/// カウンタ内蔵のState確認ウィジェット。Ch6以降で共用する。
class CounterTracker extends StatefulWidget {
  const CounterTracker(this.label, {super.key, this.onCountChanged});

  final String label;

  /// countが変化するたびに呼ばれる（外部から現在値をミラーしたい場合に使う）。
  final ValueChanged<int>? onCountChanged;

  @override
  State<CounterTracker> createState() => _CounterTrackerState();
}

class _CounterTrackerState extends State<CounterTracker> {
  int count = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('initState: ${widget.label}  state=$hashCode  count=$count');
  }

  @override
  void activate() {
    super.activate();
    debugPrint('activate: ${widget.label}  state=$hashCode  count=$count');
  }

  @override
  void deactivate() {
    debugPrint('deactivate: ${widget.label}  state=$hashCode  count=$count');
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint('dispose: ${widget.label}  state=$hashCode  count=$count');
    super.dispose();
  }

  void _increment() {
    setState(() => count += 1);
    widget.onCountChanged?.call(count);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build: ${widget.label}  state=$hashCode  count=$count');
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CounterTracker("${widget.label}")',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text('state id: $hashCode'),
            Text('count: $count'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _increment,
              child: const Text('+1'),
            ),
          ],
        ),
      ),
    );
  }
}
