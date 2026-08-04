# Phase 2-6: SyncServiceからSyncReportを返す

- 状態: 未着手
- 優先度: 中〜高 / 同期可観測性
- 依存タスク: [`../phase0/3-scope-sync-checkpoints.md`](../phase0/3-scope-sync-checkpoints.md)、[`../phase0/4-fix-result-propagation.md`](../phase0/4-fix-result-propagation.md)、[`../phase0/5-rebuild-status-sync.md`](../phase0/5-rebuild-status-sync.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 9.4

## 目的

同期全体の成功、部分成功、失敗、retry要否を呼出し元が判断できるよう、`SyncService.syncOnceAll()`からdataset別の結果を返す。

## 現在の問題

`lib/features/sync/sync_service.dart:30-46`は各`Result`をログへ出すだけで`Future<void>`を返す。Auth effectやUIは次を判断できない。

- 全datasetが成功したか
- どのdatasetが失敗したか
- checkpointがどこまで進んだか
- retryが必要か
- 認証切れ、通信失敗、競合のどれか

## 目標モデル例

```text
SyncReport
  accountId
  startedAt
  finishedAt
  datasetResults: Map<SyncDataset, DatasetSyncResult>

DatasetSyncResult
  success(changedCount, checkpoint)
  skipped(reason)
  failed(error, retryable, checkpointUnchanged)
```

機密データやremote payload全体をreportへ含めない。

## 実装方針

1. dataset IDと結果型をapplication層に定義する。
2. 各sync UseCaseを`DatasetSyncResult`へ変換する。
3. priority groupは維持しつつ、各結果をaggregateする。
4. 必須dataset失敗時に後続を停止するか、独立datasetを続行するかを明示する。
5. checkpoint更新結果をreportと一致させる。
6. Auth/session effectはreportに基づきretry schedulingやUI warningを決定する。
7. 安全なmetrics/logへdataset、duration、件数、error codeだけを出す。

## 必須テスト

- 全成功report
- 一部失敗reportと成功datasetの保持
- retryable/non-retryable分類
- 未認証やsession変更によるcancel/skip
- failure datasetのcheckpointが進まない
- priority依存datasetの停止規則

## 完了条件

- [ ] `syncOnceAll()`が`SyncReport`を返す
- [ ] dataset別の成功・失敗・skip理由が判定できる
- [ ] checkpointとreportの状態が一致する
- [ ] 呼出し元が部分失敗を無視しない
- [ ] reportにtokenや個人データを含めない
- [ ] aggregate testがある

## LLMへの引き継ぎ事項

成功件数をログへ増やすだけでは不十分。型付き結果を呼出し元へ返し、retry、UI、telemetry、checkpoint判断の共通入力にする。
