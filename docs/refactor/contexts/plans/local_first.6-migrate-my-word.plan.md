# Local-first 6: MyWord migration

状態: 完了（Stage 1〜5すべて完了。read側account scopingのみLocal-first 7へ意図的に先送り）
作成日: 2026-08-06
最終更新: 2026-08-06（セッション2、全ステージ完了）

## 目的

[`../../local_first/6-migrate-my-word.md`](../../local_first/6-migrate-my-word.md)を実装可能な段階へ分割する。MyWordの作成・更新・削除とMyWordStatusをlocal-only commandへ変更し、outbox経由でFirebaseへ非同期配送する。

依存タスク: [`../../local_first/5-migrate-word-status.md`](../../local_first/5-migrate-word-status.md) — 進行中（Stage 1/3/4/5完了、Stage 2は縮小スコープで見送り済み）。word status Stage 1で確立した「local write + outbox enqueueを同一Drift transactionで行い、既存remote pushは並行して残す」パターンをそのままMyWordへ転用できることを確認済みのため、依存タスクの残課題（account切替e2e test等）を待たずに着手可能と判断した。

## 実装スコープ全体像（段階分割、タスク文書の「移行順」6項目に対応）

| 段階 | 内容 | 対応する移行順項目 |
| --- | --- | --- |
| Stage 1（完了: 2026-08-06） | MyWord create/updateのlocal書き込みとfield mask付きoutbox mutationを同一Drift transactionで実行する（署名ユーザーのみ、既存remote pushは並行して残す） | 1, 2 |
| Stage 2（完了: 2026-08-06セッション2） | MyWord deleteをtombstone（論理削除）＋outboxへ変更する | 3 |
| Stage 3（完了: 2026-08-06セッション2） | `MyWordSyncHandler`実装、registry登録、旧`SyncMyWordInteractor`（`sync_my_word_interactor copy.dart`）をproduction経路から除去 | 4 |
| Stage 4（完了: 2026-08-06セッション2） | MyWordStatusを同じaccount scope・親IDパターンで移行する | 5 |
| Stage 5（完了: 2026-08-06セッション2） | MyWordStatus handlerをMyWord成功後に実行する依存datasetとして登録する | 6 |

## Stage 1 詳細（本セッションの実装スコープ）

### 対象パス

- `lib/features/my_word/data/data_source/local/i_my_word_local_data_source.dart`
- `lib/features/my_word/data/data_source/local/drift_my_word_dao.dart`
- `lib/features/my_word/data/data_source/local/my_word_drift_data_source.dart`
- `lib/features/my_word/data/repository_impl/my_word_repository.dart`
- `lib/features/my_word/di/data_di.dart`
- 新規test: `test/unit/features/my_word/my_word_outbox_enqueue_test.dart`

### スコープ外（Stage 1では触らない）

- `deleteWord`のtombstone化（Stage 2）。既存のhard delete + remote直接delete呼び出しは変更しない。
- `createLocalMyWord`/`updateLocalMyWord`（旧`SyncMyWordInteractor`が消費するrepositoryメソッド）の変更。これらは`sync_my_word_interactor copy.dart`が引き続き使用するため、シグネチャ・挙動を変えない。
- `MyWordSyncHandler`実装、`syncDatasetHandlerRegistryProvider`への登録。
- MyWordStatusのoutbox化（Stage 4）。
- `legacy_unowned`固定のread側account scopingをaccountId実値へ変更すること（word status Stage 2と同じ理由でLocal-first 7以降へ先送り。outbox mutationのaccountIdフィールドだけ実値を使う）。

### 実装方針

