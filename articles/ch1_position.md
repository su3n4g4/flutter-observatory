# Ch1: Elementツリーの位置管理

## 章の中心的な問い

**Elementは位置と親をどう使ってWidgetを管理しているのか？**

---

## 基本：同じ親の中で位置が変わるとき

まず「同じ親のColumn内で子の並びや数が変わったとき、Elementはどう反応するか」を確認する。

### P1: Reorder（Keyなし）

**① 初期表示**

画面を開く。StateTracker が A・B・C の順に表示される。

```
initState: A  state=899543330
initState: B  state=692949910
initState: C  state=255414316
```

3つのElementがツリーにマウントされ、それぞれStateが生成された（initState）。

**② Reverseボタン押下**

「Reverse」ボタンを押す。表示がC・B・Aに入れ替わる。

```
didUpdateWidget: A -> C  state=899543330
didUpdateWidget: B -> B  state=692949910
didUpdateWidget: C -> A  state=255414316
```

各位置のElementに何が起きたかを整理するとこうなる。

|  | ①初期表示 | ②Reverse後 | State |
| --- | --- | --- | --- |
| 位置0 | Widget("A") | Widget("C") | 899543330（同じ） |
| 位置1 | Widget("B") | Widget("B") | 692949910（同じ） |
| 位置2 | Widget("C") | Widget("A") | 255414316（同じ） |

Widgetの行は変わるが、Stateの行は変わらない。didUpdateWidgetが出るのは、既存のElementが新しいWidgetを受け取り中身を差し替えたということ。Elementは位置に留まったまま、渡されるWidgetのlabelだけが入れ替わっている。disposeは出ない。Elementは破棄されていない。

**③ 再度Reverseボタン押下**

もう一度「Reverse」ボタンを押す。表示がA・B・Cに戻る。

```
didUpdateWidget: C -> A  state=899543330
didUpdateWidget: B -> B  state=692949910
didUpdateWidget: A -> C  state=255414316
```

②と同じく、Elementは位置に留まったままWidgetが差し替わる。state idは①から一度も変わっていない。

**分かること：** Elementは位置に留まり続け、Widgetの中身だけが入れ替わる。runtimeTypeが同じであれば、Elementは破棄されず再利用される。

---

### P2: Conditional Insert/Remove

**① 初期表示**

画面を開く。StateTracker が A・B・C の順に表示される。

```
initState: A  state=340185217
initState: B  state=578920143
initState: C  state=712034568
```

3つのElementがそれぞれの位置にマウントされた。

**② 「Insert X」ボタン押下**

「Insert X」ボタンを押す。AとBの間にStateTracker('X')が挿入され、A・X・B・Cの順になる。

```
didUpdateWidget: B -> X  state=578920143
didUpdateWidget: C -> B  state=712034568
initState: C  state=163847295
```

各位置に何が起きたかを整理する。

|  | ①初期表示 | ②挿入後 | State |
| --- | --- | --- | --- |
| 位置0 | Widget("A") | Widget("A") | 340185217（同じ） |
| 位置1 | Widget("B") | Widget("X") | 578920143（同じ） |
| 位置2 | Widget("C") | Widget("B") | 712034568（同じ） |
| 位置3 | — | Widget("C") | 163847295（新規） |

位置0のAは変化なし。位置1以降はWidgetがひとつずつ後ろにずれ、既存のElementがdidUpdateWidgetで中身を差し替えている。位置3は新たにElementが生成された（initState）。

**③ 「Remove X」ボタン押下**

もう一度ボタンを押す。Xが消え、A・B・Cの順に戻る。

```
didUpdateWidget: X -> B  state=578920143
didUpdateWidget: B -> C  state=712034568
deactivate: C  state=163847295
dispose: C  state=163847295
```

|  | ②挿入後 | ③除去後 | State |
| --- | --- | --- | --- |
| 位置0 | Widget("A") | Widget("A") | 340185217（同じ） |
| 位置1 | Widget("X") | Widget("B") | 578920143（同じ） |
| 位置2 | Widget("B") | Widget("C") | 712034568（同じ） |
| 位置3 | Widget("C") | — | 163847295（破棄） |

位置1・2はdidUpdateWidgetでWidgetが差し替わった。位置3のElementはツリーから除去され、disposeが呼ばれた。Elementがツリーから完全に外れるとStateが破棄される、ということ。

