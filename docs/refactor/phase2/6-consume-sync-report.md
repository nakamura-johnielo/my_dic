# Phase 2-6: SyncReportをUI・retry・telemetryへ接続する

- 状態: 完了（2026-08-07）
- 優先度: 中〜高 / 同期可観測性
- 依存タスク: [`../local_first/4-build-sync-engine.md`](../local_first/4-build-sync-engine.md)、[`../local_first/5-migrate-word-status.md`](../local_first/5-migrate-word-status.md)
- 関連タスク: [`../local_first/8-cut-over-and-remove-legacy-sync.md`](../local_first/8-cut-over-and-remove-legacy-sync.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 9.4
- 詳細実装プラン: [`../contexts/plans/phase2.6-consume-sync-report.plan.md`](../contexts/plans/phase2.6-consume-sync-report.plan.md)

## 目的

Local-first 4で導入した`SyncReport`を、manual sync、UI warning、retry scheduling、安全なmetrics/logの共通入力として利用する。

## 前提

`SyncEngine.runOnce()`は次を返す。

```text
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

このPhaseでは結果型を再設計せず、presentationとschedulerの利用方法を整える。

## 実装方針

1. manual refreshは`SyncReport`を受け取り、全成功・部分成功・offline・認証切れを区別する。
2. local command成功とremote delivery失敗を別状態として表示する。
3. retryable failureだけをschedulerへ戻し、Queueの`nextAttemptAt`より前に強制再送しない。
4. non-retryable/dead-letterはdatasetとerror codeだけを安全に通知し、payloadをUIやlogへ含めない。
5. session変更によるcancelはerror表示せず、必要なら新accountのsyncを開始する。
6. metrics/logはdataset、duration、件数、reason/error codeに限定する。

## 必須テスト

- 全成功reportで成功表示となる
- 一部失敗でも成功datasetの結果を保持する
- local保存成功・remote未送信を「操作失敗」と表示しない
- retryable/non-retryableでscheduler動作が分かれる
- 未認証、session変更、cancelの表示規則が一貫する
- reportやlogにtoken、email、本文、remote payloadを含めない

## 完了条件

- [x] manual syncとUIが型付きreportを利用する
- [x] 部分失敗がログだけで失われない
- [x] retry schedulingがQueueの状態と一致する
- [x] local successとremote delivery状態が分離されている
- [x] telemetryが機密・個人データを含まない

## 完了時の検証

- manual controllerは`SyncReport`を安全なsummary/outcomeとone-shot UI effectへ
  変換し、raw report・account・cursor・payloadを状態へ保持しない。
- lifecycle と guest migration は scheduler を通す非対話 trigger であり、
  telemetry/retry は scheduler が所有する。例外ログは固定文言のみで、raw
  exception text を出力しない。
- 2026-08-07: focused sync/presentation/widget/security tests（56件）、
  import-boundary check、`flutter analyze`、full `flutter test`（332件）が成功。

## LLMへの引き継ぎ事項

`SyncReport`を第二の可変Storeにしない。Engineが返す不変snapshotとして扱い、永続的な未送信状態はDrift Queueを正とする。
