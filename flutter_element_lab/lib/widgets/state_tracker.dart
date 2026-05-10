import 'package:flutter/material.dart';

class StateTracker extends StatefulWidget {
  const StateTracker(this.label, {super.key});
  final String label;

  @override
  State<StateTracker> createState() => _StateTrackerState();
}

class _StateTrackerState extends State<StateTracker> {
  int _buildCount = 0;
  String _lastEvent = 'created';

  @override
  void initState() {
    super.initState();
    _lastEvent = 'created';
    debugPrint('initState: ${widget.label}  state=$hashCode');
  }

  @override
  void didUpdateWidget(covariant StateTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _lastEvent = 'updated (${oldWidget.label} → ${widget.label})';
    debugPrint(
      'didUpdateWidget: ${oldWidget.label} -> ${widget.label}  state=$hashCode',
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    _lastEvent = 'deactivated';
    debugPrint('deactivate: ${widget.label}  state=$hashCode');
  }

  @override
  void activate() {
    super.activate();
    _lastEvent = 'activated';
    debugPrint('activate: ${widget.label}  state=$hashCode');
  }

  @override
  void dispose() {
    debugPrint('dispose: ${widget.label}  state=$hashCode');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // rebuild の原因（setState / InheritedWidget 更新 / 親の更新）に関わらず
    // 必ず呼ばれる場所が build() のみのため、ここでカウントする。
    _buildCount++;
    final element = context as Element; // BuildContextの実体はElement
    debugPrint(
      'build: ${widget.label}  state=$hashCode  '
      'depth=${element.depth}  '
      'widgetType=${widget.runtimeType}  '
      'element=${element.runtimeType}',
    );

    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'StateTracker("${widget.label}")',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text('state id: $hashCode'),
            Text('build count: $_buildCount'),
            Text('last event: $_lastEvent'),
          ],
        ),
      ),
    );
  }
}
