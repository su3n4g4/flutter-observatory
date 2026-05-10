import 'package:flutter/material.dart';

import 'chapters/ch1/ch1_catalog_page.dart';
import 'chapters/ch2/ch2_catalog_page.dart';
import 'chapters/ch3/ch3_catalog_page.dart';
import 'chapters/ch4/ch4_catalog_page.dart';
import 'chapters/ch5/ch5_catalog_page.dart';
import 'widgets/nav_button.dart';

class RootCatalogPage extends StatelessWidget {
  const RootCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Element Tree Lab')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('章を選択してください。'),
            const SizedBox(height: 16),
            const NavButton(title: 'Chapter 1: Element Tree', page: Ch1CatalogPage()),
            const NavButton(title: 'Chapter 2: Lifecycle', page: Ch2CatalogPage()),
            const NavButton(title: 'Chapter 3: Identity Management', page: Ch3CatalogPage()),
            const NavButton(title: 'Chapter 4: Rebuild Scheduling', page: Ch4CatalogPage()),
            const NavButton(title: 'Chapter 5: Dependency & Notification', page: Ch5CatalogPage()),
          ],
        ),
      ),
    );
  }
}
