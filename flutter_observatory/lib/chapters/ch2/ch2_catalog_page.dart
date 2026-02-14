import 'package:flutter/material.dart';

import 'ch2_p1_if_remove_page.dart';
import 'ch2_p2_navigator_page.dart';
import 'ch2_p3_globalkey_move_page.dart';

class Ch2CatalogPage extends StatelessWidget {
  const Ch2CatalogPage({super.key});

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
      appBar: AppBar(title: const Text('Element Tree Lab - Ch2')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('目的：Element が State の生成/更新/破棄を管理する事実を観測する。'),
            const SizedBox(height: 16),
            navButton('P1: if で消す（dispose）', const Ch2P1IfRemovePage()),
            navButton('P2: Navigator push/pop', const Ch2P2NavigatorPage()),
            navButton('P3: GlobalKey で移動', const Ch2P3GlobalKeyMovePage()),
          ],
        ),
      ),
    );
  }
}
