---
title: "第6章　Stateをどこに置くか — Locality"
---

:::message alert
本章に掲載しているログはすべて**サンプル値**です。`flutter-element-lab` の `lib/chapters/ch6/` を実機で操作し、実測ログに差し替えてから公開してください（公開前チェック項目）。
:::

## 第2部のはじめに

第1部では、Elementが何を決めているかを5つの事実として確認しました。第2部では、その事実を起点に「開発者が何を決めるべきか」——つまり設計判断を扱います。

各章の進み方は同じです。第1部の確定事実をひとつ置き、そこから導かれる設計判断軸を定義し、章末のコラムで状態管理ライブラリをその軸で評価します。ライブラリを「答え」として提示することはしません。事実から軸を導き、軸に照らすと各ライブラリがどう見えるか、を並べるところまでが本シリーズの役割です。

もうひとつ、第2部全体の読み方の注意です。各章に登場する「高・中・低」の評価は、**性質の程度**であって優劣ではありません。たとえば本章で扱うLocalityが「低い」とは「Stateがツリーから解放されている」という特性の記述であり、それが有利に働くか不利に働くかは用途次第です。

## この章の中心的な問い

**Stateをどこに置くか。**

Flutterで最初に迷う設計判断はおそらくこれです。カウンタひとつでも、置き場所の候補は「使うWidgetの中」「画面の親」「もっと上」「ツリーの外」と複数あります。この章では、置き場所の違いがStateの**寿命**に何をもたらすかを、第1部の事実からログで確かめます。

## 起点となる確定事実

第1部で確認した次の2つの事実が、この章の土台です。

> **StateはElementに生かされ殺される**（第2章）
> StateオブジェクトはElementのライフサイクルに従属する。ElementがunmountされればStateはdisposeされ、保持していた値も消える。

> **親が変わればElementは破棄される**（第1章）
> Elementはツリー上の位置に紐づいて管理される。親をまたぐ移動は破棄と再生成になる。

この2つを合成すると、次の推論が成り立ちます。**Stateの寿命はツリー上の位置で決まる。ならば「Stateをどこに置くか」は、機能ではなく寿命を決める設計判断である。**本章はこの推論をログで検証します。

## Localityという評価軸

本章の評価軸は **Locality** です。ここでは次のように定義します。

**Locality：Stateのライフタイムが、Stateを使う場所の近くに縛られている度合い。**

- Localityが**高い**：Stateは使うWidgetのすぐそば（同じElement）にあり、そのElementと運命を共にする。値の出どころが一目で分かる代わりに、Elementが消えれば値も消える。
- Localityが**低い**：Stateは使う場所から離れた位置、極端にはElementツリーの外にある。Elementの生死から解放される代わりに、値の出どころと使用箇所が遠くなる。

繰り返しになりますが、高低は優劣ではありません。この章の目的は「どちらが良いか」ではなく、「置き場所を1段動かすごとに、何が変わり何が変わらないか」を事実として確定させることです。

## 前提

- Flutter 3.29.0 / 実機（Android）でログを取得します
- 検証コードは `lib/chapters/ch6/` にあります
- 本章では `StateTracker` の派生として、カウンタを内蔵した `CounterTracker` を使います

```dart
class _CounterTrackerState extends State<CounterTracker> {
  int count = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('initState: ${widget.label}  state=$hashCode  count=$count');
  }

  @override
  void dispose() {
    // disposeの瞬間にcountの値も一緒に消えることをログで残す
    debugPrint('dispose: ${widget.label}  state=$hashCode  count=$count');
    super.dispose();
  }
  // build時にも同形式でログを出す（省略）
}
```

`count` はStateのフィールドです。つまり `count` の寿命＝Stateの寿命＝Elementの寿命、という連鎖をログの `state=`（hashCode）で追跡できます。

## 基本シナリオ：ルートの中にStateを置く

第2章のPart 2（Navigator push/pop）を、第2部の視点で読み直すところから始めます。`CounterTracker` をpushした画面の中に置き、countを増やしてから戻り、もう一度進みます。

**操作**

| # | 操作 |
|---|------|
| 1 | `Navigator.push` で次画面へ |
| 2 | count +1 を3回押す |
| 3 | `Navigator.pop` で戻る |
| 4 | もう一度 `Navigator.push` |

**ログ**

```text
※サンプルログ（実測後に差し替え）
initState: IN-ROUTE  state=612340987  count=0
build: IN-ROUTE  state=612340987  count=0
build: IN-ROUTE  state=612340987  count=1
build: IN-ROUTE  state=612340987  count=2
build: IN-ROUTE  state=612340987  count=3
dispose: IN-ROUTE  state=612340987  count=3
initState: IN-ROUTE  state=298764531  count=0
build: IN-ROUTE  state=298764531  count=0
```

