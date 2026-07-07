import 'package:flutter/material.dart';

import 'chapters/ch1/ch1_catalog_page.dart';
import 'chapters/ch2/ch2_catalog_page.dart';
import 'chapters/ch3/ch3_catalog_page.dart';
import 'chapters/ch4/ch4_catalog_page.dart';
import 'chapters/ch5/ch5_catalog_page.dart';
import 'chapters/ch6/ch6_catalog_page.dart';
import 'chapters/ch7/ch7_catalog_page.dart';
import 'chapters/ch8/ch8_catalog_page.dart';
import 'chapters/ch9/ch9_catalog_page.dart';
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
            const Text('Chapterを選択してください。'),
            const SizedBox(height: 16),
            const NavButton(
              title: 'Chapter 1: Elementツリーの位置管理',
              page: Ch1CatalogPage(),
            ),
            const NavButton(
              title: 'Chapter 2: Stateのライフサイクル管理',
              page: Ch2CatalogPage(),
            ),
            const NavButton(
              title: 'Chapter 3: 同一性管理（Key）',
              page: Ch3CatalogPage(),
            ),
            const NavButton(
              title: 'Chapter 4: 再構築スケジューリング',
              page: Ch4CatalogPage(),
            ),
            const NavButton(
              title: 'Chapter 5: 依存と通知の管理',
              page: Ch5CatalogPage(),
            ),
            // const NavButton(
            //   title: 'Chapter 6: Stateをどこに置くか',
            //   page: Ch6CatalogPage(),
            // ),
            // const NavButton(
            //   title: 'Chapter 7: rebuildの責任をどう分割するか',
            //   page: Ch7CatalogPage(),
            // ),
            // const NavButton(
            //   title: 'Chapter 8: 同一性をどう守るか',
            //   page: Ch8CatalogPage(),
            // ),
            // const NavButton(
            //   title: 'Chapter 9: 依存をどう伝播させるか',
            //   page: Ch9CatalogPage(),
            // ),
          ],
        ),
      ),
    );
  }
}
