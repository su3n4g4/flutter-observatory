import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    debugPrint('[BUILD] page');

    return Scaffold(
      appBar: AppBar(title: const Text('Notification')),
      body: NotificationListener<_DemoNotification>(
        onNotification: (n) {
          debugPrint('[NOTIFICATION] received: ${n.message}');
          setState(() => count += 1);
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('notificationCount: $count'),
              const SizedBox(height: 12),
              const _NotificationDispatchLeaf(),
              const SizedBox(height: 12),
              const _IndependentWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationDispatchLeaf extends StatelessWidget {
  const _NotificationDispatchLeaf();

  @override
  Widget build(BuildContext context) {
    debugPrint('[BUILD] leaf');
    return FilledButton(
      onPressed: () {
        const _DemoNotification(message: 'leaf -> bubble').dispatch(context);
      },
      child: const Text('dispatch'),
    );
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

class _DemoNotification extends Notification {
  const _DemoNotification({required this.message});
  final String message;
}