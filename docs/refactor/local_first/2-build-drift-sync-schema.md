# Local-first 2: Driftへ同期schemaとaccount scopeを追加する

- 状態: 未着手
- 優先度: P0 / データ整合性
- 依存タスク: [`1-define-local-first-contract.md`](1-define-local-first-contract.md)、[`../phase0/2-repair-v5-migration.md`](../phase0/2-repair-v5-migration.md)
- 関連タスク: [`3-build-sync-queue.md`](3-build-sync-queue.md)、[`../phase0/3-scope-sync-checkpoints.md`](../phase0/3-scope-sync-checkpoints.md)

## 目的

user-ownedデータ、未送信mutation、pull cursorをDrift内でaccount別に永続化し、local更新・remote反映・同期進捗をtransactionで保護できるようにする。

## 目標schema

### user-owned table

- 全同期対象rowに`accountId`を追加する。
- identityは原則`PRIMARY KEY(accountId, entityId)`とする。
- guestと旧unscopedデータには空文字ではなく安定したowner scopeを割り当てる。
- MyWord系には`localRevision`、`remoteRevision`、`deletedAt`を追加する。

### sync_outbox

```text
mutationId
accountId
dataset
entityId
operation: upsert / patch / delete
fieldMaskOrPayload
payloadVersion
localRevision
baseRemoteRevision
state: pending / leased / deadLetter
attemptCount
nextAttemptAt
leaseUntil
createdAt
lastErrorCode
```

### sync_checkpoints

```text
accountId
dataset
cursorTimestamp
cursorDocumentId
lastSuccessfulAt
```

primary keyは`(accountId, dataset)`とする。

## migration方針

1. 現行schemaからuser-owned rowを`legacy_unowned`へ移す。
2. migration時点のFirebase UIDへ暗黙帰属させない。
3. 既存SharedPreferences checkpointは新Drift cursorへコピーしない。
4. datasetは新schemaの初回起動時にfull syncする。
5. full sync成功後だけ、そのdatasetの旧SharedPreferences keyを削除する。
6. failure時は旧key削除もcursor更新も行わず、再試行可能にする。

## 必須テスト

- schema v1〜現行から新versionへのfixture migration
- account A/Bで同一entity IDを保持できる
- `legacy_unowned`が現在UIDへ自動帰属しない
- outboxと業務rowがtransaction rollbackで共に戻る
- remote反映とcheckpointがtransaction rollbackで共に戻る
- SharedPreferences key削除がfull sync成功後だけ行われる

## 完了条件

- [ ] 全user-owned tableがaccount scopeを持つ
- [ ] `sync_outbox`と`sync_checkpoints`がDrift管理である
- [ ] deleteがtombstoneとして保持できる
- [ ] 全旧schemaからデータを失わずupgradeできる
- [ ] guest・legacy・signed-in accountが混在しない

## LLMへの引き継ぎ事項

checkpoint adapterの置換はPhase 0-3の契約を否定するものではない。account/dataset分離と完全成功時のみ進める保証を維持し、保存先とcursor表現を強化する。

