# Ch1: Elementツリーの位置管理

▶ [検証コード（GitHub）](https://github.com/su3n4g4/flutter-element-lab/tree/main/flutter_element_lab/lib/chapters/ch1)　▶ [検証画面](https://su3n4g4.github.io/flutter-element-lab/)

## この章で確かめること

**Elementは位置と親をどう使ってWidgetを管理しているのか？**

---

## 同じ親の中で位置が変わるとき

まず「同じ親のColumn内で子の並びや数が変わったとき、Elementはどう反応するか」を確認します。

### P1: 並べ替え（Keyなし）

**① 初期表示**

画面を開きます。StateTracker が A・B・C の順に表示されます。

```
initState: A  state=615888068
build: A  state=615888068  depth=155  widgetType=StateTracker  element=StatefulElement
initState: B  state=957829703
build: B  state=957829703  depth=155  widgetType=StateTracker  element=StatefulElement
initState: C  state=478239687
build: C  state=478239687  depth=155  widgetType=StateTracker  element=StatefulElement
```

3つのElementがツリーにマウントされ、それぞれStateが生成されました（initState）。

**② Reverseボタン押下**

「Reverse」ボタンを押します。表示がC・B・Aに入れ替わります。

```
didUpdateWidget: A -> C  state=615888068
build: C  state=615888068  depth=155  widgetType=StateTracker  element=StatefulElement
didUpdateWidget: B -> B  state=957829703
build: B  state=957829703  depth=155  widgetType=StateTracker  element=StatefulElement
didUpdateWidget: C -> A  state=478239687
build: A  state=478239687  depth=155  widgetType=StateTracker  element=StatefulElement
```

各位置のElementに何が起きたかを整理するとこうなります。

|  | ①初期表示 | ②Reverse後 | State |
| --- | --- | --- | --- |
| 位置0 | Widget("A") | Widget("C") | 615888068（同じ） |
| 位置1 | Widget("B") | Widget("B") | 957829703（同じ） |
| 位置2 | Widget("C") | Widget("A") | 478239687（同じ） |

Widgetの行は変わりますが、Stateの行は変わりません。didUpdateWidgetが出るのは、既存のElementが新しいWidgetを受け取り中身を差し替えたということです。Elementは位置に留まったまま、渡されるWidgetのlabelだけが入れ替わっています。disposeは出ません。Elementは破棄されていません。

**③ 再度Reverseボタン押下**

もう一度「Reverse」ボタンを押します。表示がA・B・Cに戻ります。

```
didUpdateWidget: C -> A  state=615888068
build: A  state=615888068  depth=155  widgetType=StateTracker  element=StatefulElement
didUpdateWidget: B -> B  state=957829703
build: B  state=957829703  depth=155  widgetType=StateTracker  element=StatefulElement
didUpdateWidget: A -> C  state=478239687
build: C  state=478239687  depth=155  widgetType=StateTracker  element=StatefulElement
```

②と同じく、Elementは位置に留まったままWidgetが差し替わります。state idは①から一度も変わっていません。

**確認できたこと：** Elementは位置に留まり続け、Widgetの中身だけが入れ替わります。runtimeTypeが同じであれば、Elementは破棄されず再利用されます。

---

### P2: 条件付き挿入・削除

**① 初期表示**

画面を開きます。StateTracker が A・B・C の順に表示されます。

```
initState: A  state=912922730
build: A  state=912922730  depth=180  widgetType=StateTracker  element=StatefulElement
initState: B  state=43712260
build: B  state=43712260  depth=180  widgetType=StateTracker  element=StatefulElement
initState: C  state=33717950
build: C  state=33717950  depth=180  widgetType=StateTracker  element=StatefulElement
```

3つのElementがそれぞれの位置にマウントされました。

**② 「Insert X」ボタン押下**

「Insert X」ボタンを押します。AとBの間にStateTracker('X')が挿入され、A・X・B・Cの順になります。

```
didUpdateWidget: B -> X  state=43712260
build: X  state=43712260  depth=180  widgetType=StateTracker  element=StatefulElement
didUpdateWidget: C -> B  state=33717950
build: B  state=33717950  depth=180  widgetType=StateTracker  element=StatefulElement
initState: C  state=587597996
build: C  state=587597996  depth=180  widgetType=StateTracker  element=StatefulElement
```

各位置に何が起きたかを整理します。

|  | ①初期表示 | ②挿入後 | State |
| --- | --- | --- | --- |
| 位置0 | Widget("A") | Widget("A") | 912922730（同じ） |
| 位置1 | Widget("B") | Widget("X") | 43712260（同じ） |
| 位置2 | Widget("C") | Widget("B") | 33717950（同じ） |
| 位置3 | — | Widget("C") | 587597996（新規） |

位置0のAは変化なしです。位置1以降はWidgetがひとつずつ後ろにずれ、既存のElementがdidUpdateWidgetで中身を差し替えています。位置3は新たにElementが生成されました（initState）。

**③ 「Remove X」ボタン押下**

もう一度ボタンを押します。Xが消え、A・B・Cの順に戻ります。

```
didUpdateWidget: X -> B  state=43712260
build: B  state=43712260  depth=180  widgetType=StateTracker  element=StatefulElement
didUpdateWidget: B -> C  state=33717950
build: C  state=33717950  depth=180  widgetType=StateTracker  element=StatefulElement
deactivate: C  state=587597996
dispose: C  state=587597996
```

|  | ②挿入後 | ③除去後 | State |
| --- | --- | --- | --- |
| 位置0 | Widget("A") | Widget("A") | 912922730（同じ） |
| 位置1 | Widget("X") | Widget("B") | 43712260（同じ） |
| 位置2 | Widget("B") | Widget("C") | 33717950（同じ） |
| 位置3 | Widget("C") | — | 587597996（破棄） |

位置1・2はdidUpdateWidgetでWidgetが差し替わりました。位置3のElementはツリーから除去され、disposeが呼ばれました。Elementがツリーから完全に外れるとStateが破棄されます。

**確認できたこと：** 子リストの長さが変わっても、先頭から位置ベースで順にupdateが走る原則は同じです。余りが出た末尾でだけ生成（initState）や破棄（dispose）が起きます。

---

### この検証からわかること

P1とP2に共通しているのは、「同じ親の中で、同じ位置に同じruntimeTypeのWidgetが来れば、Elementは再利用される」というルールです。Elementは位置に紐づいていて、Widgetの中身が変わっても位置が同じなら生き残ります。

---

## 親そのものが変わるとき

基本ルールが「同じ親の中での再利用」だと分かったところで、次は「では親が変わったらどうなるのか？」確認していきます。

### P3: 親の切り替え

**① 初期表示**

画面を開きます。StateTracker('P')がLeftボックスに表示されます。

```
initState: P  state=1047349401
build: P  state=1047349401  depth=188  widgetType=StateTracker  element=StatefulElement
```

LeftボックスにElementがマウントされ、Stateが生成されました。

**② 「StateTrackerをRightへ移動」ボタン押下**

ボタンを押します。StateTracker('P')がLeftボックスから消え、Rightボックスに表示されます。

```
deactivate: P  state=1047349401
initState: P  state=292546343
build: P  state=292546343  depth=188  widgetType=StateTracker  element=StatefulElement
dispose: P  state=1047349401
```

initStateが出た後にdisposeが出ています。Right側で新しいElementとStateが生成されてから、Left側のElementが破棄されました。state idが1047349401から292546343に変わっているのがその証拠です。

**③ 「StateTrackerをLeftへ移動」ボタン押下**

もう一度ボタンを押します。StateTracker('P')がRightボックスから消え、Leftボックスに戻ります。

```
initState: P  state=699027470
build: P  state=699027470  depth=188  widgetType=StateTracker  element=StatefulElement
deactivate: P  state=292546343
dispose: P  state=292546343
```

再びinitStateの後にdisposeが出ています。state idが毎回変わります。同じWidget記述（`const StateTracker('P')`）であっても、親が変わるたびにElementは破棄・再生成されます。

|  | ①初期表示 | ②Right移動 | ③Left移動 |
| --- | --- | --- | --- |
| Left | State 1047349401 | — | State 699027470（新規） |
| Right | — | State 292546343（新規） | — |


**確認できたこと：** 親が変わると、Elementは再利用されず破棄・再生成されます。P1・P2で見た位置ベースの再利用は「同じ親の配下」というスコープに閉じています。

---

### この検証からわかること

基本で見た「位置が同じなら再利用される」には前提条件があります。それは親が同じであることです。親が変わった時点で、旧ElementのStateはdisposeで破棄され、新しいElementがinitStateから始まります。

---

## Keyがあると位置ルールはどう変わるか（→ Ch3）

### P1-b: 並べ替え（Keyあり）

**① 初期表示**

画面を開きます。ValueKey付きStateTrackerがA・B・Cの順に表示されます。

```
initState: A  state=482925730
build: A  state=482925730  depth=155  widgetType=StateTracker  element=StatefulElement
initState: B  state=1040194703
build: B  state=1040194703  depth=155  widgetType=StateTracker  element=StatefulElement
initState: C  state=68835919
build: C  state=68835919  depth=155  widgetType=StateTracker  element=StatefulElement
```

**② Reverseボタン押下**

「Reverse」ボタンを押します。表示がC・B・Aに入れ替わります。

```
didUpdateWidget: C -> C  state=68835919
build: C  state=68835919  depth=155  widgetType=StateTracker  element=StatefulElement
didUpdateWidget: B -> B  state=1040194703
build: B  state=1040194703  depth=155  widgetType=StateTracker  element=StatefulElement
didUpdateWidget: A -> A  state=482925730
build: A  state=482925730  depth=155  widgetType=StateTracker  element=StatefulElement
```

**③ 再度Reverseボタン押下**

もう一度「Reverse」ボタンを押します。表示がA・B・Cに戻ります。

```
didUpdateWidget: A -> A  state=482925730
build: A  state=482925730  depth=155  widgetType=StateTracker  element=StatefulElement
didUpdateWidget: B -> B  state=1040194703
build: B  state=1040194703  depth=155  widgetType=StateTracker  element=StatefulElement
didUpdateWidget: C -> C  state=68835919
build: C  state=68835919  depth=155  widgetType=StateTracker  element=StatefulElement
```

P1（Keyなし）と比較します。

|  | P1（Keyなし） | P1-b（Keyあり） |
| --- | --- | --- |
| 位置0のState | 615888068のまま（Aの位置に留まる） | 68835919に変わる（Cと一緒に移動） |
| ログ | didUpdateWidget: A -> C | didUpdateWidget: C -> C（labelは変わらない） |
| Stateの追従先 | 位置 | label（Key） |

P1では`didUpdateWidget: A -> C`のように、位置に残ったElementが異なるlabelのWidgetを受け取っています。P1-bでは`didUpdateWidget: C -> C`のように、Elementは同じlabelのWidgetを受け取っています。ValueKeyがあると、ElementはKeyに一致する相手を探して紐づいて移動するため、新しい位置でも同じlabelのWidgetに更新されます。state idがlabelと一緒に移動しているのがその証拠です。

**確認できたこと：** Keyがあると、位置ベースの再利用ルールが変わります。Elementはlabel（Key）に紐づいて移動します。この判定メカニズムの詳細はCh3で扱います。

---

## 検証結果まとめ

| シナリオ | 確認できたこと |
| --- | --- |
| P1: 並べ替え（Keyなし） | 位置が同じでruntimeTypeが一致すればElementは再利用される。Widgetのlabelが変わってもdidUpdateWidgetで差し替えが起き、disposeは出ない |
| P2: 条件付き挿入・削除 | 先頭から位置ベースでupdateが走る。末尾で余った部分だけinitState（生成）またはdispose（破棄）が起きる |
| P3: 親の切り替え | 親が変わるとElementは再利用されない。dispose → initStateで毎回新しいStateが生成される |
| P1-b: 並べ替え（Keyあり） | ValueKeyがあるとElementはKeyに紐づいて移動する。StateがlabelのKeyに追従するため、countとlabelの対応が維持される |

---

## 実装時に気をつけること

- 条件分岐でWidgetを出し入れすると、除去されたElementのStateは破棄されます。表示を戻しても以前のStateは復元されません。
- Widgetの親を動的に変える構成は、意図しないState破棄を招きます。同じWidget記述でも親が異なればElementは再生成されます。
