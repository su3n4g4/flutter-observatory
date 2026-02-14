import 'package:flutter/material.dart';
import 'lifecycle_probe.dart';

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
      appBar: AppBar(title: const Text('Ch2 P1: if で消す（dispose）')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '操作：ボタンで if を切り替え。\n'
              '観測：ツリーから外れると dispose が呼ばれる。',
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => setState(() => showChild = !showChild),
              child: Text(showChild ? '子を消す（if=false）' : '子を戻す（if=true）'),
            ),
            const Divider(height: 32),
            if (showChild)
              const LifecycleProbe('IF-CHILD')
            else
              const Text('いま子はツリーに存在しません（ここで dispose が出る）'),
          ],
        ),
      ),
    );
  }
}
