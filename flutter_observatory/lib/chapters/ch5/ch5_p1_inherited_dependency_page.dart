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
              child: const Text('InheritedWidget の value を更新する'),
            ),
            const SizedBox(height: 16),

            // Page 自身を表す枠（ルート）
            WidgetBox(
              kind: WidgetKind.stateful,
              name: 'Ch5P1InheritedDependencyPage',
              role: 'ページ本体。ボタン押下で setState する',
              badges: ['inheritedValue: $inheritedValue'],
              buildCount: pageBuildCount,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '↓ この下で _DependencyScope が子孫に値を供給する',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  // InheritedWidget を可視化ラッパーで包む
                  _VisualDependencyScope(
                    value: inheritedValue,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: const [
                        _DependentConsumer(),
                        _IndependentWidget(),
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
              '・dependOn を呼んでいた _DependentConsumer だけ rebuild\n'
              '・_IndependentWidget は rebuild されない（build# が増えない）',
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
      role: '子孫に value を供給する InheritedWidget',
      badges: ['value: ${widget.value}', 'updateShouldNotify: value差分'],
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
    return value != oldWidget.value;
  }
}

// ============================================================
// 依存ありWidget
// ============================================================

class _DependentConsumer extends StatefulWidget {
  const _DependentConsumer();

  @override
  State<_DependentConsumer> createState() => _DependentConsumerState();
}

class _DependentConsumerState extends State<_DependentConsumer> {
  int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    buildCount += 1;
    final value = _DependencyScope.of(context).value;
    debugPrint('[BUILD] dependent consumer (#$buildCount) value=$value');

    return WidgetBox(
      kind: WidgetKind.stateful,
      name: '_DependentConsumer',
      role: 'dependOn を呼ぶ消費者',
      badges: const ['dependOn: ✓ 呼ぶ'],
      buildCount: buildCount,
      child: Text('受け取った value: $value'),
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
    debugPrint('[BUILD] independent widget (#$buildCount)');

    return WidgetBox(
      kind: WidgetKind.stateful,
      name: '_IndependentWidget',
      role: 'dependOn を呼ばない対照群',
      badges: const ['dependOn: ✗ 呼ばない'],
      buildCount: buildCount,
      child: const Text('InheritedWidget の更新は届かない'),
    );
  }
}