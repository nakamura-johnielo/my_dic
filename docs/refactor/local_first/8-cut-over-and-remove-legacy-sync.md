# Local-first 8: 新SyncEngineへ全面切替し旧同期を削除する

- 状態: 未着手
- 優先度: P1 / cutover
- 依存タスク: [`5-migrate-word-status.md`](5-migrate-word-status.md)、[`6-migrate-my-word.md`](6-migrate-my-word.md)、[`7-migrate-user-profile.md`](7-migrate-user-profile.md)
- 関連タスク: [`../phase2/6-consume-sync-report.md`](../phase2/6-consume-sync-report.md)、[`../phase3/2-consolidate-copy-files.md`](../phase3/2-consolidate-copy-files.md)、[`../phase3/6-split-large-components.md`](../phase3/6-split-large-components.md)

## 目的

全同期対象datasetを新SyncEngineへ切り替え、複数writer、直接Firebaseアクセス、旧listener、重複sync UseCaseを削除する。

## cutover手順

1. dataset registryが全対象datasetを新handlerへ解決することを確認する。
2. 旧syncと新Engineが同一datasetで同時稼働していないことをtestとログで確認する。
3. cold start、upgrade、sign-in、account切替、resume、network復帰を段階的に検証する。
4. 旧`SyncService`、`ISyncUseCase`、dataset別旧sync UseCaseを削除する。
5. app-facing RepositoryからremoteメソッドとFirebase data source依存を削除する。
6. Firestore listenerからの直接local更新経路を削除する。
7. 旧SharedPreferences checkpoint adapterとkey migrationコードを削除する。
8. architecture checkを新しい依存規則へ合わせ、禁止import baselineを0にする。

## import規則

Firebase/Firestore importを許可するのは次だけとする。

- auth infrastructure
- app/bootstrapのFirebase初期化
- 各featureのsync remote adapter
- Firebase Emulatorを使うintegration test

domain、presentation、通常application UseCase、local RepositoryからのFirebase importは禁止する。

## 必須テスト

- 全datasetのend-to-end syncと部分失敗report
- upgrade直後のfull syncと旧checkpoint key削除
- process killを含むQueue recovery
- account切替中の旧cycle cancel
- 二端末offline編集後の収束
- tombstone、同一timestamp、pagination、重複delivery
- Firebase Emulator上のSecurity Rules、transaction、server timestamp
- architecture checkで直接Firebase writerが0

## 完了条件

- [ ] UI/Applicationの同期対象read/writeがDriftだけを通る
- [ ] Firebase data accessが許可されたadapter境界だけに存在する
- [ ] 旧SyncService、旧sync UseCase、旧remote listener参照が0である
- [ ] SharedPreferences checkpoint参照が0である
- [ ] 全datasetがretry、account分離、競合、deleteのcontract testを通る
- [ ] Phase 2・3が新SyncEngine前提で進められる

## LLMへの引き継ぎ事項

旧実装はdataset切替と検証が完了するまで削除しない。一方、cutover後に互換wrapperを残すと直接remote経路が再利用されるため、参照0を確認して削除する。

