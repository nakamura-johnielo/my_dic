# Local-first 8: 新SyncEngineへ全面切替し旧同期を削除する

- 状態: Stage 2〜6完了。Stage 5 Release Bはユーザー承認済みの早期進行として完了しており、ship/telemetry/acceptance evidenceは主張しない。Stage 7は5 datasetのupgrade integration proofを担当し、未完了である。詳細は[`../contexts/plans/local_first.8-cut-over-and-remove-legacy-sync.plan.md`](../contexts/plans/local_first.8-cut-over-and-remove-legacy-sync.plan.md)）
- 優先度: P1 / cutover
- 依存タスク: [`5-migrate-word-status.md`](5-migrate-word-status.md)、[`6-migrate-my-word.md`](6-migrate-my-word.md)、[`7-migrate-user-profile.md`](7-migrate-user-profile.md)
- 関連タスク: [`../phase2/6-consume-sync-report.md`](../phase2/6-consume-sync-report.md)、[`../phase3/2-consolidate-copy-files.md`](../phase3/2-consolidate-copy-files.md)、[`../phase3/6-split-large-components.md`](../phase3/6-split-large-components.md)

## 目的

全同期対象datasetを新SyncEngineへ切り替え、複数writer、直接Firebaseアクセス、旧listener、重複sync UseCaseを削除する。

## 実施状況（2026-08-07）

- Stage 2: 旧`SyncService`、`ISyncUseCase`、MyWord/MyWordStatus向け旧sync UseCaseとDI providerを削除した。`applicationLifecycleEffectsProvider`からも旧`autoSyncProvider`のwatch/importを撤去し、foreground同期は`syncSchedulerProvider`経由の新`SyncEngine`だけが担当する。
- Stage 3: MyWord、MyWordStatus、Userのapp-facing Repositoryはローカル専用にした。同期用のremote操作はRepositoryから分離されたhandler/adapter側に残し、User Profileの初期プロビジョニングは`UserProfileProvisioner`へ分離した。
- Stage 4: 旧remote listener/writer APIを削除した。Esp-Jpn/Jpn-Esp word statusのremote adapterは各featureの`data/sync/remote`へ配置し、Firestore `Timestamp`/`DocumentSnapshot`の変換はDTO mapper内に閉じ込めた。status remote pageはinclusiveな`(updatedAt, documentId)` cursorを使い、同一timestampの順序と継続pullをfocused boundary/handler testで検証する。
- Stage 5 Release A: bootstrapで`lastSync_wordStatus`と`sync_checkpoint.v1.*`を削除する。旧cursorをread/copyせず、cleanup成功後にだけcompletion markerを書く。cleanup failureはnon-fatalであり、次回以降のbootstrapでretryする。
- Stage 5 Release B: legacy SharedPreferences sync-status checkpoint adapter/type/provider chainを削除した。Release A cleanupはsupported upgradeの旧key削除のために残す。これはユーザー承認済みの早期進行であり、ship/telemetry/acceptance evidenceを主張しない。
- 検証: `flutter analyze`は0 issues、full `flutter test`は285 passed。

- Stage 6: Firebase import allowlist と legacy-import rule の baseline は 0。
  SDK import は `lib/features/auth/data/**`、`lib/app/bootstrap/**`、各
  `lib/features/*/data/sync/remote/**`（および Emulator integration test）だけに
  限定した。core Firebase provider/DAO/transaction、MyWord/User の旧 remote
  source はそれぞれ bootstrap または feature-owned remote adapter へ移設し、
  legacy sync import は残していない。`dart run tool/check_import_boundaries.dart
  --baseline tool/import_boundaries/baseline.json --check`、`flutter analyze`、
  sync/word-status/MyWord/User/app の対象 unit test（161 tests）は成功した。
  `firebase_options.dart` は生成・ignore 対象なので、FlutterFire の出力先は
  `lib/app/bootstrap/firebase_options.dart` とする。

Stage 5（Release A/B）とStage 6のimport-boundary baseline 0は完了している。Stage 5 Release Bはユーザー承認済みの早期進行であり、ship/telemetry/acceptance evidenceは主張しない。Stage 7が担当する5 datasetのfull upgrade integration proofは未完了である。

## cutover手順

1. dataset registryが全対象datasetを新handlerへ解決することを確認する。
2. 旧syncと新Engineが同一datasetで同時稼働していないことをtestとログで確認する。
3. cold start、upgrade、sign-in、account切替、resume、network復帰を段階的に検証する。
4. 旧`SyncService`、`ISyncUseCase`、dataset別旧sync UseCaseを削除する。 （Stage 2完了）
5. app-facing RepositoryからremoteメソッドとFirebase data source依存を削除する。 （Stage 3完了）
6. Firestore listenerからの直接local更新経路を削除する。 （Stage 4完了）
7. Stage 5 Release Aでbootstrap legacy-key cleanupを実装し、Release Bでlegacy SharedPreferences sync-status checkpoint chainを削除する（完了）。Release Bはユーザー承認済みの早期進行であり、ship/telemetry/acceptance evidenceは主張しない。
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
- Stage 7: 5 datasetのupgrade integration proof（upgrade直後のfull syncを含む）
- process killを含むQueue recovery
- account切替中の旧cycle cancel
- 二端末offline編集後の収束
- tombstone、同一timestamp、pagination、重複delivery
- Firebase Emulator上のSecurity Rules、transaction、server timestamp
- architecture checkで直接Firebase writerが0

## 完了条件

- [x] UI/Applicationの同期対象read/writeがDriftだけを通る
- [x] app-facing Repositoryから旧SyncService、旧sync UseCase参照が0である
- [x] word statusのremote adapterがfeature-owned boundaryにあり、Firestore SDK型はDTO mapper内に閉じている（Stage 4）
- [x] 旧remote listener/writer参照が0であり、status paginationはinclusiveなtimestamp/document-ID cursorを使う（Stage 4）
- [x] Stage 5 Release Aのbootstrap cleanupが`lastSync_wordStatus`と`sync_checkpoint.v1.*`をread/copyせずに削除し、成功後だけmarkerを書き、failureをnon-fatal retryにする
- [x] Stage 5 Release Bでlegacy SharedPreferences sync-status checkpoint chainを削除した（ユーザー承認済みの早期進行。ship/telemetry/acceptance evidenceは主張しない）
- [ ] 全datasetがretry、account分離、競合、deleteのcontract testを通る
- [ ] Phase 2・3が新SyncEngine前提で進められる

## LLMへの引き継ぎ事項

旧実装はdataset切替と検証が完了するまで削除しない。一方、cutover後に互換wrapperを残すと直接remote経路が再利用されるため、参照0を確認して削除する。
