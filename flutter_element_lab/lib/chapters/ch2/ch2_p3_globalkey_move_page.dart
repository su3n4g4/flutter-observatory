import 'package:flutter/material.dart';
import '../../widgets/state_tracker.dart';

class Ch2P3GlobalKeyMovePage extends StatefulWidget {
  const Ch2P3GlobalKeyMovePage({super.key});

  @override
  State<Ch2P3GlobalKeyMovePage> createState() => _Ch2P3GlobalKeyMovePageState();
}

class _Ch2P3GlobalKeyMovePageState extends State<Ch2P3GlobalKeyMovePage> {
  bool putInTopSlot = true;

  // GlobalKey を付けた StatefulWidget は、同一インスタンスとしてツリー内を「移動」できる
  // → dispose されずに deactivate -> activate になるのを観測する
  final GlobalKey _probeKey = GlobalKey(debugLabel: 'GLOBAL-KEYED-PROBE');

  @override
  Widget build(BuildContext context) {
    Widget keyedProbe() => StateTracker('GLOBAL-KEYED', key: _probeKey);

    return Scaffold(
      appBar: AppBar(title: const Text('Chapter 2 Part 3: GlobalKey で移動')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'ボタンで StateTracker を上下のスロットに切り替えてください。\n'
              '切り替えても state id が変わらず、dispose が出ないことを確認します。',
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => setState(() => putInTopSlot = !putInTopSlot),
              child: const Text('上下スロットを切り替える'),
            ),
            const Divider(height: 32),
            _SlotFrame(
              title: 'Top Slot',
              child: putInTopSlot ? keyedProbe() : const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            _SlotFrame(
              title: 'Bottom Slot',
              child: putInTopSlot ? const SizedBox.shrink() : keyedProbe(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SlotFrame extends StatelessWidget {
  const _SlotFrame({required this.title, required this.child});

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
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
