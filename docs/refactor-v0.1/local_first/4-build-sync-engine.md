# Local-first 4: SyncEngineとSyncReportを実装する

- 状態: 完了
- 優先度: P0 / 同期orchestration
- 依存タスク: [`3-build-sync-queue.md`](3-build-sync-queue.md)
- 関連タスク: [`../phase1/1-create-composition-root.md`](../phase1/1-create-composition-root.md)、[`../phase1/4-introduce-current-session.md`](../phase1/4-introduce-current-session.md)、[`../phase2/6-consume-sync-report.md`](../phase2/6-consume-sync-report.md)

## 目的

dataset固有処理をhandlerへ委譲しつつ、account単位の排他、優先順、cancel、retry判断、結果集約を一つのEngineで管理する。

## application contract

```text
SyncEngine.runOnce(SyncContext) -> SyncReport

SyncContext
  accountId
  sessionEpoch
  reason
  cancellation

SyncReport
  accountId
  startedAt
  finishedAt
  datasetResults: Map<SyncDataset, DatasetSyncResult>

DatasetSyncResult
  success(pushedCount, pulledCount, cursor)
  skipped(reason)
  failed(errorCode, retryable, cursorUnchanged)
  cancelled(reason)
```

## DatasetSyncHandler

各featureのhandlerは次を担当する。

- Queue mutationをFirebaseへ送信する。
- remote pageをserver cursorから取得する。
- conflict resolutionとDTO変換を行う。
- remote snapshotとcheckpointを同一Drift transactionで反映する。
- tombstoneとremote schema versionを処理する。

SyncEngineはcollection名やfeature固有DTOをswitch文で扱わない。

## 実行規則

- 同一accountではsingle-flightとし、重複triggerは現在cycleへcoalesceする。
- account切替時はsession epoch不一致で旧cycleをcancelする。
- 親dataset失敗時は依存する子datasetをskipする。
- 独立datasetは他dataset失敗後も続行し、部分成功をreportへ残す。
- remote listenerはdatasetのwake signalだけを発行し、単件同期を直接実行しない。
- foreground triggerだけを初期対象とし、OS background taskは追加しない。

## 必須テスト

- 全成功、一部失敗、skip、cancel report
- account別single-flightと別account切替cancel
- priority/依存datasetの停止規則
- Queue retryable/non-retryable分類
- failure datasetのcursorが進まない
- listener取りこぼし後のfull/delta pullで収束する
- reportにtokenやremote payloadを含めない

## 完了条件

- [x] `runOnce`がdataset別の型付き結果を返す
- [x] Queue、handler、session、clockをfakeで差し替えられる
- [x] EngineからFirebase/Drift具体型への直接依存がない
- [x] account切替で旧accountの反映・ackが停止する
- [x] schedulerがEngineを起動するだけの責務になっている

## LLMへの引き継ぎ事項

旧`SyncService`へ新規責務を積み増さない。新Engineを並行構築し、dataset単位の切替が完了した後に旧実装を削除する。
