import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../widgets/state_tracker.dart';

class Ch4P1RebuildSchedulingPage extends StatefulWidget {
  const Ch4P1RebuildSchedulingPage({super.key});

  @override
  State<Ch4P1RebuildSchedulingPage> createState() =>
      _Ch4P1RebuildSchedulingPageState();
}

class _Ch4P1RebuildSchedulingPageState extends State<Ch4P1RebuildSchedulingPage> {
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
      appBar: AppBar(title: const Text('Ch4 P1: 再構築スケジューリング')),
      body: SingleChildScrollView(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StateTracker('child-A'),
                SizedBox(height: 8),
                StateTracker('child-B'),
              ],
            ),
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