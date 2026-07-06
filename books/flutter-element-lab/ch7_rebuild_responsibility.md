---
title: "第7章　rebuildの責任をどう分割するか — Traceability"
---

:::message alert
本章に掲載しているログはすべて**サンプル値**です。`flutter-element-lab` の `lib/chapters/ch7/` を実機で操作し、実測ログに差し替えてから公開してください（公開前チェック項目）。
:::

## この章の中心的な問い

**このrebuildは、誰が起こしたのか。**

アプリが育つと、「なぜかこのWidgetが再buildされる」という状況に必ず出会います。そのとき原因まで遡れるかどうかは、rebuildのトリガーを**どの仕組みに任せたか**という設計判断で事前に決まっています。この章では、setState・InheritedWidget・Streamという3種類のトリガーを同じ条件で観察し、トリガーからbuildまでの経路がどう違うかをログで確かめます。

## 起点となる確定事実

> **buildを呼ぶのはフレーム内のBuildOwner**（第3章）
> `setState` はbuildを実行しない。dirtyの印を付けて次のフレームを予約するだけで、実際にbuildを呼ぶのはフレーム処理内の `BuildOwner.buildScope` である。

この事実の含意は、**どんなトリガーを使っても、buildの実行地点はひとつしかない**ということです。setStateでも、Providerの通知でも、Streamでも、最終的には同じ `buildScope` に合流します。つまり各手段の違いはbuildの実行方法ではなく、「**dirtyの印が付くまでの経路**」にあります。この章はその経路の違いを扱います。

## Traceabilityという評価軸

**Traceability：rebuildが起きたとき、その原因（トリガー）まで開発者が遡れる度合い。**

- Traceabilityが**高い**：トリガーからdirtyマークまでが同期的な呼び出しで繋がっており、コードを読めば（あるいはスタックを見れば）因果が追える
- Traceabilityが**低い**：トリガーとdirtyマークの間に非同期境界や別レイヤーが挟まり、因果が時系列でしか追えない

例によって高低は優劣ではありません。非同期境界を挟むことは、UIとロジックを分離するための意図的な設計でもあります。ここで確定させたいのは「その分離が追跡可能性と引き換えである」という事実です。

## 前提

- Flutter 3.29.0 / 実機（Android）でログを取得します
- 検証コードは `lib/chapters/ch7/` にあります
- 各ログに `SchedulerBinding.instance.schedulerPhase` を併記します。`idle` はフレーム外、`persistentCallbacks` はフレーム内（buildやlayoutが走る区間）を意味します
- Streamの検証には `StreamController` と `StreamBuilder` を直接使います。BLoCライブラリの中核はこの組み合わせであり、フレームワークとの接続点を観察する目的にはこれで十分だからです

## 基本シナリオ：setStateによるトリガー

タイル（`TILE-SETSTATE`）のボタンを押し、自身のsetStateでrebuildを起こします。

**ログ**

```text
※サンプルログ（実測後に差し替え）
[TAP] setState  phase=SchedulerPhase.idle
[BUILD] TILE-SETSTATE (#2)  phase=SchedulerPhase.persistentCallbacks
```

**時系列**

| 操作 | ログ | 解釈 |
|------|------|------|
| タップ | [TAP]（phase=idle） | フレームの外で、ユーザーコードがsetStateを呼ぶ。この瞬間にdirtyマークとフレーム予約が済む |
| （次フレーム） | [BUILD]（phase=persistentCallbacks） | フレーム内のBuildOwnerがbuildを実行 |

**確認できたこと**

トリガー（[TAP]）はフレーム外、build本体はフレーム内、という第3章の事実がphase付きで再確認できました。Traceabilityの観点で重要なのは、dirtyマークを付けたのが**自分のコードに書いたsetState**だという点です。「なぜrebuildされたか」の答えがコード上のsetState呼び出し箇所と一対一に対応します。経路は最短です。

## 派生シナリオ1：InheritedWidget（notifyClients）によるトリガー

値を保持する親がsetStateし、その配下のInheritedWidgetが更新されることで、依存タイル（`TILE-INHERITED`）がrebuildされる経路です。第5章で確認したdependOn登録が受信側の仕組みでした。今回は送信側——通知がいつ・どこで走るか——を見ます。

**ログ**

```text
※サンプルログ（実測後に差し替え）
[TAP] 親のsetState  phase=SchedulerPhase.idle
[BUILD] provider-parent (#2)  phase=SchedulerPhase.persistentCallbacks
[DEPEND] didChangeDependencies: TILE-INHERITED  phase=SchedulerPhase.persistentCallbacks
[BUILD] TILE-INHERITED (#2)  phase=SchedulerPhase.persistentCallbacks
```

**確認できたこと**

