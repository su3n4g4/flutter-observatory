import 'package:flutter/material.dart';
import '../../widgets/state_tracker.dart';

class Ch2P1IfRemovePage extends StatefulWidget {
  const Ch2P1IfRemovePage({super.key});

  @override
  State<Ch2P1IfRemovePage> createState() => _Ch2P1IfRemovePageState();
}

class _Ch2P1IfRemovePageState extends State<Ch2P1IfRemovePage> {
  bool showChild = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chapter 2 Part 1: if で消す（dispose）')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'StateTrackerの表示を切り替え。',
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => setState(() => showChild = !showChild),
              child: Text(showChild ? 'StateTrackerを消す（if=false）' : 'StateTrackerを戻す（if=true）'),
            ),
            const Divider(height: 32),
            if (showChild)
              const StateTracker('IF-CHILD')
            else
              const Text('StateTrackerが非表示になりました'),
          ],
        ),
      ),
    );
  }
}
