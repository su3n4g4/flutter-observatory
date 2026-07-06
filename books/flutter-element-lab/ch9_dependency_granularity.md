---
title: "第9章　依存をどう伝播させるか — Granularity"
---

:::message alert
本章に掲載しているログはすべて**サンプル値**です。`flutter-element-lab` の `lib/chapters/ch9/` を実機で操作し、実測ログに差し替えてから公開してください（公開前チェック項目）。
:::

## この章の中心的な問い

**値の一部だけが変わったとき、どこまでrebuildに巻き込むか。**

状態オブジェクトが育つと、必ずこの問いに突き当たります。プロフィール（名前とカウント）のカウントだけが変わったのに、名前を表示しているWidgetまでrebuildされる——動作は正しいのに、rebuild範囲が意図より広い。この章では、その範囲を決めているのが**依存登録の単位**であることを確認し、単位を細かくする手段を段階的に比べます。

## 起点となる確定事実

> **依存はdependOn呼び出し時にElementが登録する**（第5章）
> `of(context)` の実体は `dependOnInheritedWidgetOfExactType` であり、呼び出した瞬間に、呼び出し元のElementが依存者として登録される。通知はこの登録簿に基づいて行われる。

フレームワークソース（3.29.0）の該当箇所です。

```dart
// packages/flutter/lib/src/widgets/framework.dart（本番処理のみ抽出）
InheritedWidget dependOnInheritedElement(InheritedElement ancestor, { Object? aspect }) {
  _dependencies ??= HashSet<InheritedElement>();
  _dependencies!.add(ancestor);
  ancestor.updateDependencies(this, aspect);
  return ancestor.widget as InheritedWidget;
}
```

https://github.com/flutter/flutter/blob/3.29.0/packages/flutter/lib/src/widgets/framework.dart

注目すべきは、登録されるのが `this`——つまり**Element**だという点です。「この値のこのフィールドに依存する」ではなく「このElementがこのInheritedElementに依存する」という単位で登録簿が作られます。この登録単位こそが、本章で扱うrebuild範囲の正体です。

## Granularityという評価軸

**Granularity：rebuild範囲を、依存する値のどの細かさまで絞り込めるかの度合い。**

- Granularityが**高い**：値の特定のフィールドや射影だけを監視でき、無関係な変更ではrebuildされない
- Granularityが**低い**：値のどこが変わっても、依存者全体に通知が届く

高いほど無駄なrebuildは減りますが、監視の宣言は細かく・多くなります。逆に低い側は宣言が単純で、rebuild範囲は広くなります。ここでも高低はトレードオフの位置の記述です。

## 前提

- Flutter 3.29.0 / 実機（Android）でログを取得します
- 検証コードは `lib/chapters/ch9/` にあります
- 状態は2フィールドのオブジェクト `Profile(name, count)` とし、`NAME-TILE`（nameだけ表示）と `COUNT-TILE`（countだけ表示）の2つのWidgetで消費します
- 操作は「count +1」と「name変更」の2ボタンです

## 基本シナリオ：InheritedWidgetのof()で依存する

`ProfileScope`（InheritedWidget）で `Profile` を配り、両タイルが `ProfileScope.of(context)` で値を取ります。

**ログ**

```text
※サンプルログ（実測後に差し替え）
[BUILD] NAME-TILE (#1)  name=alice
[BUILD] COUNT-TILE (#1)  count=0
[ACTION] count +1
[BUILD] NAME-TILE (#2)  name=alice
[BUILD] COUNT-TILE (#2)  count=1
```

**時系列**

| 操作 | ログ | 解釈 |
|------|------|------|
| count +1 | COUNT-TILEのbuild | 期待どおり |
| （同上） | **NAME-TILEのbuild**（nameは変わっていない） | 登録簿には「NAME-TILEのElementがProfileScopeに依存」としか書かれていないため、区別できない |

**確認できたこと**

nameが変わっていないのにNAME-TILEがrebuildされました。冒頭のソースで確認したとおり、登録の単位はElementです。ProfileScope側から見える情報は「どのElementが依存しているか」だけで、そのElementが値の**どの部分**を使ったかは登録簿に残りません。だから通知は依存Element全員に届きます。of()を使う限り、Granularityの下限は「InheritedWidgetひとつ＝依存Element全員」です。

なお、of()を呼ぶ**位置**を工夫して依存Elementを小さく切り出す（消費部分だけ子Widgetに分離する）ことはできます。これはGranularityをWidget分割で稼ぐアプローチで、InheritedWidgetの評価「中」はこの余地を含んだものです。

## 派生シナリオ1：ValueNotifierで監視する

`ValueNotifier<Profile>` に置き換え、両タイルを `ValueListenableBuilder` で包みます。

**ログ**

```text
※サンプルログ（実測後に差し替え）
[ACTION] count +1
[BUILD] NAME-TILE (#2)  name=alice
[BUILD] COUNT-TILE (#2)  count=1
```

**確認できたこと**

結果は基本シナリオと同じです。ValueNotifierの通知は「値（オブジェクト全体）が変わった」の1種類しかなく、countだけの変更でもProfileオブジェクトごと差し替わるため、両方のBuilderに通知が届きます。Builderの置き方でrebuildの**Widget範囲**は絞れますが、**値のどの部分か**では絞れません。絞り込みの語彙を持たない、という意味でGranularityは「低」です（ValueNotifierをフィールドごとに分割すれば絞れますが、それは状態設計の変更であり、監視側の手段ではありません）。

