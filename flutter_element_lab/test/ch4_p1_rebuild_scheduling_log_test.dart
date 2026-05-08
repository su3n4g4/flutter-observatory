import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_element_lab/chapters/ch4/ch4_p1_rebuild_scheduling_page.dart';

void main() {
  testWidgets('Ch4P1 rebuild scheduling logs', (WidgetTester tester) async {
    final logs = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) logs.add(message);
    };

    try {
      // [1] 初期表示
      await tester.pumpWidget(
        const MaterialApp(home: Ch4P1RebuildSchedulingPage()),
      );
      await tester.pump(); // post frame callback を処理

      // [2] 同一イベントで setState を3回
      await tester.tap(find.text('同一イベントで setState を3回呼ぶ'));
      await tester.pump();

      // [3] もう一度
      await tester.tap(find.text('同一イベントで setState を3回呼ぶ'));
      await tester.pump();

      // [4] 非同期 setState
      await tester.tap(find.text('非同期完了後に setState を呼ぶ'));
      await tester.pump(); // 即時フレーム（async started）
      await tester.pump(const Duration(milliseconds: 400)); // 350ms 待機後
      await tester.pump(); // post frame callback
    } finally {
      debugPrint = originalDebugPrint;
    }

    // ignore: avoid_print
    for (final log in logs) { print(log); }
  });
}
