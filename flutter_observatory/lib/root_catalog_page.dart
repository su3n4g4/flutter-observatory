import 'package:flutter/material.dart';

import 'chapters/ch1/ch1_catalog_page.dart';
import 'chapters/ch2/ch2_catalog_page.dart';

class RootCatalogPage extends StatelessWidget {
  const RootCatalogPage({super.key});

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
      appBar: AppBar(title: const Text('Element Tree Lab')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('章を選択してください。'),
            const SizedBox(height: 16),
            navButton('Chapter 1: Element Tree', const Ch1CatalogPage()),
            navButton('Chapter 2: Lifecycle', const Ch2CatalogPage()),
          ],
        ),
      ),
    );
  }
}
