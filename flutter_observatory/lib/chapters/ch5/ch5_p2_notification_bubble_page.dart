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
    pageBuildCount += 1;
    debugPrint('[BUILD] Ch5 P2 page (#$pageBuildCount)');

    return Scaffold(
      appBar: AppBar(title: const Text('Ch5 P2: Notification バブルアップ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '💡 枠が黄色く光る = build() が実行された証拠',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              'この章で確認すること',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '・Notification.dispatch はツリーを子から親へバブルアップする\n'
              '・NotificationListener がバブルアップしてきた通知を捕捉する\n'
              '・捕捉側で setState を呼ぶとページ全体が rebuild される（= P1 との対比）',
              style: TextStyle(fontSize: 13),
            ),
            const Divider(height: 24),

            // ページ
            _LayerLabel('ページ', color: Color(0xFF1976D2)),
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
                  _LayerLabel('リスナー', color: Color(0xFFF57C00)),
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
                        _LayerLabel('利用側', color: Color(0xFF616161)),
                        _DispatchWidget(),
                        _IndependentWidget(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              '起きる現象',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '・ボタン押下で末端から Notification.dispatch\n'
              '・ツリーを上へバブルアップし NotificationListener が捕捉\n'
              '・onNotification 内で setState → Page が rebuild\n'
              '・Page の子（dispatch Leaf も Independent も）すべて rebuild される\n'
              '・P1 と違い「依存登録」に基づく選択的 rebuild ではない',
              style: TextStyle(fontSize: 13),
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
          const _DemoNotification(message: 'leaf -> bubble').dispatch(context);
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
// 層ラベル
// ============================================================

class _LayerLabel extends StatelessWidget {
  const _LayerLabel(this.label, {required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
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