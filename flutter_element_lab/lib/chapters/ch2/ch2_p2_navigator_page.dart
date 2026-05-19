import 'package:flutter/material.dart';
import '../../widgets/state_tracker.dart';

class Ch2P2NavigatorPage extends StatelessWidget {
  const Ch2P2NavigatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chapter 2 Part 2: Navigator push/pop')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '次の画面に移動し、戻るボタンで戻ってください。\n'
              '戻ったときのログに dispose が出ます。\n'
              'この画面の State は push 後も生きています。ログに dispose が出ないことで確認できます。',
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
              'Navigator.pop（戻る）ボタンを押すと、この画面と StateTracker の両方が破棄されます。\n'
              'ログに deactivate → dispose の順で出ることを確認してください。',
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Navigator.pop（戻る）'),
            ),
            const Divider(height: 32),
            const StateTracker('PUSHED-PAGE-CHILD'),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
