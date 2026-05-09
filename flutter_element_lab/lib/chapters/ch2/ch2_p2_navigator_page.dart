import 'package:flutter/material.dart';
import '../../widgets/state_tracker.dart';

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
                  MaterialPageRoute(builder: (_) => const _PushedPage()),
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

class _PushedPage extends StatefulWidget {
  const _PushedPage();

  @override
  State<_PushedPage> createState() => _PushedPageState();
}

class _PushedPageState extends State<_PushedPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('PushedPage: initState');
  }

  @override
  void deactivate() {
    debugPrint('PushedPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint('PushedPage: dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('PushedPage: build');
    return Scaffold(
      appBar: AppBar(title: const Text('Pushed Page')),
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
            const StateTracker('PUSHED-PAGE-CHILD'),
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
