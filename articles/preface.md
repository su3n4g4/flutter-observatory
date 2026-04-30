# FlutterのElementツリーを理解する

## なぜElementを知る必要があるか

Flutterでアプリを書いていると、こんな場面に出会います。

- リストを並び替えたら、表示がずれた
- `setState`を呼んだのに、なぜか別のウィジェットまで再描画された
- `dispose`が予期しないタイミングで呼ばれた

これらは全て、Elementツリーの動作を知っていれば根本原因を説明できます。Widgetは設計図、RenderObjectは描画、そしてElementはその間でツリーの実体を管理しています。Flutterを書き続けるほど、Elementの知識が「なんとなく動く」と「なぜ動くかわかる」の境界線になります。

## このシリーズの構成

Elementが持つ5つの責務を観測で確定させます。

```
Ch1: 構造と位置（空間）─ Elementはどこにいるか
Ch2: 状態の変遷（時間）─ Elementはいつ生き、いつ死ぬか
              ↓
    存在しているElementへの作用
Ch3: 同一性  ─ ElementはどのWidgetと対応するか
Ch4: 再構築  ─ buildはいつ・何回実行されるか
Ch5: 依存    ─ 変化はどのElementまで伝播するか
```

Ch1とCh2が土台です。この2章が腑に落ちると、Ch3〜Ch5が「存在しているElementに何が起きるか」という問いの延長として読めるようになります。

## 検証スタイル

理論の説明より先に「何が起きるか」を観測し、そこから事実を確定させる順序で進みます。操作→観測→事実の3ステップです。

各章の構成はこのテンプレートに従います。

```
・この章の問い
・何を検証したか
・結果から読み取れること
```

## リポジトリ

検証に使うコードはすべて以下のリポジトリにあります。手元で動かしながら読むと、ログの意味がより実感を持って確認できます。

