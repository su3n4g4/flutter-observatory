---
title: "第8章　同一性をどう守るか — Integrity / Coupling"
---

:::message alert
本章に掲載しているログはすべて**サンプル値**です。`flutter-element-lab` の `lib/chapters/ch8/` を実機で操作し、実測ログに差し替えてから公開してください（公開前チェック項目）。
:::

## この章の中心的な問い

**「同じもの」であり続けることを、誰にどこまで保証させるか。**

リストの並べ替えで入力値が別の行に化ける。タブを切り替えたらフォームが白紙に戻る。これらはすべて、開発者が意図する「同じもの」とフレームワークが判定する「同じもの」がずれたときに起きます。この章では、そのずれを防ぐ手段——Key・GlobalKey・ツリー外保持——を段階的に強めながら、同一性の**有効範囲**が広がるにつれて何と引き換えになるかをログで確かめます。

## 起点となる確定事実

> **判断根拠はruntimeTypeとKeyだけ**（第4章）
> Elementが新しいWidgetを受け入れるか（＝StateとElementを維持するか）の判定は `Widget.canUpdate` で行われ、その材料はruntimeTypeとKeyの2つしかない。

フレームワークソース（3.29.0）の該当箇所は次のとおりです。

```dart
// packages/flutter/lib/src/widgets/framework.dart（本番処理のみ抽出）
static bool canUpdate(Widget oldWidget, Widget newWidget) {
  return oldWidget.runtimeType == newWidget.runtimeType
      && oldWidget.key == newWidget.key;
}
```

https://github.com/flutter/flutter/blob/3.29.0/packages/flutter/lib/src/widgets/framework.dart

この事実の含意は2つあります。第一に、Keyを指定しなければ同一性の判定材料は型だけになり、同じ型が並ぶ場面では**位置**が事実上の同一性になること。第二に、Keyは開発者がこの判定に介入できる**唯一の**入口だということです。

## IntegrityとCouplingという評価軸

この章は2軸で評価します。

**Integrity：開発者が意図した単位で、State（あるいは値）の同一性が保たれる度合い。**

**Coupling：その同一性の保証が、Elementツリーの構造にどれだけ依存しているかの度合い。**

この2軸を分ける理由は本文で明らかになります。先に結論の形だけ述べると、Integrityを同じ「高」にする手段が複数あり、それらのCouplingが正反対になるからです。

## 前提

- Flutter 3.29.0 / 実機（Android）でログを取得します
- 検証コードは `lib/chapters/ch8/` にあります
- `CounterTracker` を使います。本章ではdeactivate / activate（ツリー内の付け替え）もログに出します
- Part 4ではflutter_riverpodを使用します

## 基本シナリオ：Keyなしで並べ替える

`CounterTracker('A')` と `CounterTracker('B')` を縦に並べ、Aのcountを3にしてから順序を入れ替えます。

**ログ**

```text
※サンプルログ（実測後に差し替え）
initState: A  state=118203944  count=0
initState: B  state=530918276  count=0
（Aのcount +1 ×3）
[ACTION] swap（子リストの順序を入れ替え）
build: B  state=118203944  count=3
build: A  state=530918276  count=0
```

**時系列**

| 操作 | ログ | 解釈 |
|------|------|------|
| 初期表示 | initState ×2 | 位置1にstate=118203944、位置2にstate=530918276 |
| A +1 ×3 | build（count=3まで） | count=3は位置1のStateに蓄積される |
| swap | build: **B** state=**118203944** count=**3** | 位置1のElementが、新しく来たWidget「B」をcanUpdate＝trueで受け入れた。**count=3がラベルBに引っ越した** |

**確認できたこと**

initStateもdisposeも出ていません。フレームワークの立場では何も壊れていない——runtimeTypeが同じでKeyがnil同士なのでcanUpdateはtrueであり、各位置のElementは新しいWidgetを正しく受け入れただけです。壊れたのは開発者の意図する同一性（「count=3はAのもの」）のほうです。Keyを渡さないという選択は、「位置＝同一性でよい」という設計判断を暗黙にしていることになります。

## 派生シナリオ1：ValueKeyで意図を伝える

同じ構成で `ValueKey('A')` / `ValueKey('B')` を付けます。

**ログ**

```text
※サンプルログ（実測後に差し替え）
[ACTION] swap
build: B  state=530918276  count=0
build: A  state=118203944  count=3
```

**確認できたこと**

今度はcount=3がラベルAに付いていきました。initState / disposeが出ていない点は基本シナリオと同じですが、意味が違います。親は子リストを更新する際、Keyが一致する旧Elementを探して対応づけるため、Element（とState）が**Widgetに付いて位置を移った**のです。第4章で確認した判定材料のうちKeyを使い、開発者の意図する同一性をフレームワークの判定に一致させた状態です。

ただし、この対応づけが機能するのは**同じ親の子リストの中**だけです。同一性の有効範囲は親ひとつ分に限られます。

## 派生シナリオ2：GlobalKeyで親をまたぐ

`GlobalKey` を付けた `CounterTracker('G')` を、左の枠と右の枠（別の親、別の深さ）の間で移動させます。

**ログ**

