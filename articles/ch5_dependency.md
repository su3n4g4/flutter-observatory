# Ch5: 依存と通知の管理

▶ [検証コード（GitHub）](https://github.com/su3n4g4/flutter-element-lab/tree/main/flutter_element_lab/lib/chapters/ch5)　▶ [検証画面](https://su3n4g4.github.io/flutter-element-lab/)

## この章で確かめること

**ツリー内で離れた場所にあるWidget同士は、どのように値を共有し、どの範囲までrebuildが届くのか？**

---

## 前提：InheritedWidgetとNotificationは何をしているのか

こちらも検証に入る前にInheritedWidgeとNotificationの前提知識から説明していきます。
`setState`はElement自身を再構築するための仕組みでした（Ch4）。しかし実アプリでは、自分自身ではなくツリーの離れた場所にあるWidgetに変更を届けたい場面があります。親が持つテーマ色を深い子孫で使いたい、子孫でのイベントを親に知らせたい、といった要求です。

Flutterはこれを2つの仕組みで解決します。

- **InheritedWidget**：親から子孫への「下方向」の値の供給
- **Notification**：子孫から親への「上方向」のイベントの伝播

両者は方向が逆なだけでなく、**通知先がどう決まるか**が根本的に異なります。InheritedWidgetは「`of()`を呼んだElementだけに通知が届く」という動的な依存登録を持つのに対し、Notificationは「ツリー上にあるListenerが順番に受け取る」という静的な構造解決しか持ちません。この違いを理解するために、まず両者がmount時とbuild時にそれぞれ何を構築しているかを押さえておきます。

### Elementは2系統の補助構造を保持する

mountされた各Elementは、Widget本体のツリー（親子関係）とは別に、2系統の補助構造を保持しています。

- **`_inheritedElements`**：祖先のInheritedElementを型で引くためのマップ
- **`_notificationTree`**：祖先の`NotificationListener`を辿るための連結リスト

どちらもmountのタイミングで親から引き継いで構築されます。違いは「自分自身がそこに登場するかどうか」であり、これがそのまま2つの経路の性格を決めています。
次のセクションでそれぞれの仕組みの詳細をみていきます。

### InheritedWidget

InheritedWidgetは「スコープの公開」と「差分判定」を担います。mount時とbuild時の2つのタイミングで、それぞれ異なる構造を構築します。

#### mount時：祖先の索引化

Elementがmountされる際に、任意のElementが祖先のInheritedWidgetを型名で引けるよう、下記の流れでマップを作成します。
- 親の_inheritedElementsマップ（`Type` → `InheritedElement`）をコピーする
- `InheritedElement`の場合のみ、コピーしたマップに自分自身を追加する
- 更新済みのマップを子に渡す

```dart
// Element._updateInheritance()
void _updateInheritance() {
  _inheritedElements = _parent?._inheritedElements;
}

// InheritedElement._updateInheritance()（オーバーライド）
@override
void _updateInheritance() {
  assert(_lifecycleState == _ElementLifecycle.active);
  final PersistentHashMap<Type, InheritedElement> incomingWidgets =
      _parent?._inheritedElements ?? const PersistentHashMap<Type, InheritedElement>.empty();
  _inheritedElements = incomingWidgets.put(widget.runtimeType, this);
}
```

ここで構築されるのは「祖先を引くための索引」であって、「rebuild対象としての登録」ではありません。

#### build時：依存登録

`build()`内で`of()`が呼ばれた瞬間に、呼び出し元のElementを「InheritedWidgetが更新されたらrebuildすべき対象」として登録します。

- mount時に作成したマップから祖先のInheritedElementを取得する
- 呼び出し元のElement（`this`）を祖先の`_dependents`（InheritedElementが保持する通知先リスト）に追加する

```dart
// Element.dependOnInheritedWidgetOfExactType<T>()
@override
T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({Object? aspect}) {
  assert(_debugCheckStateIsActiveForAncestorLookup());
  final InheritedElement? ancestor = _inheritedElements?[T];  // ← mount時の索引を使う
  if (ancestor != null) {
    return dependOnInheritedElement(ancestor, aspect: aspect) as T;
  }
  _hadUnsatisfiedDependencies = true;
  return null;
}

// Element.dependOnInheritedElement()
@override
InheritedWidget dependOnInheritedElement(InheritedElement ancestor, { Object? aspect }) {
  _dependencies ??= HashSet<InheritedElement>();
  _dependencies!.add(ancestor);
  ancestor.updateDependencies(this, aspect);  // ← ここで_dependentsに登録
  return ancestor.widget as InheritedWidget;
}
```

ここで重要なのは登録のタイミングです。
登録が起きるのは`build()`内で`dependOn`が呼ばれた時点のみで、Widget定義時でもmount時でもありません。
また、同じElementでも、`of()`を呼ばなかったフレームでは依存を失います。

**どのElementが通知を受け取るかはWidgetの静的な構造からは決まらず、build()の実行履歴によって決まります。**

#### 更新時：notifyClients による通知

値が変化したかどうかは、アプリ側で実装する`updateShouldNotify`メソッドで判定され、`true`を返した場合のみ`notifyClients`が呼ばれます。

```dart
@override
void notifyClients(InheritedWidget oldWidget) {
  assert(_debugCheckOwnerBuildTargetExists('notifyClients'));
  for (final Element dependent in _dependents.keys) {
    assert(() {
      // check that it really is our descendant
      Element? ancestor = dependent._parent;
      while (ancestor != this && ancestor != null) {
        ancestor = ancestor._parent;
      }
      return ancestor == this;
    }());
    // check that it really depends on us
    assert(dependent._dependencies!.contains(this));
    notifyDependent(oldWidget, dependent);  // 内部でdependent.didChangeDependencies() → markNeedsBuild()
  }
}
```

`notifyClients`では`_dependents.keys`を走査して、登録済みElementにのみ`markNeedsBuild`を通知します。逆に言えば、`_dependents.keys`に含まれないElementには通知が届きません。

### Notification

NotificationにはInheritedWidgetとは異なり「rebuild対象としての依存登録」がありません。

#### mount時：連結リストの構築

すべてのElementは`mount`のタイミングで`attachNotificationTree()`を呼び出します。通常のElementは親の参照をそのまま受け継ぐだけですが、`NotifiableElementMixin`（`NotificationListener`が使う）は自分自身を先頭に追加した新しいノードを作ります。

```dart
void attachNotificationTree() {
  _notificationTree = _NotificationNode(_parent?._notificationTree, this);
}
```

これにより任意の子Elementから`dispatch`を呼ぶと、`_notificationTree`チェーンを通じて祖先のListenerへ順に到達できます。

#### dispatch時：3層に分かれた処理

`dispatch`の処理は3つのクラスに責務が分かれています。

- **`Notification`**：データの運搬役に徹し、`context.dispatchNotification`を呼ぶだけ
- **`NotifiableElementMixin`**：mount時に構築済みの`_notificationTree`チェーンの走査を開始する
- **`_NotificationNode`**：各ノードで`onNotification`を呼び出し、`true`なら伝播停止、`false`なら上位ノードへ続ける（型が一致しないListenerも`false`を返してスルーされる）

```dart
// Notification.dispatch
void dispatch(BuildContext? target) {
  target?.dispatchNotification(this);
}

// NotifiableElementMixin.dispatchNotification
@override
void dispatchNotification(Notification notification) {
  _notificationTree?.dispatchNotification(notification);
}

// _NotificationNode.dispatchNotification
void dispatchNotification(Notification notification) {
  if (current?.onNotification(notification) ?? true) {
    return;  // true → 伝播停止
  }
  parent?.dispatchNotification(notification);  // false → 上位ノードへ続く
}
```

ここで重要なのは、**通知の宛先がツリー構造（mount時に決まる静的な配置）から完全に決まっていて、build()内で何を呼ぼうと宛先は変わらない**ということです。InheritedWidgetが`of()`を呼んだElementを動的に`_dependents`へ登録するのとは対照的に、Notificationは「誰が通知を受け取るか」を構造そのもので固定しています。

そして、Notificationそれ自体はrebuildを起こしません。rebuildが起きるかどうかは、Listenerが`onNotification`コールバックの中で`setState`を呼ぶかどうかに依存します。呼べば通常のsetStateと同じ経路（Ch4）でrebuildが起き、呼ばなければ何も起きません。

### 2つの経路の対比

ここまでの整理をまとめます。

| 観点 | InheritedWidget | Notification |
| --- | --- | --- |
| mount時に作られる構造 | `_inheritedElements`（祖先の型索引） | `_notificationTree`（Listenerの連結リスト） |
| 「rebuild対象」としての登録 | あり（build時に`_dependents`へ追加） | なし |
| 通知先の決まり方 | build()の実行履歴で動的に決まる | ツリー構造で静的に決まる |
| 通知それ自体がrebuildを起こすか | はい（`markNeedsBuild`を直接呼ぶ） | いいえ（`setState`を呼ぶかは捕捉側次第） |

InheritedWidgetは`_dependents`という索引を持つことで、Widgetツリーの親子関係とは独立して通知先を絞れます。対してNotificationは依存登録機構を持たず、rebuildの範囲は捕捉側が`setState`を呼ぶかどうか・どのElementで呼ぶかだけで決まります。

## ログの仕込み方

ここまでで、2つの仕組みの違いが分かりました。

- InheritedWidgetは`_dependents`という索引で通知先を絞り、登録は`build()`内で`dependOn`が呼ばれた時点で起きます
- Notificationは依存登録機構を持たず、宛先はmount時に決まる`_notificationTree`の構造で固定されます
- rebuildを起こすかどうかも、前者は索引経由で自動、後者は捕捉側の`setState`次第です

これを確認するには、「誰が、いつ、何回rebuildされたか」のログを全Widgetに仕込みます。ただし確認したい事柄は2つの仕組みで異なるので、ログも仕組みごとに分けて設計します。

### InheritedWidget用：依存登録の有無がrebuildを分けることを確認する

InheritedWidget側で確かめたいのは「`of()`を呼んだElementだけがrebuildされる」という選択性です。これを確認するには、build回数の差と、`_dependents`への通知が走る直前の差分判定タイミングを両方押さえる必要があります。

**[BUILD]：build()内のdebugPrint（dependent/independent両方に仕込む）**

```dart
@override
Widget build(BuildContext context) {
  buildCount += 1;
  final value = _DependencyScope.of(context).value;
  debugPrint('[BUILD] dependent (#$buildCount) value=$value');
  // ...
}
```

dependent側だけでなくindependent側にも同じ形で仕込みます（`of()`は呼ばない）。両者のbuildカウントを並べて見ることで、依存登録があるElementだけがrebuildされる選択性が直接ログに表れます。

**[Inherited]：updateShouldNotify内のdebugPrint**

```dart
@override
bool updateShouldNotify(_DependencyScope oldWidget) {
  debugPrint('[Inherited] updateShouldNotify old=${oldWidget.value} new=$value');
  return value != oldWidget.value;
}
```

差分判定が呼ばれたタイミングと新旧値を記録します。`_dependents`への通知が起きる直前の関門であり、ここで`false`が返れば通知自体が起きません。「親はrebuildされた、子の`updateShouldNotify`は呼ばれた、それでもindependentは沈黙した」という3段階の事実が並ぶことで、選択性の根拠が`_dependents`にあることが言えます。

**期待される出力パターン**

```
[Scope] build (#N) value=Y                     ← 値を保持する側のrebuild（setState起点）
[Inherited] updateShouldNotify old=X new=Y     ← 差分判定（trueで通知が走る）
[BUILD] dependent (#N) value=V                 ← 登録済みElementだけrebuild
（[BUILD] independentは出ない）                ← 未登録Elementは沈黙
```

この出力が得られれば、`updateShouldNotify`が`true`を返したのにindependentが反応しないという事実から、「通知先は依存登録の有無で決まる」「`_dependents`未登録のElementには通知が届かない」という主張がログだけで証明できます。

### Notification用：rebuild範囲が捕捉側に委ねられることを観測する

Notification側で確かめたいのは、InheritedWidgetとは正反対の主張です：**選択的rebuildのような索引が存在せず、`onNotification`内で`setState`を呼んだ瞬間に捕捉側Element以下が一括でrebuildに巻き込まれる**こと。これを確認するには、通知の到達と、そこから始まる通常のrebuildパスが捕捉側Element配下を一括で巻き込む様子を押さえます。

**[NOTIFICATION]：onNotificationコールバック内のdebugPrint**

```dart
onNotification: (notification) {
  debugPrint('[NOTIFICATION] received: ${notification.message}');
  setState(() => notificationCount += 1);
  return true;
},
```

Notificationが`_notificationTree`チェーンを辿ってListenerに届いた瞬間と、そこから`setState`が呼ばれる瞬間を記録します。

**[BUILD]：捕捉側ページと配下Widget全部に仕込む**

InheritedWidget側と同じ`[BUILD]`ログを、捕捉側ページ・dispatch元のleaf・dispatchに関与しないindependentすべてに仕込みます。Notification経由では`onNotification`内の`setState`が通常のrebuildパス（Ch4）を起動するため、ページ以下が依存の有無に関係なく全部rebuildされます。これがログでも全Widgetがカウントアップする形で見えます。

**期待される出力パターン**

```
[NOTIFICATION] received: leaf -> bubble        ← _notificationTreeを辿って捕捉
[BUILD] page (#N)                              ← setState起点の通常rebuildパス
[BUILD] dispatch widget (#N)                 ← 配下なので巻き込まれる
[BUILD] independent widget (#N)                ← 依存していなくても巻き込まれる
```

この出力が得られれば、「Notification自体はrebuildを起こさず、捕捉側`setState`が通常のrebuildパスを起動する」「依存登録機構を持たないので範囲は絞れない」という主張がログだけで言えます。InheritedWidget側でindependentが沈黙したのと対比すれば、両者の挙動の差が依存登録機構の有無に帰着することも明確になります。

### この章で確認すること

前提を踏まえると、この章の検証シナリオが何を確認しようとしているかが分かります。

- **依存登録による選択的rebuildの確認**：InheritedWidgetの値を更新したとき、`of()`を呼んだ子だけがrebuildされ、呼ばなかった子は沈黙するか（基本）
- **登録機構を持たない経路の確認**：Notificationは`_dependents`のような依存登録を持たず、rebuild範囲は捕捉側の`setState`に委ねられることを示せるか（派生）

---

## dependOnを呼んだ子だけがrebuildされる

前提で「依存登録による選択的rebuild」の仕組みを見ました。ここではそれを実際のログで確認します。

### InheritedWidget配下に「依存あり」「依存なし」の子を並べる

検証画面の構造は次のとおりです。値の保持と更新は`_VisualDependencyScope`（StatefulWidget）が担い、その内側で`_DependencyScope`（InheritedWidget）を子に被せます。配下に2種類の子を並べます。

```
_Ch5P1InheritedDependencyPage (Stateless)
  └─ _VisualDependencyScope (Stateful, value=N)
      └─ _DependencyScope (InheritedWidget)
          ├─ _DependentWidget    ← build内でof()を呼ぶ（依存登録あり）
          └─ _IndependentWidget  ← 何も呼ばない（依存登録なし）
```

検証コード（主要部のみ）。

```dart
// 値の管理とInheritedWidgetの可視化を担うラッパー
class _VisualDependencyScopeState extends State<_VisualDependencyScope> {
  int value = 0;
  int buildCount = 0;

  void _increment() {
    setState(() => value += 1);
  }

  @override
  Widget build(BuildContext context) {
    buildCount += 1;
    debugPrint('[Scope] build (#$buildCount) value=$value');
    return WidgetBox(
      kind: WidgetKind.inherited,
      name: '_DependencyScope',
      role: 'value を公開する InheritedWidget。of() でアクセス可',
      badges: ['value: $value', 'updateShouldNotify'],
      buildCount: buildCount,
      child: _DependencyScope(
        value: value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            FilledButton(
              onPressed: _increment,
              child: const Text('value を更新する（_DependentWidget だけ rebuild される）'),
            ),
            const SizedBox(height: 8),
            widget.child,
          ],
        ),
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

// 依存ありWidget
class _DependentWidgetState extends State<_DependentWidget> {
  int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    buildCount += 1;
    final value = _DependencyScope.of(context).value;  // ← ここで依存登録
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

// 依存なしWidget
class _IndependentWidgetState extends State<_IndependentWidget> {
  int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    buildCount += 1;
    debugPrint('[BUILD] independent (#$buildCount)');  // ← of()を呼ばない

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
```

**① 初期表示**

画面を開きます。`_VisualDependencyScope`、dependent、independentがすべて初回buildされます。

```
[Scope] build (#1) value=0
[BUILD] dependent (#1) value=0
[BUILD] independent (#1)
```

この時点で起きていることは次のとおりです。

- `_DependentWidget`：build内で`_DependencyScope.of(context)`が呼ばれ、`InheritedElement._dependents`に自分自身を登録（前提で見た`dependOnInheritedElement → updateDependencies`の経路）
- `_IndependentWidget`：`of()`を呼ばないので`_dependents`には載りません
- 結果として、`_dependents`には dependent だけが登録された状態になります

**② 「valueを更新」ボタン押下**

ボタンを押します。`_VisualDependencyScope`の`setState`で`value`が0から1に変わります。

```
[Scope] build (#2) value=1
[Inherited] updateShouldNotify old=0 new=1
[BUILD] dependent (#2) value=1
```

`[BUILD] independent`は**出ません**。ここで起きている処理を順を追って見ます。

```mermaid
sequenceDiagram
    participant U as ユーザー
    participant VS as _VisualDependencyScope<br/>(StatefulElement)
    participant FW as Framework<br/>(Element.update)
    participant DS as _DependencyScope<br/>(InheritedElement)
    participant DEP as _DependentWidget
    participant IND as _IndependentWidget

    U->>VS: ボタン押下 → setState
    VS->>VS: build() 実行<br/>[Scope] build (#2) value=1
    VS->>FW: 新しい_DependencyScope(value:1)を返す
    FW->>DS: 新旧Widgetを比較
    DS->>DS: updateShouldNotify(old:0, new:1)<br/>[Inherited] updateShouldNotify
    DS-->>FW: true
    FW->>DS: notifyClients()
    DS->>DS: _dependents を走査
    DS->>DEP: didChangeDependencies()<br/>→ markNeedsBuild()
    Note over IND: _dependentsに載っていない<br/>→ 通知されない
    DEP->>DEP: rebuild<br/>[BUILD] dependent (#2) value=1
```

ステップごとに整理すると：

1. **[ログ出力] `[Scope] build (#2) value=1`**：`_VisualDependencyScope`の`setState`起点でbuildが走り、冒頭でdebugPrintが打たれます
2. **[内部処理]**：build()内で新しい`_DependencyScope(value: 1)`が生成されます
3. **[内部処理]**：`Element.update`で新旧の`_DependencyScope`を比較します
4. **[ログ出力] `[Inherited] updateShouldNotify old=0 new=1`**：差分判定が`true`を返します
5. **[内部処理]**：`notifyClients()`が`_dependents`を走査します
6. **[内部処理]**：登録済みElementで`didChangeDependencies` → `markNeedsBuild`
7. **[ログ出力] `[BUILD] dependent (#2) value=1`**：登録済みのdependentだけがrebuildされます
8. **[沈黙] `[BUILD] independent`は出ません**：`_dependents`に載っていないので通知が届きません

**ログの順序が示す時間差**

`[Scope] build`が先で`[Inherited] updateShouldNotify`が後、という順序は重要なヒントです。これは「buildの冒頭でログが出る → buildが完了して新Widgetが返る → フレームワークが新旧Widgetを比較する過程でupdateShouldNotifyを呼ぶ」という時間差をそのまま表しています。差分判定はbuildの内部処理ではなく、build結果を受け取ったフレームワーク側の処理です。

**確認できたこと**

ログが3段階に分かれて出る順序自体が、次の経路を実証しています。

```
setState
  → 親build（[Scope] build）
    → updateShouldNotify（[Inherited]）
      → notifyClients
        → 依存ElementだけmarkNeedsBuild
          → dependentのrebuild（[BUILD] dependent）
```

そして`[BUILD] independent`が出ないことで、`_dependents`に登録されたElementだけが通知を受ける仕組みが働いていることが裏付けられます。`of()`を呼んだdependentは登録されており、呼ばなかったindependentは登録されていません。**依存登録の有無が、rebuildの有無を直接決定しています。**

---

## Notificationには登録機構がない

基本では、InheritedWidgetが`_dependents`という独自の索引で通知先を絞ることを確認しました。では、同じ「ツリーをまたいだ通信」の仕組みでも、登録機構を持たないNotificationではrebuildの範囲がどう決まるのでしょうか。前提で見た「捕捉側の`setState`に依存する」ことをログで確認します。

### 子からdispatchし、親のNotificationListenerで捕捉する

検証画面の構造は次のとおりです。`NotificationListener`はbuildCountを観測するために`_VisualNotificationListener`（StatefulWidget）でラップしてあります。

```
_Ch5P2NotificationBubblePage (Stateful, notificationCount=N)
  └─ _VisualNotificationListener (Stateful)
      └─ NotificationListener<_DemoNotification>
          ├─ _DispatchWidget    ← ボタン押下でdispatch
          └─ _IndependentWidget           ← 通知には関与しない
```

検証コード（主要部のみ）。

```dart
class _Ch5P2NotificationBubblePageState
    extends State<Ch5P2NotificationBubblePage> {
  int notificationCount = 0;
  int pageBuildCount = 0;

  @override
  Widget build(BuildContext context) {
    pageBuildCount += 1;
    debugPrint('[BUILD] Ch5 P2 page (#$pageBuildCount)');

    return Scaffold(
      appBar: AppBar(title: const Text('Ch5 P2: Notification バブルアップ')),
      body: WidgetBox(
        kind: WidgetKind.stateful,
        name: 'Ch5P2NotificationBubblePage',
        role: 'ページ本体。onNotification で setState する',
        badges: ['notificationCount: $notificationCount'],
        buildCount: pageBuildCount,
        child: _VisualNotificationListener(
          onNotification: (notification) {
            debugPrint('[NOTIFICATION] received: ${notification.message}');
            setState(() => notificationCount += 1);  // ← ここでrebuild起点
            return true;
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              _DispatchWidget(),
              _IndependentWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

// NotificationListener の可視化ラッパー
class _VisualNotificationListenerState
    extends State<_VisualNotificationListener> {
  int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    buildCount += 1;
    return WidgetBox(
      kind: WidgetKind.listener,
      name: '_NotificationListener',
      role: 'バブルアップしてきた通知を捕捉する',
      badges: const ['onNotification'],
      buildCount: buildCount,
      child: NotificationListener<_DemoNotification>(
        onNotification: widget.onNotification,
        child: widget.child,
      ),
    );
  }
}

// dispatchする末端Widget
class _DispatchWidgetState extends State<_DispatchWidget> {
  int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    buildCount += 1;
    debugPrint('[BUILD] dispatch widget (#$buildCount)');

    return WidgetBox(
      kind: WidgetKind.stateful,
      name: '_DispatchWidget',
      role: 'dispatch する',
      badges: const ['dispatch: ✓'],
      buildCount: buildCount,
      child: FilledButton.tonal(
        onPressed: () {
          const _DemoNotification(message: 'leaf -> bubble').dispatch(context);
        },
        child: const Text('Notification.dispatch で親へ通知する'),
      ),
    );
  }
}

// 対照群：通知に関与しないWidget
class _IndependentWidgetState extends State<_IndependentWidget> {
  int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    buildCount += 1;
    debugPrint('[BUILD] independent widget (#$buildCount)');

    return WidgetBox(
      kind: WidgetKind.stateful,
      name: '_IndependentWidget',
      role: 'dispatch しない',
      badges: const ['dispatch: ✗'],
      buildCount: buildCount,
      child: const Text('それでもページ全体の rebuild に巻き込まれる'),
    );
  }
}

class _DemoNotification extends Notification {
  const _DemoNotification({required this.message});
  final String message;
}
```

**① 初期表示**

画面を開きます。ページ、leaf、independentがすべて初回buildされます。

```
[BUILD] Ch5 P2 page (#1)
[BUILD] dispatch widget (#1)
[BUILD] independent widget (#1)
```

この時点で起きていることは次のとおりです。

- 各Element：mount時に`attachNotificationTree`が呼ばれ、親の`_notificationTree`を引き継ぎます
- `_VisualNotificationListener`配下の`NotificationListener`：`_NotificationNode`を生成して連結リストの先頭に追加します
- 結果として、leaf と independent は同じ`_notificationTree`を保持し、その先頭ノードが`NotificationListener`を指しています
- ただし、基本と異なり「どのElementが将来rebuildされるか」という依存情報はどこにも持ちません

**② ボタン押下（Notification.dispatch）**

末端のボタンを押します。`_DemoNotification`がdispatchされます。

```
[NOTIFICATION] received: leaf -> bubble
[BUILD] Ch5 P2 page (#2)
[BUILD] dispatch widget (#2)
[BUILD] independent widget (#2)
```

`[BUILD] dispatch widget`と`[BUILD] independent widget`の**両方**が`(#2)`にカウントアップします。ここが基本のログとの決定的な違いです。基本ではindependentは沈黙したままでしたが、派生ではdispatchに関与しないindependentも巻き込まれています。ここで起きている処理を順を追って見ます。

```mermaid
sequenceDiagram
    participant U as ユーザー
    participant LEAF as _DispatchWidget<br/>(Element)
    participant TREE as _notificationTree<br/>(連結リスト)
    participant NE as _NotificationElement
    participant PAGE as Ch5P2Page<br/>(StatefulElement)
    participant IND as _IndependentWidget

    U->>LEAF: ボタン押下
    LEAF->>LEAF: _DemoNotification.dispatch(context)
    LEAF->>TREE: context.dispatchNotification(notification)
    TREE->>NE: current.onNotification(notification)
    NE->>NE: notification is T → true<br/>[NOTIFICATION] received
    NE->>PAGE: setState(() => notificationCount += 1)
    Note over TREE,NE: return true → 伝播停止
    PAGE->>PAGE: rebuild<br/>[BUILD] Ch5 P2 page (#2)
    PAGE->>LEAF: 子として再構築<br/>[BUILD] dispatch widget (#2)
    PAGE->>IND: 子として再構築<br/>[BUILD] independent widget (#2)
    Note over LEAF,IND: 依存登録の有無に関係なく<br/>配下が一括で巻き込まれる
```

ステップごとに整理すると：

1. **[ユーザー操作]**：ボタン押下で`_DemoNotification.dispatch(context)`が呼ばれます
2. **[内部処理]**：`context.dispatchNotification`が leaf の Element が保持する`_notificationTree`を起点にチェーンを走査します
3. **[ログ出力] `[NOTIFICATION] received: leaf -> bubble`**：`_NotificationElement`で型一致を確認し、コールバックを実行します
4. **[コールバック内]**：`setState(() => notificationCount += 1)`で`Ch5P2Page`がdirtyになります
5. **[ログ出力] `[BUILD] Ch5 P2 page (#2)`**：通常のrebuildパス（Ch4）が起動します
6. **[ログ出力] `[BUILD] dispatch widget (#2)`**：親rebuildに巻き込まれます
7. **[ログ出力] `[BUILD] independent widget (#2)`**：依存関係に関わらず、親rebuildに巻き込まれます

**通知経路とrebuild経路は別物**

ここで重要な区別があります。`dispatch`→`_notificationTree`チェーンの走査→Listenerで捕捉までは「通知経路」で、Notificationそれ自体は何もrebuildを起こしません。rebuildが始まるのは、捕捉側が`onNotification`内で`setState`を呼んでから先です。つまり次の2経路は完全に分離しています。

```
通知経路（Notification側）:
  dispatch → _notificationTree → onNotification

rebuild経路（Ch4の通常setState）:
  setState → markNeedsBuild → 次フレームで親build → 配下を全部rebuild
```

**確認できたこと**

Notification経路にはInheritedWidgetでいう`_dependents`のような選択的な索引が存在しません。捕捉後の`setState`は通常のrebuildパスをそのまま起動するため、捕捉側Element以下のWidgetは依存の有無に関係なく全て巻き込まれます。

independentが`[BUILD]`を出したのは、**Notificationに反応したからではなく**、親の`setState`によって通常のrebuild経路に乗っただけです。ログ上は`[NOTIFICATION] received`と`[BUILD] independent widget`が連続して見えますが、両者の因果関係は「Notification → independent」ではなく「Notification → setState → 親rebuild → 配下全部」という二段構えになっています。**Notification自体には範囲を絞る仕組みがないので、rebuildの広さは捕捉側がどのElementで`setState`を呼ぶかだけで決まります。**

### この検証からわかること

基本と派生を合わせて確認できたのは、「ツリーをまたいだ通信」と一口に言っても、rebuildの範囲を決める仕組みは両者で全く異なるということです。

- InheritedWidgetは`_dependents`という独自の索引を持つので、`of()`を呼んだElementにだけrebuildを届けられます
- Notificationは登録機構を持たないので、rebuild範囲は捕捉側の`setState`が張る通常の経路そのものになります

どちらが優れているかという話ではなく、依存登録の有無が挙動の違いを生んでいます。`of()`を呼ぶたびに依存が登録されるという非対称な構造が、InheritedWidgetだけに「選択的rebuild」を可能にしています。

---

## 検証結果まとめ

| シナリオ | 確認できたこと |
| --- | --- |
| 基本: dependOnを呼んだ子だけrebuildされる | of()を呼んだElementだけが_dependentsに登録される。updateShouldNotifyがtrueを返しても、未登録のElementには通知が届かずrebuildされない |
| 派生: Notificationには登録機構がない | Notification自体はrebuildを起こさない。捕捉側のonNotification内でsetStateを呼んだ瞬間に通常のrebuildパスが起動し、捕捉側Element以下が依存の有無に関係なく全て巻き込まれる |

---

## 実装時に気をつけること

- InheritedWidgetの`_dependents`による選択的rebuildは、`of()`を呼んだ時点でしか登録されません。`build()`内で条件分岐して`of()`を呼ばなかったフレームがあると、そのElementは依存を失った状態になります。次のbuildで再度`of()`を通らない限り、更新通知は届きません。条件付きで依存を扱いたい場合でも、`of()`は無条件に呼ぶのが安全です。
- Notificationはrebuild範囲を絞る仕組みを持たないため、`onNotification`で`setState`を呼ぶとListener以下すべてがrebuild対象になります。細かい範囲だけを更新したいなら、Notificationで親に伝えた後、親側でInheritedWidgetや状態管理パッケージ経由で配信する二段構えが必要になります。
- `updateShouldNotify`は差分判定のためだけに呼ばれる関数であり、副作用を持たせる場所ではありません。ここで外部の状態を変更したりログ以上の処理を書いたりすると、フレームワークの内部タイミングに依存した壊れやすいコードになります。新旧の値を比較して`bool`を返すだけに留めるのが安全です。
