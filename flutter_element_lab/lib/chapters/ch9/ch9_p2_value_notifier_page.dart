import 'package:flutter/material.dart';

import 'profile.dart';

class Ch9P2ValueNotifierPage extends StatefulWidget {
  const Ch9P2ValueNotifierPage({super.key});

  @override
  State<Ch9P2ValueNotifierPage> createState() =>
      _Ch9P2ValueNotifierPageState();
}

class _Ch9P2ValueNotifierPageState extends State<Ch9P2ValueNotifierPage> {
  final ValueNotifier<Profile> _notifier =
      ValueNotifier<Profile>(const Profile(name: 'alice', count: 0));

  void _incrementCount() {
    debugPrint('[ACTION] count +1');
    _notifier.value =
        _notifier.value.copyWith(count: _notifier.value.count + 1);
  }

  void _toggleName() {
    final next = _notifier.value.name == 'alice' ? 'bob' : 'alice';
    debugPrint('[ACTION] name変更 -> $next');
    _notifier.value = _notifier.value.copyWith(name: next);
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chapter 9 Part 2: ValueNotifier')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'count +1 と name変更 のそれぞれで、'
              'NAME-TILEとCOUNT-TILEの両方がrebuildされることを確認してください。',
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _incrementCount,
              child: const Text('count +1'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _toggleName,
              child: const Text('name変更'),
            ),
            const Divider(height: 24),
            ValueListenableBuilder<Profile>(
              valueListenable: _notifier,
              builder: (context, profile, _) => _NameTile(name: profile.name),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<Profile>(
              valueListenable: _notifier,
              builder: (context, profile, _) => _CountTile(count: profile.count),
            ),
          ],
        ),
      ),
    );
  }
}

class _NameTile extends StatefulWidget {
  const _NameTile({required this.name});

  final String name;

  @override
  State<_NameTile> createState() => _NameTileState();
}

class _NameTileState extends State<_NameTile> {
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    _buildCount += 1;
    debugPrint('[BUILD] NAME-TILE (#$_buildCount)  name=${widget.name}');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text('NAME-TILE  build: $_buildCount  name: ${widget.name}'),
      ),
    );
  }
}

class _CountTile extends StatefulWidget {
  const _CountTile({required this.count});

  final int count;

  @override
  State<_CountTile> createState() => _CountTileState();
}

class _CountTileState extends State<_CountTile> {
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    _buildCount += 1;
    debugPrint('[BUILD] COUNT-TILE (#$_buildCount)  count=${widget.count}');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text('COUNT-TILE  build: $_buildCount  count: ${widget.count}'),
      ),
    );
  }
}
