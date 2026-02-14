import 'package:flutter/material.dart';

class LifecycleProbe extends StatefulWidget {
  const LifecycleProbe(this.label, {super.key});
  final String label;

  @override
  State<LifecycleProbe> createState() => _LifecycleProbeState();
}

class _LifecycleProbeState extends State<LifecycleProbe> {
  @override
  void initState() {
    super.initState();
    debugPrint('initState: ${widget.label} state=$hashCode');
  }

  @override
  void didUpdateWidget(covariant LifecycleProbe oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('didUpdateWidget: ${oldWidget.label} -> ${widget.label} state=$hashCode');
  }

  @override
  void deactivate() {
    super.deactivate();
    debugPrint('deactivate: ${widget.label} state=$hashCode');
  }

  @override
  void activate() {
    super.activate();
    debugPrint('activate: ${widget.label} state=$hashCode');
  }

  @override
  void dispose() {
    debugPrint('dispose: ${widget.label} state=$hashCode');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build: ${widget.label} state=$hashCode');
    debugPrint('-----------------------------------------------');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(widget.label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