```text
※サンプルログ（実測後に差し替え）
initState: G  state=904417382  count=0
（count +1 ×2）
[ACTION] 右の枠へ移動
deactivate: G  state=904417382  count=2
activate: G  state=904417382  count=2
build: G  state=904417382  count=2
```

**確認できたこと**

親をまたいだのにdispose / initStateが出ていません。第1章の「親が変わればElementは破棄される」の、唯一の例外経路です。GlobalKeyを持つElementはdeactivate後すぐには破棄されず、同一フレーム内で同じGlobalKeyのWidgetが別の場所に現れると、Element実体ごと**移送**されます（ログのdeactivate→activateがその痕跡です）。GlobalKeyは `BuildOwner._globalKeyRegistry` でツリー全体を対象に一意管理されているため、同一性の有効範囲はツリー全体に広がります。

代償も記録しておきます。GlobalKeyは `currentState` を通じて、ツリーのどこからでもそのStateへ直接アクセスできる参照です。同一性の保証と引き換えに、キーを握るコードとツリー内部のState実体が直結する——第4章で「内容結合に近い」と評価した構造がここで効いてきます。有効範囲がツリー全体になった瞬間、結合の相手もツリー全体になったわけです。

## 派生シナリオ3：Riverpodでツリーの外に置く

最後に、値そのものをツリーの外（ProviderContainer）に置きます。countを保持する `Notifier` をProviderに載せ、それを表示するConsumerを**破棄してから再生成**します。

**ログ**

```text
※サンプルログ（実測後に差し替え）
create: Ch8Counter  notifier=772651908
[ACTION] increment -> 2
[ACTION] consumerを破棄（Widgetをツリーから外す）
[ACTION] consumerを再表示
[BUILD] consumer (#1)  count=2
（ページから戻る）
dispose: Ch8Counter  notifier=772651908
```

**確認できたこと**

ConsumerのWidget・Element・Stateは完全に破棄され、再表示時には**別物として**作り直されています（buildカウントが#1に戻っている）。それでもcount=2が表示されました。同一性が保たれたのはElementではなく**値**であり、その値はcanUpdateの判定対象になるツリーの中にそもそも存在しないからです。KeyもGlobalKeyも不要で、Widgetが持つのはProviderへの参照だけ。ツリー構造への依存はありません。

## ここまでの帰結

同一性の有効範囲を広げる4段階を並べます。

| 手段 | 同一性の有効範囲 | 保たれるもの | 結合の相手 |
|------|------------------|--------------|-----------|
| Keyなし | 位置（同型の並び） | — | — |
| ValueKey | 同じ親の子リスト内 | Element＋State | 親ひとつ |
| GlobalKey | ツリー全体 | Element＋State（実体ごと移送） | ツリー構造そのもの |
| Riverpod | ツリー外 | 値（Element実体は作り直し） | コンテナへの参照のみ |

有効範囲が広がるほど強力になる、という単調な話ではないことがこの表から読み取れます。GlobalKeyまでは「Elementの同一性」を守る手段の強化でしたが、Riverpodで守っているものは「値の同一性」に変わっています。この違いが次のマトリクスの読み方を決めます。

## 設計判断のまとめ（評価マトリクス）

| 手段 | Integrity | Coupling | 特徴 |
|------|-----------|----------|------|
| Keyなし | 低 | 低 | runtimeTypeのみ。位置変化で同一性が壊れる |
| GlobalKey | 高 | 高 | 内容結合に近い。ツリーに強く依存 |
| Riverpod | 高 | 低 | ツリーから切り離して値を保持 |

## 章末コラム：GlobalKeyとRiverpod——同じ「高」で結合が真逆になる理由

マトリクスだけ見ると、GlobalKeyとRiverpodは「Integrity高」で並び、Couplingだけが真逆です。同じものを守っているのに片方だけ結合が重い、という奇妙な表に見えますが、本文の検証を踏まえると理由は明確です。**両者は守っている「同一性」の対象が違います。**

GlobalKeyが守るのはElement実体の同一性です。State、RenderObject、スクロール位置やアニメーションの進行——ツリーに生えている状態の全部を、実体ごと移送して守ります。それを実現するために、キーはツリー内部のElementへの直接参照として機能し、レジストリでツリー全体と同期します。守る対象がツリーの中にあるのだから、結合の相手もツリーになる。Couplingの高さは実装の粗さではなく、守る対象の所在から来る必然です。

Riverpodが守るのは値の同一性です。Element実体は使い捨てて構わない、復元に必要なデータだけコンテナに置く、という割り切りです。だからWidget側の結合はProvider参照ひとつで済み、ツリーのどこで再構築されても成立します。代わりに、Element実体に紐づくもの（スクロール位置など）は守備範囲外で、必要なら値として明示的に保存する設計が要ります。

つまり選択の基準はこうなります。守りたいのが**ツリー上の実体**なら、結合を引き受けてGlobalKey。守りたいのが**データ**なら、実体の再生成を受け入れてツリー外保持。「同じIntegrity高」は、守る対象を決めたあとで初めて比較可能になる評価です。

## 次章に向けて

本章では「何が同じであり続けるか」を確認しました。第2部の最終章では、依存の伝播——「どこまで巻き込んでrebuildするか」を扱います。起点となる事実は第5章の「依存はdependOn呼び出し時にElementが登録する」です。