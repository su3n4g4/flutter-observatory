import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Ch8P4RiverpodSurvivalPage extends StatefulWidget {
  const Ch8P4RiverpodSurvivalPage({super.key});

  @override
  State<Ch8P4RiverpodSurvivalPage> createState() =>
      _Ch8P4RiverpodSurvivalPageState();
}

class _Ch8P4RiverpodSurvivalPageState
    extends State<Ch8P4RiverpodSurvivalPage> {
  bool _showConsumer = true;

  void _toggleConsumer() {
    debugPrint(
      _showConsumer
          ? '[ACTION] consumerを破棄（Widgetをツリーから外す）'
          : '[ACTION] consumerを再表示',
    );
    setState(() => _showConsumer = !_showConsumer);
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Scaffold(
        appBar: AppBar(title: const Text('Chapter 8 Part 4: Riverpodでの同一性維持')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '+1してから「consumerを破棄」→「再表示」してください。\n'
                'Notifierの状態はProviderScopeが維持しているため、'
                '再表示後もcountは残り、buildカウントだけ#1に戻ります。',
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _toggleConsumer,
                child: Text(_showConsumer ? 'consumerを破棄' : 'consumerを再表示'),
              ),
              const Divider(height: 24),
              _showConsumer ? _CounterConsumer() : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class Ch8Counter extends Notifier<int> {
  @override
  int build() {
    ref.onDispose(() => debugPrint('dispose: Ch8Counter  notifier=$hashCode'));
    debugPrint('create: Ch8Counter  notifier=$hashCode');
    return 0;
  }

  void increment() {
    state++;
    debugPrint('[ACTION] increment -> $state');
  }
}

final ch8CounterProvider = NotifierProvider<Ch8Counter, int>(Ch8Counter.new);

class _CounterConsumer extends ConsumerStatefulWidget {
  const _CounterConsumer();

  @override
  ConsumerState<_CounterConsumer> createState() => _CounterConsumerState();
}

class _CounterConsumerState extends ConsumerState<_CounterConsumer> {
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    _buildCount += 1;
    final count = ref.watch(ch8CounterProvider);
    debugPrint('[BUILD] consumer (#$_buildCount)  count=$count');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('consumer build: $_buildCount'),
            Text('count: $count'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => ref.read(ch8CounterProvider.notifier).increment(),
              child: const Text('+1'),
            ),
          ],
        ),
      ),
    );
  }
}
