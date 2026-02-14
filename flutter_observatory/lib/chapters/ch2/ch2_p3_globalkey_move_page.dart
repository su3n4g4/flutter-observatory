import 'package:flutter/material.dart';
import 'lifecycle_probe.dart';

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
    Widget keyedProbe() => LifecycleProbe('GLOBAL-KEYED', key: _probeKey);

    return Scaffold(
      appBar: AppBar(title: const Text('P3: GlobalKey で移動')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '観測したいこと：\n'
              '- 上下スロットを切り替えても State(state=xxxx) が同一のまま\n'
              '- dispose が出ない\n'
              '- deactivate -> activate が出ることがある',
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
            const Text(
              'ログの見方：\n'
              '1) 最初に initState/build が出る\n'
              '2) 切り替えで deactivate/activate/build が出る（dispose は出ない）\n'
              '3) state= の値（hashCode）が変わらないことを確認',
            ),
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
