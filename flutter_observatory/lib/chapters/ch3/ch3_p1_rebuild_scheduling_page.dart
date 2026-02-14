import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Ch3P1RebuildSchedulingPage extends StatefulWidget {
  const Ch3P1RebuildSchedulingPage({super.key});

  @override
  State<Ch3P1RebuildSchedulingPage> createState() =>
      _Ch3P1RebuildSchedulingPageState();
}

class _Ch3P1RebuildSchedulingPageState extends State<Ch3P1RebuildSchedulingPage> {
  int syncActionCount = 0;
  int asyncActionCount = 0;
  int frameCount = 0;

  @override
  void initState() {
    super.initState();
    _scheduleFrameProbe();
  }

  void _scheduleFrameProbe() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      frameCount += 1;
      debugPrint('[FRAME] drawFrame completed: #$frameCount');
      _scheduleFrameProbe();
    });
  }

  void _runMultipleSetState() {
    debugPrint('[ACTION] call setState x3 in one tap');
    setState(() => syncActionCount += 1);
    setState(() => syncActionCount += 1);
    setState(() => syncActionCount += 1);
  }

  Future<void> _runAsyncSetState() async {
    debugPrint('[ACTION] async started');
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) {
      return;
    }
    debugPrint('[ACTION] async completed -> setState');
    setState(() => asyncActionCount += 1);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[BUILD] parent page');

    return Scaffold(
      appBar: AppBar(title: const Text('Ch3 P1: 再構築スケジューリング')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'この章で説明すること\n'
              '- setState は build を直接呼ばない\n'
              '- Element は dirty マークを付けて BuildOwner に登録される',
            ),
            const SizedBox(height: 12),
            const Text(
              '照合コード\n'
              '- Element.markNeedsBuild\n'
              '- BuildOwner.scheduleBuildFor\n'
              '- WidgetsBinding.drawFrame',
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _runMultipleSetState,
              child: const Text('同一イベントで setState を3回呼ぶ'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _runAsyncSetState,
              child: const Text('非同期完了後に setState を呼ぶ'),
            ),
            const Divider(height: 32),
            Text('syncActionCount: $syncActionCount'),
            Text('asyncActionCount: $asyncActionCount'),
            const SizedBox(height: 12),
            const _BuildOrderProbeTree(),
            const SizedBox(height: 12),
            const Text(
              '観測ポイント\n'
              '- setState を何回呼んでも build はフレームでまとめて実行される\n'
              '- build の順序はツリー構造（親→子）に従う\n'
              '- 実行順はデバッグコンソールの [BUILD]/[FRAME] ログで確認する',
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildOrderProbeTree extends StatelessWidget {
  const _BuildOrderProbeTree();

  @override
  Widget build(BuildContext context) {
    debugPrint('[BUILD] tree root');
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BuildLeaf(label: 'child-A'),
        _BuildLeaf(label: 'child-B'),
      ],
    );
  }
}

class _BuildLeaf extends StatelessWidget {
  const _BuildLeaf({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    debugPrint('[BUILD] $label');
    return Text('probe: $label');
  }
}
