import 'package:flutter/material.dart';

/// Widget種別ごとのアクセント色（ラベルにのみ使う）。
enum WidgetKind {
  stateful(Color(0xFF1976D2), '<Stateful>'),
  stateless(Color(0xFF388E3C), '<Stateless>'),
  inherited(Color(0xFF7B1FA2), '<Inherited>'),
  listener(Color(0xFFF57C00), '<Listener>');

  const WidgetKind(this.accentColor, this.typeLabel);
  final Color accentColor;
  final String typeLabel;
}

/// ツリー階層に左ボーダーで色付きラベルを表示する。
class LayerLabel extends StatelessWidget {
  const LayerLabel(this.label, {super.key, required this.color});

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

/// Widgetツリーの構造を可視化する枠。
///
/// デザイン方針：普段は白地＋細枠で静かに、rebuildされた瞬間だけ黄色く光る。
/// 色を抑えることで、画面の色情報の大部分が「何が今 rebuild されたか」に向く。
class WidgetBox extends StatefulWidget {
  const WidgetBox({
    super.key,
    required this.kind,
    required this.name,
    required this.buildCount,
    this.role,
    this.badges = const [],
    required this.child,
  });

  final WidgetKind kind;

  /// クラス名（例: "_DependentWidget"）
  final String name;

  /// 役割の短い説明
  final String? role;

  /// 属性バッジ（例: ["dependOn: ✓"]）
  final List<String> badges;

  /// buildCount の値。変化を検知してフラッシュを発火する。
  final int buildCount;

  final Widget child;

  @override
  State<WidgetBox> createState() => _WidgetBoxState();
}

class _WidgetBoxState extends State<WidgetBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward(from: 0);
    });
  }

  @override
  void didUpdateWidget(covariant WidgetBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.buildCount != widget.buildCount) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = 1.0 - _controller.value;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            // 普段は白、rebuild時のみ黄色がかぶさる
            color: Color.lerp(Colors.white, Colors.yellow.shade300, t * 0.8),
            border: Border.all(
              // 普段は薄いグレー、rebuild時はアクセント色が浮き上がる
              color: Color.lerp(
                Colors.grey.shade300,
                widget.kind.accentColor,
                t,
              )!,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダ行：型ラベル + クラス名 + buildカウント
            Row(
              children: [
                if (widget.kind.typeLabel.isNotEmpty) ...[
                  Text(
                    widget.kind.typeLabel,
                    style: TextStyle(
                      color: widget.kind.accentColor,
                      fontSize: 11,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                Text(
                  'build #${widget.buildCount}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            // 役割説明
            if (widget.role != null) ...[
              const SizedBox(height: 2),
              Text(
                widget.role!,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 11,
                ),
              ),
            ],
            // 属性バッジ
            if (widget.badges.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 2,
                children: widget.badges
                    .map((b) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            b,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
            // 本体
            const SizedBox(height: 8),
            widget.child,
          ],
        ),
      ),
    );
  }
}