▶ [flutter-observatory](https://github.com/su3n4g4/flutter-observatory)

コードの詳細は記事では省略し、各章に該当ファイルへのリンクを置きます。

---

# 前提整理：Widget / Element / State の役割

## Widget — 「何を作るかの定義」

Widgetはimmutableな設計図です。自分自身では画面上に何も持たず、「こういう見た目・振る舞いにしてほしい」という宣言を保持するだけです。`build()`が呼ばれるたびに新しいインスタンスが作られても問題ないように、軽量に設計されています。

Widgetが持つのはコンストラクタで受け取った設定値（`label`、`color`、`padding`など）と`createElement()`メソッドだけです。Widget自身はツリー上に位置を持たず、状態も持ちません。

## Element — 「ツリー上の実体」

ElementはWidgetと1対1で生成され、ツリー上に実際に位置を占める存在です。親子関係、位置（slot/index）、ライフサイクルの管理をすべて担います。

Elementの責務は5つに分かれ、それぞれがこのシリーズの各章に対応しています。

| 責務 | 対応章 | やっていること |
| --- | --- | --- |
| 位置管理 | Ch1 | 親子関係とslotで自分の居場所を管理する |
| ライフサイクル管理 | Ch2 | Stateの生成・破棄・再接続を制御する |
| 同一性管理 | Ch3 | Elementを再利用するか破棄するかを判断する |
| リビルドスケジューリング | Ch4 | rebuildのタイミングと順序を制御する |
| 依存・通知管理 | Ch5 | InheritedWidgetへの依存登録と選択的rebuild |

重要なのは、ElementはWidgetが差し替わっても生き続けるということです。条件が満たされれば既存のElementに新しいWidgetを渡すだけで、Element（とState）は同一インスタンスのまま再利用されます。その条件が何かは次の前提整理で見ていきます。

## State — 「Elementに管理される可変の状態」

StateはStatefulWidgetに対応するElementが所有する、可変の状態です。自力では生まれも死にもできず、Elementのライフサイクルに完全に従属します。

`initState`や`dispose`といったコールバックはState自身が定義しますが、それを呼ぶタイミングはすべてElementが決めます。`setState()`だけはState側から呼べますが、それはElementに「再描画が必要だ」と伝えるリクエストにすぎません。実際にいつ`build()`を実行するかもElementとフレームワークが決めます。

具体的にどのElementがどのタイミングでStateのコールバックを呼ぶかは、次の前提整理で見ていきます。

## 3者の関係をひと言で

**Widget**は「こう作ってほしい」という定義を渡すだけで、渡したら役目を終えます。**Element**はその定義を受け取ってツリー上に実体を持ち、子の生成・更新・破棄をすべてFlutter内部の`updateChild`メソッドで管理します。**State**はElementに所有され、Elementのライフサイクルイベントに応じてコールバックが呼ばれる受動的な存在です。

この構造があるからこそ、Widgetを毎フレーム使い捨てにしてもパフォーマンスに影響せず、ElementとStateが差分更新で効率的にツリーを維持できます。

---

# 前提整理：Element.updateChild の動き

Elementがツリー上で子を管理するとき、その判断はすべて`updateChild`という1つのメソッドに集約されています。「子を新しく作るか、既存のものを再利用するか、破棄するか」——この章以降で観測するすべての現象（位置がずれる、disposeが呼ばれる、Stateが維持される）は、ここに帰着します。`updateChild`の分岐を知っておくと、ログで見える現象の理由が説明できるようになります。

`updateChild`は`packages/flutter/lib/src/widgets/framework.dart`に実装されています。

## 4つの分岐

`updateChild(child, newWidget, slot)`は引数の組み合わせで4つに分岐します。

| child | newWidget | 動作 |
| --- | --- | --- |
| null | null | 何もしない |
| null | non-null | `inflateWidget`（新規生成） |
| non-null | null | `deactivateChild`（破棄） |
| non-null | non-null | `canUpdate`→ true なら`update`、false なら deactivate + inflate |

```
updateChild(child, newWidget, slot)
│
├─ newWidget == null
│    └─ child があれば deactivateChild(child)  → dispose へ
│
├─ child == null
│    └─ inflateWidget(newWidget, slot)  → 新規 Element 生成
│
└─ child も newWidget も non-null
     ├─ child.widget == newWidget（同一インスタンス）
     │    └─ slot のみ更新、何もしない
     │
     ├─ Widget.canUpdate == true
     │    └─ child.update(newWidget)  → didUpdateWidget が呼ばれる
     │
     └─ Widget.canUpdate == false
          ├─ deactivateChild(child)
          └─ inflateWidget(newWidget, slot)  → 新規 Element 生成
```

## Widget.canUpdate の判定

```dart
// packages/flutter/lib/src/widgets/framework.dart
static bool canUpdate(Widget oldWidget, Widget newWidget) {
  return oldWidget.runtimeType == newWidget.runtimeType
      && oldWidget.key == newWidget.key;
}
```

判断基準は**runtimeTypeとKeyの2つだけ**です。childrenの内容や他のプロパティは一切見ません。この単純なルールがCh1・Ch3の検証の根拠になります。

---

# 前提整理：State が作られるまでの流れ

## 起点：親Elementの`updateChild`

すべては親Elementが`updateChild(null, newWidget, slot)`を呼ぶところから始まります。`child`がnullで`newWidget`が非nullのとき、「この位置にまだ子がいないので新しく作る」という分岐に入り、`inflateWidget`が呼ばれます。

## Elementの生成：`createElement()`

`inflateWidget`の中で`newWidget.createElement()`が実行されます。Widgetの種類に応じたElementが生まれます。

- `StatefulWidget` → `StatefulElement`
- `StatelessWidget` → `StatelessElement`
- `Padding`などの`SingleChildRenderObjectWidget` → `SingleChildRenderObjectElement`

## Stateの生成：StatefulElementのコンストラクタ

`StatefulElement`が特別なのはここです。コンストラクタの中で`widget.createState()`を呼び、Stateインスタンスをフィールド`_state`に保持します。Stateは`mount`よりも前、Elementが生まれた瞬間に作られます。

## ツリーへの接続：`mount` → `_firstBuild`

Elementが生成されると、`inflateWidget`は続けて`element.mount(parent, slot)`を呼びます。ここでElementがツリーに接続され、`_firstBuild()`の中でStateのコールバックが順に発火します。

1. `state.initState()` — 初期化処理
2. `state.didChangeDependencies()` — initState直後に必ず呼ばれる（詳細はCh5で扱います）
3. `state.build(context)` — 最初のWidgetツリーを返す

## 再帰：build()の戻り値が次のupdateChildへ

`state.build(context)`が返したWidgetは、今度はこのStatefulElement自身が`updateChild(_child, builtWidget, slot)`を呼ぶときの`newWidget`になります。初回は`_child`がnullなので再び`inflateWidget`に入り、子のElementが生成されます。このサイクルがツリーの末端まで再帰的に繰り返されます。

## Stateのコールバックと呼び出し元

ここまでの流れを整理すると、Stateの各コールバックはすべてElementのメソッドから呼ばれていることがわかります。

| Stateのコールバック | 呼び出し元 | タイミング |
| --- | --- | --- |
| `createState()` | `StatefulElement`のコンストラクタ | Elementが生まれた瞬間 |
| `initState()` | `_firstBuild()`内 | mount直後 |
| `didUpdateWidget()` | `StatefulElement.update()` | `canUpdate`がtrueで既存Elementを再利用したとき |
| `deactivate()` | `Element.deactivateChild()` | ツリーから外されたとき |
| `dispose()` | `StatefulElement.unmount()` | フレーム末尾で再接続されなかったとき |
| `setState()` | State自身が呼べる | 唯一Stateが能動的に起動できる操作（詳細はCh4） |

`setState()`以外のコールバックは、Stateが自分の意思で呼ぶことはできません。StateのライフサイクルはすべてElementが支配しています。

| フェーズ | 何が起きるか | Widgetの役割 |
| --- | --- | --- |
| `inflateWidget` | `newWidget.createElement()` | 定義 → Elementを生成する設計図 |
| コンストラクタ内 | `widget.createState()` | 定義 → Stateを生成する設計図 |
| `mount` | `element.mount(parent, slot)` | ここでElementがツリーに接続される |
| `_firstBuild` | `initState` → `build` | WidgetのbuildがはじめてWidgetを返す |

`inflateWidget`の中で「定義を渡す → オブジェクトを作る → ツリーに接続する」という3段階が一気に実行されます。`initState`の中で`of(context)`のような祖先への参照が使えない理由も、このmountのタイミングから来ています。詳細はCh5で扱います。

---

# StateTrackerとログの読み方

ここまでの前提整理で登場したElementのメソッド（`_firstBuild`、`update`、`deactivateChild`、`unmount`など）は、実際の検証では直接見えません。代わりに、これらのメソッドが呼び出すState側のコールバックがログとして観測できます。それを出力するのが`StateTracker`です。

## StateTrackerとは

全章を通じて`StateTracker`という確認用ウィジェットを使います。観察対象であると同時に、ライフサイクルイベントをログに出力する観察装置でもあります。

```dart
StateTracker("A")
```

画面上にはこのように表示されます。

```
┌─────────────────────────────┐
│ StateTracker("A")           │
│ state id:    1234           │
│ build count: 3              │
│ last event:  deactivated    │
└─────────────────────────────┘
```

デバッグコンソールには以下のログが出ます。

```
initState: A  state=1234
build: A  state=1234  depth=12  element=StatefulElement
didUpdateWidget: A -> C  state=1234
deactivate: A  state=1234
dispose: A  state=1234
```

## ログの読み方

各ログが何の確認につながるかを先に整理しておきます。

| ログ | 意味 | 何の確認になるか |
| --- | --- | --- |
| `initState` | 新しいStateが生成された | Elementが新規作成された |
| `dispose` | Stateが破棄された | Elementがツリーから永久に外れた |
| `deactivate` → `activate` | 一時切り離し→再接続 | disposeなしで移動した（GlobalKey） |
| `didUpdateWidget` | 同じElementに別のWidgetが渡された | 位置ベースで再利用された |
| `state=` の値が変わる | 別のインスタンスが生成された | Elementが作り直された |
| `state=` の値が変わらない | 同じインスタンスが使われた | Elementが再利用された |

特に`state=`の値（StateインスタンスのhashCode）が変わるかどうかが、多くのシナリオで判断の基準になります。同じ値であればElementが再利用され、変わっていればElementが作り直されています。

## ログと呼び出し元の対応

| StateTrackerのログ | 呼び出し元 | タイミング |
| --- | --- | --- |
| `initState: P` | `StatefulElement._firstBuild()` | mount直後 |
| `build: P` | `StatefulElement.performRebuild()` | initState直後、および以降のrebuild時 |
| `didUpdateWidget: A → C` | `StatefulElement.update()` | `canUpdate`がtrueで既存Elementを再利用したとき |
| `deactivate: P` | `Element.deactivateChild()` | ツリーから外されたとき |
| `activate: P` | `Element.activate()` | GlobalKeyで再接続されたとき |
| `dispose: P` | `StatefulElement.unmount()` | フレーム末尾で再接続されなかったとき |

---

以上が検証に入る前の前提整理です。Ch1からは実際の観測に入ります。