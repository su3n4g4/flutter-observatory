import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile.dart';

class Ch9P3RiverpodSelectPage extends StatelessWidget {
  const Ch9P3RiverpodSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Scaffold(
        appBar: AppBar(title: const Text('Chapter 9 Part 3: Riverpod select')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'count +1ではCOUNT-TILEのみ、name変更ではNAME-TILEのみが'
                'rebuildされることを確認してください。',
              ),
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, _) => FilledButton(
                  onPressed: () =>
                      ref.read(profileProvider.notifier).incrementCount(),
                  child: const Text('count +1'),
                ),
              ),
              const SizedBox(height: 8),
              Consumer(
                builder: (context, ref, _) => FilledButton(
                  onPressed: () =>
                      ref.read(profileProvider.notifier).toggleName(),
                  child: const Text('name変更'),
                ),
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

class ProfileNotifier extends Notifier<Profile> {
  @override
  Profile build() => const Profile(name: 'alice', count: 0);

  void incrementCount() {
    state = state.copyWith(count: state.count + 1);
    debugPrint('[ACTION] count +1');
  }

  void toggleName() {
    final next = state.name == 'alice' ? 'bob' : 'alice';
    state = state.copyWith(name: next);
    debugPrint('[ACTION] name変更 -> $next');
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, Profile>(
  ProfileNotifier.new,
);

class _NameTile extends ConsumerStatefulWidget {
  const _NameTile();

  @override
  ConsumerState<_NameTile> createState() => _NameTileState();
}

class _NameTileState extends ConsumerState<_NameTile> {
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    _buildCount += 1;
    final name = ref.watch(profileProvider.select((p) => p.name));
    debugPrint('[BUILD] NAME-TILE (#$_buildCount)  name=$name');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text('NAME-TILE  build: $_buildCount  name: $name'),
      ),
    );
  }
}

class _CountTile extends ConsumerStatefulWidget {
  const _CountTile();

  @override
  ConsumerState<_CountTile> createState() => _CountTileState();
}

class _CountTileState extends ConsumerState<_CountTile> {
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    _buildCount += 1;
    final count = ref.watch(profileProvider.select((p) => p.count));
    debugPrint('[BUILD] COUNT-TILE (#$_buildCount)  count=$count');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text('COUNT-TILE  build: $_buildCount  count: $count'),
      ),
    );
  }
}
