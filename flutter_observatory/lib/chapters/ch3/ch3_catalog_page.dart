import 'package:flutter/material.dart';

import 'ch3_p1_rebuild_scheduling_page.dart';

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
            const Text('目的：再構築スケジューリングを観測し、dirty 登録と frame 単位の rebuild を確認する。'),
            const SizedBox(height: 16),
            navButton('P1: setState と Build Scheduling', const Ch3P1RebuildSchedulingPage()),
          ],
        ),
      ),
    );
  }
}
