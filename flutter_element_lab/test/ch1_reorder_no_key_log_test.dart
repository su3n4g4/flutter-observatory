import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_element_lab/chapters/ch1/p1_reorder_no_key_page.dart';

void main() {
  testWidgets('P1ReorderNoKeyPage lifecycle logs', (WidgetTester tester) async {
    final logs = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) logs.add(message);
    };

    try {
      // ignore: avoid_print
      print('\n=== [1] 初期表示 (A, B, C) ===');
      await tester.pumpWidget(
        const MaterialApp(home: P1ReorderNoKeyPage()),
      );
      await tester.pump();

      // ignore: avoid_print
      print('\n=== [2] Reverse ボタン押下 (C, B, A) ===');
      await tester.tap(find.text('Reverse'));
      await tester.pump();

      // ignore: avoid_print
      print('\n=== [3] 再度 Reverse ボタン押下 (A, B, C) ===');
      await tester.tap(find.text('Reverse'));
      await tester.pump();
    } finally {
      debugPrint = originalDebugPrint;
    }

    // ignore: avoid_print
    print('\n=== 全ログ (${logs.length}件) ===');
    for (final log in logs) { print(log); } // ignore: avoid_print
  });
}
