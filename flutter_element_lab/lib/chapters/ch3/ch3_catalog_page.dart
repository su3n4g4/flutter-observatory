import 'package:flutter/material.dart';

import '../../widgets/nav_button.dart';
import 'ch3_p1_no_key_page.dart';
import 'ch3_p2_value_key_page.dart';
import 'ch3_p3_global_key_page.dart';

class Ch3CatalogPage extends StatelessWidget {
  const Ch3CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Element Tree Lab - Ch3')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Partを選択してください'),
            const SizedBox(height: 16),
            const NavButton(title: 'Part 1: 並べ替え（Keyなし）', page: Ch3P1NoKeyPage()),
            const NavButton(title: 'Part 2: 並べ替え（ValueKey）', page: Ch3P2ValueKeyPage()),
            const NavButton(title: 'Part 3: GlobalKey で配置先を切り替える', page: Ch3P3GlobalKeyPage()),
          ],
        ),
      ),
    );
  }
}
