import 'package:flutter/material.dart';

import '../../widgets/nav_button.dart';
import 'ch7_p1_setstate_trigger_page.dart';
import 'ch7_p2_inherited_trigger_page.dart';
import 'ch7_p3_stream_trigger_page.dart';

class Ch7CatalogPage extends StatelessWidget {
  const Ch7CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Element Tree Lab - Ch7')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Partを選択してください'),
            const SizedBox(height: 16),
            const NavButton(
              title: 'Part 1: setStateによる再構築',
              page: Ch7P1SetstateTriggerPage(),
            ),
            const NavButton(
              title: 'Part 2: InheritedWidgetによる再構築',
              page: Ch7P2InheritedTriggerPage(),
            ),
            const NavButton(
              title: 'Part 3: Streamによる再構築',
              page: Ch7P3StreamTriggerPage(),
            ),
          ],
        ),
      ),
    );
  }
}
