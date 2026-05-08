# flutter-element-lab

FlutterのElementツリーが持つ5つの責務を、検証画面を動かしながら確認するためのリポジトリです。

## 検証ページ

ブラウザで動作を確認できます。

▶ https://su3n4g4.github.io/flutter-element-lab/

## 構成

```
Ch1: 構造と位置（空間）─ Elementはどこにいるか
Ch2: 状態の変遷（時間）─ Elementはいつ生き、いつ死ぬか
Ch3: 同一性           ─ ElementはどのWidgetと対応するか
Ch4: 再構築           ─ buildはいつ・何回実行されるか
Ch5: 依存             ─ 変化はどのElementまで伝播するか
```

## 記事

| 章 | タイトル | ファイル |
|----|----------|----------|
| 序文 | FlutterのElementツリーを理解する | [articles/preface.md](articles/preface.md) |
| Ch1 | Elementツリーの位置管理 | [articles/ch1_position.md](articles/ch1_position.md) |
| Ch2 | Stateのライフサイクル管理 | [articles/ch2_lifecycle.md](articles/ch2_lifecycle.md) |
| Ch3 | 同一性管理（Key） | [articles/ch3_identity.md](articles/ch3_identity.md) |
| Ch4 | 再構築スケジューリング | [articles/ch4_rebuild.md](articles/ch4_rebuild.md) |
| Ch5 | 依存と通知の管理 | [articles/ch5_dependency.md](articles/ch5_dependency.md) |

## ソースコード

| 章 | ディレクトリ |
|----|--------------|
| Ch1 | [flutter_element_lab/lib/chapters/ch1/](flutter_element_lab/lib/chapters/ch1/) |
| Ch2 | [flutter_element_lab/lib/chapters/ch2/](flutter_element_lab/lib/chapters/ch2/) |
| Ch3 | [flutter_element_lab/lib/chapters/ch3/](flutter_element_lab/lib/chapters/ch3/) |
| Ch4 | [flutter_element_lab/lib/chapters/ch4/](flutter_element_lab/lib/chapters/ch4/) |
| Ch5 | [flutter_element_lab/lib/chapters/ch5/](flutter_element_lab/lib/chapters/ch5/) |

検証に使うコアウィジェットは [flutter_element_lab/lib/widgets/state_tracker.dart](flutter_element_lab/lib/widgets/state_tracker.dart) です。
