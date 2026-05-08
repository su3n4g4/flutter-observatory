import 'package:flutter/material.dart';

import '../../widgets/state_tracker.dart';

class Ch3P3GlobalKeyPage extends StatefulWidget {
  const Ch3P3GlobalKeyPage({super.key});

  @override
  State<Ch3P3GlobalKeyPage> createState() => _Ch3P3GlobalKeyPageState();
}

class _Ch3P3GlobalKeyPageState extends State<Ch3P3GlobalKeyPage> {
  bool placeInTopSlot = true;

  final GlobalKey probeKey = GlobalKey(debugLabel: 'ch3-global-probe');

  @override
  Widget build(BuildContext context) {
    final currentElement = probeKey.currentContext as Element?;
    final keyedTracker = StateTracker('GLOBAL-KEYED', key: probeKey);

    return Scaffold(
      appBar: AppBar(title: const Text('Ch3 P3: GlobalKey で配置先を切り替える')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: () => setState(() => placeInTopSlot = !placeInTopSlot),
              child: const Text('配置先を切り替える'),
            ),
            const SizedBox(height: 12),
            Text(
              'currentElement.hashCode: ${currentElement?.hashCode}\n'
              'currentElement.depth: ${currentElement?.depth}',
            ),
            const Divider(height: 24),
            _Slot(
              title: 'Top Slot',
              child: placeInTopSlot ? keyedTracker : const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            _Slot(
              title: 'Bottom Slot',
              child: placeInTopSlot ? const SizedBox.shrink() : keyedTracker,
            ),
          ],
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