**時系列**

| 操作 | ログ | 解釈 |
|------|------|------|
| push | initState（state=612340987） | Route配下にElementが作られ、Stateが生まれる |
| +1 ×3 | build ×3（count=3まで） | countはState内で育つ |
| pop | dispose（count=3） | Routeの破棄＝Elementの破棄＝Stateの破棄。**count=3はこの行を最後に消える** |
| 再push | initState（state=298764531、count=0） | 別のStateが新規に作られる。前の値との連続性はない |

**確認できたこと**

pop時のdisposeログにcount=3が記録され、再push後はstate idが変わってcount=0から始まりました。第2章で確認した「StateはElementに生かされ殺される」が、そのまま「**ルート内に置いた値はルートの寿命を超えられない**」という設計上の制約として現れています。これがLocality「高」の状態です。値と使用箇所は最短距離にあり、その代償として寿命も最短のスコープに縛られます。

## 派生シナリオ1：共通祖先へ持ち上げる

では、値を遷移をまたいで残したい場合はどうするか。素朴な答えは「両方のRouteから見える共通祖先にStateを持ち上げる」です。共通祖先とは、Routeを生むNavigatorよりも**上**のWidgetを意味します。

検証コードでは、章ページの中にネストしたNavigatorを置き、その上（章ページのState）に `counter` を持たせました。枠内の遷移が「ライフタイムをまたぐ遷移」、枠の外が「共通祖先」に対応します。値と操作はコンストラクタとコールバックで内側のRouteへ渡します。

**操作**

| # | 操作 |
|---|------|
| 1 | 内側のNavigator.pushで詳細画面へ |
| 2 | counter +1 を3回押す |
| 3 | 内側のNavigator.popで戻り、もう一度push |
| 4 | 章ページ自体から戻る |

**ログ**

```text
※サンプルログ（実測後に差し替え）
initState: LIFTED-HOLDER  state=745112390  counter=0
[BUILD] holder (#1)  state=745112390  counter=0
[ACTION] increment -> counter=1
[BUILD] holder (#2)  state=745112390  counter=1
[ACTION] increment -> counter=2
[BUILD] holder (#3)  state=745112390  counter=2
[ACTION] increment -> counter=3
[BUILD] holder (#4)  state=745112390  counter=3
（内側pop→再push：disposeログは出ない）
dispose: LIFTED-HOLDER  state=745112390  counter=3
```

**確認できたこと（1）：寿命は延びる**

内側のpop・再pushを繰り返してもdisposeログは出ず、state idは745112390のまま変わりません。counterはNavigatorより上のElementに属しているため、Route配下のElementがいくら破棄されても巻き込まれない。「StateはElementに生かされ殺される」は変わっておらず、**紐づくElementを寿命の長いものに差し替えた**だけです。

**確認できたこと（2）：伝播が壊れる**

ここで画面に注目します。詳細画面には「push時点のcounter」をコンストラクタで渡していますが、+1を押しても**詳細画面内の表示は変わらず、枠の外（保持側）の表示だけが更新されます**。

これはRouteの中身が、保持側のsetStateでは再buildされないためです。pushで作られたRouteのビルダーは、Navigatorの親が再buildされても再実行されません。コンストラクタで渡した値はpush時点のスナップショットのままになります。

つまり持ち上げは、寿命の問題を解決する代わりに2つのコストを生みます。値を使う場所と持つ場所が離れ、コールバックをコンストラクタで引き回す必要が生じる（Localityの低下そのもの）こと。そして、**Routeをまたいだ値の伝播が、コンストラクタ渡しでは成立しない**ことです。

## 派生シナリオ2：Providerで供給する

2つ目のコスト——伝播——を解決するのがInheritedWidget系の仕組みです。ここでは評価対象ライブラリのProviderを使い、派生シナリオ1と同じ構造で「値の受け渡し」だけを `context.watch` に置き換えます。

```dart
ChangeNotifierProvider(
  create: (_) => CounterModel(),   // 生成・破棄をログに出すChangeNotifier
  child: /* 内側のNavigator */,
)
```

**ログ**

```text
※サンプルログ（実測後に差し替え）
create: CounterModel  model=331209845  count=0
[BUILD] inner home (#1)  count=0
[BUILD] inner detail (#1)  count=0
[ACTION] increment -> count=1  model=331209845
[BUILD] inner home (#2)  count=1
[BUILD] inner detail (#2)  count=1
（内側pop→再push）
[BUILD] inner detail (#1)  count=1
（章ページから戻る）
dispose: CounterModel  model=331209845  count=1
```

**確認できたこと**

