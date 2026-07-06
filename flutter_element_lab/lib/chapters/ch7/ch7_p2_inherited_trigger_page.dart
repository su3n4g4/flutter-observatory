import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Ch7P2InheritedTriggerPage extends StatefulWidget {
  const Ch7P2InheritedTriggerPage({super.key});

  @override
  State<Ch7P2InheritedTriggerPage> createState() =>
      _Ch7P2InheritedTriggerPageState();
}

class _Ch7P2InheritedTriggerPageState
    extends State<Ch7P2InheritedTriggerPage> {
  int _value = 0;
  int _buildCount = 0;

  void _onTap() {
    debugPrint(
      '[TAP] 親のsetState  phase=${SchedulerBinding.instance.schedulerPhase}',
    );
    setState(() => _value += 1);
  }

  @override
  Widget build(BuildContext context) {
    _buildCount += 1;
    debugPrint(
      '[BUILD] provider-parent (#$_buildCount)  '
      'phase=${SchedulerBinding.instance.schedulerPhase}',
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Chapter 7 Part 2: InheritedWidgetによる再構築')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'ボタンを押して、[TAP] -> [BUILD] provider-parent -> [DEPEND] -> [BUILD] TILE-INHERITED\n'
              'の順序とphaseを確認してください。',
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _onTap,
              child: const Text('親のsetStateを呼ぶ'),
            ),
            const Divider(height: 24),
            _ValueScope(
              value: _value,
              child: _TileInherited(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueScope extends InheritedWidget {
  const _ValueScope({required this.value, required super.child});

  final int value;

  static int of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_ValueScope>();
    assert(scope != null, '_ValueScope is missing in the widget tree');
    return scope!.value;
  }

  @override
  bool updateShouldNotify(_ValueScope oldWidget) => value != oldWidget.value;
}

class _TileInherited extends StatefulWidget {
  const _TileInherited();

  @override
  State<_TileInherited> createState() => _TileInheritedState();
}

class _TileInheritedState extends State<_TileInherited> {
  int _buildCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint(
      '[DEPEND] didChangeDependencies: TILE-INHERITED  '
      'phase=${SchedulerBinding.instance.schedulerPhase}',
    );
  }

  @override
  Widget build(BuildContext context) {
    _buildCount += 1;
    final value = _ValueScope.of(context);
    debugPrint(
      '[BUILD] TILE-INHERITED (#$_buildCount)  '
      'phase=${SchedulerBinding.instance.schedulerPhase}',
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text('TILE-INHERITED  build: $_buildCount  value: $value'),
      ),
    );
  }
}
