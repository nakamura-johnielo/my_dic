# Local-first 8: 新SyncEngineへの全面切替と旧同期削除

状態: 計画済み（実装未着手）  
作成日: 2026-08-07

## 目的

[`../../local_first/8-cut-over-and-remove-legacy-sync.md`](../../local_first/8-cut-over-and-remove-legacy-sync.md)を、安全に実装できるcutover単位へ分割する。5つの同期datasetを新`SyncEngine`だけで動かし、UI/ApplicationのSoTをDriftへ固定したうえで、旧`SyncService`、旧dataset別sync UseCase、app-facing Repositoryのremote API、Firestore listenerによる直接同期、SharedPreferences checkpointを削除する。

このフェーズは「新旧を並行稼働させる移行」ではなく、先に新経路の網羅性をtestで固定し、その後に旧経路を参照元から削除するcutoverである。互換wrapperや空の旧providerは残さない。

## 現在地（2026-08-07時点のコード確認結果）

### すでに成立していること

- `SyncDataset.values`は`espJpnWordStatus`、`jpnEspWordStatus`、`myWords`、`myWordStatus`、`userProfile`の5件である。
- `syncDatasetHandlerRegistryProvider`は上記5件すべてのproduction handlerを登録済みである。
- `DatasetPlan.localFirst`は全datasetを対象とし、`myWordStatus -> myWords`の依存を持つ。
- `applicationLifecycleEffectsProvider`は`AppSessionReady`とapp resumeから`SyncScheduler.foreground`を起動する。
- word status、MyWord、MyWordStatus、User Profileの通常writeはDrift transaction + outboxへ移行済みである。
- guest/account read scope、5 datasetのtransactional guest移管、account session fenceは実装済みである。
- 旧`syncServiceProvider`は空配列でproduction処理を行わない。

### cutover前に埋める必要がある差分

- registryの「計画対象datasetが全件存在する」ことをcomposition testで固定していない。欠落時も現在は`handler unavailable`というskipで実行が継続する。
- production triggerはsession ready、resume、guest移管後だけであり、network復帰、通常local mutation後のwake、明示的manual refreshが未接続である。
- `SyncReport`は呼び出し元で破棄されており、cutover観測用の安全なログがない。
- MyWord/MyWordStatusのRepository interface・実装・DIに旧remote/local-sync APIとFirebase data source依存が残る。
- MyWord/MyWordStatusのremote adapterには新handlerで不要なbatch writer、delete、listener APIが残る。word status remote adapterにも同種の旧APIが残る。
- `SyncService`、`ISyncUseCase`、旧sync UseCase/provider、SharedPreferences checkpoint一式と、それらだけを検証するtestが残る。
- `firebase_at_boundaries`の現行globは`repository_impl`等を確実に捕捉せず、Firebase許可パスを明示的allowlistにできていない。
- Firebase Emulator設定とRulesは存在するが、Emulatorを起動して5 datasetのSecurity Rules、transaction、server timestampを検証するintegration test/CI jobはない。
- remote revision、mutation ID重複delivery、MyWord tombstone対古いupdateのremote protocolは未完了であり、全面切替のcontract gateを満たしていない。

### 文書上の注意

`local_first/7-migrate-user-profile.md`と既存のLocal-first 7 planには古い「進行中」記述が残る一方、現在のコードと[`../current.md`](../current.md)にはguest統合・live profile接続済みと記録されている。Stage 0でコードとtestを正本として再検証し、Local-first 7の文書状態を揃えてから依存完了を確定する。

## 実装スコープ

- 5 datasetのregistry完全性と新Engine単独起動をtestで固定する。
- cold start、upgrade、sign-in、account切替、resume、network復帰、local mutation後wake、manual refreshを新schedulerへ集約する。
- cutover観測に必要な、payloadやtokenを含まないdataset別結果ログを追加する。
- 旧同期のcomposition、UseCase、Repository API、listener、checkpoint永続化を段階的に削除する。
- MyWord/MyWordStatusのapp-facing Repositoryをlocal-onlyにし、sync remote adapterをhandler専用DI境界へ分離する。
- User Profileのeditable field同期とremote authority provisioningを別ポートとして明文化し、通常RepositoryからFirebase SDK依存を除く。
- Firebase/Firestore importを許可されたadapter境界だけに限定するarchitecture ruleを追加し、このルールはbaselineなしで0違反にする。
- unit/contract/integration/Emulator testとCIを追加する。
- 実装結果に合わせてLocal-first 5〜8およびcontextsを更新する。

## スコープ外

