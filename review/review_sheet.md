# Flutter Observatory — レビューシート

> このシートは、記事（`articles/`）と検証コード（`flutter_element_lab/lib/`）のレビューを行うためのテンプレートです。
>
> レビュアーは各章のセクションに記入し、完了したら進捗欄のステータスを更新してください。

---

## 凡例

| 記号 | 意味 |
|---|---|
| `[x]` | OK … 問題なし |
| `[!]` | 要確認 … 修正が必要 |
| `[~]` | 軽微 … 表記揺れ等 |
| `[?]` | 検証推奨 … 実機確認推奨 |

チェックボックス：
- [ ] 未対応
- [x] 対応済み

---

## 📋 レビュー進捗

| 章 | タイトル | 記事 | コード | レビュアー | 最終更新 |
| --- | --- | --- | --- | --- | --- |
| 序文 | FlutterのElementツリーを理解する | `[ ]` 未 / `[~]` 中 / `[x]` 済 | ─ |  |  |
| Ch1 | Elementツリーの位置管理 | `[ ]` 未 / `[~]` 中 / `[x]` 済 | `[ ]` 未 / `[~]` 中 / `[x]` 済 |  |  |
| Ch2 | Stateのライフサイクル管理 | `[ ]` 未 / `[~]` 中 / `[x]` 済 | `[ ]` 未 / `[~]` 中 / `[x]` 済 |  |  |
| Ch3 | 同一性管理（Key） | `[ ]` 未 / `[~]` 中 / `[x]` 済 | `[ ]` 未 / `[~]` 中 / `[x]` 済 |  |  |
| Ch4 | 再構築スケジューリング | `[ ]` 未 / `[~]` 中 / `[x]` 済 | `[ ]` 未 / `[~]` 中 / `[x]` 済 |  |  |
| Ch5 | 依存と通知の管理 | `[ ]` 未 / `[~]` 中 / `[x]` 済 | `[ ]` 未 / `[~]` 中 / `[x]` 済 |  |  |

---

## 🔍 レビュー観点の説明

レビューは以下の観点で行います。各章のチェックリストに沿って確認してください。

**記事（Markdown）の観点**

| 観点 | 確認内容 |
| --- | --- |
| ✅ 技術的正確性 | Flutterの内部実装（フレームワークのソースコード）と説明が一致しているか |
| ✅ わかりやすさ | 前提知識のない読者が読んで理解できる流れになっているか。用語は初出時に説明されているか |
| ✅ 構成・順序 | 章内の説明の順序が論理的で、前章との接続が自然か |
| ✅ コードとの整合性 | 記事中のログ例・コード例が、実際の検証コードの動作と一致しているか |
| ✅ 実装への接続 | 「実装時に気をつけること」など実践的な示唆が適切に提供されているか |

**コード（Dart）の観点**

| 観点 | 確認内容 |
| --- | --- |
| ✅ 動作の正確性 | ボタン操作やシナリオを踏んだとき、記事に書かれたログが実際に出るか |
| ✅ 記事との整合性 | StateTrackerのラベル名・シナリオ名が記事の表記と一致しているか |
| ✅ 読みやすさ | 検証コードとして、意図が明確に読み取れるか。不要な複雑さがないか |
| ✅ 保守性 | 検証ページの追加・変更が容易な構造になっているか |

---

## 序文：FlutterのElementツリーを理解する

> 対象ファイル：`articles/ch0_preface.md`

### シリーズ全体の構成と序文の役割

このシリーズはFlutterのElementツリーが持つ5つの責務（位置・ライフサイクル・同一性・再構築・依存）を、検証コードとログで順に確認していく構成です。序文では前提知識（Widget / Element / State の役割、`updateChild`の4分岐、`canUpdate`の判定ロジック）と、全章で使用する`StateTracker`の使い方を説明しています。

---

### ✅ 記事レビューチェックリスト（序文）

#### 技術的正確性

- [ ] Widget / Element / State の役割分担の説明は正確か
- [ ] `updateChild`の4分岐（null×null、null×non-null、non-null×null、non-null×non-null）の記述は正確か
- [ ] `inflateWidget` / `deactivateChild` / `update` の呼ばれるタイミングの説明は正確か
- [ ] Stateが作られるまでの流れ（createElement → mount → _firstBuild → initState → build）は正確か

#### わかりやすさ

- [ ] Widget・Element・Stateの説明を読んで、3者の関係を初読者が理解できるか
- [ ] `updateChild`の4分岐の表が直感的に読めるか
- [ ] StateTrackerのサンプル出力とログ対応表が、以降の章を読む前に理解できるか

#### 構成・順序

