import 'package:flutter/material.dart';
import '../../widgets/state_tracker.dart';

class Ch4P1IdentityManagementPage extends StatefulWidget {
  const Ch4P1IdentityManagementPage({super.key});

  @override
  State<Ch4P1IdentityManagementPage> createState() => _Ch4P1IdentityManagementPageState();
}

class _Ch4P1IdentityManagementPageState extends State<Ch4P1IdentityManagementPage> {
  bool reversed = false;
  bool useKeys = false;
  bool placeGlobalInTop = true;
  final List<String> labels = ['A', 'B', 'C'];

  final GlobalKey probeKey = GlobalKey(debugLabel: 'ch4-global-probe');

  @override
  Widget build(BuildContext context) {
    final ordered = reversed ? labels.reversed.toList() : labels;
    final currentElement = probeKey.currentContext as Element?;

    return Scaffold(
      appBar: AppBar(title: const Text('Ch4 P1: 同一性管理')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'この章で説明すること\n'
              '- Element は「同じかどうか」を Key で判断する\n\n'
              '必要な情報\n'
              '- Widget.canUpdate\n'
              '- Key の比較ルール\n'
              '- GlobalKey が持つ参照',
            ),
            const SizedBox(height: 12),
            const Text(
              '照合するコード\n'
              '- Element.updateChild\n'
              '- Widget.canUpdate\n'
              '- GlobalKey._currentElement',
            ),
            const Divider(height: 28),
            const Text('アプリ側の操作例: List の並び替え / Key を付ける・付けない'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('ValueKey を使う'),
              value: useKeys,
              onChanged: (v) => setState(() => useKeys = v),
            ),
            FilledButton(
              onPressed: () => setState(() => reversed = !reversed),
              child: Text(reversed ? '元の順番に戻す' : 'List を reverse する'),
            ),
            const SizedBox(height: 12),
            for (final label in ordered)
              _IdentityRow(
                label: label,
                key: useKeys ? ValueKey<String>(label) : null,
              ),
            const SizedBox(height: 8),
            const Text(
              '起きる現象\n'
              '- Key がないと State がずれる\n'
              '- Key があると label ごとの State が維持される\n'
              '※ 各行の +1 ボタンで count を増やしてから reverse すると差が見えます。',
            ),
            const Divider(height: 32),
            const Text('GlobalKey の参照保持（Element を跨いで保持）'),
            FilledButton(
              onPressed: () => setState(() => placeGlobalInTop = !placeGlobalInTop),
              child: const Text('GlobalKey 付き Widget の配置先を切り替える'),
            ),
            const SizedBox(height: 8),
            Text(
              'probeKey.currentContext: ${probeKey.currentContext}\n'
              'currentElement.depth: ${currentElement?.depth}\n'
              'currentElement.hashCode: ${currentElement?.hashCode}',
            ),
            const SizedBox(height: 12),
            _Slot(
              title: 'Top Slot',
              child: placeGlobalInTop
                  ? StateTracker('GLOBAL-KEYED', key: probeKey)
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            _Slot(
              title: 'Bottom Slot',
              child: placeGlobalInTop
                  ? const SizedBox.shrink()
                  : StateTracker('GLOBAL-KEYED', key: probeKey),
            ),
            const SizedBox(height: 8),
            const Text('ログで deactivate/activate と state の同一性を確認してください。'),
          ],
        ),
      ),
    );
  }
}

class _IdentityRow extends StatefulWidget {
  const _IdentityRow({required this.label, super.key});

  final String label;

  @override
  State<_IdentityRow> createState() => _IdentityRowState();
}

class _IdentityRowState extends State<_IdentityRow> {
  int count = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('[ROW] initState label=${widget.label} state=$hashCode');
  }

  @override
  void didUpdateWidget(covariant _IdentityRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('[ROW] didUpdateWidget ${oldWidget.label} -> ${widget.label} state=$hashCode');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('label=${widget.label} / count=$count / state=$hashCode'),
        trailing: IconButton(
          onPressed: () => setState(() => count += 1),
          icon: const Icon(Icons.add),
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
