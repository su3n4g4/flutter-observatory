import 'package:flutter/material.dart';

import 'profile.dart';

class Ch9P1InheritedOfPage extends StatefulWidget {
  const Ch9P1InheritedOfPage({super.key});

  @override
  State<Ch9P1InheritedOfPage> createState() => _Ch9P1InheritedOfPageState();
}

class _Ch9P1InheritedOfPageState extends State<Ch9P1InheritedOfPage> {
  Profile _profile = const Profile(name: 'alice', count: 0);

  void _incrementCount() {
    debugPrint('[ACTION] count +1');
    setState(() => _profile = _profile.copyWith(count: _profile.count + 1));
  }

  void _toggleName() {
    final next = _profile.name == 'alice' ? 'bob' : 'alice';
    debugPrint('[ACTION] name変更 -> $next');
    setState(() => _profile = _profile.copyWith(name: next));
  }

  @override
  Widget build(BuildContext context) {
    return ProfileScope(
      profile: _profile,
      child: Scaffold(
        appBar: AppBar(title: const Text('Chapter 9 Part 1: InheritedWidget.of')),
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
              _NameTile(),
              const SizedBox(height: 12),
              _CountTile(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileScope extends InheritedWidget {
  const ProfileScope({super.key, required this.profile, required super.child});

  final Profile profile;

  static Profile of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ProfileScope>();
    assert(scope != null, 'ProfileScope is missing in the widget tree');
    return scope!.profile;
  }

  @override
  bool updateShouldNotify(ProfileScope oldWidget) =>
      profile != oldWidget.profile;
}

class _NameTile extends StatefulWidget {
  const _NameTile();

  @override
  State<_NameTile> createState() => _NameTileState();
}

class _NameTileState extends State<_NameTile> {
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    _buildCount += 1;
    final name = ProfileScope.of(context).name;
    debugPrint('[BUILD] NAME-TILE (#$_buildCount)  name=$name');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text('NAME-TILE  build: $_buildCount  name: $name'),
      ),
    );
  }
}

class _CountTile extends StatefulWidget {
  const _CountTile();

  @override
  State<_CountTile> createState() => _CountTileState();
}

class _CountTileState extends State<_CountTile> {
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    _buildCount += 1;
    final count = ProfileScope.of(context).count;
    debugPrint('[BUILD] COUNT-TILE (#$_buildCount)  count=$count');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text('COUNT-TILE  build: $_buildCount  count: $count'),
      ),
    );
  }
}
