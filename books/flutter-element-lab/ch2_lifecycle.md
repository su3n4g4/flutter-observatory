---
title: "Chapter 2: Stateのライフサイクル管理"
---

▶ [検証コード（GitHub）](https://github.com/su3n4g4/flutter-element-lab/tree/main/flutter_element_lab/lib/chapters/ch2)　▶ [検証画面](https://su3n4g4.github.io/flutter-element-lab/)

## この章で確かめること

**StateはいつElementから生成され、いつ破棄されるのか？**

---

## ツリーから外れるとStateは破棄される

### Part 1: if で消す（dispose）

Chapter 1 Part 2では、条件分岐で親が変わったElementが破棄されるときにdisposeが出ることを位置管理の文脈で確認しました。ここでは同じ現象をStateのライフサイクルの観点からElementがツリーから外れたときに何が起きているのかを確認していきます。

**① 初期表示**

画面を開きます。StateTracker('IF-CHILD')が表示されます。

```
initState: IF-CHILD  state=437281950
build: IF-CHILD  state=437281950  depth=6  widgetType=StateTracker  element=StatefulElement
```

Elementがツリーにマウントされ、Stateが生成されました（initState）。ここがStateの誕生地点です。

**② 「StateTrackerを消す（if=false）」ボタン押下**

ボタンを押します。StateTracker('IF-CHILD')が画面から消えます。

```
deactivate: IF-CHILD  state=437281950
dispose: IF-CHILD  state=437281950
```

deactivateの直後にdisposeが呼ばれました。Elementがツリーから外れると、そのElementが管理していたStateも一緒に破棄されます。

**③ 「StateTrackerを戻す（if=true）」ボタン押下**

もう一度ボタンを押します。StateTracker('IF-CHILD')が再び表示されます。

```
initState: IF-CHILD  state=812034567
build: IF-CHILD  state=812034567  depth=6  widgetType=StateTracker  element=StatefulElement
```

initStateが呼ばれています。state idが437281950から812034567に変わりました。同じWidget記述（`const StateTracker('IF-CHILD')`）でも、一度disposeされたStateは復元されません。Elementもろとも新しく作り直されます。

| 操作 | state id | ライフサイクルイベント |
| --- | --- | --- |
| ①初期表示 | 437281950 | initState → build |
| ②if=false | 437281950 | deactivate → dispose |
| ③if=true | 812034567（新規） | initState → build |

**確認できたこと：** Stateの生死はElementが決めます。Elementがツリーにマウントされるとき createState → initState でStateが生まれ、ツリーから外れるとき deactivate → dispose でStateが死にます。ifで消して戻しても、以前のStateは復元されません。

---

### この検証からわかること

Part 1が示しているのは単純ですが重要な事実です。Stateは自分の生死を自分で決められません。Elementがツリーにいる限りStateは生き続け、Elementがツリーから外れればStateも一緒に消えます。Stateのライフサイクルの全権限はElementにあります。

---

## Navigatorのpopでツリーごと破棄される

前の検証で「1つのElementとStateの生死」を確認しました。では、画面遷移でRoute配下のツリー全体が外れたとき、そこに含まれる全てのStateはどうなるでしょうか。

### Part 2: Navigator push/pop

**① push（次画面へ遷移）**

「Navigator.push（次画面へ）」ボタンを押します。PushedPageが表示されます。

```
PushedPage: initState
PushedPage: build
initState: PUSHED-PAGE-CHILD  state=295841073
build: PUSHED-PAGE-CHILD  state=295841073  depth=9  widgetType=StateTracker  element=StatefulElement
```

PushedPageの State と、その子の StateTracker('PUSHED-PAGE-CHILD') の State が生成されました。ここで重要なのは、前画面（push元）のWidgetにdisposeが出ていないことです。push元のRouteはNavigatorのスタックに残っているため、Elementツリーはそのまま維持されています。

**② pop（前画面へ戻る）**

「Navigator.pop（戻る）」ボタンを押します。PushedPageが閉じ、前画面に戻ります。

```
PushedPage: deactivate
deactivate: PUSHED-PAGE-CHILD  state=295841073
dispose: PUSHED-PAGE-CHILD  state=295841073
PushedPage: dispose
```

PushedPageのStateとStateTracker('PUSHED-PAGE-CHILD')のState、両方にdisposeが呼ばれました。popによってRoute配下のElementツリーがまるごと破棄され、そこに含まれる全てのStateが連鎖的にdisposeされています。

deactivateの順序に注目してください。親（PushedPage）のdeactivateが先に呼ばれ、その後に子（PUSHED-PAGE-CHILD）のdeactivateが呼ばれています。これはFlutterが親から子へ再帰的にdeactivateを伝播させるためです。一方disposeは逆で、子（PUSHED-PAGE-CHILD）が先にdisposeされ、その後に親（PushedPage）がdisposeされます。`_InactiveElements._unmount`が「子を全てunmountしてから自身をunmount」する深さ優先の末端から先という処理をするためです。

| 操作 | PushedPageのState | StateTracker('PUSHED-PAGE-CHILD') |
| --- | --- | --- |
| ①push | initState | initState（state=295841073） |
| ②pop | deactivate → dispose | deactivate → dispose（state=295841073） |

**③ 再度push**

もう一度pushすると、全て新しいstate idで initState が出ます。popで破棄されたStateは復元されません。

```
PushedPage: initState
PushedPage: build
initState: PUSHED-PAGE-CHILD  state=641927385
build: PUSHED-PAGE-CHILD  state=641927385  depth=9  widgetType=StateTracker  element=StatefulElement
```

state idが295841073から641927385に変わっています。Part 1と同じ原則が、Route配下のツリー全体に適用されています。

**確認できたこと：** Navigatorのpopは特別なことをしているわけではありません。Route配下のElementツリーをまるごとツリーから外す、というだけです。ツリーから外れたElementのStateが破棄されるのはPart 1と同じ原則です。違いはスコープだけで、1つのStateに起きることがツリー全体の全Stateに起きます。

---

### この検証からわかること

Part 2が示しているのは、Part 1の原則がツリーのスケールに関係なく適用されるということです。Navigatorのpopは「Route配下のElementツリーをまるごとツリーから切り離す」操作であり、切り離された全てのElementがそれぞれのStateをdisposeします。pushで前画面が残るのも同じ原則の裏返しで、Elementがツリーにいる限りStateは生き続けます。

---

## GlobalKeyがあるとdisposeされない（→ Chapter 3）

Part 1・Part 2では「ツリーから外れたらStateは破棄される」と確認しました。ではこのルールに例外はあるのでしょうか。

### Part 3: GlobalKey で移動

**① 初期表示**

画面を開きます。GlobalKey付きStateTracker('GLOBAL-KEYED')がTop Slotに表示されます。

```
initState: GLOBAL-KEYED  state=573819240
build: GLOBAL-KEYED  state=573819240  depth=8  widgetType=StateTracker  element=StatefulElement
```

**② 「上下スロットを切り替える」ボタン押下**

ボタンを押します。StateTracker('GLOBAL-KEYED')がTop SlotからBottom Slotに移動します。

```
deactivate: GLOBAL-KEYED  state=573819240
activate: GLOBAL-KEYED  state=573819240
build: GLOBAL-KEYED  state=573819240  depth=8  widgetType=StateTracker  element=StatefulElement
```

P1・P2との決定的な違いがここにあります。deactivateは出ましたが、disposeが出ていません。代わりにactivateが出ています。そしてstate idが573819240のまま変わっていません。

P1（if除去）と比較します。

|  | Part 1: if で消す | Part 3: GlobalKey移動 |
| --- | --- | --- |
| ツリーから外れたとき | deactivate → dispose | deactivate → activate |
| state id | 変わる（新規生成） | 変わらない（同一State） |
| Stateの状態 | 破棄・再生成 | 維持 |

**③ 再度「上下スロットを切り替える」ボタン押下**

もう一度ボタンを押します。Bottom SlotからTop Slotに戻ります。

```
deactivate: GLOBAL-KEYED  state=573819240
activate: GLOBAL-KEYED  state=573819240
build: GLOBAL-KEYED  state=573819240  depth=8  widgetType=StateTracker  element=StatefulElement
```

何度切り替えても、state idは573819240のままです。disposeは一度も出ません。

| 操作 | state id | ライフサイクルイベント |
| --- | --- | --- |
| ①初期表示 | 573819240 | initState → build |
| ②Bottom移動 | 573819240（同じ） | deactivate → activate → build |
| ③Top移動 | 573819240（同じ） | deactivate → activate → build |

**確認できたこと：** GlobalKeyを持つElementは、ツリーから一時的に切り離されても即座にdisposeされません。deactivateで「仮の離脱」状態になり、同じフレーム内で新しい位置に再接続されるとactivateで復帰します。Stateはその間ずっと生きています。これは「ツリーから外れたらStateは破棄される」という基本ルールの唯一の例外であり、GlobalKeyの同一性管理メカニズムの詳細はChapter 3で扱います。

---

## 検証結果まとめ

| シナリオ | 確認できたこと |
| --- | --- |
| Part 1: if で消す（dispose） | Elementがツリーから外れるとStateはdeactivate → disposeで破棄される。同じWidget記述で表示を戻しても、以前のStateは復元されずinitStateから再開される |
| Part 2: Navigator push/pop | popはRoute配下のElementツリーをまるごと切り離す操作であり、含まれる全StateがdisposeされるPart 1の原則がツリー全体に適用されたもの |
| Part 3: GlobalKey で移動 | GlobalKeyを持つElementはツリーから外れてもdisposeされない。deactivate → activateのサイクルでStateを維持したまま新しい位置に再接続される |

---

## 実装時に気をつけること

- 条件分岐や画面遷移でWidgetをツリーから外すと、そのStateは破棄されます。表示を戻しても以前のStateは復元されません。StreamのSubscription、AnimationController、TextEditingControllerなど、Stateが保持するリソースはdisposeで確実に解放する必要があります。
- Navigatorのpopは、Route配下の全Stateを連鎖的にdisposeします。push元の画面は残りますが、pop先の画面は完全に破棄されます。画面をまたいでStateを保持したい場合は、State以外の場所（Provider / Riverpod / グローバルな状態管理）に置く設計が必要になります。
- 非同期処理のコールバック内では、awaitの後にStateがすでにdisposeされている可能性があります。`if (!mounted) return;` でチェックしてからsetStateを呼ぶことで、破棄済みのStateへのアクセスを防げます。このガードがなぜ必要かの仕組み（`markNeedsBuild`のライフサイクルチェック）はChapter 4で扱います。
- GlobalKeyを使うとStateをdispose無しに移動できますが、これは例外的な手段です。意図せずStateが生き残る事故の原因にもなります。
