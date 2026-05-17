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
      appBar: AppBar(title: const Text('Chapter 4 Part 1: 再構築スケジューリング')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '各ボタンを押してログを確認してください。\n'
              'setState を何回呼んでも build は1フレームにまとめて実行されます。',
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
                const SizedBox(height: 8),
                StateTracker('child-B'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}