## 派生シナリオ2：Riverpodのref.selectで射影する

`NotifierProvider` に載せ替え、NAME-TILEは `ref.watch(profileProvider.select((p) => p.name))`、COUNT-TILEは `select((p) => p.count)` で監視します。

**ログ**

```text
※サンプルログ（実測後に差し替え）
[ACTION] count +1
[BUILD] COUNT-TILE (#2)  count=1
[ACTION] name変更 -> bob
[BUILD] NAME-TILE (#2)  name=bob
```

**確認できたこと**

count +1でNAME-TILEのログが**出ませんでした**。selectに渡した関数は値の射影（`p.name`）を定義しており、Riverpodは通知のたびに射影の結果を前回値と比較して、変わったときだけ監視元をrebuildします。依存の宣言が「このProviderに依存する」から「このProviderの**この射影**に依存する」に細分化された形です。Granularityの単位がWidget（Element）からフィールドに移りました。

## ここまでの帰結

| 手段 | 絞り込みの単位 | 絞り込む場所 |
|------|----------------|--------------|
| InheritedWidget（of） | 依存Element全員 | of()を呼ぶ位置＝Widget分割 |
| ValueNotifier | 値オブジェクト全体 | Builderの配置＝Widget分割 |
| Riverpod（select） | 値の射影（フィールド単位） | 監視の宣言そのもの |

上2つに共通するのは、絞り込みの手段が結局**ツリー側の構造**（Widgetをどう分割し、どこで購読するか）だという点です。selectはこれを反転させ、絞り込みを**値側の宣言**に移しました。rebuild範囲の設計判断とは、「範囲の制御をツリーの形で行うか、監視の宣言で行うか」の選択だと言えます。

## 設計判断のまとめ（評価マトリクス）

| ライブラリ | Granularity | 仕組み |
|-----------|-------------|--------|
| InheritedWidget | 中 | of()の呼び出し位置でdependOn登録。Widget単位 |
| Riverpod | 高 | ref.selectで値の一部のみ監視。フィールド単位 |
| BLoC | 中 | distinct()等でStreamの差分を間引く（第7章の経路上で絞る） |
| ValueNotifier | 低 | 値全体の変化で通知。監視側の絞り込み手段なし |

## 章末コラム：ref.selectはdependOnの上位互換か

第5章の仕組みと本章の結果を素直に並べると、「ref.selectはdependOnの上位互換」と言いたくなります。同じ「依存を登録して通知を受ける」構図で、登録の粒度だけが細かいからです。しかし両者の実装を見ると、この表現は少しずれています。

まず、dependOn側にも絞り込みの仕組みは**あります**。冒頭のソース抜粋にあった `aspect` 引数がそれで、`InheritedModel` はこれを使って「値のどの側面に依存するか」を登録簿に残し、通知時に側面単位でふるい分けます。つまり「フィールド単位の通知」自体はフレームワーク内で完結できる設計であり、selectだけの発明ではありません。

selectが違うのは絞り込みの**判定方式**です。aspectは登録時にラベルを預ける方式で、通知側（InheritedModelの実装者）がラベルごとの判定ロジックを書きます。selectは射影関数を預ける方式で、判定は「射影結果の==比較」に一般化されており、通知側に個別実装は要りません。さらにこの比較はProviderContainer内で行われるため、InheritedElementの登録簿——つまりElementツリーの仕組み——に依存しません。第6章で見た「Stateがツリーの外にある」構造が、ここでは「依存の管理もツリーの外にある」という形で効いています。

まとめると、ref.selectはdependOnの上位互換というより、**絞り込みの判定を登録時のラベルから通知時の射影比較へ移し、その置き場所をツリーの外に出した別解**です。dependOnの登録簿がElement単位である以上（本章冒頭のソースのとおり）、ツリーの仕組みの中での絞り込みにはaspectという追加の語彙が要る。ツリーの外なら、射影と比較だけで済む。第1部の事実から読むと、この対比が一番正確だと考えています。

## 第2部のまとめ

4つの章で確認した設計判断軸を並べます。

| 章 | 設計判断軸 | 主要ility | 起点となる確定事実 |
|----|-----------|-----------|--------------------|
| 6 | State配置 | Locality | StateはElementに生かされ殺される |
| 7 | rebuild責務 | Traceability | buildを呼ぶのはフレーム内のBuildOwner |
| 8 | Key・GlobalKey戦略 | Integrity / Coupling | 判断根拠はruntimeTypeとKeyだけ |
| 9 | rebuild範囲 | Granularity | 依存はdependOn呼び出し時にElementが登録する |

状態管理ライブラリの選定は、しばしば「どれが良いか」という問いで語られます。第2部で試みたのは、その問いを「このアプリのStateには、どの寿命・どの追跡可能性・どの同一性・どの伝播範囲が要るか」という4つの問いに分解することでした。4つの答えが出れば、各章のマトリクスがライブラリを指します。答えを出すのは読者のアプリの要件であって、この記事ではありません。

第3部では視点を反転させ、これらの軸を踏み外したときに何が起きるか——事故コードの逆引き辞典に進みます。