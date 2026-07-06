import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Ch7P1SetstateTriggerPage extends StatefulWidget {
  const Ch7P1SetstateTriggerPage({super.key});

  @override
  State<Ch7P1SetstateTriggerPage> createState() =>
      _Ch7P1SetstateTriggerPageState();
}

class _Ch7P1SetstateTriggerPageState extends State<Ch7P1SetstateTriggerPage> {
  int _tapCount = 0;

  void _onTap() {
    debugPrint(
      '[TAP] setState  phase=${SchedulerBinding.instance.schedulerPhase}',
    );
    setState(() => _tapCount += 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chapter 7 Part 1: setStateによる再構築')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'ボタンを押して、[TAP]と[BUILD]のphaseの違いを確認してください。',
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _onTap,
              child: const Text('setStateを呼ぶ'),
            ),
            const Divider(height: 24),
            Text('tapCount: $_tapCount'),
            const SizedBox(height: 12),
            _TileSetState(tapCount: _tapCount),
          ],
        ),
      ),
    );
  }
}

class _TileSetState extends StatefulWidget {
  const _TileSetState({required this.tapCount});

  final int tapCount;

  @override
  State<_TileSetState> createState() => _TileSetStateState();
}

class _TileSetStateState extends State<_TileSetState> {
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    _buildCount += 1;
    debugPrint(
      '[BUILD] TILE-SETSTATE (#$_buildCount)  '
      'phase=${SchedulerBinding.instance.schedulerPhase}',
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'TILE-SETSTATE  build: $_buildCount  tapCount: ${widget.tapCount}',
        ),
      ),
    );
  }
}
