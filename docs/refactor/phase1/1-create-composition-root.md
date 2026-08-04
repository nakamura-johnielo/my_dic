# Phase 1-1: app/bootstrapへcomposition rootを集約する

- 状態: 未着手
- 優先度: 高 / 境界固定
- 依存タスク: Phase 0完了を推奨
- 関連タスク: [`../phase2/3-remove-build-time-io.md`](../phase2/3-remove-build-time-io.md)、[`../phase2/4-remove-ref-from-coordinators.md`](../phase2/4-remove-ref-from-coordinators.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 4.3、8.1、8.2

## 目的

DB、Router、SharedPreferences、認証監視、同期開始など、アプリ全体の構築とlifecycleを`app/bootstrap`へ集約し、Widgetやfeatureからcomposition責務を除く。

## 現在の問題

- `main.dart`がFirebaseとSharedPreferencesを初期化する一方、`MyApp.build()`がDB open用`SELECT 1`と横断effectのwatchも行う
- Database singletonがRiverpod管理外で、dispose責務が不明確
- Router、navigation state、global notifierが複数ディレクトリへ分散している
- Widget rebuildが初期化や副作用の再実行条件になり得る

## 目標構造

```text
lib/app/
├── bootstrap/
│   ├── bootstrap.dart
│   ├── app_dependencies.dart
│   └── lifecycle_effects.dart
├── routing/
└── session/
```

`main()`は環境初期化を一度実行して、完成したoverride/dependenciesを`ProviderScope`へ渡す。`MyApp.build()`は`MaterialApp.router`の描画に限定する。

## 対象範囲

- `lib/main.dart`
- `lib/core/di/**`
- `lib/router/**`
- `lib/core/infrastructure/database/drift/database_provider.dart`
- `authEffectProvider`、`autoSyncProvider`など横断effect
- DB closeとProviderContainer dispose

## 実装方針

1. 現在の起動依存と初期化順序を図またはtestで固定する。
2. Firebase、SharedPreferences、DB、Routerの生成責務を`app/bootstrap`へ移す。
3. DBはproviderで所有し、provider dispose時にcloseする。
4. 横断effectは一度だけ有効化されるapplication lifecycle providerへ集約する。
5. `build()`内のDB probeを削除し、明示的なbootstrap Future/AsyncValueでloading/errorを表す。
6. global instanceを新設せず、既存globalを段階的にprovider overrideへ移す。
7. testでfake DB、fake auth、fake routerをoverride可能にする。

## 推奨テスト

- bootstrap成功時に各dependencyが一度だけ生成される
- bootstrap失敗時にerror UIへ遷移する
- Widget rebuildでDB openやeffect登録が増えない
- ProviderContainer disposeでDBがcloseされる
- test用overrideでFirebaseや実DBへ接続しない

## 完了条件

- [ ] `MyApp.build()`が初期化・DB I/O・横断副作用を開始しない
- [ ] compositionの入口が`app/bootstrap`から辿れる
- [ ] DB lifecycleがproviderに所有される
- [ ] 横断effectが一度だけ登録される
- [ ] bootstrapの成功・失敗・dispose testがある

## LLMへの引き継ぎ事項

単なるファイル移動ではなく、生成・所有・破棄の責務を一箇所へ集める。Phase 0の認証・同期挙動を変えないよう、移動前後のcharacterization testを利用する。
