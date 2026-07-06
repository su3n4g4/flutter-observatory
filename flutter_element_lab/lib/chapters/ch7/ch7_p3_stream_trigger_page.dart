import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Ch7P3StreamTriggerPage extends StatefulWidget {
  const Ch7P3StreamTriggerPage({super.key});

  @override
  State<Ch7P3StreamTriggerPage> createState() =>
      _Ch7P3StreamTriggerPageState();
}

class _Ch7P3StreamTriggerPageState extends State<Ch7P3StreamTriggerPage> {
  final StreamController<int> _controller = StreamController<int>.broadcast();
  late final StreamSubscription<int> _subscription;
  int _value = 0;

  @override
  void initState() {
    super.initState();
    _subscription = _controller.stream.listen((count) {
      debugPrint(
        '[STREAM] listenコールバック  count=$count  '
        'phase=${SchedulerBinding.instance.schedulerPhase}',
      );
    });
  }

  void _onTap() {
    _value += 1;
    debugPrint(
      '[TAP] sink.add($_value)  phase=${SchedulerBinding.instance.schedulerPhase}',
    );
    _controller.sink.add(_value);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chapter 7 Part 3: Streamによる再構築')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'ボタンを押して、[TAP] -> [STREAM] -> [BUILD] の順序とphaseを確認してください。\n'
              '[STREAM]のphaseがidleのままであることが検証の要点です。',
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _onTap,
              child: const Text('sink.addを呼ぶ'),
            ),
            const Divider(height: 24),
            StreamBuilder<int>(
              stream: _controller.stream,
              initialData: 0,
              builder: (context, snapshot) {
                return _TileStream(count: snapshot.data ?? 0);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TileStream extends StatefulWidget {
  const _TileStream({required this.count});

  final int count;

  @override
  State<_TileStream> createState() => _TileStreamState();
}

class _TileStreamState extends State<_TileStream> {
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    _buildCount += 1;
    debugPrint(
      '[BUILD] TILE-STREAM (#$_buildCount)  '
      'phase=${SchedulerBinding.instance.schedulerPhase}',
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text('TILE-STREAM  build: $_buildCount  count: ${widget.count}'),
      ),
    );
  }
}
