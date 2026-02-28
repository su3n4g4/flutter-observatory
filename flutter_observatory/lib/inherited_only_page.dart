import 'package:flutter/material.dart';

class InheritedOnlyPage extends StatefulWidget {
  const InheritedOnlyPage({super.key});

  @override
  State<InheritedOnlyPage> createState() => _InheritedOnlyPageState();
}

class _InheritedOnlyPageState extends State<InheritedOnlyPage> {
  int inheritedValue = 0;

  void _increment() => setState(() => inheritedValue += 1);

  @override
  Widget build(BuildContext context) {
    debugPrint('[BUILD] page');

    return Scaffold(
      appBar: AppBar(title: const Text('Inherited only')),
      body: _DependencyScope(
        value: inheritedValue,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: _increment,
                child: const Text('value++'),
              ),
              const SizedBox(height: 12),
              Text('inheritedValue: $inheritedValue'),
              const SizedBox(height: 12),
              const _DependentConsumer(),
              const SizedBox(height: 8),
              const _IndependentWidget(),
            ],
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
    assert(scope != null);
    return scope!;
  }

  @override
  bool updateShouldNotify(_DependencyScope oldWidget) {
    debugPrint('[Inherited] updateShouldNotify old=${oldWidget.value} new=$value');
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('[Dependent] didChangeDependencies');
  }

  @override
  Widget build(BuildContext context) {
    buildCount += 1;
    final value = _DependencyScope.of(context).value;
    debugPrint('[BUILD] dependent (#$buildCount) value=$value');
    return Text('dependent: value=$value / buildCount=$buildCount');
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
    debugPrint('[BUILD] independent (#$buildCount)');
    return Text('independent: buildCount=$buildCount');
  }
}