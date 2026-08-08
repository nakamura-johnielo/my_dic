# Phase 2-3: Widget build内のI/Oと副作用を除去する

- 状態: 未着手
- 優先度: 高 / lifecycle
- 依存タスク: [`../phase1/1-create-composition-root.md`](../phase1/1-create-composition-root.md)
- 関連タスク: [`2-standardize-viewmodel-state.md`](2-standardize-viewmodel-state.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 8.1

## 目的

Widgetの`build()`を冪等な描画処理に限定し、rebuild回数によってDB open、fetch、state更新、navigationなどが重複しないようにする。

## 現在の問題

- `lib/main.dart:42-49`の`MyApp.build()`が未awaitの`SELECT 1`を実行する
- `WordPageFragment.build()`がfetchを開始し、その結果がStateNotifierを更新する
- providerのwatchと副作用有効化がWidget lifecycleに混在する
- rebuild、hot reload、親state変更で処理が再実行され得る

## 対象範囲

- `build()`内のFuture、DB、Repository、Notifier mutation、navigation呼出し
- bootstrap provider
- parameterized load provider/ViewModel初期化
- one-shot UI effect

## 実装方針

1. `build()`内の`read(...).method()`、unawaited Future、DB queryを全検索する。
2. アプリ初期化は`app/bootstrap`のFuture/Async providerへ移す。
3. 画面データloadはroute parameterをkeyにしたprovider、AsyncNotifier、または明示的なViewModel初期化へ移す。
4. 同一keyで重複fetchしないcache/lifecycleを定義する。
5. navigationやSnackbarは`ref.listen`などのeffect境界で処理し、build式から分離する。
6. Widget dispose時のrequest cancelまたは結果無視を保証する。

## 推奨テスト

- 同じWidgetを複数回rebuildしてもfetchが一回
- route parameter変更時だけ新しいloadが開始される
- dispose後の結果がstateを更新しない
- bootstrap失敗がerror stateとして表示される
- hot restart/cold startで初期化順序が安定する

## 完了条件

- [ ] `build()`内にDB queryやfetch開始がない
- [ ] アプリ初期化がbootstrap providerにある
- [ ] 画面loadがparameterized lifecycleで管理される
- [ ] rebuild重複を検出するtestがある
- [ ] one-shot effectが描画stateと分離されている

## LLMへの引き継ぎ事項

`initState`へ移すだけではRiverpodのdependency変更に追随できない場合がある。データのkeyと所有期間を決め、provider lifecycleとして表現する。