1. `MyWordDao`に`insertMyWordWithRevision`（新規行、`localRevision=1`で挿入し挿入行を返す）と`updateMyWordWithRevision`（既存行の`localRevision`を+1して更新し、更新後の行を返す。対象行が無ければ`null`を返す）を追加する。どちらも`legacyOwner`スコープを維持し、既存の`insertMyWord`/`updateMyWord`/`deleteMyword`（旧sync経路が使用）には触れない。
2. `IMyWordLocalDataSource`に`runInTransaction<T>`と上記2メソッドのインターフェースを追加し、`MyWordDriftDataSource`で`_myWordDao.transaction(action)`へ委譲する。
3. `MyWordRepository`に`OutboxWriter`と`Uuid`を注入する。`registerWord`/`updateWord`を、DAO書き込みと`accountId != null`時のoutbox enqueue（`registerWord`は`SyncMutationOperation.upsert`、`updateWord`は`SyncMutationOperation.patch`。`fieldMask`/`payload`は`word`・`contents`固定の2フィールド）を同一`runInTransaction`内で実行するよう変更する。既存の`_remoteDataSource`直接呼び出しはtransaction成功後にそのまま残す。
4. `myWordRepositoryProvider`（`di/data_di.dart`）で`app/bootstrap/sync_composition.dart`の`driftOutboxWriterProvider`を注入する。

### 検証

```powershell
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check
flutter test test/unit/features/my_word/my_word_outbox_enqueue_test.dart
```

`test/unit/features/my_word/domain/usecase/load_my_word_interactor_test.dart`は本セッション以前から`test/helpers/fake_my_word_repository.dart`と`IMyWordRepository`の不整合でcompile errorになっており、本Stageの変更と無関係（Local-first 5のcontextsに既知不具合として記録済み）。`IMyWordRepository`にメソッド追加は行っていないため悪化はしないが、解消もしない。

### contexts更新方針

- Stage 1完了後、[`../next-phase-guide.md`](../next-phase-guide.md)のLocal-first 6節へ実装済み内容と次スライスへの引き継ぎを追記する。
- [`../feature-map.md`](../feature-map.md)の`my_word`行のうち、`registerWord`/`updateWord`がoutbox経由になったことが分かるよう該当セルを更新する。
- Stage 2以降の設計判断は本ファイルへ追記する。

### Stage 1 実施結果（2026-08-06）

- 変更ファイル: 上記対象パス一覧のとおり。
- 新規test: `test/unit/features/my_word/my_word_outbox_enqueue_test.dart`（署名ユーザーのregister/updateがfield mask付きmutationを1件だけ積むこと、guest登録・更新ではenqueueされないこと、連続更新がcoalesceしてlocal_revisionが進むこと、`sync_outbox`へ積まれたmutationのdatasetが`my_words`であることを検証）。
- 検証結果: 下記参照。

## Stage 2〜5 実施結果（2026-08-06 セッション2）

「Local-first 6の全ステージを完了させる」依頼を受け、Stage 2〜5を1セッションで実装した。

### Stage 2: MyWord deleteのtombstone化

対象パス:

- `lib/features/my_word/data/data_source/local/drift_my_word_dao.dart`（`getMyWordById`/`getFilteredMyWordByPage`/`getIdsFilteredMyWordByPage`/`getMyWordsAfter`/`watchMyWordIdsAfter`/`streamMyWordById`へ`deleted_at IS NULL`条件を追加。`tombstoneMyWord`を新規追加し、`deleted_at`セット＋`local_revision`+1＋子`my_word_status`行のhard deleteを同一transactionで行う）
- `lib/features/my_word/data/data_source/local/i_my_word_local_data_source.dart`・`my_word_drift_data_source.dart`（`tombstoneMyWord`追加）
- `lib/features/my_word/data/repository_impl/my_word_repository.dart`（`deleteWord`を`_localDataSource.deleteMyword`のhard deleteから`tombstoneMyWord`+outbox enqueue（`operation: delete`、`fieldMask: ['deletedAt']`）へ変更）

設計判断: 旧sync経路（`createLocalMyWord`/`updateLocalMyWord`が使う`insertMyWord`/`updateMyWord`/`deleteMyword`）は変更していないが、`getMyWordById`等の読み取り系にtombstone除外フィルタを追加したため、旧sync経路もtombstone後のrowを「ローカルに存在しない」として扱うようになる。Stage 3で旧sync usecase自体をproduction経路から外すため、この過渡的な影響はセッション内で解消される。

### Stage 3: `MyWordSyncHandler`実装とregistry登録

対象パス（新規）:

