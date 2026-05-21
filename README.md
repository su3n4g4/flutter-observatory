# flutter-element-lab

FlutterのElementツリーが持つ5つの責務を、検証画面を動かしながら確認するためのリポジトリです。

## 検証ページ

ブラウザで動作を確認できます。

▶ https://su3n4g4.github.io/flutter-element-lab/

## 記事

| 章 | タイトル | ファイル |
|----|----------|----------|
| 序文 | FlutterのElementツリーを理解する | [articles/ch0_element_preface.md](articles/ch0_element_preface.md) |
| Chapter1 | Elementツリーの位置管理 | [articles/ch1_position.md](articles/ch1_position.md) |
| Chapter2 | Stateのライフサイクル管理 | [articles/ch2_lifecycle.md](articles/ch2_lifecycle.md) |
| Chapter3 | 同一性管理（Key） | [articles/ch3_identity.md](articles/ch3_identity.md) |
| Chapter4 | 再構築スケジューリング | [articles/ch4_element_rebuild.md](articles/ch4_element_rebuild.md) |
| Chapter5 | 依存と通知の管理 | [articles/ch5_dependency.md](articles/ch5_dependency.md) |

## ソースコード

| 章 | ディレクトリ |
|----|--------------|
| Chapter1 | [flutter_element_lab/lib/chapters/ch1/](flutter_element_lab/lib/chapters/ch1/) |
| Chapter2 | [flutter_element_lab/lib/chapters/ch2/](flutter_element_lab/lib/chapters/ch2/) |
| Chapter3 | [flutter_element_lab/lib/chapters/ch3/](flutter_element_lab/lib/chapters/ch3/) |
| Chapter4 | [flutter_element_lab/lib/chapters/ch4/](flutter_element_lab/lib/chapters/ch4/) |
| Chapter5 | [flutter_element_lab/lib/chapters/ch5/](flutter_element_lab/lib/chapters/ch5/) |

検証に使うコアウィジェットは [flutter_element_lab/lib/widgets/state_tracker.dart](flutter_element_lab/lib/widgets/state_tracker.dart) です。
