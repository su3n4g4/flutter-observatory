import 'package:flutter/material.dart';

import '../../widgets/nav_button.dart';
import 'ch9_p1_inherited_of_page.dart';
import 'ch9_p2_value_notifier_page.dart';
import 'ch9_p3_riverpod_select_page.dart';

class Ch9CatalogPage extends StatelessWidget {
  const Ch9CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Element Tree Lab - Ch9')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Partを選択してください'),
            const SizedBox(height: 16),
            const NavButton(
              title: 'Part 1: InheritedWidget.of',
              page: Ch9P1InheritedOfPage(),
            ),
            const NavButton(
              title: 'Part 2: ValueNotifier',
              page: Ch9P2ValueNotifierPage(),
            ),
            const NavButton(
              title: 'Part 3: Riverpod select',
              page: Ch9P3RiverpodSelectPage(),
            ),
          ],
        ),
      ),
    );
  }
}
