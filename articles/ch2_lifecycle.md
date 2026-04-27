# Ch2: Stateのライフサイクル管理

## 章の中心的な問い

**StateはいつElementに生成され、いつ破棄されるのか？**

---

## 基本：ツリーから外れるとStateは破棄される

Ch1では「Elementは位置と親で管理される」ことを確認した。ここではその先、「Elementがツリーから外れたとき、Stateに何が起きるか」を確認する。

### P1: if で消す（dispose）

**① 初期表示**

画面を開く。StateTracker('IF-CHILD')が表示される。

```
initState: IF-CHILD  state=437281950
build: IF-CHILD  state=437281950  depth=6  widgetType=StateTracker  element=StatefulElement
```

Elementがツリーにマウントされ、Stateが生成された（initState）。ここがStateの誕生地点。

**② 「子を消す（if=false）」ボタン押下**

ボタンを押す。StateTracker('IF-CHILD')が画面から消える。

```
deactivate: IF-CHILD  state=437281950
dispose: IF-CHILD  state=437281950
```

deactivateの直後にdisposeが呼ばれた。Elementがツリーから外れると、そのElementが管理していたStateも一緒に破棄される。

**③ 「子を戻す（if=true）」ボタン押下**

もう一度ボタンを押す。StateTracker('IF-CHILD')が再び表示される。

```
initState: IF-CHILD  state=812034567
build: IF-CHILD  state=812034567  depth=6  widgetType=StateTracker  element=StatefulElement
```

initStateが呼ばれている。state idが437281950から812034567に変わった。同じWidget記述（`const StateTracker('IF-CHILD')`）でも、一度disposeされたStateは復元されない。Elementもろとも新しく作り直される。

| 操作 | state id | ライフサイクルイベント |
| --- | --- | --- |
| ①初期表示 | 437281950 | initState → build |
| ②if=false | 437281950 | deactivate → dispose |
| ③if=true | 812034567（新規） | initState → build |

**分かること：** Stateの生死はElementが決める。Elementがツリーにマウントされるとき createState → initState でStateが生まれ、ツリーから外れるとき deactivate → dispose でStateが死ぬ。ifで消して戻しても、以前のStateは復元されない。

---

### 基本の解釈

P1が示しているのは単純だが重要な事実。Stateは自分の生死を自分で決められない。Elementがツリーにいる限りStateは生き続け、Elementがツリーから外れればStateも一緒に消える。Stateのライフサイクルの全権限はElementにある。

---

## 派生：Navigatorのpopでツリーごと破棄される

基本で「1つのElementとStateの生死」を確認した。では、画面遷移でRoute配下のツリー全体が外れたとき、そこに含まれる全てのStateはどうなるか。

### P2: Navigator push/pop

**① push（次画面へ遷移）**

「Navigator.push（次画面へ）」ボタンを押す。SecondRoutePageが表示される。

```
SecondRoute: initState
SecondRoute: build
initState: SECOND-ROUTE-CHILD  state=295841073
build: SECOND-ROUTE-CHILD  state=295841073  depth=9  widgetType=StateTracker  element=StatefulElement
```

SecondRoutePageの State と、その子の StateTracker('SECOND-ROUTE-CHILD') の State が生成された。ここで重要なのは、前画面（push元）のWidgetにdisposeが出ていないこと。push元のRouteはNavigatorのスタックに残っているため、Elementツリーはそのまま維持されている。

**② pop（前画面へ戻る）**

「Navigator.pop（戻る）」ボタンを押す。SecondRoutePageが閉じ、前画面に戻る。

```
deactivate: SECOND-ROUTE-CHILD  state=295841073
SecondRoute: dispose
dispose: SECOND-ROUTE-CHILD  state=295841073
```

SecondRoutePageのStateとStateTracker('SECOND-ROUTE-CHILD')のState、両方にdisposeが呼ばれた。popによってRoute配下のElementツリーがまるごと破棄され、そこに含まれる全てのStateが連鎖的にdisposeされている。

| 操作 | SecondRoutePageのState | StateTracker('SECOND-ROUTE-CHILD') |
| --- | --- | --- |
| ①push | initState | initState（state=295841073） |
| ②pop | dispose | deactivate → dispose（state=295841073） |

**③ 再度push**

もう一度pushすると、全て新しいstate idで initState が出る。popで破棄されたStateは復元されない。