まず、+1を押すと**詳細画面内の表示が即時更新されました**。第5章で確認したとおり、`watch`（内部は `dependOnInheritedWidgetOfExactType`、すなわちdependOn登録）による依存はElement単位で登録されるため、Route境界に関係なく通知が届きます。コンストラクタ渡しで壊れていた伝播が、依存登録という別経路で回復した形です。

次に、ログの2〜5行目に注目すると、+1のたびに `inner home` のbuildも出ています。画面上は詳細画面の下に隠れているRouteですが、watchで依存登録している以上、通知を受けてrebuildされます（この挙動は実測での要確認ポイントです）。伝播範囲の制御は第9章（Granularity）の主題になります。

最後に、章ページから戻った瞬間に `dispose: CounterModel` が出ました。ここが本章の要点です。**Providerが変えたのは伝播の経路であって、寿命ではありません。**CounterModelの寿命は依然としてChangeNotifierProviderのElementに縛られており、そのElementが破棄されれば値も消えます。

## ここまでの帰結

3つのシナリオを事実として並べます。

| 配置 | 寿命 | 伝播 | Locality |
|------|------|------|----------|
| ルート内（setState） | Routeと同じ | 不要（同一Element内） | 高 |
| 共通祖先（setState持ち上げ） | 祖先Elementと同じ | コンストラクタ渡しはRouteをまたげない | 中 |
| 共通祖先＋Provider | 祖先Element（Provider）と同じ | dependOn登録でRouteをまたぐ | 中 |

どの形でも変わらない一点があります。**ツリー内に配置する限り、Stateの寿命は必ずどこかのElementの寿命に縛られる。**持ち上げは縛る相手を替える操作であり、Providerは縛られたまま伝播経路を足す仕組みです。「親が変わればElementは破棄される」以上、アプリ全体をまたいで生きるStateをツリー内で実現しようとすると、縛る相手はどんどんルートに近づき、Localityはどんどん下がっていきます。

では、この縛りそのものを外す選択肢はないのか——それが章末コラムの主題です。

## 設計判断のまとめ（評価マトリクス）

| ライブラリ | Locality | 意味 |
|-----------|----------|------|
| setState | 高 | Element消滅でState消滅。完全にツリー内 |
| Provider | 中 | ツリー内だが、供給位置と使用位置をInheritedWidgetが仲介する |
| Riverpod | 低 | ProviderContainerでツリー外。ナビゲーションをまたげる |

高が良い・低が良いという表ではありません。「入力フォームの一時値」ならLocality高の配置が値の出どころを最短にしますし、「ログインセッション」ならLocality低の配置だけが寿命の要件を満たします。**この列を決めるのは要件であって、ライブラリの優劣ではない**、というのが本章の設計判断です。

## 章末コラム：RiverpodはなぜElementライフタイムからStateを切り離せるのか

本文で確認したとおり、ツリー内配置ではStateは必ずどこかのElementと運命を共にします。Riverpodがこの構図の外にいられるのは、Stateの保管場所が**ProviderContainer**という、Elementツリーとは別のオブジェクトだからです。

構造はこうなっています。`ProviderScope` はツリー上のWidgetですが、その役割はコンテナを生成して子孫に**公開する**ことに留まります。各Providerの状態はコンテナ内部で管理され、Widget側（`ConsumerWidget` など）が持つのはコンテナへの参照だけです。つまり、状態を表示していたWidget・Elementが破棄されても、それは「リスナーがひとり減った」ことを意味するだけで、値そのものはコンテナに残ります。コンテナを `runApp` の外で生成すれば（`UncontrolledProviderScope`）、アプリのElementツリーの生死からも完全に独立させられます。

ここで第1部の事実と対比してみます。

- ツリー内配置：「親が変わればElementは破棄される」——Stateの寿命はツリーの**構造**の関数
- コンテナ配置：コンテナには「親」がない——Stateの寿命はツリーの構造から独立

なお、Riverpodに寿命管理がないわけではありません。`autoDispose` を付けたProviderは「リスナーがゼロになったら破棄」という規則で寿命が決まります。重要なのは、この規則が**Elementツリーの構造ではなく参照の有無**に基づいている点です。ナビゲーションをまたぐStateを扱うとき、ツリー内配置では原理的に不可能だったこと（Routeの破棄から値を守ること）が、コンテナ配置では構造的に可能になる。どちらを選ぶかは、そのStateに求める寿命の要件が決めます。

## 次章に向けて

本章では「どこに置くか」が寿命を決めることを確認しました。次章では視点を変えて、「誰がrebuildを起こすのか」を扱います。起点となる事実は第3章の「buildを呼ぶのはフレーム内のBuildOwner」です。