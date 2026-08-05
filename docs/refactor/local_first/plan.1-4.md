以下の4段階・4PRで進めるのが安全です。1〜4では共通基盤だけを完成させ、実datasetのproduction切替はLocal-first 5〜7まで行いません。

```text
LF1 契約固定
  ↓
LF2 Drift v6 schema・migration
  ↓
LF3 永続Queue
  ↓
LF4 汎用Engine
  ↓
Phase 1 composition/session完了
  ↓
LF5〜7 datasetを1つずつ切替
```

## 最初に固定する設計判断

実装開始前に4文書へ次を追記します。

1. cursorは`timestampSeconds + timestampNanoseconds + documentId`
2. outboxは`payload`と`fieldMask`を別カラムにする
3. lease競合防止に`leaseToken`を追加する
4. ack条件は`mutationId + leaseToken + leasedLocalRevision`
5. 初期版ではmutationをcoalesceしない
6. Engineは逐次実行から開始する
7. 実行中triggerは「現在処理へ相乗り」ではなく、終了後に最大1回rerunする
8. 既存`SyncService`とSharedPreferences checkpointはLocal-first 8までlegacyとして残す
9. 1〜4ではproduction dataset handlerを登録しない

---

## PR 1：Local-first 1 契約固定

対象文書：[`1-define-local-first-contract.md`](/C:/Users/deded/Documents/LocalDev/my_dic/docs/refactor/local_first/1-define-local-first-contract.md)

### 実装ファイル

```text
lib/core/shared/enums/
└── sync_dataset.dart

lib/features/sync/application/
├── model/
│   ├── sync_context.dart
│   ├── sync_cursor.dart
│   ├── sync_mutation.dart
│   ├── mutation_lease.dart
│   ├── dataset_sync_result.dart
│   └── sync_report.dart
├── port/
│   ├── dataset_sync_handler.dart
│   ├── sync_queue.dart
│   ├── outbox_writer.dart
│   ├── sync_checkpoint_store.dart
│   └── session_fence.dart
└── policy/
    ├── dataset_plan.dart
    └── retry_policy.dart
```

`SyncDataset`だけは複数featureとlegacy checkpointが参照するため、限定的に`core/shared`へ置きます。Engine固有型はすべて`features/sync/application`へ置きます。

### 型の概要

- `SyncDataset`
  - 5つのstable ID
  - enum ordinalは永続化しない
- `SyncCursor`
  - seconds
  - nanoseconds
  - documentId
- `SyncMutation`
  - mutationId、accountId、dataset、entityId
  - operation、payload、fieldMask
  - localRevision、baseRemoteRevision
- `MutationLease`
  - mutation本体
  - leaseToken、leasedLocalRevision、leaseUntil
- `DatasetSyncResult`
  - `success / skipped / failed / cancelled`
- `SyncReport`
  - token、例外、remote payloadを保持しない

小さなimmutable contractなので、原則Dart 3の`sealed class`を使い、Freezedは必須にしません。

### テスト

```text
test/unit/features/sync/application/
├── sync_dataset_test.dart
├── sync_cursor_test.dart
├── sync_mutation_test.dart
└── sync_report_test.dart
```

確認内容：

- stable IDが固定されている
- 空のaccountId/entityIdを拒否する
- cursorの同一timestampをdocumentIdで順序付けできる
- reportへ機密情報を格納できない
- dataset dependencyの循環を検出できる

### 完了ゲート

- Firebase、Drift、Flutterへの依存がapplication contractにない
- 後続PRが文字列や`Map<String,dynamic>`で独自契約を作らなくてよい
- 現在の [`SyncCheckpoint`](/C:/Users/deded/Documents/LocalDev/my_dic/lib/core/domain/entity/sync_checkpoint.dart:38) はlegacyとして明示されている

---

## PR 2：Local-first 2 Drift v6 schema

対象文書：[`2-build-drift-sync-schema.md`](/C:/Users/deded/Documents/LocalDev/my_dic/docs/refactor/local_first/2-build-drift-sync-schema.md)

### 新規ファイル

```text
lib/core/infrastructure/database/drift/
├── tables/sync/
│   ├── sync_outbox.dart
│   └── sync_checkpoints.dart
├── migrations/
│   └── migration_v6_local_first.dart
└── daos/sync/
    ├── sync_outbox_dao.dart
    └── sync_checkpoint_dao.dart
```

