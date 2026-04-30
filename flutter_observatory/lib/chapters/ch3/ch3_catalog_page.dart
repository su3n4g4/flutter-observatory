import 'package:flutter/material.dart';

import 'ch3_p1_no_key_page.dart';
import 'ch3_p2_value_key_page.dart';
import 'ch3_p3_global_key_page.dart';

class Ch3CatalogPage extends StatelessWidget {
  const Ch3CatalogPage({super.key});

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
      appBar: AppBar(title: const Text('Element Tree Lab - Ch3')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('目的：Element の同一性管理を Key 中心に観測する。'),
            const SizedBox(height: 16),
            navButton('P1: Reorder（Keyなし）', const Ch3P1NoKeyPage()),
            navButton('P2: Reorder（ValueKey）', const Ch3P2ValueKeyPage()),
            navButton('P3: GlobalKey で配置先を切り替える', const Ch3P3GlobalKeyPage()),
          ],
        ),
      ),
    );
  }
}
