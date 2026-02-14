import 'package:flutter/material.dart';

class Probe extends StatefulWidget {
  const Probe(this.label, {super.key});
  final String label;

  @override
  State<Probe> createState() => _ProbeState();
}

class _ProbeState extends State<Probe> {
  @override
  void initState() {
    super.initState();
    debugPrint('initState: ${widget.label}  state=$hashCode');
  }

  @override
  void didUpdateWidget(covariant Probe oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint(
      'didUpdateWidget: ${oldWidget.label} -> ${widget.label}  state=$hashCode',
    );
  }

  @override
  void dispose() {
    debugPrint('dispose: ${widget.label}  state=$hashCode');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final element = context as Element; // BuildContextの実体
    debugPrint(
      'build: ${widget.label}  state=$hashCode  '
      'depth=${element.depth}  '
      'widgetType=${widget.runtimeType}  '
      'element=${element.runtimeType}',
    );
    debugPrint('===============================================');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        widget.label,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
