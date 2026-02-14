import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_observatory/app.dart';

void main() {
  testWidgets('root catalog shows chapter entries', (WidgetTester tester) async {
    await tester.pumpWidget(const ElementTreeLabApp());

    expect(find.text('Chapter 1: Element Tree'), findsOneWidget);
    expect(find.text('Chapter 2: Lifecycle'), findsOneWidget);
    expect(find.text('Chapter 3: Rebuild Scheduling'), findsOneWidget);
  });
}