- [ ] 序文→Ch1への流れが自然につながっているか
- [ ] 前提知識の順序（3者の役割 → updateChild → Stateが作られるまで → StateTracker）は適切か

#### コードとの整合性

- [ ] StateTrackerのサンプルログ（`initState: A state=1234` など）の形式は実際のコード出力と一致しているか

**コメント・指摘事項（序文）**

---

## Ch1：Elementツリーの位置管理

> 対象ファイル：
> 記事 `articles/ch1_position.md`
> コード `flutter_element_lab/lib/chapters/ch1/`

### この章の要約

Elementは「ツリー上の位置」に紐づいており、同じ親の中で位置が変わってもElementは破棄されず再利用される（Keyなし）。検証シナリオP1〜P3と補足のPart 1-bで、並べ替え・条件付き挿入削除・親の切り替え・Keyあり並べ替えを通じて位置管理の挙動を観測する。

---

### ✅ 記事レビューチェックリスト（Ch1）

#### 技術的正確性

- [ ] Keyなし並べ替えで`didUpdateWidget`が出てdisposeが出ない理由（位置にElementが紐づく）の説明は正確か
- [ ] 条件付き挿入・削除でdisposeが発生するメカニズム（`updateChild`の分岐）の説明は正確か
- [ ] 親が変わるとElementが作り直される理由（`canUpdate`がfalseになる）の説明は正確か
- [ ] 各シナリオのログ例（state idの値、イベント名）は実際の出力と一致しているか

#### わかりやすさ

- [ ] P1・P2・P3の各シナリオの「①②③」の操作手順が明確か
- [ ] 表（位置×操作後のWidget・State）は直感的に読めるか
- [ ] 「確認できたこと」まとめの文章は、検証から何を学んだかを簡潔に示せているか
- [ ] Part 1-bのKeyなし／Keyあり対比表が、KeyによってElementの追従先がどう変わるかを直感的に示しているか

#### 構成・順序

- [ ] Ch1 Part 1-bでKeyあり並べ替えを先取りして示しつつ、詳細はChapter 3で扱うという流れが記事内で示唆されているか
- [ ] P1（並べ替え）→ P2（挿入削除）→ P3（親の切り替え）→ Part 1-b（Keyあり並べ替え）の流れは適切か

#### コードとの整合性

- [ ] P1〜P3・Part 1-bのシナリオ名・StateTrackerのラベルが記事と一致しているか
- [ ] 「Reverseボタン」「Insert Xボタン」「StateTrackerをRightへ移動」等の画面上のボタン名称が一致しているか

#### 実装への接続

- [ ] 「条件分岐でWidgetを出し入れするとStateは復元されない」「親を動的に変えると意図しないState破棄が起きる」という実装上の注意点が適切に示されているか

---

### ✅ コードレビューチェックリスト（Ch1）

> 対象：`ch1_catalog_page.dart` / `p1_reorder_no_key_page.dart` / `p1_reorder_with_key_page.dart` / `p2_conditional_page.dart` / `p3_move_parent_page.dart`

- [ ] 各Pageのシナリオ（ボタン操作）が記事に書かれた手順通りに動作するか
- [ ] StateTrackerのラベル名が記事の表記と一致しているか（例：`"A"`, `"B"`, `"C"`）
- [ ] ボタン名（"Reverse", "Insert X", "StateTrackerをRightへ移動" 等）が記事の記述と一致しているか
- [ ] Part 1-bのKeyあり並べ替えでstateがlabelと一緒に移動することが確認できるか
- [ ] 検証に不要な余分なロジック・UIが混入していないか
- [ ] カタログページからの遷移が正しく機能しているか

**コメント・指摘事項（Ch1）**

---

## Ch2：Stateのライフサイクル管理

> 対象ファイル：
> 記事 `articles/ch2_lifecycle.md`
> コード `flutter_element_lab/lib/chapters/ch2/`

### この章の要約

Stateの生死はElementが決める。Elementがツリーにマウントされたとき`initState`でStateが生まれ、ツリーから外れると`dispose`でStateが死ぬ。P1（if除去）・P2（Navigator pop）・P3（GlobalKeyで移動）を通じて、この原則とGlobalKeyによる唯一の例外を観測する。

---

### ✅ 記事レビューチェックリスト（Ch2）

#### 技術的正確性

- [ ] `deactivate → dispose`の順序の説明は正確か
- [ ] Navigator.popがRoute配下のElementツリーをまるごと破棄するという説明は正確か
- [ ] Navigator.pushで前画面のStateが維持される理由（スタックに残るため）の説明は正確か
- [ ] GlobalKeyで`deactivate → activate`が起きてdisposeが起きない理由の説明は正確か
- [ ] P3のログ例（`activate`が出ること、state idが変わらないこと）は正確か
- [ ] 「GlobalKeyの同一性管理メカニズムの詳細はCh3で扱います」という参照は適切か