- `SyncReport`をUI state、ユーザー向けretry表示、telemetry backendへ接続する作業。これは[`../../phase2/6-consume-sync-report.md`](../../phase2/6-consume-sync-report.md)で行う。Phase 8では構造化ログとtest hookまでに留める。
- OS background task、push notification、常駐Firestore listenerの導入。
- word status featureのdomain/repository統合、copy file全般の整理、大型handler/DAO分割。Phase 1-6/Phase 3の責務とする。
- Ranking等、`SyncDataset`に登録されていないデータのlocal-first化。
- 既存の`core_no_feature`、`domain_no_framework` baseline全件解消。Phase 8で追加・強化するFirebase/legacy-sync規則だけをbaseline 0とする。
- remote schemaの破壊的変更。revision/idempotency/tombstone契約に必要な追加は後方互換なfield・transactionとして行う。

## 参照する計画書とcontexts

- [`../../local_first/index.md`](../../local_first/index.md)
- [`../../local_first/4-build-sync-engine.md`](../../local_first/4-build-sync-engine.md)
- [`../../local_first/5-migrate-word-status.md`](../../local_first/5-migrate-word-status.md)
- [`../../local_first/6-migrate-my-word.md`](../../local_first/6-migrate-my-word.md)
- [`../../local_first/7-migrate-user-profile.md`](../../local_first/7-migrate-user-profile.md)
- [`../current.md`](../current.md)
- [`../runtime-and-status.md`](../runtime-and-status.md)
- [`../feature-map.md`](../feature-map.md)
- [`../next-phase-guide.md`](../next-phase-guide.md)
- [`../../phase2/6-consume-sync-report.md`](../../phase2/6-consume-sync-report.md)

## 実装順序

```text
Stage 0 依存・protocol gateを閉じる
   ↓
Stage 1 新Engineの網羅性とtriggerを固定する
   ↓
Stage 2 production compositionを新Engine単独にする
   ↓
Stage 3 app-facing Repositoryとremote adapterを分離する
   ↓
Stage 4 旧listener/writer/APIを削除する
   ↓
Stage 5 checkpointを移行リリース → 除去リリースの2段階で廃止する
   ↓
Stage 6 architecture ruleをallowlist化しbaseline 0を固定する
   ↓
Stage 7 全体・Emulator・upgrade検証後に文書を完了へ更新する
```

旧実装のファイル削除はStage 0〜2のgateが通るまで開始しない。Stage 3〜5では各段階の参照0を`rg`とcompileで確認してから次へ進む。

## Stage 7: 検証マトリクスと完了判定

### unit / contract test

- registryが5 datasetを過不足なく解決する。
- 全成功、一部失敗、dependency skip、cancel、retryable/non-retryable report。
- 同一account single-flight、trigger coalesce、別account epoch cancel。
- queue lease recovery、process kill相当の再open、ack token/revision保護。
- 全datasetのaccount分離、remote apply非enqueue、cursor rollback、pagination tie-break。
- MyWord/MyWordStatus親子順、tombstone、同一field競合、重複mutation ID。
- guest import accept/cancel/retry/session切替rollback。
- Release Aの旧SharedPreferences key削除とfull sync。
- Repository constructor/APIとFirebase importのarchitecture test。

### Firebase Emulator integration test

新規`integration_test/sync/`またはVMで実行可能な`test/integration/sync/`を用意し、実行方式をCIとREADMEへ明記する。

- 認証なし・別UIDによるread/write拒否。
- 5 datasetのowner read/write成功。
- 許可field以外、subscription変更、hard deleteの拒否。
- transactionによるrevision単調増加、`lastMutationId`冪等性。
- `FieldValue.serverTimestamp`がserver timeとして確定してからackされる。
- 同一timestamp + document ID pagination。
- 二クライアントのoffline編集、再接続、retry後の最終収束。
- MyWord tombstone後に古いupdateを送っても復活しない。

CIではFirebase Emulatorを起動してintegration testを実行し、通常の`flutter test`と分離して失敗原因を判別できるjobにする。

### lifecycle / upgrade scenario

| scenario | 期待結果 |
| --- | --- |
| clean cold start | Ready後に1 cycle、全5 datasetを実行 |
| legacy versionからupgrade | 旧key削除、Drift cursorなしでfull pull |
| sign-in | 新account epochでcycle開始 |
| account AからBへ切替 | Aのcycleをcancelし、Aのapply/checkpoint/ackなし |
| resume | foreground cycleをcoalesceして実行 |
| offlineからnetwork復帰 | wake後にQueue retryとdelta pull |
| local mutation | transaction commit後だけwake |
| process kill中のleased mutation | lease期限後にpendingへ回復 |
| manual refresh | 共通trigger経由でreportを返す |

### 検証コマンド

AGENTS.mdの指示に従い、`dart`/`flutter`は直接sandbox外で実行する。

```powershell
dart format --output=none --set-exit-if-changed lib test integration_test tool
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check
flutter analyze
flutter test test/unit/features/sync/ test/unit/features/word_status/ test/unit/features/my_word/ test/unit/features/user/ test/unit/app/
flutter test
firebase emulators:exec --only firestore "flutter test <採用したEmulator test入口>"
```

`integration_test`を採用しない場合は、存在しないpathをformat/testコマンドから除き、実際のtest入口をplanの実施結果へ記録する。

## 削除予定ファイル一覧

