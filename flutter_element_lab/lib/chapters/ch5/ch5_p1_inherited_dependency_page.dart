import 'package:flutter/material.dart';

import 'widget_box.dart';

class Ch5P1InheritedDependencyPage extends StatelessWidget {
  const Ch5P1InheritedDependencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chapter 5 Part 1: InheritedWidget 依存')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            const Text(
              'ボタンを押して、どちらの枠が光るかを確認してください。\n'
              'of() を呼んでいる Widget だけが rebuild されます。',
              style: TextStyle(fontSize: 13),
            ),
            const Divider(height: 24),

            // スコープ
            LayerLabel('スコープ', color: Color(0xFF7B1FA2)),
            _VisualDependencyScope(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayerLabel('利用側', color: Color(0xFF388E3C)),
                  _DependentWidget(),
                  _IndependentWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// InheritedWidget 本体と、その可視化用ラッパー
// ============================================================

/// 値の管理とInheritedWidgetの可視化を担うラッパー。
/// ページのsetStateを経由せず、このWidget内でのみ値を更新する。
class _VisualDependencyScope extends StatefulWidget {
  const _VisualDependencyScope({required this.child});
  final Widget child;

  @override
  State<_VisualDependencyScope> createState() => _VisualDependencyScopeState();
}

class _VisualDependencyScopeState extends State<_VisualDependencyScope> {
  int value = 0;
  int buildCount = 0;

  void _increment() {
    setState(() => value += 1);
  }

  @override
  Widget build(BuildContext context) {
    // rebuild の原因（setState / InheritedWidget 更新 / 親の更新）に関わらず
    // 必ず呼ばれる場所が build() のみのため、ここでカウントする。
    buildCount += 1;
    debugPrint('[Scope] build (#$buildCount) value=$value');
    return WidgetBox(
      kind: WidgetKind.inherited,
      name: '_DependencyScope',
      role: 'value を公開する InheritedWidget。of() でアクセス可',
      badges: ['value: $value', 'updateShouldNotify'],
      buildCount: buildCount,
      child: _DependencyScope(
        value: value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            FilledButton(
              onPressed: _increment,
              child: const Text('value を更新する（_DependentWidget だけ rebuild される）'),
            ),
            const SizedBox(height: 8),
            widget.child,
          ],
        ),
      ),
    );
  }
}

class _DependencyScope extends InheritedWidget {
  const _DependencyScope({required super.child, required this.value});

  final int value;

  static _DependencyScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_DependencyScope>();
    assert(scope != null, '_DependencyScope is missing in the widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(_DependencyScope oldWidget) {
    debugPrint('[Inherited] updateShouldNotify old=${oldWidget.value} new=$value');
    return value != oldWidget.value;
  }
}

// ============================================================
// 依存ありWidget
// ============================================================

class _DependentWidget extends StatefulWidget {
  const _DependentWidget();

  @override
  State<_DependentWidget> createState() => _DependentWidgetState();
}

class _DependentWidgetState extends State<_DependentWidget> {
  int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    // rebuild の原因（setState / InheritedWidget 更新 / 親の更新）に関わらず
    // 必ず呼ばれる場所が build() のみのため、ここでカウントする。
    buildCount += 1;
    final value = _DependencyScope.of(context).value;
    debugPrint('[BUILD] dependent (#$buildCount) value=$value');

    return WidgetBox(
      kind: WidgetKind.stateful,
      name: '_DependentWidget',
      role: 'of() で value を取得する',
      badges: const ['dependOn: ✓'],
      buildCount: buildCount,
      child: Text('value: $value'),
    );
  }
}

// ============================================================
// 依存なしWidget
// ============================================================

class _IndependentWidget extends StatefulWidget {
  const _IndependentWidget();

  @override
  State<_IndependentWidget> createState() => _IndependentWidgetState();
}

class _IndependentWidgetState extends State<_IndependentWidget> {
  int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    // rebuild の原因（setState / InheritedWidget 更新 / 親の更新）に関わらず
    // 必ず呼ばれる場所が build() のみのため、ここでカウントする。
    buildCount += 1;
    debugPrint('[BUILD] independent (#$buildCount)');

    return WidgetBox(
      kind: WidgetKind.stateful,
      name: '_IndependentWidget',
      role: 'of() を呼ばない',
      badges: const ['dependOn: ✗'],
      buildCount: buildCount,
      child: const Text('InheritedWidget の更新は届かない'),
    );
  }
}
