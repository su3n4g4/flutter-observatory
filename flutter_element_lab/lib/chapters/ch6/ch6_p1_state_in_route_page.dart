import 'package:flutter/material.dart';

import 'counter_tracker.dart';

class Ch6P1StateInRoutePage extends StatelessWidget {
  const Ch6P1StateInRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chapter 6 Part 1: ルート内配置')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'push後にCounterTrackerを+1し、popしてから再度pushしてください。\n'
              'ルートに直接配置したStateはpopで破棄され、再pushで新しいStateが作られます。',
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const _InRoutePage()),
                );
              },
              child: const Text('push（次画面へ）'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InRoutePage extends StatelessWidget {
  const _InRoutePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IN-ROUTE page')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('戻る（pop）と、このStateは破棄されます。'),
            const SizedBox(height: 12),
            CounterTracker('IN-ROUTE'),
          ],
        ),
      ),
    );
  }
}
