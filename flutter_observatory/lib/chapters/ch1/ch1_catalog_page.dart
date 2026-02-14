import 'package:flutter/material.dart';

import 'p1_reorder_no_key_page.dart';
import 'p1_reorder_with_key_page.dart';
import 'p2_conditional_page.dart';
import 'p3_move_parent_page.dart';

class Ch1CatalogPage extends StatelessWidget {
  const Ch1CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget navButton(String title, Widget page) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: FilledButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => page),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(title),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Element Tree Lab - Ch1')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '目的：Elementツリーが管理する「親子・位置(slot/index)・生死」を観測で確定する。',
            ),
            const SizedBox(height: 16),
            navButton('P1: Reorder（Keyなし）', const P1ReorderNoKeyPage()),
            navButton('P1: Reorder（Keyあり）', const P1ReorderWithKeyPage()),
            navButton('P2: Conditional Insert/Remove', const P2ConditionalPage()),
            navButton('P3: Move Between Parents', const P3MoveParentPage()),
          ],
        ),
      ),
    );
  }
}
