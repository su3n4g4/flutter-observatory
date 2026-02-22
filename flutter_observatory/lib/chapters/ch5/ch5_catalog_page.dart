import 'package:flutter/material.dart';

import 'ch5_p1_dependency_notification_page.dart';

class Ch5CatalogPage extends StatelessWidget {
  const Ch5CatalogPage({super.key});

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
      appBar: AppBar(title: const Text('Element Tree Lab - Ch5')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('目的：依存関係と通知バブルアップの挙動を観測する。'),
            const SizedBox(height: 16),
            navButton('P1: 依存・通知管理', const Ch5P1DependencyNotificationPage()),
          ],
        ),
      ),
    );
  }
}