#### わかりやすさ

- [ ] P1・P2・P3の対比（P1とP2は同じ原則のスケール違い、P3は例外）が明確に示されているか
- [ ] 「Stateの自律性のなさ」（自分の生死を自分で決められない）というコアメッセージが伝わるか
- [ ] P3の「deactivate → activate」が「dispose → initState」との違いとして直感的に理解できるか

#### 構成・順序

- [ ] P1（基本）→ P2（スケール）→ P3（例外）という順序は論理的か
- [ ] Ch2の結論がCh3（同一性管理）への橋渡しになっているか

#### コードとの整合性

- [ ] P1〜P3のシナリオ名・StateTrackerのラベルが記事と一致しているか
- [ ] state idの値はログ例として一貫しているか

#### 実装への接続

- [ ] StreamのSubscription・AnimationController・TextEditingControllerのdispose注意点は適切か
- [ ] `mounted`チェックの重要性の説明はあるか（Ch4との接続）

---

### ✅ コードレビューチェックリスト（Ch2）

> 対象：`ch2_catalog_page.dart` / `ch2_p1_if_remove_page.dart` / `ch2_p2_navigator_page.dart` / `ch2_p3_globalkey_move_page.dart`

- [ ] P1のif制御でStateTracker('IF-CHILD')が正しく表示・非表示になるか
- [ ] P2のNavigator push/popで正しくinitState/disposeが発火するか
- [ ] P3のGlobalKeyで「上下スロットを切り替える」操作時にdisposeが出ず、activateが出るか
- [ ] StateTrackerのラベル名が記事の表記と一致しているか（'IF-CHILD'、'PUSHED-PAGE-CHILD'、'GLOBAL-KEYED'）
- [ ] ボタン名（「子を消す（if=false）」「子を戻す（if=true）」「上下スロットを切り替える」等）が記事の記述と一致しているか

**コメント・指摘事項（Ch2）**

---

## Ch3：同一性管理（Key）

> 対象ファイル：
> 記事 `articles/ch3_identity.md`
> コード `flutter_element_lab/lib/chapters/ch3/`

### この章の要約

FlutterはKeyの有無・種類によって「どのElementと対応するか」を決める。Keyなし（位置で同一性判断）→ ValueKey（同じ親のchildren内でKey照合）→ GlobalKey（アプリ全体のレジストリで照合）という3段階の対比を通じて、`canUpdate`の判定スコープの違いを観測する。

---

### ✅ 記事レビューチェックリスト（Ch3）

#### 技術的正確性

- [ ] `canUpdate`の判定式（runtimeType + key）の説明と掲載コードは正確か
- [ ] ValueKeyの照合スコープが「親のchildren内」であることの説明は正確か
- [ ] GlobalKeyの照合スコープが`BuildOwner._globalKeyRegistry`（アプリ全体）であることの説明は正確か
- [ ] `BuildOwner._globalKeyRegistry`（`Map<GlobalKey, Element>`）のコード引用は正確か
- [ ] `inflateWidget`内でGlobalKeyが引き取り分岐に入る仕組みの説明とコード引用は正確か
- [ ] P3の表（state hashCodeが変わらないこと）は正確か

#### わかりやすさ

- [ ] P1（Keyなし）→ P2（ValueKey）→ P3（GlobalKey）の対比構造が明確か
- [ ] 「位置で決まる / 同じ親のchildren内で決まる / アプリ全体で決まる」という段階の説明が直感的か
- [ ] P3の前提知識（GlobalKeyのレジストリと引き取り）の説明が長すぎないか、過不足ないか

#### 構成・順序

- [ ] Ch2 P3との接続（「Ch2ではdisposeが出ないことを確認、Ch3では同一性の観点から見る」）は自然か
- [ ] 「設計の優先順位」（Keyなし → ValueKey → GlobalKey）の位置付けは適切か

#### コードとの整合性

- [ ] P2のStateTracker表（操作後の表示位置・label・state hashCode）は実際の動作と一致しているか
- [ ] P3の表（state hashCodeが不変）は実際の動作と一致しているか

#### 実装への接続

- [ ] `ValueKey(index)` はNG・`ValueKey(item.id)` はOKの具体例は説得力があるか
- [ ] GlobalKeyを`build()`内で毎回生成してはいけない理由とNG/OKコード例は適切か

---

