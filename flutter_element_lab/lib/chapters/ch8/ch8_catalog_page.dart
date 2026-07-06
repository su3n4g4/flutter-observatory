import 'package:flutter/material.dart';

import '../../widgets/nav_button.dart';
import 'ch8_p1_no_key_swap_page.dart';
import 'ch8_p2_value_key_swap_page.dart';
import 'ch8_p3_global_key_reparent_page.dart';
import 'ch8_p4_riverpod_survival_page.dart';

class Ch8CatalogPage extends StatelessWidget {
  const Ch8CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Element Tree Lab - Ch8')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Partを選択してください'),
            const SizedBox(height: 16),
            const NavButton(
              title: 'Part 1: Keyなしで順序を入れ替え',
              page: Ch8P1NoKeySwapPage(),
            ),
            const NavButton(
              title: 'Part 2: ValueKeyで順序を入れ替え',
              page: Ch8P2ValueKeySwapPage(),
            ),
            const NavButton(
              title: 'Part 3: GlobalKeyで親をまたいで移動',
              page: Ch8P3GlobalKeyReparentPage(),
            ),
            const NavButton(
              title: 'Part 4: Riverpodでの同一性維持',
              page: Ch8P4RiverpodSurvivalPage(),
            ),
          ],
        ),
      ),
    );
  }
}