[`DatabaseProvider`](/C:/Users/deded/Documents/LocalDev/my_dic/lib/core/infrastructure/database/drift/database_provider.dart:53)へテーブルを登録し、`schemaVersion`を5から6へ上げます。

### `sync_outbox`

主なカラム：

```text
mutationId PK
accountId
dataset
entityId
operation
payload
fieldMask
payloadVersion
localRevision
baseRemoteRevision
state
attemptCount
nextAttemptAt
leaseToken
leaseUntil
createdAt
lastErrorCode
```

追加index：

```text
(accountId, dataset, state, nextAttemptAt, createdAt)
(accountId, dataset, entityId, state)
(leaseUntil, state)
```

### `sync_checkpoints`

```text
accountId
dataset
cursorSeconds
cursorNanoseconds
cursorDocumentId
lastSuccessfulAt

PRIMARY KEY(accountId, dataset)
```

### user-owned tableの変更

対象：

- Esp-Jpn WordStatus
- Jpn-Esp WordStatus
- MyWords
- MyWordStatus
- UserProfile新規table

原則：

```text
PRIMARY KEY(accountId, entityId)
```

また、必要に応じて以下を追加します。

```text
localRevision
remoteRevision
deletedAt
lastMutationId
```

既存rowはすべて明示的に`legacy_unowned`へ移します。新しいカラムへdefault値を設定して暗黙的にlegacy扱いするのではなく、legacy DAOも明示的に`legacy_unowned`を指定・検索するよう変更します。

### migration手順

1. v5 schemaをexport
2. v6 shadow tableを作成
3. v5 rowを`legacy_unowned`付きでcopy
4. 件数と親子関係を検証
5. 問題があればthrowしてrollback
6. 旧tableをdrop
7. shadow tableを正式名へrename
8. outbox/checkpoint/profile tableを作成
9. index・制約を検証

SharedPreferences checkpointはこのmigrationではコピー・削除しません。

### テスト

```text
test/unit/core/infrastructure/database/drift/
├── database_provider_v6_migration_test.dart
├── sync_schema_constraints_test.dart
└── account_scope_test.dart
```

最低限：

- v1〜v5のfixtureからv6へ移行できる
- migration前後で件数と値が一致する
- 全旧rowが`legacy_unowned`
- account A/Bが同じentity IDを保持できる
- 空accountIdを保存できない
- migration途中の失敗でv5全体がrollbackされる
- fresh v6とmigrated v6のschemaが一致する
- Web/SQLite双方で利用する型にFirebase型が混入しない

### 完了ゲート

- v6 schemaとmigration testが通る
- legacy同期のproduction挙動はまだ変わらない
- 新outbox/checkpointは存在するが、production writerはまだ接続されない

---

## PR 3：Local-first 3 永続Queue

対象文書：[`3-build-sync-queue.md`](/C:/Users/deded/Documents/LocalDev/my_dic/docs/refactor/local_first/3-build-sync-queue.md)

### 実装ファイル

```text
lib/features/sync/infrastructure/persistence/drift/
├── drift_outbox_writer.dart
├── drift_sync_queue.dart
└── drift_sync_checkpoint_store.dart

lib/features/sync/application/policy/
├── exponential_backoff.dart
└── sync_error_classifier.dart
```

### port分割

業務更新側：

```dart
abstract interface class OutboxWriter {
  Future<void> enqueue(EnqueueMutation mutation);
}
```

Engine側：

```dart
abstract interface class SyncQueue {
  Future<List<MutationLease>> leasePending(...);
  Future<bool> ack(MutationLease lease);
  Future<void> retry(MutationLease lease, ...);
  Future<void> deadLetter(MutationLease lease, ...);
  Future<int> releaseExpiredLeases(...);
}
```

### state遷移

```text
pending
  ├── lease → leased
  └── validation failure → deadLetter

leased
  ├── server ack → row削除
  ├── retryable failure → pending
  ├── non-retryable failure → deadLetter
  └── lease timeout → pending
```

認証切れはattemptを消費するretryではなく、session回復までpause扱いにします。

### atomicity

将来のfeature Repositoryでは以下を一つのDrift transactionにします。

```text
業務row更新
localRevision増加
outbox enqueue
transaction commit
```

1〜4ではproduction Repositoryへまだ組み込みません。代わりにテスト用業務tableまたは既存tableを使い、transaction rollback契約を先に証明します。実datasetへの接続は5〜7で行います。

### coalesce

初期実装では行いません。