```
SecondRoute: initState
SecondRoute: build
initState: SECOND-ROUTE-CHILD  state=641927385
build: SECOND-ROUTE-CHILD  state=641927385  depth=9  widgetType=StateTracker  element=StatefulElement
```

state idが295841073から641927385に変わっている。P1と同じ原則が、Route配下のツリー全体に適用されている。

**分かること：** Navigatorのpopは特別なことをしているわけではない。Route配下のElementツリーをまるごとツリーから外す、というだけ。ツリーから外れたElementのStateが破棄されるのはP1と同じ原則。違いはスケールだけで、1つのStateに起きることがツリー全体の全Stateに起きる。

---

### 派生の解釈

P2が示しているのは、P1の原則がツリーのスケールに関係なく適用されるということ。Navigatorのpopは「Route配下のElementツリーをまるごとツリーから切り離す」操作であり、切り離された全てのElementがそれぞれのStateをdisposeする。pushで前画面が残るのも同じ原則の裏返しで、Elementがツリーにいる限りStateは生き続ける。

---

## 補足：GlobalKeyがあるとdisposeされない（→ Ch4）

P1・P2では「ツリーから外れたらStateは破棄される」と確認した。ではこのルールに例外はあるのか。

### P3: GlobalKey で移動

**① 初期表示**

画面を開く。GlobalKey付きStateTracker('GLOBAL-KEYED')がTop Slotに表示される。

```
initState: GLOBAL-KEYED  state=573819240
build: GLOBAL-KEYED  state=573819240  depth=8  widgetType=StateTracker  element=StatefulElement
```

**② 「上下スロットを切り替える」ボタン押下**

ボタンを押す。StateTracker('GLOBAL-KEYED')がTop SlotからBottom Slotに移動する。

```
deactivate: GLOBAL-KEYED  state=573819240
activate: GLOBAL-KEYED  state=573819240
build: GLOBAL-KEYED  state=573819240  depth=8  widgetType=StateTracker  element=StatefulElement
```

P1・P2との決定的な違いがここにある。deactivateは出たが、disposeが出ていない。代わりにactivateが出ている。そしてstate idが573819240のまま変わっていない。

P1（if除去）と比較する。

|  | P1: if で消す | P3: GlobalKey移動 |
| --- | --- | --- |
| ツリーから外れたとき | deactivate → dispose | deactivate → activate |
| state id | 変わる（新規生成） | 変わらない（同一State） |
| Stateの状態 | 破棄・再生成 | 維持 |

**③ 再度「上下スロットを切り替える」ボタン押下**

もう一度ボタンを押す。Bottom SlotからTop Slotに戻る。

```
deactivate: GLOBAL-KEYED  state=573819240
activate: GLOBAL-KEYED  state=573819240
build: GLOBAL-KEYED  state=573819240  depth=8  widgetType=StateTracker  element=StatefulElement
```

何度切り替えても、state idは573819240のまま。disposeは一度も出ない。

| 操作 | state id | ライフサイクルイベント |
| --- | --- | --- |
| ①初期表示 | 573819240 | initState → build |
| ②Bottom移動 | 573819240（同じ） | deactivate → activate → build |
| ③Top移動 | 573819240（同じ） | deactivate → activate → build |

**分かること：** GlobalKeyを持つElementは、ツリーから一時的に切り離されても即座にdisposeされない。deactivateで「仮の離脱」状態になり、同じフレーム内で新しい位置に再接続されるとactivateで復帰する。Stateはその間ずっと生きている。これは「ツリーから外れたらStateは破棄される」という基本ルールの唯一の例外であり、GlobalKeyの同一性管理メカニズムの詳細はCh4で扱う。

---

## 設計上の注意点

- 条件分岐や画面遷移でWidgetをツリーから外すと、そのStateは破棄される。表示を戻しても以前のStateは復元されない。StreamのSubscription、AnimationController、TextEditingControllerなど、Stateが保持するリソースはdisposeで確実に解放する必要がある。
- Navigatorのpopは、Route配下の全Stateを連鎖的にdisposeする。push元の画面は残るが、pop先の画面は完全に破棄される。画面をまたいでStateを保持したい場合は、State以外の場所（Provider / Riverpod / グローバルな状態管理）に置く設計が必要になる。
- GlobalKeyを使うとStateをdispose無しに移動できるが、これは例外的な手段。意図せずStateが生き残る事故の原因にもなる。