注目は3行目です。依存タイルへの通知（didChangeDependencies）が `persistentCallbacks`、つまり**フレームの内側**で起きています。経路はこうです。親のsetState（フレーム外）→ 次フレームで親がbuildされ、新しいInheritedWidgetがElementに渡る → その場で `updated` → `notifyClients` が同期的に走り、依存Elementにdirtyマークが付く → 同じbuildScopeの中でビルドされる。

つまりInheritedWidget経由の伝播は、**フレーム内の同期呼び出しの連鎖**です。トリガーから依存先のbuildまでがひと続きのスタックで繋がっており、依存関係そのものも第5章のとおり `of()` の呼び出し位置として明示されています。経路は1段増えましたが、各段は追跡可能です。

## 派生シナリオ2：Streamによるトリガー

`StreamController` にイベントを流し、`StreamBuilder` 配下のタイル（`TILE-STREAM`）がrebuildされる経路です。

**ログ**

```text
※サンプルログ（実測後に差し替え）
[TAP] sink.add(1)  phase=SchedulerPhase.idle
[STREAM] listenコールバック  count=1  phase=SchedulerPhase.idle
[BUILD] TILE-STREAM (#2)  phase=SchedulerPhase.persistentCallbacks
```

**確認できたこと**

1行目と2行目の間に**非同期境界**があります。`sink.add` はその場でリスナーを呼びません。イベントはマイクロタスクとして予約され、タップ処理が終わったあとに（phase=idleのまま）リスナーが実行されます。そしてdirtyマークを付けるsetStateは、リスナーの中——正確には**StreamBuilderの内部実装**——が呼びます。

Traceabilityの観点で決定的なのはこの最後の点です。プロジェクトのコードをsetStateでgrepしても、このrebuildのトリガーは見つかりません。dirtyマークの実行者はフレームワーク側のStreamBuilderであり、開発者のコードにあるのは `sink.add` だけ。両者の対応は同期スタックでは繋がっておらず、時系列（このaddの後にこのbuildが来た）でしか追えません。

## ここまでの帰結

3つの経路を並べます。

| トリガー | dirtyマークの実行者 | トリガーとの接続 | フレームとの関係 |
|----------|--------------------|-----------------| -----------------|
| setState | 自分のコード | 同一箇所 | フレーム外で予約 |
| notifyClients | フレームワーク（Element） | of()による明示的な依存 | フレーム内で同期伝播 |
| Stream | フレームワーク（StreamBuilder） | 非同期境界を挟む | フレーム外・別タスクから予約 |

合流点は常にBuildOwnerで、そこは選べません。開発者が選べるのは**dirtyマークに至る経路**であり、経路が同期スタックで繋がっているほどrebuildの原因は追いやすく、非同期境界を挟むほどUIとロジックの分離は進む——rebuild責務の分割とは、このトレードオフのどこに立つかという設計判断です。

## 設計判断のまとめ（評価マトリクス）

| ライブラリ | Traceability | 意味 |
|-----------|--------------|------|
| setState | 高 | BuildOwner直結。トリガー＝自分のコード |
| InheritedWidget | 高 | notifyClientsは可視。依存グラフがof()として明示される |
| Riverpod | 中 | invalidate等のトリガーは可視だが、間にContainerが介在する |
| BLoC | 低 | Streamという非同期境界の向こうからrebuildが始まる |

BLoCの「低」は欠点の指摘ではありません。イベントの発生源とUIを切り離すことがBLoCの目的であり、Traceabilityの低さはその目的の裏面です。追跡はログやDevToolsで補う前提の設計だと理解した上で選ぶ、というのがこの軸の使い方です。

## 章末コラム：StreamとnotifyClientsは何が違うのか

本文の派生シナリオ1と2は、どちらも「他者がdirtyマークを付ける」経路でした。しかしフレームループとの位置関係が正反対です。

notifyClientsが走るのは、親のbuildの最中——**フレームの内側**です。InheritedElementの更新処理から依存Elementのdirtyマークまでが1つの同期スタックに収まっており、同じbuildScopeの中で消化されます。フレームワークの管理下から一度も出ていない、と言い換えられます。

一方Streamのイベントは、**フレームの外側**、イベントループの別のタスクからやってきます。フレームワークから見れば、setState（StreamBuilder内部の）が突然呼ばれたのと同じで、それがStream由来なのか、タイマーなのか、ネットワーク応答なのかを区別する手段はありません。トリガーの素性がフレームワークの視界の外にある——これが「Streamがフレームループ外から来る」ことの意味です。

第3章の事実に戻ると、BuildOwnerはどちらのdirtyマークも同じように次のフレームで処理します。フレームワークにとって両者は等価です。**差が生じるのは、原因を遡ろうとする開発者の側**であり、だからこの差はパフォーマンスの軸ではなくTraceabilityの軸に現れます。

## 次章に向けて

本章では「誰がrebuildを起こすか」を確認しました。次章の主題は「rebuildをまたいで何が保たれるか」——同一性です。起点となる事実は第4章の「判断根拠はruntimeTypeとKeyだけ」です。