- `lib/features/my_word/data/data_source/remote/myword/firebase_my_word_dto.dart`（`deletedAt`nullable fieldを追加。tombstoneをremoteへ伝える）
- `lib/features/my_word/data/data_source/remote/myword/firebase_my_word_dao.dart`・`i_my_word_remote_data_source.dart`・`firebase_my_word_data_source.dart`（`patchMyWord`追加。field mask付きmerge writeで、`deletedAt`はISO8601文字列からFirestore `Timestamp`へ変換）
- `lib/features/my_word/data/data_source/local/drift_my_word_dao.dart`（`applyRemoteFields`追加。pull適用は`local_revision`を変えずoutboxにも触れない。既存でローカルtombstone済みのrowは非削除系remote更新で復活させない）
- `lib/features/my_word/data/sync/my_word_sync_handler.dart`（新規、`MyWordSyncHandler`）
- `lib/features/my_word/di/data_di.dart`（`myWordSyncHandlerProvider`追加）
- `lib/app/bootstrap/sync_composition.dart`（registryへ登録）
- `lib/features/sync/di.dart`（`syncMyWordUseCaseProvider`を`syncServiceProvider`から除去）
- `lib/features/my_word/data/repository_impl/my_word_repository.dart`（`registerWord`/`updateWord`/`deleteWord`から直接remote push呼び出しを削除。配送はoutbox+handlerへ一本化）

設計判断: MyWordのcreate/update/deleteはすべて同じfield mask付き`payload`/`fieldMask`契約を持つため、push側は`operation`の種類（upsert/patch/delete）で分岐せず、`patchMyWord`という単一のmerge-write契約だけで処理できる。`isNew`判定は`getMyWordById`の有無で行う。

新規test: `test/unit/features/my_word/my_word_sync_handler_test.dart`（push成功/retry/dead-letter、pull適用、pending field skip、remote tombstoneのローカル反映を検証）。

### Stage 4: MyWordStatusのoutbox化

対象パス:

- `lib/features/my_word/data/data_source/local/drift_my_word_status_dao.dart`（`applyStatusPatch`・`applyRemoteFields`・`runInTransaction`追加。既存`updateStatus`/`insertStatus`/`exist`/`getWordStatus`は旧sync usecase向けに変更なし）
- `lib/features/my_word/data/data_source/local/i_my_word_status_local_data_source.dart`・`my_word_status_drift_data_source.dart`（対応するインターフェース追加）
- `lib/features/my_word/data/data_source/remote/status/firebase_my_word_status_dao.dart`・`i_my_word_status_remote_data_source.dart`・`firebase_my_word_status_data_source.dart`（`patchStatus`追加）
- `lib/features/my_word/data/repository_impl/my_word_status_repository.dart`（`OutboxWriter`/`Uuid`を注入し、`updateStatus`をDrift transaction＋outbox enqueueへ変更。直接remote push（`_remoteDataSource.updateStatus`呼び出し）は削除。`updateLocalStatus`等、旧sync usecaseが使うメソッドは変更なし）
- `lib/features/my_word/di/data_di.dart`（`myWordStatusRepositoryProvider`へ`driftOutboxWriterProvider`注入）

新規test: `test/unit/features/my_word/my_word_status_outbox_enqueue_test.dart`（word statusと同じ契約：field mask付き1件だけのenqueue、guestではenqueueなし、coalesce、no-op検証）。

### Stage 5: MyWordStatus handlerの依存dataset登録

対象パス:

- `lib/features/my_word/data/sync/my_word_status_sync_handler.dart`（新規、`MyWordStatusSyncHandler`。`MyWordStatusDTO`には`hasNote`フィールドがないため、pull適用時`hasNote`は常に`null`＝変更しない）
- `lib/features/my_word/di/data_di.dart`（`myWordStatusSyncHandlerProvider`追加）
- `lib/app/bootstrap/sync_composition.dart`（registryへ登録）
- `lib/features/sync/application/policy/dataset_plan.dart`（`DatasetPlan.localFirst`に`dependencies: {SyncDataset.myWordStatus: {SyncDataset.myWords}}`を追加。`SyncEngine.runOnce`は依存datasetが失敗/キャンセル/スキップの場合に子datasetを`skipped('dependency did not succeed')`にする既存ロジックをそのまま利用）
- `lib/features/sync/di.dart`（`syncMyWordStatusUseCaseProvider`を`syncServiceProvider`から除去。`syncServiceProvider`は空配列となり、旧`SyncService`は実質的に無効化された）

