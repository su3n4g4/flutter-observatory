---
title: "FlutterのElementツリーを理解する"
---

Widgetを書いているつもりでも、実際にツリーを動かしているのはElementです。本シリーズでは、ソースコードと実測ログをもとにその内部動作を確かめていきます。

## このシリーズの構成

こちらの序章ではElementの検証を行う前に前提知識と、検証でのログの読み方について説明をします。
そのあとにElementが持つ5つの責務を下記の順で確認していきます。

```
Chapter 1: 構造と位置（空間）─ Elementはどこにいるか
Chapter 2: 状態の変遷（時間）─ Elementはいつ生き、いつ死ぬか
              ↓
    存在しているElementへの作用
Chapter 3: 同一性  ─ ElementはどのWidgetと対応するか
Chapter 4: 再構築  ─ buildはいつ・何回実行されるか
Chapter 5: 依存    ─ 変化はどのElementまで伝播するか
```

Chapter 1とChapter 2が土台となり、この2章が腑に落ちると、Chapter 3〜Chapter 5が「存在しているElementに何が起きるか」という問いの延長として読めるようになります。

## 検証方法

検証コードを用いて章ごとに動作を確認していきます。

### リポジトリ

検証に使うコードはすべて以下のリポジトリにあります。

▶ [flutter-element-lab](https://github.com/su3n4g4/flutter-element-lab)

コードの詳細は記事では省略し、各章に該当ファイルへのリンクを置きます。

### 検証画面

下記より検証コードをブラウザで動かすことができます。
ログはChromeのDevToolにてconsoleに出力されます。
手元で動かしながら読むと、ログの意味がより実感を持って確認できます。

▶ [https://su3n4g4.github.io/flutter-element-lab/](https://su3n4g4.github.io/flutter-element-lab/)

次のセクションから前提知識の説明に入ります。

### Flutterのバージョン
利用しているFlutterのバージョンは下記となります
3.29.0

---

## 前提知識1：Widget / Element / State の役割

### Widget — 「何を作るかの定義」

Widgetはimmutableな設計図です。自分自身では画面上に何も持たず、「こういう見た目・振る舞いにしてほしい」という宣言を保持するだけです。build()`が呼ばれるたびに新しいインスタンスが作られても問題ないように、軽量に設計されています。

Widgetが持つのはコンストラクタで受け取った設定値（`label`、`color`、`padding`など）と`Widget.createElement()`メソッドだけです。Widget自身はツリー上に位置を持たず、状態も持ちません。

### Element — 「ツリー上の実体」

ElementはWidgetと1対1で生成され、ツリー上に実際に位置を占める存在です。親子関係、位置（slot/index）、ライフサイクルの管理をすべて担います。ライフサイクルとは、Elementが **active**（ツリー上にある）→ **inactive**（一時切り離し）→ **defunct**（破棄済み）と遷移する状態変化のことで、Stateの各コールバックはこの遷移に連動して呼ばれます。詳細は前提知識3で確認します。

Elementの責務は5つに分かれ、それぞれがこのシリーズの各章に対応しています。

| 責務 | 対応章 | やっていること |
| --- | --- | --- |
| 位置管理 | Chapter 1 | 親子関係とslotで自分の居場所を管理する |
| ライフサイクル管理 | Chapter 2 | Stateの生成・破棄・再接続を制御する |
| 同一性管理 | Chapter 3 | Elementを再利用するか破棄するかを判断する |
| リビルドスケジューリング | Chapter 4 | rebuildのタイミングと順序を制御する |
| 依存・通知管理 | Chapter 5 | InheritedWidgetへの依存登録と選択的rebuild |

重要なのは、ElementはWidgetが差し替わっても生き続けるということです。条件が満たされれば既存のElementに新しいWidgetを渡すだけで、Element（とState）は同一インスタンスのまま再利用されます。

### State — 「Elementに管理される可変の状態」

StateはStatefulWidgetに対応するElementが所有する、可変の状態です。自力では生まれも死にもできず、Elementのライフサイクルに完全に従属します。

`State.initState`や`State.dispose`といったコールバックはState自身が定義しますが、それを呼ぶタイミングはすべてElementが決めます。`State.setState()`だけはState側から呼べますが、それはElementに「再描画が必要だ」と伝えるリクエストにすぎません。実際にいつ`State.build()`を実行するかもElementとフレームワークが決めます。


### 3者の関係

**Widget**は「こう作ってほしい」という定義を渡すだけで、渡したら役目を終えます。
**Element**はその定義を受け取ってツリー上に実体を持ち、子の生成・更新・破棄をすべてFlutter内部の`Element.updateChild`メソッドで管理します。
**State**はElementに所有され、Elementのライフサイクルイベントに応じてコールバックが呼ばれる受動的な存在です。

この構造があるからこそ、Widgetを毎フレーム使い捨てにしてもパフォーマンスに影響せず、ElementとStateが差分更新で効率的にツリーを維持できます。

---

## 前提知識2：Element.updateChild の動き

Elementがツリー上で子を管理するとき、その判断はすべて`Element.updateChild`という1つのメソッドに集約されています。「子を新しく作るか、既存のものを再利用するか、破棄するか」——この章以降で確認する現象（位置がずれる、disposeが呼ばれる、Stateが維持される等）はここに帰着します。`Element.updateChild`の分岐を知っておくと、ログで見える現象の理由が説明できるようになります。

`Element.updateChild`は`packages/flutter/lib/src/widgets/framework.dart`に実装されています。

### 4つの分岐

`updateChild`は3つの引数を取ります。

- **`child`**：現在その位置に存在する子Element。まだ何もなければnull
- **`newWidget`**：今回のbuildが返した新しいWidget。その位置に何も置かなければnull
- **`slot`**：親の中でこの子が占める位置情報（インデックスなど）。分岐の判断には使われない

分岐の中で呼ばれるメソッドの意味は次のとおりです。

- **`Element.inflateWidget`**：WidgetからElementを新規生成し、ツリーに接続する。`State.initState`が呼ばれる
- **`Element.deactivateChild`**：Elementをツリーから`inactive`状態にする。同フレーム内で再接続されなければ`State.dispose`が呼ばれてStateが破棄される
- **`Element.update`**：既存のElementに新しいWidgetを渡す。変更前のWidgetを引数にStateへ変化を通知する`State.didUpdateWidget`が呼ばれる
  - **`Widget.canUpdate`**：`Element.update`を呼ぶかを決める判定。

この組み合わせで4つに分岐します。

| child | newWidget | 状況 | 動作 |
| --- | --- | --- | --- |
| null | null | 変化なし | 何もしない |
| null | non-null | 新規追加 | `Element.inflateWidget`（Elementを新規生成） |
| non-null | null | 削除 | `Element.deactivateChild`（Elementを破棄） |
| non-null | non-null | rebuild | `Widget.canUpdate`が true なら`Element.update`（既存Elementを再利用）、false なら`Element.deactivateChild`して`Element.inflateWidget`（作り直し） |

---

## 前提知識3：State が作られるまでの流れ

初期表示は「Elementツリーの構築 → Layout → Paint」の順で進みます。前提知識3で扱うのは最初のフェーズ、`updateChild`が呼ばれてから最初の`build()`が完了するまでです。

```
【Elementツリーの構築】 ← 前提知識3の範囲
  updateChild
    └─ inflateWidget
         ├─ createElement   (Element生成)
         ├─ createState     (State生成)
         └─ mount → _firstBuild
                    ├─ initState
                    └─ build → 再帰（ツリーの末端まで繰り返し）

【Layout】→【Paint】
```

### 起点：親Elementの`updateChild`

すべては親Elementが`Element.updateChild(null, newWidget, slot)`を呼ぶところから始まります。`child`がnullで`newWidget`が非nullのとき、「この位置にまだ子がいないので新しく作る」という分岐に入り、`Element.inflateWidget`が呼ばれます。

### Elementの生成：`createElement()`

`Element.inflateWidget`の中で`newWidget.createElement()`が実行されます。Widgetの種類に応じたElementが生まれます。

- `StatefulWidget` → `StatefulElement`
- `StatelessWidget` → `StatelessElement`
- `Padding`などの`SingleChildRenderObjectWidget` → `SingleChildRenderObjectElement`

### Stateの生成：StatefulElementのコンストラクタ

`StatefulElement`が特別なのはここです。コンストラクタの中で`widget.createState()`を呼び、Stateインスタンスをフィールド`_state`に保持します。Stateは`mount`よりも前、Elementが生まれた瞬間に作られます。

### ツリーへの接続：`mount` → `_firstBuild`

Elementが生成されると、`Element.inflateWidget`は続けて`Element.mount(parent, slot)`を呼びます。ここでElementがツリーに接続され、`StatefulElement._firstBuild()`の中でStateのコールバックが順に発火します。

1. `state.initState()` — 初期化処理
2. `state.build(context)` — 最初のWidgetツリーを返す

### 再帰：build()の戻り値が次のupdateChildへ

mountされたStatefulElementは、自分の子Elementを管理する親でもあります。`state.build(context)`が返したWidgetはその子を生成するための材料になるため、StatefulElementは親の立場でそのWidgetを引数に`Element.updateChild`を呼び、子のElementを生成します。

その子がStatefulWidgetであれば、同様に`StatefulWidget.createState()` → `Element.mount` → `State.initState`の流れが走ります。こうして「Stateが作られるまでの流れ」がツリーの末端まで再帰的に繰り返されます。

```
StatefulElement.mount()
  └─ _firstBuild()
       └─ state.build() → Widget を返す
            └─ updateChild(Widget) → inflateWidget       ← StatefulElementが親として呼ぶ
                 └─ 子Element.mount()
                      └─ （StatefulWidgetなら）createState() → initState → build → ...
```

### Stateのコールバックと呼び出し元

Stateの各コールバックと呼び出し元を一覧にします。`State.setState()`を除き、いずれもElementのメソッドから呼ばれます。

| Stateのコールバック | 呼び出し元 | タイミング |
| --- | --- | --- |
| `StatefulWidget.createState()` | `StatefulElement`のコンストラクタ | Elementが生まれた瞬間 |
| `State.initState()` | `StatefulElement._firstBuild()`内 | mount直後 |
| `State.didUpdateWidget()` | `StatefulElement.update()` | `Widget.canUpdate`がtrueで既存Elementを再利用したとき |
| `State.deactivate()` | `Element.deactivateChild()` | ツリーから外されたとき |
| `State.dispose()` | `StatefulElement.unmount()` | フレーム末尾で再接続されなかったとき |
| `State.setState()` | State自身が呼べる | 唯一Stateが能動的に起動できる操作 |

---

## StateTrackerとログの読み方

ここまでの前提知識で登場したElementのメソッド（`StatefulElement._firstBuild`、`Element.update`、`Element.deactivateChild`、`StatefulElement.unmount`など）は、実際の検証では直接見えません。代わりに、これらのメソッドが呼び出すState側のコールバックがログとして確認できます。それを出力するのが`StateTracker`です。

### StateTrackerとは

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

### ログの読み方

ログの解釈の対応表です。「このログが出た＝Elementについて何が言えるか」を整理します。

| ログ | 意味 | 何の確認になるか |
| --- | --- | --- |
| `initState` | 新しいStateが生成された | Elementが新規作成された |
| `didUpdateWidget` | 同じElementに別のWidgetが渡された | 位置ベースで再利用された |
| `deactivate` → `activate` | 一時切り離し→再接続 | disposeなしで移動した（GlobalKey） |
| `dispose` | Stateが破棄された | Elementがツリーから永久に外れた |
| `state=` の値が変わる | 別のインスタンスが生成された | Elementが作り直された |
| `state=` の値が変わらない | 同じインスタンスが使われた | Elementが再利用された |

特に`state=`の値（StateインスタンスのhashCode）が変わるかどうかが、多くのシナリオで判断の基準になります。同じ値であればElementが再利用され、変わっていればElementが作り直されています。

### ログと呼び出し元の対応

実装視点の対応表です。フレームワーク内部のどのメソッドがこのログを呼び出しているかを示します。

| StateTrackerのログ | 呼び出し元 | タイミング |
| --- | --- | --- |
| `initState: P` | `StatefulElement._firstBuild()` | mount直後 |
| `build: P` | `StatefulElement.performRebuild()` | initState直後、および以降のrebuild時 |
| `didUpdateWidget: A → C` | `StatefulElement.update()` | `Widget.canUpdate`がtrueで既存Elementを再利用したとき |
| `deactivate: P` | `Element.deactivateChild()` | ツリーから外されたとき |
| `activate: P` | `Element.activate()` | GlobalKeyで再接続されたとき |
| `dispose: P` | `StatefulElement.unmount()` | フレーム末尾で再接続されなかったとき |

---

以上が検証に入る前の前提知識となります。Chapter 1からは実際の検証に入ります。
