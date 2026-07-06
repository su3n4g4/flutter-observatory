import 'package:flutter/material.dart';

import '../../widgets/nav_button.dart';
import 'ch6_p1_state_in_route_page.dart';
import 'ch6_p2_lifted_state_page.dart';
import 'ch6_p3_provider_scope_page.dart';

class Ch6CatalogPage extends StatelessWidget {
  const Ch6CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Element Tree Lab - Ch6')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Partを選択してください'),
            const SizedBox(height: 16),
            const NavButton(
              title: 'Part 1: ルート内配置',
              page: Ch6P1StateInRoutePage(),
            ),
            const NavButton(
              title: 'Part 2: ネストNavigator＋共通祖先への持ち上げ',
              page: Ch6P2LiftedStatePage(),
            ),
            const NavButton(
              title: 'Part 3: ChangeNotifierProvider供給',
              page: Ch6P3ProviderScopePage(),
            ),
          ],
        ),
      ),
    );
  }
}
