import 'package:flutter/material.dart';

import '../../widgets/widget_box.dart';

class Ch5P1InheritedDependencyPage extends StatefulWidget {
  const Ch5P1InheritedDependencyPage({super.key});

  @override
  State<Ch5P1InheritedDependencyPage> createState() =>
      _Ch5P1InheritedDependencyPageState();
}

class _Ch5P1InheritedDependencyPageState
    extends State<Ch5P1InheritedDependencyPage> {
  int inheritedValue = 0;
  int pageBuildCount = 0;

  void _incrementInheritedValue() {
    setState(() => inheritedValue += 1);
  }

  @override
  Widget build(BuildContext context) {
    pageBuildCount += 1;
    debugPrint('[BUILD] Ch5 P1 page (#$pageBuildCount)');

    return Scaffold(
      appBar: AppBar(title: const Text('Ch5 P1: InheritedWidget 依存')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '💡 枠が黄色く光る = build() が実行された証拠',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              'この章で観測すること',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '・dependOn を呼んだ Element だけが InheritedWidget 更新時に rebuild される\n'
              '・依存登録していない Element は rebuild されない（枠が光らない）',
              style: TextStyle(fontSize: 13),
            ),
            const Divider(height: 24),
            FilledButton(
              onPressed: _incrementInheritedValue,
              child: const Text('value を更新する（_DependentWidget だけ rebuild される）'),
            ),
            const SizedBox(height: 16),

            // ページ
            _LayerLabel('ページ', color: Color(0xFF1976D2)),
            WidgetBox(
              kind: WidgetKind.stateful,
              name: 'Ch5P1InheritedDependencyPage',
              role: 'ページ本体。ボタン押下で setState する',
              badges: ['inheritedValue: $inheritedValue'],
              buildCount: pageBuildCount,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // スコープ
                  _LayerLabel('スコープ', color: Color(0xFF7B1FA2)),
                  _VisualDependencyScope(
                    value: inheritedValue,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _LayerLabel('利用側', color: Color(0xFF388E3C)),
                        const _DependentWidget(),
                        const _IndependentWidget(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              '起きる現象',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '・ボタンを押すと Page が setState → rebuild\n'
              '・Page の build で _DependencyScope の value が変わる\n'
              '・_DependencyScope.updateShouldNotify が true を返す\n'
              '・of() を呼んでいた _DependentWidget だけ rebuild（光る）\n'
              '・_IndependentWidget は rebuild されない（光らない）',
              style: TextStyle(fontSize: 13),
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

/// InheritedWidget の存在を視覚化するためのラッパー。
/// 本物の _DependencyScope を WidgetBox で包んで表示する。
class _VisualDependencyScope extends StatefulWidget {
  const _VisualDependencyScope({required this.value, required this.child});
  final int value;
  final Widget child;

  @override
  State<_VisualDependencyScope> createState() => _VisualDependencyScopeState();
}

class _VisualDependencyScopeState extends State<_VisualDependencyScope> {
  int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    buildCount += 1;
    return WidgetBox(
      kind: WidgetKind.inherited,
      name: '_DependencyScope',
      role: 'value を公開する InheritedWidget。of() でアクセス可',
      badges: const ['updateShouldNotify'],
      buildCount: buildCount,
      child: _DependencyScope(
        value: widget.value,
        child: widget.child,
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
// 層ラベル
// ============================================================

class _LayerLabel extends StatelessWidget {
  const _LayerLabel(this.label, {required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
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