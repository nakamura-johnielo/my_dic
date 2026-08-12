# MyWord feature リファクタ計画

## Summary

`my_word` を Catalog と同じ境界設計へ移行する。MyWord と MyWordStatus は同一 feature が所有する別 write aggregate とし、schema・Firebase wire・sync・画面挙動を変えずに、公開契約と内部実装を分離する。

対象は `lib/features/my_word/**`、直接利用する app bootstrap／routing／guest migration、関連テスト、境界チェッカー、公開 surface 文書とする。

## Ownership と公開 API

- MyWord が CRUD、validation、account scope、revision／tombstone／outbox、MyWordStatus、card projection、dataset mapping、guest migration capability、presentation を所有する。
- Sync は retry、queue、checkpoint、cancellation、schedulingを、app は session、cross-feature transaction、routing、runtime lifetime を所有する。
- MyWord presentation から WordStatus の共通 UI を使う場合は `word_status/port/presentation_entry.dart` のみに依存し、逆依存を作らない。
- 唯一の business facade として `features/my_word/port/my_word.dart` を追加し、以下だけを明示 export する。
  - `RegisterMyWordCommand`、`UpdateMyWordCommand`、`DeleteMyWordCommand`
  - `UpdateMyWordStatusCommand` と共有 `FieldUpdate`
  - `LoadMyWordsQuery`、`WatchMyWordItemQuery`
  - `MyWordCommandPort`、`MyWordStatusCommandPort`、`MyWordReaderPort`
  - pure Dart の `MyWord`、`MyWordStatus`、`MyWordItem`
  - MyWord 所有の typed error と共有 `Result<T>`
  - `MyWordGuestMigrationPort`、`MyWordGuestRowCounts`
- reader は `loadIds(LoadMyWordsQuery)` と `watchItem(WatchMyWordItemQuery)` に絞る。単体未存在は `success(null)`、collection 未存在は空 success、stream error は `Stream<Result<MyWordItem?>>` として正規化する。
- validation／not-found／conflict／storage failure は MyWord 所有 error に正規化し、現行のcode、message、UI表示を維持する。
- `composition.dart` と `presentation_entry.dart` は facade から export しない technical seam とする。
  - `MyWordPorts` は reader、commands、statusCommands、guestMigrationを束ねる。
  - `createMyWordPorts(MyWordDependencyReader)` は pure Dart signature とし、Riverpod、Drift、Firebase、`DatabaseProvider`、Provider型を公開しない。
  - Sync用の2つの `DatasetSyncHandler` factory は現行契約を維持する。
  - presentation entry は `SessionScopeKey` と `MyWordPorts` を受け取る controlled widget とする。

## Implementation Changes

1. Characterization

   - CRUD、validation境界、ページoffset／ordering、account分離、UTC化を固定する。
   - status default／partial update、projectionのmissing-status補完、revision／tombstone／outbox、sync mappingを固定する。
   - guest migrationのcount、collision、pair保持、idempotency、rollbackを固定する。
   - 初回load、retry、重複排除、account切替、effect consume-onceを固定する。

2. Pure port導入

   - `command.dart`、`query.dart`、`result.dart` を port-local型へ置換し、internal re-exportを廃止する。
   - internal entityの `word/contents/editAt` と公開DTOの `headword/description/updatedAt` は owner mapper で変換する。
   - 現在の use case interface／input data は移行中のみ compatibility adapter として残す。

3. Application／infrastructure接続

   - focused port実装から既存 repository／DAO を呼び出し、DB例外やstream例外をMyWord errorへ変換する。
   - `IMyWordItemQueryRepository`、domain entity、DAO、Drift row、Firebase DTO、UI modelはinternalに閉じる。
   - MyWord Firebase infrastructureから `UserDTO.collectionName` への依存を除き、値を変えずに中立なFirestore runtime設定から親collection pathを受け取る。
   - schema、collection／field名、sync stable ID、payload、field mask、同期順序は変更しない。

4. Guest migration capability化

   - countとMyWord／MyWordStatus移行、collision判定、pair保持、outbox enqueueを `MyWordGuestMigrationPort` 実装へ移す。
   - app workflowは同じ `DatabaseProvider` 上で全feature capabilityを一つのtransaction内から呼び、MyWordのfailure時はtransactionをabortする。
   - session fence、共通migration ID、cross-feature順序はappに残す。
   - appからMyWord local data sourceへの直接依存を削除する。

5. Composition／presentation移行

   - owner factoryでDAO、repository、application port、guest migration、sync adapterを構築する。
   - Riverpod providerはapp bootstrapまたは `internal/presentation/provider/**` に限定する。
   - viewはproviderをconstructor／内部scopeから受け、`internal/composition/**` をimportしない。
   - routerはapp-owned providerからscopeと`MyWordPorts`を解決してcontrolled entryへ注入する。
   - 現在検出されている4件のpresentation→composition依存を解消する。

6. Consumer切替とcleanup

   - business consumerを `port/my_word.dart`、technical consumerを該当technical seamへ切り替える。
   - production、test、generated codeの参照0を確認後、旧internal export、provider alias、`I*UseCase`、input data、未使用watch use caseを削除する。
   - 最後に必要なpath renameとDrift codegenを行い、生成SQLと型の差分を審査する。
   - MyWord sole-facade規則とpositive／negative fixtureを両境界チェッカーへ追加し、ADR／public-surface文書を更新する。

## Test Plan and Acceptance

- Public contract: facade単一import、DTO validation、typed error、absence semantics、framework／internal型の非公開。
- Application: CRUD、status、paging、watch、projection、account scope、UTC、not-found／storage failure。
- Infrastructure／Sync: schema、wire、revision、tombstone、outbox、ack、remote apply、dataset順序。
- Guest migration: count、成功、retry、collision、pair保持、session change、transaction rollback。
- Presentation: fake `MyWordPorts` による初回load、pagination retry、stale response破棄、effect一回処理、dispose後通知なし。
- 検証順は focused tests → targeted `dart analyze` → 両boundary checker → full `flutter test` とする。
- 完了時はMyWord由来のchecker違反が0、外部からのinternal／deep port importが0、business portのframework importが0、一時shimが0であること。非MyWordの既存違反は別のremaining-workとして扱う。

## Assumptions

- 構造リファクタを優先し、ページングの`hasMore`追加や`size + 1`取得は行わない。
- ID／account scopeは既存の`String`表現を維持し、新しいUUID value objectは導入しない。
- validation code／message、route、画面仕様、`hasNote`挙動、schema、Firebase wire、sync protocolを変更しない。
- MyWordStatusのWordStatus featureへの移動、Catalogとのdomain統合、他featureの境界違反修正は対象外とする。
