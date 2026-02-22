import 'package:flutter/material.dart';

class Ch5P1DependencyNotificationPage extends StatefulWidget {
  const Ch5P1DependencyNotificationPage({super.key});

  @override
  State<Ch5P1DependencyNotificationPage> createState() =>
      _Ch5P1DependencyNotificationPageState();
}

class _Ch5P1DependencyNotificationPageState extends State<Ch5P1DependencyNotificationPage> {
  int inheritedValue = 0;
  int notificationCount = 0;

  void _incrementInheritedValue() {
    setState(() => inheritedValue += 1);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[BUILD] Ch5 page');

    return Scaffold(
      appBar: AppBar(title: const Text('Ch5 P1: 依存・通知管理')),
      body: NotificationListener<_DemoNotification>(
        onNotification: (notification) {
          debugPrint('[NOTIFICATION] received: ${notification.message}');
          setState(() => notificationCount += 1);
          return true;
        },
        child: _DependencyScope(
          value: inheritedValue,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'この章で説明すること\n'
                  '- Element は「誰が誰に依存しているか」を管理している',
                ),
                const SizedBox(height: 12),
                const Text(
                  '必要な情報\n'
                  '- InheritedElement\n'
                  '- dependOnInheritedWidgetOfExactType\n'
                  '- Notification のバブルアップ',
                ),
                const SizedBox(height: 12),
                const Text(
                  '照合するコード\n'
                  '- InheritedElement.updateDependencies\n'
                  '- InheritedElement.notifyClients\n'
                  '- Notification.dispatch',
                ),
                const SizedBox(height: 12),
                const Text(
                  'アプリ側の操作例\n'
                  '- InheritedWidget / Provider / Riverpod\n'
                  '- NotificationListener',
                ),
                const Divider(height: 24),
                FilledButton(
                  onPressed: _incrementInheritedValue,
                  child: const Text('依存元の値を更新する（InheritedWidget を更新）'),
                ),
                const SizedBox(height: 12),
                Text('inheritedValue: $inheritedValue'),
                Text('notificationCount: $notificationCount'),
                const SizedBox(height: 12),
                const _DependentConsumer(),
                const SizedBox(height: 8),
                const _IndependentWidget(),
                const SizedBox(height: 8),
                const _NotificationDispatchLeaf(),
                const SizedBox(height: 12),
                const Text(
                  '起きる現象\n'
                  '- 依存先が変わると build が走る\n'
                  '- 依存していない Widget は rebuild されない',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DependencyScope extends InheritedWidget {
  const _DependencyScope({required super.child, required this.value});

  final int value;

  static _DependencyScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_DependencyScope>();
    assert(scope != null, '_DependencyScope is missing in the widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(_DependencyScope oldWidget) {
    return value != oldWidget.value;
  }
}

class _DependentConsumer extends StatefulWidget {
  const _DependentConsumer();

  @override
  State<_DependentConsumer> createState() => _DependentConsumerState();
}

class _DependentConsumerState extends State<_DependentConsumer> {
  int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    buildCount += 1;
    final value = _DependencyScope.of(context).value;
    debugPrint('[BUILD] dependent consumer (#$buildCount) value=$value');

    return Text('依存あり Consumer: value=$value / buildCount=$buildCount');
  }
}

class _IndependentWidget extends StatefulWidget {
  const _IndependentWidget();

  @override
  State<_IndependentWidget> createState() => _IndependentWidgetState();
}

class _IndependentWidgetState extends State<_IndependentWidget> {
  int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    buildCount += 1;
    debugPrint('[BUILD] independent widget (#$buildCount)');
    return Text('依存なし Widget: buildCount=$buildCount');
  }
}

class _NotificationDispatchLeaf extends StatelessWidget {
  const _NotificationDispatchLeaf();

  @override
  Widget build(BuildContext context) {
    debugPrint('[BUILD] notification leaf');

    return FilledButton.tonal(
      onPressed: () {
        const _DemoNotification(message: 'leaf -> bubble').dispatch(context);
      },
      child: const Text('Notification.dispatch で親へ通知する'),
    );
  }
}

class _DemoNotification extends Notification {
  const _DemoNotification({required this.message});

  final String message;
}