### ✅ コードレビューチェックリスト（Ch3）

> 対象：`ch3_catalog_page.dart` / `ch3_p1_no_key_page.dart` / `ch3_p2_value_key_page.dart` / `ch3_p3_global_key_page.dart`

- [ ] P1でKeyなし並べ替え時にstateがlabelに追従しないことが確認できるか
- [ ] P2でValueKey付き並べ替え時にstateがlabelに追従することが確認できるか
- [ ] P3でGlobalKey付き切り替え時にstate hashCodeが不変であることが確認できるか
- [ ] 各ページのStateTrackerのKey設定（なし / ValueKey / GlobalKey）が意図通りか
- [ ] ラベル名・ボタン名が記事と一致しているか

**コメント・指摘事項（Ch3）**

---

## Ch4：再構築スケジューリング

> 対象ファイル：
> 記事 `articles/ch4_rebuild.md`
> コード `flutter_element_lab/lib/chapters/ch4/`

### この章の要約

`setState`はbuildを直接呼ばない。`markNeedsBuild`でdirtyフラグを立ててBuildOwnerに登録し、次のVSync（フレーム）でBuildOwnerが一括実行する。`[ACTION]` / `[BUILD]` / `[FRAME]` の3種のログで「登録と実行の分離」を観測し、setStateの回数によらずbuildがフレームあたり1回にまとまること（重複排除）、非同期完了後のsetStateも同じ仕組みで処理されること（遅延実行）、depth順で親から子にrebuildされること（depth順ソート）の3点を確認する。

---

### ✅ 記事レビューチェックリスト（Ch4）

#### 技術的正確性

- [ ] フレームの概念（60fps ≒ 16.7ms）の説明は正確か
- [ ] SchedulerBinding / BuildOwner / WidgetsBindingの役割分担の説明は正確か
- [ ] mermaidシーケンス図の流れ（setState → markNeedsBuild → scheduleBuildFor → scheduleFrame → handleDrawFrame → buildScope → rebuild）は正確か
- [ ] `markNeedsBuild`の`if (dirty) return;`による重複排除のコード引用は正確か
- [ ] `buildScope`のdirtyリストが空のときの早期リターンのコード引用は正確か
- [ ] depth順ソートによる親→子の再構築順序の説明は正確か

#### わかりやすさ

- [ ] 「登録（フレームの外）と実行（フレームの中）の分離」という設計の意図が伝わるか
- [ ] `[ACTION]` / `[BUILD]` / `[FRAME]` の3ログの位置が1フレームの処理順序の図と対応して理解しやすいか
- [ ] 「仮にsetStateから直接buildを呼ぶ場合」の比較説明は設計の意図を明確にしているか
- [ ] 非同期シナリオで「350ms間に約21フレーム」という実測値との対応付けは分かりやすいか

#### 構成・順序

- [ ] 前提（フレーム・3つの責務・ログ仕込み）→ 重複排除の確認（同一イベントx3）→ 遅延実行の確認（非同期）→ depth順ソートの確認という流れは適切か
- [ ] 前提セクションが長いが、検証シナリオを読む前に必要な情報として過不足ないか

#### コードとの整合性

- [ ] `[BUILD] parent page` / `[ACTION] call setState x3 in one tap` / `[FRAME] drawFrame completed: #N` の出力形式は実際のコードと一致しているか
- [ ] ログの時系列表（`#67` → `[ACTION]` → `[BUILD]` → `#68`）は実際の出力と一致するか
- [ ] 遅延実行シナリオの「350ms待機・約21フレーム」は実際のコードの待機時間（`Future.delayed(Duration(milliseconds: 350), ...)`）と一致しているか

#### 実装への接続

- [ ] setStateの「スコープ（どのStatefulWidgetで呼ぶか）」がパフォーマンスに影響するという指摘は適切か
- [ ] `mounted`チェックの必要性がCh2の内容と接続されているか

---

### ✅ コードレビューチェックリスト（Ch4）

> 対象：`ch4_catalog_page.dart` / `ch4_p1_rebuild_scheduling_page.dart`

- [ ] `[ACTION]` / `[BUILD]` / `[FRAME]` の3種のログが正しいタイミングで出力されるか
- [ ] setStateを3回呼んだとき`[BUILD]`が1回しか出ないことが確認できるか
- [ ] 非同期完了後のsetStateで`[BUILD]`が次フレームで実行されることが確認できるか
- [ ] `addPostFrameCallback`の再登録（自分自身を次フレームにも登録）が正しく実装されているか
- [ ] child-A / child-B のdepth値が同じであることがログで確認できるか

**コメント・指摘事項（Ch4）**

---