`enqueue()`はmutationを常に独立rowとして追加します。Queueの正しさが確認できた後、5〜7でdataset別に安全なcoalesceを追加します。

### 共通contract test

```text
test/support/contracts/sync_queue_contract.dart

test/unit/features/sync/
├── fake_sync_queue_contract_test.dart
└── drift_sync_queue_contract_test.dart
```

同じテストをfakeとDrift実装の両方へ適用します。

必須ケース：

- account/dataset別lease
- limitとFIFO
- leaseTokenの一意性
- 古いleaseTokenでackできない
- 古いlocalRevisionでackできない
- retry/backoff/jitter
- lease timeout復旧
- dead-letter
- process kill相当のDB reopen
- row更新とenqueueのatomicity
- remote成功後・ack前kill相当の安全な再送

### 完了ゲート

- Queueの正はDriftだけ
- dirty flagを新設していない
- clockとrandomをfakeへ差し替えられる
- payloadやtokenをログへ出さない

---

## PR 4：Local-first 4 汎用Engine

対象文書：[`4-build-sync-engine.md`](/C:/Users/deded/Documents/LocalDev/my_dic/docs/refactor/local_first/4-build-sync-engine.md)

### 実装ファイル

```text
lib/features/sync/application/
├── sync_engine.dart
├── dataset_handler_registry.dart
├── single_flight_coordinator.dart
└── cancellation_token.dart

test/helpers/sync/
├── fake_dataset_sync_handler.dart
├── fake_sync_queue.dart
├── fake_session_fence.dart
└── fake_clock.dart
```

### Engine constructor

```text
SyncEngine
  handlers
  datasetPlan
  sessionFence
  clock
  singleFlightCoordinator
```

EngineはFirebase、Firestore、Driftを直接参照しません。

### 実行アルゴリズム

1. `SyncContext`を検証
2. 同一accountの実行中cycleを確認
3. 実行中ならrerun要求を記録
4. dataset planを依存順に走査
5. session epochを確認
6. 親dataset失敗なら子をskip
7. 独立datasetは続行
8. handler結果をreportへ格納
9. rerun要求があればもう1 cycle実行
10. typed `SyncReport`を返す

初期版は逐次実行です。

### cancellation

次の各タイミングで`sessionEpoch`とtokenを確認します。

- handler開始前
- remote送信後
- pull page取得後
- Drift反映前
- checkpoint更新前
- Queue ack前

旧accountのremote Futureが遅れて完了しても、Drift反映・checkpoint・ackを行わせません。

### handler registry

Engine内部にdataset switch文を置きません。

```text
DatasetSyncHandler
  dataset
  run(context)
```

実handlerはLocal-first 5〜7で各featureへ追加し、Phase 1のcomposition rootから登録します。

1〜4完了時点ではproduction registryを空にするか、テスト用handlerだけを使用します。

### テスト

```text
test/unit/features/sync/application/
├── sync_engine_report_test.dart
├── sync_engine_dependency_test.dart
├── sync_engine_single_flight_test.dart
├── sync_engine_cancellation_test.dart
└── dataset_handler_registry_test.dart
```

必須ケース：

- 全成功
- 一部失敗
- 親失敗による子skip
- 独立dataset継続
- cancel report
- 同一account single-flight
- 実行中triggerによる1回rerun
- account切替後の旧account反映・ack禁止
- handler例外のtyped failure化
- reportにpayload、token、例外本文を含めない
- dependency循環・handler重複を起動時に拒否

### 完了ゲート

- Engineが具体的なFirebase/Drift型をimportしていない
- fakeのみで全orchestrationを検証できる
- 現行 [`SyncService`](/C:/Users/deded/Documents/LocalDev/my_dic/lib/features/sync/sync_service.dart:8) は変更せず稼働可能
- lifecycle schedulerやRiverpod providerへの接続はPhase 1まで行わない

## 1〜4全体の最終確認

以下を満たした段階でLocal-first 5へ進めます。

- `dart format`
- 変更対象の`dart analyze`
- 全sync unit test
- v1〜v6 migration test
- fake/Drift共通Queue contract test
- 既存Phase 0同期テスト
- generated Driftコードに差分漏れがない
- 新Engineへproduction datasetが登録されていない
- 旧・新Engineが同じdatasetを処理する経路がない

この計画なら、1〜4完了時点は「新基盤が完全にテスト済みだが、production動作はまだ旧同期」という安全な状態になります。そこからLocal-first 5でWord Statusを最初の縦切りとして接続できます。