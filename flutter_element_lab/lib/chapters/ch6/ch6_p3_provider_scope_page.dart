import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Ch6P3ProviderScopePage extends StatelessWidget {
  const Ch6P3ProviderScopePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CounterModel>(
      create: (_) => CounterModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Chapter 6 Part 3: ChangeNotifierProviderで供給')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '内側のNavigatorでdetailをpush/popしてください。\n'
                '+1を押すと、表示中のdetail画面だけでなく、'
                '隠れているhome画面もrebuildされるかを確認します。',
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (context) => FilledButton(
                  onPressed: () => context.read<CounterModel>().increment(),
                  child: const Text('CounterModel.increment（+1）'),
                ),
              ),
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
                        builder: (_) => const _InnerHomePage(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CounterModel extends ChangeNotifier {
  int count = 0;

  void increment() {
    count += 1;
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('dispose: CounterModel');
    super.dispose();
  }
}

class _InnerHomePage extends StatelessWidget {
  const _InnerHomePage();

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CounterModel>().count;
    debugPrint('[BUILD] inner home  count=$count');
    return Scaffold(
      appBar: AppBar(title: const Text('inner home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('count: $count'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const _InnerDetailPage()),
                );
              },
              child: const Text('detailへpush（内側push）'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InnerDetailPage extends StatelessWidget {
  const _InnerDetailPage();

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CounterModel>().count;
    debugPrint('[BUILD] inner detail  count=$count');
    return Scaffold(
      appBar: AppBar(title: const Text('inner detail')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('count: $count'),
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
