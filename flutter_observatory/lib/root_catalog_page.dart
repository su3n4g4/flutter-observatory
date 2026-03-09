import 'package:flutter/material.dart';

import 'chapters/ch1/ch1_catalog_page.dart';
import 'chapters/ch2/ch2_catalog_page.dart';
import 'chapters/ch3/ch3_catalog_page.dart';
import 'chapters/ch4/ch4_catalog_page.dart';
import 'chapters/ch5/ch5_catalog_page.dart';
import 'inherited_page.dart';
import 'notification_page.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('章を選択してください。'),
            const SizedBox(height: 16),
            navButton('Chapter 1: Element Tree', const Ch1CatalogPage()),
            navButton('Chapter 2: Lifecycle', const Ch2CatalogPage()),
            navButton('Chapter 3: Rebuild Scheduling', const Ch3CatalogPage()),
            navButton('Chapter 4: Identity Management', const Ch4CatalogPage()),
            navButton('Chapter 5: Dependency & Notification', const Ch5CatalogPage()),
            navButton('InheritedPage', const InheritedPage()),
            navButton('NotificationPage', const NotificationPage()),
          ],
        ),
      ),
    );
  }
}
