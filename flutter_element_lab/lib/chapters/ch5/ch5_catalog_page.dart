import 'package:flutter/material.dart';

import '../../widgets/nav_button.dart';
import 'ch5_p1_inherited_dependency_page.dart';
import 'ch5_p2_notification_bubble_page.dart';

class Ch5CatalogPage extends StatelessWidget {
  const Ch5CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Element Tree Lab - Ch5')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('目的：依存関係と通知バブルアップの挙動を確認する。'),
            const SizedBox(height: 16),
            const NavButton(title: 'Part 1: InheritedWidget 依存', page: Ch5P1InheritedDependencyPage()),
            const NavButton(title: 'Part 2: Notificationのバブルアップ', page: Ch5P2NotificationBubblePage()),
          ],
        ),
      ),
    );
  }
}