新規test: `test/unit/features/my_word/my_word_status_sync_handler_test.dart`（push成功/retry、pull適用、pending field skipを検証）。

### 共通の検証結果

```powershell
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check
flutter test test/unit/features/my_word/ test/unit/features/sync/ test/unit/features/word_status/
```

- import境界チェック: `feature:my_word -> feature:sync`/`feature:sync -> feature:my_word`の双方向cycleが解消されたため、baselineから該当2件を除去して0件。他のbaseline違反（`core_no_feature`、`domain_no_framework`、`no_cross_feature_presentation`、esp_jpn/jpn_esp間の`no_feature_cycle`）は本タスクと無関係で変化なし。
- `flutter test`: 対象3ディレクトリで86件中85件成功。唯一の失敗は`test/unit/features/my_word/domain/usecase/load_my_word_interactor_test.dart`で、`test/helpers/fake_my_word_repository.dart`と現行`IMyWordRepository`の不整合による既存compile error（Local-first 5から記録済みの無関係な既存不具合。本セッションでは`IMyWordRepository`のシグネチャを変更していないため悪化も改善もしていない）。

### 未対応（次フェーズへの引き継ぎ）

- read側account scoping（`legacy_unowned`固定）: word status・MyWordともLocal-first 7（User Profile/guest統合）で横断的に扱う方針を維持。
- 旧`SyncMyWordInteractor`（`sync_my_word_interactor copy.dart`）・`SyncMyWordStatusUsecase`のクラスファイル自体、および対応する`syncMyWordUseCaseProvider`/`syncMyWordStatusUseCaseProvider`のdi provider定義は削除していない（`test/unit/features/sync/result_propagation_test.dart`・`sync_checkpoint_scoping_test.dart`が直接参照しているため、削除には別途テスト移行が必要）。実行経路（`syncServiceProvider`）からは完全に外れている。Local-first 8で旧実装とともに削除する対象として引き継ぐ。
- account切替（session epoch）を跨いだMyWord/MyWordStatus handler単体のend-to-end testは未実装（word status Local-first 5と同じ既知の未対応事項）。
- pushのretry backoffが`attempt=1`固定の簡略実装である点、pauseエラーをretryと同一扱いにしている点はword status実装からそのまま踏襲した既知の簡略化。
- `MyWordStatusDTO`に`hasNote`のremote fieldが存在しないため、pull側では`hasNote`を同期できない（既存のremote schemaの制約であり、本タスクのスコープ外）。

## 完了条件（本タスク全体、タスク文書のチェックリストを転記）

- [x] MyWord/MyWordStatusの通常Repositoryがlocal-onlyである（`registerWord`/`updateWord`/`deleteWord`/`updateStatus`から直接remote呼び出しを除去し、配送はoutbox+`DatasetSyncHandler`のみが担う。ただし`IMyWordRepository`/`IMyWordStatusRepository`インターフェース自体は旧sync usecase向けのremoteメソッドを引き続き公開している）
- [x] create/update/deleteがtransactional outboxを利用する
- [x] MyWordStatusが親dataset依存を守る（`DatasetPlan.dependencies`でMyWordStatusはMyWordに依存し、MyWord失敗時は`skipped('dependency did not succeed')`になる）
- [x] hard delete差分欠落がtombstoneで解消される（`deleted_at`列を使った論理削除＋remoteへの`deletedAt`伝播）
- [x] 旧MyWord sync UseCaseがproduction registryから外れている（`features/sync/di.dart`の`syncServiceProvider`は空配列。旧usecaseクラス自体は`test/unit/features/sync/`のtestが直接参照するため未削除、Local-first 8へ引き継ぎ）
