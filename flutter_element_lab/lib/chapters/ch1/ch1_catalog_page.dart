import 'package:flutter/material.dart';

import '../../widgets/nav_button.dart';
import 'p1_reorder_no_key_page.dart';
import 'p1_reorder_with_key_page.dart';
import 'p2_conditional_page.dart';
import 'p3_move_parent_page.dart';

class Ch1CatalogPage extends StatelessWidget {
  const Ch1CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Element Tree Lab - Ch1')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Partを選択してください',
            ),
            const SizedBox(height: 16),
            const NavButton(title: 'Part 1: 並べ替え（Keyなし）', page: P1ReorderNoKeyPage()),
            const NavButton(title: 'Part 1: 並べ替え（Keyあり）', page: P1ReorderWithKeyPage()),
            const NavButton(title: 'Part 2: 条件付き挿入・削除', page: P2ConditionalPage()),
            const NavButton(title: 'Part 3: 親の切り替え', page: P3MoveParentPage()),
          ],
        ),
      ),
    );
  }
}
