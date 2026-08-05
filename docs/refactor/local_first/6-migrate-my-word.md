# Local-first 6: MyWordとMyWordStatusを移行する

- 状態: 未着手
- 優先度: P0 / user content
- 依存タスク: [`5-migrate-word-status.md`](5-migrate-word-status.md)
- 関連タスク: [`8-cut-over-and-remove-legacy-sync.md`](8-cut-over-and-remove-legacy-sync.md)、[`../phase2/1-move-usecases-to-application.md`](../phase2/1-move-usecases-to-application.md)

## 目的

MyWordの作成・更新・削除とMyWordStatusをlocal-only commandへ変更し、親子関係、offline delete、本文競合を失わずFirebaseへ同期する。

## 移行順

1. MyWord query/watchをDrift-only契約として固定する。
2. MyWord create/updateを業務row＋outboxのtransactionへ変更する。
3. MyWord deleteをtombstone＋outboxへ変更する。
4. MyWord handlerをproductionへ切り替える。
5. MyWordStatusを同じaccount scopeと親IDで移行する。
6. MyWordStatus handlerをMyWord成功後に実行する依存datasetとして登録する。

## 競合・削除規則

- client生成UUIDを安定したentity IDとして維持する。
- mutationは`baseRemoteRevision`を持ち、remote revision不一致を検出する。
- 本文競合ではpending local版を優先し、新しいremote revisionとして再送する。
- delete tombstoneは古いremote updateより優先する。
- tombstoneは全必要replicaへの反映とretention期間完了まで物理削除しない。
- parent MyWordがremoteに存在しない状態でMyWordStatusを送らない。

## Repository分割

- app-facing MyWord RepositoryはDrift query/commandだけを公開する。
- Firebase DTOとCRUDはsync専用remote replicaへ移す。
- SyncEngine以外からremote replicaをresolveできないDI構造にする。
- local command successはDrift transaction成功を意味し、remote delivery状態はSyncReport/Queueから別途公開する。

## 必須テスト

- offline create/update/delete後の再接続でremoteへ収束する
- create中の再編集を古いackが消さない
- delete後に古いremote updateで復活しない
- MyWord失敗時にMyWordStatusがskipされる
- remote failureがlocal command failureとして誤表示されない
- local DB failureではoutboxだけが残らない
- account A/BとguestのMyWordが混在しない
- hard deleteなしで他端末へ削除が伝播する

## 完了条件

- [ ] MyWord/MyWordStatusの通常Repositoryがlocal-onlyである
- [ ] create/update/deleteがtransactional outboxを利用する
- [ ] MyWordStatusが親dataset依存を守る
- [ ] hard delete差分欠落がtombstoneで解消される
- [ ] 旧MyWord sync UseCaseがproduction registryから外れている

## LLMへの引き継ぎ事項

既存の`sync_my_word_interactor copy.dart`を新設計へ統合しない。新handlerのcontract testが通った後、Local-first 8で旧実装とともに削除する。