## Ch5：依存と通知の管理

> 対象ファイル：
> 記事 `articles/ch5_dependency.md`
> コード `flutter_element_lab/lib/chapters/ch5/`

### この章の要約

FlutterのツリーをまたぐWidget間通信には2つの仕組みがある。`InheritedWidget`は`of()`を呼んだElement（build時に動的登録）のみにrebuildを通知する。`Notification`はmount時に構築された`_notificationTree`（Listenerの連結リスト）を辿る静的な構造解決で、rebuildを起こすかはListenerの`setState`呼び出し次第。「InheritedWidgetは依存元だけをrebuildするか」で選択的rebuildを、「Notificationはrebuildを制御しないか」で捕捉側のsetStateがrebuild範囲を決める仕組みを観測する。

---

### ✅ 記事レビューチェックリスト（Ch5）

#### 技術的正確性

- [ ] `_inheritedElements`（型索引）と`_notificationTree`（Listenerの連結リスト）の2系統の構造の説明は正確か
- [ ] InheritedWidgetの「段階1：mount時の祖先索引化」と「段階2：build時の依存登録」の説明は正確か
- [ ] `_updateInheritance()`と`InheritedElement._updateInheritance()`のコード引用は正確か
- [ ] `dependOnInheritedWidgetOfExactType`と`dependOnInheritedElement`のコード引用は正確か
- [ ] `notifyClients`のコード引用と`_dependents.keys`走査の説明は正確か
- [ ] `NotifiableElementMixin.attachNotificationTree()`のコード引用は正確か
- [ ] `_NotificationNode.dispatchNotification`の伝播停止ロジック（true → 停止、false → 上位へ）の説明は正確か
- [ ] `updateShouldNotify`の役割（差分判定→通知実行のゲート）の説明は正確か

#### わかりやすさ

- [ ] InheritedWidgetの「2段階構え」（mount時の索引化 ＋ build時の依存登録）の概念が明確に伝わるか
- [ ] 「通知先がbuildの実行履歴で動的に決まる（InheritedWidget）vs. 構造で静的に決まる（Notification）」という対比が明確か
- [ ] Notificationが「rebuildを直接起こさない」という点が強調されているか
- [ ] 2つの経路の対比表は読みやすく、違いが一目で分かるか
- [ ] この章は他章と比べてコード引用が多いが、説明の流れを妨げていないか

#### 構成・順序

- [ ] 前提（2系統の補助構造）→ InheritedWidgetの詳細 → Notificationの詳細 → 対比表 → ログの仕込み → 検証という流れは適切か
- [ ] 前提セクションの情報量が多いが、P1・P2の検証を読む前に必要な情報として過不足ないか

#### コードとの整合性

- [ ] ログ仕込みの説明（InheritedWidget用・Notification用）が実際のコード実装と一致しているか
- [ ] P1・P2の検証シナリオのログ例が実際の出力と一致しているか

#### 実装への接続

- [ ] `of()`を呼ぶ位置でrebuildの粒度が変わるという実装上の示唆は適切か
- [ ] `updateShouldNotify`で不要なrebuildを抑制できるという説明はあるか

---

### ✅ コードレビューチェックリスト（Ch5）

> 対象：`ch5_catalog_page.dart` / `ch5_p1_inherited_dependency_page.dart` / `ch5_p2_notification_bubble_page.dart` / `widget_box.dart`

- [ ] P1（InheritedWidget）でvalueを更新したとき、`_DependentWidget`（`of()`あり）のみがrebuildされ、`_IndependentWidget`（`of()`なし）は沈黙するか
- [ ] P1で`[Scope] build`→`[Inherited] updateShouldNotify`→`[BUILD] dependent`の順序で出力されるか
- [ ] P2（Notification）でdispatch後に`[NOTIFICATION] received`が出た後、ページ配下のすべてのWidgetが`[BUILD]`に出るか（`_IndependentWidget`も含む）
- [ ] P2でListenerの`onNotification`が`true`を返して伝播が止まる仕組みがコードに実装されているか
- [ ] `widget_box.dart`の役割が検証補助ウィジェットとして適切か（余分なロジックがないか）
- [ ] ウィジェット名（`_DependentWidget`、`_IndependentWidget`、`_DispatchWidget`）・ボタン名が記事と一致しているか

**コメント・指摘事項（Ch5）**

---

## 🏁 全体コメント

### シリーズ全体の評価

### 特に良かった点

### 全体を通じた改善提案

### 公開前に必ず対応が必要な指摘

---

*このシートはテンプレートです。コピーしてレビュアーごとに使用するか、コメント欄に記入者名を添えてご利用ください。*