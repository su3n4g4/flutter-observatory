import 'package:flutter/material.dart';

import 'widget_box.dart';

class Ch5P2NotificationBubblePage extends StatefulWidget {
  const Ch5P2NotificationBubblePage({super.key});

  @override
  State<Ch5P2NotificationBubblePage> createState() =>
      _Ch5P2NotificationBubblePageState();
}

class _Ch5P2NotificationBubblePageState
    extends State<Ch5P2NotificationBubblePage> {
  int notificationCount = 0;
  int pageBuildCount = 0;

  @override
  Widget build(BuildContext context) {
    // rebuild の原因（setState / InheritedWidget 更新 / 親の更新）に関わらず
    // 必ず呼ばれる場所が build() のみのため、ここでカウントする。
    pageBuildCount += 1;
    debugPrint('[BUILD] Ch5 P2 page (#$pageBuildCount)');

    return Scaffold(
      appBar: AppBar(title: const Text('Chapter 5 Part 2: Notificationのバブルアップ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'ボタンを押して、どの枠が光るかを確認してください。\n'
              'Part 1 と違い、通知に関与していない Widget も含めてすべて rebuild されます。',
              style: TextStyle(fontSize: 13),
            ),
            const Divider(height: 24),
            // ページ
            LayerLabel('ページ', color: Color(0xFF1976D2)),
            WidgetBox(
              kind: WidgetKind.stateful,
              name: 'Ch5P2NotificationBubblePage',
              role: 'ページ本体。onNotification で setState する',
              badges: ['notificationCount: $notificationCount'],
              buildCount: pageBuildCount,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // リスナー
                  LayerLabel('リスナー', color: Color(0xFFF57C00)),
                  _VisualNotificationListener(
                    onNotification: (notification) {
                      debugPrint(
                          '[NOTIFICATION] received: ${notification.message}');
                      setState(() => notificationCount += 1);
                      return true;
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 利用側
                        LayerLabel('利用側', color: Color(0xFF616161)),
                        _DispatchWidget(),
                        _IndependentWidget(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// NotificationListener の可視化ラッパー
// ============================================================

class _VisualNotificationListener extends StatefulWidget {
  const _VisualNotificationListener({
    required this.onNotification,
    required this.child,
  });
  final bool Function(_DemoNotification) onNotification;
  final Widget child;

  @override
  State<_VisualNotificationListener> createState() =>
      _VisualNotificationListenerState();
}

class _VisualNotificationListenerState
    extends State<_VisualNotificationListener> {
  int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    // rebuild の原因（setState / InheritedWidget 更新 / 親の更新）に関わらず
    // 必ず呼ばれる場所が build() のみのため、ここでカウントする。
    buildCount += 1;
    return WidgetBox(
      kind: WidgetKind.listener,
      name: '_NotificationListener',
      role: 'バブルアップしてきた通知を捕捉する',
      badges: const ['onNotification'],
      buildCount: buildCount,
      child: NotificationListener<_DemoNotification>(
        onNotification: widget.onNotification,
        child: widget.child,
      ),
    );
  }
}

// ============================================================
// dispatchする末端Widget
// ============================================================

class _DispatchWidget extends StatefulWidget {
  const _DispatchWidget();

  @override
  State<_DispatchWidget> createState() =>
      _DispatchWidgetState();
}

class _DispatchWidgetState extends State<_DispatchWidget> {
  int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    // rebuild の原因（setState / InheritedWidget 更新 / 親の更新）に関わらず
    // 必ず呼ばれる場所が build() のみのため、ここでカウントする。
    buildCount += 1;
    debugPrint('[BUILD] dispatch widget (#$buildCount)');

    return WidgetBox(
      kind: WidgetKind.stateful,
      name: '_DispatchWidget',
      role: 'dispatch する',
      badges: const ['dispatch: ✓'],
      buildCount: buildCount,
      child: FilledButton.tonal(
        onPressed: () {
          const _DemoNotification(message: 'dispatch -> bubble').dispatch(context);
        },
        child: const Text('Notification.dispatch で親へ通知する'),
      ),
    );
  }
}

// ============================================================
// 対照群：通知に関与しないWidget
// ============================================================

class _IndependentWidget extends StatefulWidget {
  const _IndependentWidget();

  @override
  State<_IndependentWidget> createState() => _IndependentWidgetState();
}

class _IndependentWidgetState extends State<_IndependentWidget> {
  int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    // rebuild の原因（setState / InheritedWidget 更新 / 親の更新）に関わらず
    // 必ず呼ばれる場所が build() のみのため、ここでカウントする。
    buildCount += 1;
    debugPrint('[BUILD] independent widget (#$buildCount)');

    return WidgetBox(
      kind: WidgetKind.stateful,
      name: '_IndependentWidget',
      role: 'dispatch しない',
      badges: const ['dispatch: ✗'],
      buildCount: buildCount,
      child: const Text('それでもページ全体の rebuild に巻き込まれる'),
    );
  }
}

// ============================================================
// Notification 型
// ============================================================

class _DemoNotification extends Notification {
  const _DemoNotification({required this.message});

  final String message;
}