参照移植後に削除する。実装時に`rg`で再確認し、現行コードに存在しないものは無理に作らない。

- `lib/features/sync/sync_service.dart`
- `lib/features/sync/di.dart`
- `lib/core/domain/usecase/i_sync_usecase.dart`
- `lib/core/domain/i_repository/i_sync_repository.dart`（参照0の空interface）
- `lib/core/domain/i_repository/i_sync_status_repository.dart`
- `lib/core/domain/entity/sync_checkpoint.dart`
- `lib/core/infrastructure/repositories/sync_status_repository.dart`
- `lib/core/infrastructure/datasource/sync/i_sync_status_data_source.dart`
- `lib/core/infrastructure/datasource/sync/shared_preferences_sync_status_data_source.dart`
- `lib/core/infrastructure/database/shared_preferences/shared_preferences_syncstatus_dao.dart`
- `lib/features/my_word/domain/usecase/my_word/sync_my_word/sync_my_word_interactor_copy.dart`
- `lib/features/my_word/domain/usecase/my_word/sync_my_word/i_sync_my_word_usecase.dart`
- `lib/features/my_word/domain/usecase/my_word_status/sync_myword_status/sync_myword_status_usecase.dart`
- `test/unit/core/infrastructure/database/shared_preferences/shared_preferences_syncstatus_dao_test.dart`
- 旧経路だけを対象にした`test/unit/features/sync/result_propagation_test.dart`
- 旧経路だけを対象にした`test/unit/features/sync/sync_checkpoint_scoping_test.dart`

`lib/features/sync/infrastructure/persistence/drift/drift_sync_checkpoint_store.dart`と`SyncCheckpointStore` portは新Engineの現役実装なので削除しない。

## contexts更新方針

各Stage完了時に実装事実と検証結果だけを追記し、未来形の説明を現状説明として残さない。

- `docs/refactor/local_first/5-migrate-word-status.md`: 残contract testの完了状況。
- `docs/refactor/local_first/6-migrate-my-word.md`: 旧UseCase/remote Repository API削除と競合/tombstone契約。
- `docs/refactor/local_first/7-migrate-user-profile.md`: guest統合/live profileの実装済み状態へ同期。
- `docs/refactor/local_first/8-cut-over-and-remove-legacy-sync.md`: Stage gateと最終checkbox。
- `docs/refactor/contexts/runtime-and-status.md`: 新Engineだけのruntime flowへ図を更新。
- `docs/refactor/contexts/feature-map.md`: sync、MyWord、Userの旧surface記述を削除。
- `docs/refactor/contexts/current.md`: 全面cutover完了時だけ全体結論を更新。
- `docs/refactor/contexts/next-phase-guide.md`: Phase 2-6/Phase 3へ渡す未対応事項、Emulator test入口、Release B条件を記録。

## 完了条件

- [ ] production registryが`SyncDataset.values`全件を過不足なく解決し、欠落時に起動前失敗する。
- [ ] cold start、upgrade、sign-in、account切替、resume、network復帰、local mutation後wake、manual refreshが新schedulerだけを起動する。
- [ ] UI/Applicationの同期対象read/writeがDriftだけを通る。
- [ ] app-facing Repositoryにremote CRUD/listener APIやFirebase data source依存がない。
- [ ] Firebase importがAuth infrastructure、bootstrap初期化、sync remote adapter、Emulator testだけに存在する。
- [ ] Phase 8追加のFirebase/legacy-sync architecture ruleがbaselineなし・0違反である。
- [ ] `SyncService`、`ISyncUseCase`、旧dataset sync UseCase/provider、互換wrapperの参照が0である。
- [ ] Firestore listenerからlocalへ直接反映する経路と旧remote writerの参照が0である。
- [ ] SharedPreferences checkpoint keyがRelease Aで削除され、Release Bでadapter/type/provider参照が0になる。
- [ ] 5 datasetがretry、account分離、競合、delete、pagination、重複delivery contractを通る。
- [ ] process kill recovery、account切替cancel、二端末offline収束を検証できる。
- [ ] Emulator上でSecurity Rules、transaction、server timestamp testが通る。
- [ ] `flutter analyze`、import boundary check、全`flutter test`、Emulator integration testが成功する。
- [ ] Phase 2-6とPhase 3が旧同期surfaceを考慮せず新`SyncEngine`前提で着手できる。

## 中断条件

次のいずれかに該当した場合、旧ファイル削除を進めずplanへ根拠を記録する。

- remote revision/idempotency/tombstoneのFirestore contractが確定せず、二端末収束を証明できない。
- account切替後に旧epochのackまたはcheckpoint更新が再現する。
- 5 datasetのいずれかがregistryに未登録、または通常Repositoryのremote writerに依存している。
- Release Aを経由していない直接upgrade元をまだサポートするのに、旧key cleanupを除去しようとしている。
- Emulator testがSecurity Rulesとproduction remote adapterを同じschemaで検証できない。
