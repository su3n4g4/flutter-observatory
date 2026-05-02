# Ch3: 同一性管理（Key）

▶ [検証コード（GitHub）](https://github.com/su3n4g4/flutter-observatory/tree/main/flutter_observatory/lib/chapters/ch3)　▶ [検証画面](https://su3n4g4.github.io/flutter-observatory/)

## 章の中心的な問い

Widgetが並び替えられたり、ツリーの別の場所に移動したりするとき、FlutterはどうやってElementの「同一性」を判断するのか？

## 前提知識

### canUpdate の判定ロジック

リビルド時、FlutterはElementを再利用できるかどうかを `Widget.canUpdate` で判定します。

判定基準は `runtimeType（ウィジェットのクラス）` と `key` の2つで、両方が一致する場合のみ既存のElementが再利用されます。一致しない場合は古いElementを破棄し、新しいElementを生成します。

```dart
// packages/flutter/lib/src/widgets/framework.dart
static bool canUpdate(Widget oldWidget, Widget newWidget) {
  return oldWidget.runtimeType == newWidget.runtimeType
      && oldWidget.key == newWidget.key;
}
```

:::message
Key照合が有効な範囲はKeyの種類によって異なり、その差が同一性判断の有効範囲を決めます
:::

### Keyの種類と同一性の有効範囲

|  | Keyなし | LocalKey（ValueKeyなど） | GlobalKey |
| --- | --- | --- | --- |
| canUpdateの式 | null == null → true（型一致のみ） | runtimeType一致 && Key一致 | runtimeType一致 && Key一致 |
| Key比較の解決スコープ | なし | 親Elementのchildren内 | BuildOwner._globalKeyRegistry（アプリ全体） |
| 同一性の有効範囲 | 同じ位置 | 同じ親の兄弟間 | アプリ全体 |
| 登録場所 | なし | 親Elementのchildren内 | BuildOwner._globalKeyRegistry |
| 親をまたいだ移動 | 不可（破棄＆再生成） | 不可（破棄＆再生成） | 可（deactivate→activate） |
| dispose発生 | 位置がずれると発生 | 親が変わると発生 | 発生しない（移動時） |
| 同時に2箇所に配置 | 可 | 可 | 不可（エラー） |
| 典型的な用途 | 静的・順不同なリスト | 並び替えあるリスト | フォーム参照・ツリー間移動 |

---

## P1｜Keyなしでリストをreverse

**検証内容：** Keyがないとき、`canUpdate` はruntimeTypeのみで判定し、位置ベースでElementを再利用する

**操作：** Reverse ボタンを押す

**ログ：**

```
# 初期表示
initState: A  state=997303568
build: A  state=997303568  depth=153  widgetType=StateTracker  element=StatefulElement
initState: B  state=545823583
build: B  state=545823583  depth=153  widgetType=StateTracker  element=StatefulElement
initState: C  state=1040413516
build: C  state=1040413516  depth=153  widgetType=StateTracker  element=StatefulElement

# Reverse ボタン押下後
didUpdateWidget: A -> C  state=997303568
build: C  state=997303568  depth=153  widgetType=StateTracker  element=StatefulElement
didUpdateWidget: B -> B  state=545823583
build: B  state=545823583  depth=153  widgetType=StateTracker  element=StatefulElement
didUpdateWidget: C -> A  state=1040413516
build: A  state=1040413516  depth=153  widgetType=StateTracker  element=StatefulElement
# state hashCodeは変化なし（Elementが位置で再利用された）
```

**観察まとめ：**

| 操作後の表示位置 | label | count（State） | state hashCode |
| --- | --- | --- | --- |
| 1行目 | C（移動） | 1（元の位置のまま） | 997303568（変化なし） |
| 2行目 | B（不変） | 1 | 545823583 |
| 3行目 | A（移動） | 1（元の位置のまま） | 1040413516（変化なし） |

**確認できたこと：** Keyがない場合、`canUpdate` はruntimeTypeのみで判定するため、
各位置のElementがそのまま再利用されます。
`didUpdateWidget` でlabelの変化は受け取りますが、Stateはlabelに追従せず位置に留まります。
countとlabelの対応が崩れた状態がそのまま表示されることが確認できます。

---

## P2｜ValueKeyありでリストをreverse

**検証内容：** ValueKeyがあるとき、`canUpdate` はKey一致で判定し、StateがlabelのKeyに紐づいて移動する

**操作：** Reverse ボタンを押す

**ログ：**

```
# 初期表示
initState: A  state=110179758
build: A  state=110179758  depth=153  widgetType=StateTracker  element=StatefulElement
initState: B  state=520698145
build: B  state=520698145  depth=153  widgetType=StateTracker  element=StatefulElement
initState: C  state=277223098
build: C  state=277223098  depth=153  widgetType=StateTracker  element=StatefulElement

# Reverse ボタン押下後
didUpdateWidget: C -> C  state=277223098
build: C  state=277223098  depth=153  widgetType=StateTracker  element=StatefulElement
didUpdateWidget: B -> B  state=520698145
build: B  state=520698145  depth=153  widgetType=StateTracker  element=StatefulElement
didUpdateWidget: A -> A  state=110179758
build: A  state=110179758  depth=153  widgetType=StateTracker  element=StatefulElement
# state hashCodeは変化なし（ElementがlabelのKeyに追従して移動した）
```

**観察まとめ：**

| 操作後の表示位置 | label | count（State） | state hashCode |
| --- | --- | --- | --- |
| 1行目 | C | 1（Cのまま） | 277223098（Cと一緒に移動） |
| 2行目 | B | 1 | 520698145 |
| 3行目 | A | 1（Aのまま） | 110179758（Aと一緒に移動） |

**確認できたこと：** ValueKeyがある場合、`canUpdate` は親のchildren内でKey一致するElementを探して再利用します。
StateはlabelのKeyに紐づいているため、表示位置が変わってもlabelとcountの対応が維持されます。
P1との対比でKeyの有無が何を変えるかが明確になります。

---

## P3の前提：GlobalKeyのレジストリと引き取り

GlobalKeyの `canUpdate` 自体はValueKeyと同じ式となります。
違うのはKeyの比較が行われるスコープで、ValueKeyが親Elementのchildren内で照合されるのに対し、
GlobalKeyは `BuildOwner` が保持するレジストリで照合されます。

```dart
// packages/flutter/lib/src/widgets/framework.dart
class BuildOwner {
  final Map<GlobalKey, Element> _globalKeyRegistry = <GlobalKey, Element>{};
}
```

このMapはGlobalKeyとElementを1対1で対応しています。
Elementがマウントされる際に自身をこのレジストリに登録し、unmount時に削除を行います。
「同じGlobalKeyを同時に2箇所に配置できない」という制約は、このデータ構造が1対1であることから来ています。

新しい位置にGlobalKey付きWidgetが現れたとき、
`inflateWidget` はレジストリを引き当て、既存Elementを引き取る分岐に入ります。

```dart
// packages/flutter/lib/src/widgets/framework.dart
// debug用のコードを削除したコード
Element inflateWidget(Widget newWidget, Object? newSlot) {
  final Key? key = newWidget.key;
  if (key is GlobalKey) {
    final Element? newChild = _retakeInactiveElement(key, newWidget);
    if (newChild != null) {
      newChild._activateWithParent(this, newSlot);
      return newChild;
    }
  }
  // 通常のcreateElement経路
  ...
}
```

引き取られたElementでは `deactivate → activate` のペアが発生し、
この経路に入る限りElementは `dispose` されません。
（引き取られずにフレーム末尾まで残ったElementがunmountされる仕組みはCh2で扱った通りです）

---

## P3｜GlobalKeyの参照保持と配置先切り替え

**検証内容：** GlobalKeyはアプリ全体のレジストリにElement参照を保持し、配置先の親が変わってもElementとStateの同一性を維持する

**操作：** GlobalKey付きStateTrackerをTop Slot → Bottom Slot → Top Slotと切り替える

:::message
GlobalKeyの本質は「どのスロット（位置）に置かれていても、同じElementを指し続ける」という参照保持にある。
位置が変わることを起こさないとその能力が検証できないため、スロット切り替えが最小操作となる。
:::

**ログ：**

```
# 初期表示
initState: GLOBAL-KEYED  state=31115166
build: GLOBAL-KEYED  state=31115166  depth=158  widgetType=StateTracker  element=StatefulElement

# 「配置先を切り替える」ボタン押下後
deactivate: GLOBAL-KEYED  state=31115166
activate: GLOBAL-KEYED  state=31115166
didUpdateWidget: GLOBAL-KEYED -> GLOBAL-KEYED  state=31115166
build: GLOBAL-KEYED  state=31115166  depth=158  widgetType=StateTracker  element=StatefulElement
# initState / dispose は発火しない
# state hashCodeは変化なし（同一Elementが再利用される）
```

**観察まとめ：**

| タイミング | state hashCode | last event | dispose |
| --- | --- | --- | --- |
| Top Slot配置中 | 31115166 | activate | なし |
| Bottom Slotへ切り替え | 31115166（不変） | activate | なし |
| Top Slotへ戻す | 31115166（不変） | activate | なし |

**確認できたこと：** GlobalKeyは `BuildOwner._globalKeyRegistry` にElement参照を保持するため、
配置先の親が変わってもElementは破棄されません。
`deactivate → activate` のサイクルのみが発生し、disposeは出ません。
`probeKey.currentContext` が常に同一Elementを指すことで、配置先に関わらずStateへのアクセスが保証されます。
P2のValueKeyが「同じ親の中でのKey照合」であるのに対し、
GlobalKeyは「アプリ全体のレジストリでのKey照合」という対比がここで完成します。

---

## 設計上の注意点

### Keyなし運用の許容範囲

Keyなしが問題になるのは「順序や数が動的に変わる」場合に限られます。
以下の条件がすべて満たせる場合、Keyなしで運用できます。

- リストの順序が変わらない
- 条件付き表示による挿入・削除が起きない（またはStatelessWidgetのみ）
- 各項目のStateが他の項目と混在しても支障がない

逆に言えば、StatefulWidgetを動的なリストに並べる時点でValueKeyは原則必要と考えたほうがよいでしょう。
Keyなしの不具合はログに出づらく、UIの見た目だけが静かに壊れます。

### ValueKeyの採用条件

ValueKeyに渡す値は項目を一意に識別できるものでなければなりません。
インデックス（`ValueKey(index)`）は並び替えに対して無意味なため、
IDや名前など項目固有の値を使います。

```dart
// NG：インデックスはKeyとして機能しない
ListView.builder(
  itemBuilder: (context, i) => ItemWidget(key: ValueKey(i), ...),
)

// OK：項目固有のIDを使う
ListView.builder(
  itemBuilder: (context, i) => ItemWidget(key: ValueKey(items[i].id), ...),
)
```

また、ValueKeyは同じ親の兄弟間でのみ有効です。
親をまたいだ同一性の維持が必要な場合はGlobalKeyを検討してください。

### GlobalKeyの採用条件と制約

GlobalKeyは強力ですが、採用前に以下を確認してください。

採用が正当化されるケース：

- ツリー間でElementを移動させる必要がある（ドラッグ＆ドロップなど）
- 別Widget階層からStateのメソッドやBuildContextを参照する必要がある

制約：

- 同じKeyを同時に2箇所に配置できない（_registryに1対1で登録されるため）
- `const`コンストラクタと併用できない
- rebuildのたびに生成してはいけない（フィールドで保持する）

```dart
// NG：buildメソッド内で生成するとframeごとに新しいKeyになる
Widget build(BuildContext context) {
  return StateTracker(key: GlobalKey(), ...); // 毎回別インスタンス
}

// OK：フィールドで保持する
class _MyWidgetState extends State<MyWidget> {
  final _key = GlobalKey();
  ...
}
```

### 設計の優先順位

Keyなし → ValueKey → GlobalKey

GlobalKeyは「最後の手段」として位置づけます。
多くの場合、GlobalKeyで解決しようとしている問題は、状態の持ち方やWidget構造の見直しで回避できます。
