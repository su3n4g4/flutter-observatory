import 'package:flutter/material.dart';
import 'lifecycle_probe.dart';

class Ch2P2NavigatorPage extends StatelessWidget {
  const Ch2P2NavigatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ch2 P2: Navigator push/pop')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '操作：push で次画面へ、pop で戻る。\n'
              '観測：pop すると次画面ツリーが unmount され dispose が呼ばれる。',
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const _SecondRoutePage()),
                );
              },
              child: const Text('Navigator.push（次画面へ）'),
            ),
            const Divider(height: 32),
            const Text(
              '注：このページのウィジェットは push では破棄されない。\n'
              '（前面から外れるだけで、Route は残る）',
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondRoutePage extends StatefulWidget {
  const _SecondRoutePage();

  @override
  State<_SecondRoutePage> createState() => _SecondRoutePageState();
}

class _SecondRoutePageState extends State<_SecondRoutePage> {
  @override
  void initState() {
    super.initState();
    debugPrint('SecondRoute: initState');
  }

  @override
  void dispose() {
    debugPrint('SecondRoute: dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('SecondRoute: build');
    return Scaffold(
      appBar: AppBar(title: const Text('Second Route')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'この画面は pop で破棄される（unmount→dispose）。\n'
              '下の Probe の dispose も確認する。',
            ),
            const SizedBox(height: 12),
            const LifecycleProbe('SECOND-ROUTE-CHILD'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Navigator.pop（戻る）'),
            ),
          ],
        ),
      ),
    );
  }
}
