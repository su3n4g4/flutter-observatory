import 'package:flutter/material.dart';

import '../../widgets/nav_button.dart';
import 'ch4_p1_rebuild_scheduling_page.dart';

class Ch4CatalogPage extends StatelessWidget {
  const Ch4CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Element Tree Lab - Ch4')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Partを選択してください'),
            const SizedBox(height: 16),
            const NavButton(title: 'Part 1: setState と再構築スケジューリング', page: Ch4P1RebuildSchedulingPage()),
          ],
        ),
      ),
    );
  }
}