**分かること：** 子リストの長さが変わっても、先頭から位置ベースで順にupdateが走る原則は同じ。余りが出た末尾でだけ生成（initState）や破棄（dispose）が起きる。

---

### 基本の解釈

P1とP2に共通しているのは、「同じ親の中で、同じ位置に同じruntimeTypeのWidgetが来れば、Elementは再利用される」というルールです。Elementは位置に紐づいていて、Widgetの中身が変わっても位置が同じなら生き残る。

---

## 派生：親そのものが変わるとき

基本ルールが「同じ親の中での再利用」だと分かったところで、自然に湧く疑問がある。「では親が変わったらどうなるのか？」

### P3: Move Between Parents

**① 初期表示**

画面を開く。StateTracker('P')がLeftボックスに表示される。

```
initState: P  state=482917305
```

LeftボックスにElementがマウントされ、Stateが生成された。

**② 「StateTrackerをRightへ移動」ボタン押下**

ボタンを押す。StateTracker('P')がLeftボックスから消え、Rightボックスに表示される。

```
dispose: P  state=482917305
initState: P  state=739201486
```

disposeが出た後にinitStateが出ている。Left側のElementが破棄され、Right側で新しいElementとStateが生成された。state idが482917305から739201486に変わっているのがその証拠。

**③ 「StateTrackerをLeftへ移動」ボタン押下**

もう一度ボタンを押す。StateTracker('P')がRightボックスから消え、Leftボックスに戻る。

```
dispose: P  state=739201486
initState: P  state=915438672
```

再びdisposeの後にinitState。state idが毎回変わる。同じWidget記述（`const StateTracker('P')`）であっても、親が変わるたびにElementは破棄・再生成される。

|  | ①初期表示 | ②Right移動 | ③Left移動 |
| --- | --- | --- | --- |
| Left | State 482917305 | — | State 915438672（新規） |
| Right | — | State 739201486（新規） | — |

毎回state idが変わる。Elementが再利用されていない。

**分かること：** 親が変わると、Elementは再利用されず破棄・再生成される。P1・P2で見た位置ベースの再利用は「同じ親の配下」というスコープに閉じている。これがCh1の確定事実「親が変わればElementは破棄される」の根拠。

---

### 派生の解釈

基本で見た「位置が同じなら再利用される」には前提条件がある。それは親が同じであること。親が変わった時点で、旧ElementのStateはdisposeで破棄され、新しいElementがinitStateから始まる。これがCh1の確定事実「親が変わればElementは破棄される」の根拠です。

---

## 補足：Keyがあると位置ルールはどう変わるか（→ Ch4）

### P1-b: Reorder（Keyあり）

**① 初期表示**

画面を開く。ValueKey付きStateTrackerがA・B・Cの順に表示される。

```
initState: A  state=521748903
initState: B  state=384619275
initState: C  state=647382019
```

**② Reverseボタン押下**

「Reverse」ボタンを押す。表示がC・B・Aに入れ替わる。

```
build: C  state=647382019
build: B  state=384619275
build: A  state=521748903
```

P1（Keyなし）と比較する。

|  | P1（Keyなし） | P1-b（Keyあり） |
| --- | --- | --- |
| 位置0のState | 899543330のまま（Aの位置に留まる） | 647382019に変わる（Cと一緒に移動） |
| ログ | didUpdateWidget: A -> C | didUpdateWidgetは出ない |
| Stateの追従先 | 位置 | label（Key） |

didUpdateWidgetが出ないのは、Widgetの差し替えが起きていないということ。ValueKeyがあると、Elementは位置ではなくKeyの一致で再利用相手を探す。state idがlabelと一緒に移動しているのがその証拠。

**分かること：** Keyがあると、位置ベースの再利用ルールが変わる。Elementはlabel（Key）に紐づいて移動する。この判定メカニズムの詳細はCh4で扱う。

---

## 設計上の注意点

- 条件分岐でWidgetを出し入れすると、除去されたElementのStateは破棄される。表示を戻しても以前のStateは復元されない。
- Widgetの親を動的に変える構成は、意図しないState破棄を招く。同じWidget記述でも親が異なればElementは再生成される。