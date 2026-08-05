# Phase 0-3: 同期checkpointをaccount・dataset単位に分離する

- 状態: 完了
- 優先度: P0 / データ整合性
- 依存タスク: Phase 0-2と独立して実施可能
- 関連タスク: [`5-rebuild-status-sync.md`](5-rebuild-status-sync.md)、[`../phase2/6-return-sync-report.md`](../phase2/6-return-sync-report.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) P0-3

## 目的

各ユーザー・各datasetが独立した最終成功時刻を持ち、あるdatasetの成功や失敗が別datasetの差分取得範囲を壊さないようにする。

## 現在の問題

`lib/core/infrastructure/database/shared_preferences/shared_preferences_syncstatus_dao.dart:6-17`は単一の最終同期日時だけを保存する。interfaceにもaccountやdatasetの引数がない。

`SyncService`はpriority順にMyWord、statusなどを処理するため、先に成功したMyWordが共通cursorを進めると、後続statusは本来自分が読むべき更新を取得できない。account切替時にも前ユーザーのcursorを再利用し得る。

## 対象範囲

- sync checkpointのdomain/application port
- SharedPreferences adapterとkey migration
- 全同期UseCaseのcheckpoint read/write
- `lib/features/sync/sync_service.dart`
- account切替、dataset部分失敗のtest

## データモデル

最低限、次のキーを持たせる。

```text
SyncCheckpointKey(accountId, dataset)
SyncCheckpoint(lastSuccessfulAt, optionalRemoteCursor)
```

`dataset`は文字列を散在させず、安定したenumまたはvalue objectにする。将来cursorが日時以外になる可能性を考慮する。

## 実装方針

1. 現在同期対象となるdataset一覧と安定したIDを定義する。
2. checkpoint portへ`accountId`と`dataset`を必須引数として追加する。
3. SharedPreferences keyをversion付きnamespaceにする。
4. 旧単一keyは安全側へ移行する。datasetへ複製すると欠落する可能性があるため、原則として各datasetをfull syncまたは十分古い時刻から再同期する。
5. datasetが完全成功した場合だけ、そのdatasetのcheckpointをcommitする。
6. 失敗datasetのcheckpointは変更しない。
7. sign-out時に削除するかaccount別に保持するかを明文化する。別accountへの流用は禁止する。

## 必須テスト

- MyWord成功後もstatusが自身の旧checkpointから取得する
- dataset A成功、dataset B失敗でAだけ進む
- 同じdatasetでもaccount AとBのcheckpointが分離される
- 旧単一keyからの移行で更新を取りこぼさない
- retry時に失敗datasetが同じ範囲を再取得する
- process killをcheckpoint commit前後で模擬する

## 完了条件

- [x] checkpoint keyにaccountIdとdatasetが含まれる
- [x] dataset完全成功前にcheckpointを進めない
- [x] 部分失敗とaccount切替のtestが通る
- [x] 旧keyの安全な移行方針が実装・記録されている
- [x] 同期処理に単一global cursorへの参照が残っていない

## 実装済みの運用方針

- 旧単一keyは新しいdatasetへ複製せず、初回のscoped checkpointアクセス時に削除する。各datasetはcheckpointなしとしてsentinelからfull syncする。
- checkpointはaccount別に保持し、sign-outでは削除しない。別accountは異なるkeyを使用するため流用されない。
- 全件同期開始時刻をcommit候補にし、dataset内のremote取得、各項目反映、local uploadがすべて成功した後だけ保存する。
- 単件のlocal/remote更新イベントは全件pull checkpointを進めない。
- checkpointと同時刻の更新を再取得するため、差分境界は`>=`とする。重複処理より取りこぼし防止を優先する。

## LLMへの引き継ぎ事項

日時精度やclock skewも確認する。cursor比較が`>`か`>=`か、同時刻更新をどう扱うかをtestで固定する。Phase 2-6までは戻り値の全面再設計を避けてもよいが、checkpoint更新判断はdataset結果に基づかせる。
