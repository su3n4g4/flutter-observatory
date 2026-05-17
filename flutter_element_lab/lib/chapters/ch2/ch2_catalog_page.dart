import 'package:flutter/material.dart';

import '../../widgets/nav_button.dart';
import 'ch2_p1_if_remove_page.dart';
import 'ch2_p2_navigator_page.dart';
import 'ch2_p3_globalkey_move_page.dart';

class Ch2CatalogPage extends StatelessWidget {
  const Ch2CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Element Tree Lab - Ch2')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Partを選択してください'),
            const SizedBox(height: 16),
            const NavButton(title: 'Part 1: if で消す（dispose）', page: Ch2P1IfRemovePage()),
            const NavButton(title: 'Part 2: Navigator push/pop', page: Ch2P2NavigatorPage()),
            const NavButton(title: 'Part 3: GlobalKey で移動', page: Ch2P3GlobalKeyMovePage()),
          ],
        ),
      ),
    );
  }
}
