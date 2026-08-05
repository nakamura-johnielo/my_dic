# Local-first 1: 同期contractとSource of Truthを固定する

- 状態: 未着手
- 優先度: P0 / 設計基盤
- 依存タスク: Phase 0完了
- 関連タスク: [`2-build-drift-sync-schema.md`](2-build-drift-sync-schema.md)、[`../phase1/2-enforce-import-boundaries.md`](../phase1/2-enforce-import-boundaries.md)

## 目的

Drift、Firebase、SyncEngine、feature Repositoryの責務を一意にし、datasetごとに異なる同期処理が同じ配送保証とaccount分離を満たすようにする。

## 固定する境界

- 同期対象業務データのread/writeはDriftだけを通す。
- 通常Repositoryはlocal portだけを実装し、remoteメソッドを公開しない。
- remote replica portはsync/application側に置き、Firebase adapterは各featureのinfrastructureで実装する。
- `app/bootstrap`だけがSyncEngine、Queue、dataset handler、schedulerを組み立てる。
- Firebase Authはidentityのsource of truth、Security Rules/backendは認可の最終authorityとする。

## 初期dataset

安定したIDを次の順で定義する。

1. `esp_jpn_word_status`
2. `jpn_esp_word_status`
3. `my_words`
4. `my_word_status`
5. `user_profile`

静的辞書データと端末固有設定はremote同期datasetへ含めない。

## 競合規則

- Word statusは変更fieldだけを送るpatchとし、別fieldの同時編集はmergeする。
- Word statusの同一field競合はserverが最後に受理したmutationを優先する。
- MyWord本文は`baseRemoteRevision`で競合を検出し、未送信local版を優先して新revisionとして再送する。
- User Profileの編集可能fieldはfield単位patchとする。
- deleteはhard deleteせずtombstoneを同期し、古いupdateで復活させない。

## 配送・cursor規則

- at-least-once deliveryを前提とし、`mutationId`とremote `lastMutationId`で重複を無害化する。
- remote documentは最低限`revision`、server `updatedAt`、`lastMutationId`、`deletedAt`、`schemaVersion`を持つ。
- pull cursorはserver `updatedAt`とdocument IDの複合値とし、clientの`DateTime.now()`を進捗根拠にしない。
- 同一timestamp、再取得、順不同を許容し、Drift反映を冪等にする。

## 必須テスト設計

- 同じmutationの複数回配送で最終状態が変わらない
- 別accountのrow、queue、cursorが混在しない
- remote failure後もlocal操作結果がDriftに残る
- listener取りこぼし後も次回pullで収束する
- status、MyWord、Profileが規定の競合方針へ収束する

## 完了条件

- [ ] SoTと例外が文書・型・import規則で一意である
- [ ] dataset ID、依存順、競合、削除、cursor方針が決定済みである
- [ ] 通常Repositoryとremote replicaの境界が決定済みである
- [ ] server acknowledgmentの定義がFirebase local cache受付と区別されている
- [ ] 後続タスクが追加判断なしで実装できる

## LLMへの引き継ぎ事項

同期共通型をfeature循環回避のため無条件に`core`へ置かない。SyncEngineが所有する契約は`features/sync`へ置き、feature固有DTOとmerge規則は所有featureへ残す。

