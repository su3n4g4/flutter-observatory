import 'package:flutter/material.dart';

import 'counter_tracker.dart';

class Ch6P2LiftedStatePage extends StatefulWidget {
  const Ch6P2LiftedStatePage({super.key});

  @override
  State<Ch6P2LiftedStatePage> createState() => _Ch6P2LiftedStatePageState();
}

class _Ch6P2LiftedStatePageState extends State<Ch6P2LiftedStatePage> {
  int _liftedCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chapter 6 Part 2: 共通祖先への持ち上げ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '内側のNavigatorでdetailをpush/popしてください。\n'
              '下のLIFTED-HOLDERは共通祖先（内側Navigatorの外）にあるためpush/popで破棄されません。\n'
              'LIFTED-HOLDERの+1は枠外の表示だけを更新し、'
              'detail画面内の表示はpush時点の値のまま変わりません。',
            ),
            const SizedBox(height: 12),
            CounterTracker(
              'LIFTED-HOLDER',
              onCountChanged: (c) => _liftedCount = c,
            ),
            const SizedBox(height: 12),
            const Divider(height: 24),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Navigator(
                  onGenerateRoute: (settings) {
                    return MaterialPageRoute(
                      builder: (_) => _InnerHomePage(
                        getLiftedCount: () => _liftedCount,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InnerHomePage extends StatelessWidget {
  const _InnerHomePage({required this.getLiftedCount});

  final int Function() getLiftedCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('inner home')),
      body: Center(
        child: FilledButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _InnerDetailPage(initialCount: getLiftedCount()),
              ),
            );
          },
          child: const Text('detailへpush（内側push）'),
        ),
      ),
    );
  }
}

class _InnerDetailPage extends StatelessWidget {
  const _InnerDetailPage({required this.initialCount});

  final int initialCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('inner detail')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('push時点のLIFTED-HOLDER count: $initialCount'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('戻る（内側pop）'),
            ),
          ],
        ),
      ),
    );
  }
}
