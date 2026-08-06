# Local-first 5: Word status migration

状態: 進行中（Stage 1完了）
作成日: 2026-08-06
最終更新: 2026-08-06

## 目的

[`../../local_first/5-migrate-word-status.md`](../../local_first/5-migrate-word-status.md)を実装可能な段階へ分割する。Esp-Jpn/Jpn-Esp両directionのstatus更新をDriftのみへ書き込み、outbox経由でFirebaseへ非同期配送する最初の縦切りdatasetを完成させる。

依存タスク（すべて完了確認済み: 2026-08-06）:
- [`../../local_first/4-build-sync-engine.md`](../../local_first/4-build-sync-engine.md) — 完了
- [`../../phase0/5-fix-status-update-contract.md`](../../phase0/5-fix-status-update-contract.md) — 完了
- [`../../phase1/1-create-composition-root.md`](../../phase1/1-create-composition-root.md) — `app/bootstrap`が入口として機能済み
- [`../../phase1/2-enforce-import-boundaries.md`](../../phase1/2-enforce-import-boundaries.md) — `tool/import_boundaries`導入済み
- [`../../phase1/4-introduce-current-session.md`](../../phase1/4-introduce-current-session.md) — `CurrentSession`/`appSessionProvider`導入済み（コア実装済み）

## 実装スコープ全体像（段階分割）

タスク文書の「実装方針」8項目は1セッションで安全に実装するには大きすぎるため、次の段階に分ける。

| 段階 | 内容 | 対応する実装方針項目 |
| --- | --- | --- |
| Stage 1（本セッションで実装） | local status行更新とfield mask付きoutbox mutationを同一Drift transactionで書き込む（署名ユーザーのみ、既存remote pushは並行して残す） | 2 |
| Stage 2（未着手） | 実rowレベルaccount scopingへの移行（`legacy_unowned`固定から`accountId`実値への移行）とguest scope設計 | 8完了条件「direction/account/guest scopeを跨いでrowが混在しない」 |
| Stage 3（未着手） | Esp-Jpn/Jpn-Esp共通の`DatasetSyncHandler`実装（push: leasePending→field mask付きFirestore patch→ack、pull: checkpoint cursor→server差分取得→field単位merge→Drift反映+checkpoint更新を同一transaction） | 4, 5, 6 |
| Stage 4（未着手） | `syncDatasetHandlerRegistryProvider`へ両handlerを登録し、旧`SyncEspJpnWordStatusInteractor`/旧status向けremote pushを`SyncService`から外す | 7 |
| Stage 5（未着手） | `applicationLifecycleEffectsProvider`から`syncSchedulerProvider.foreground(...)`を実際に呼ぶforeground trigger配線 | （タスク文書に明記はないが本番切替に必須） |

## Stage 1 詳細（本セッションの実装スコープ）

### 対象パス

- `lib/core/infrastructure/datasource/word_status/i_local_word_status_data_source.dart`
- `lib/core/infrastructure/datasource/word_status/drift_word_status_data_source.dart`
- `lib/core/infrastructure/datasource/jpn_esp_word_status/i_local_jpn_esp_word_status_data_source.dart`
- `lib/core/infrastructure/datasource/jpn_esp_word_status/jpn_esp_drift_word_status_data_source.dart`
- `lib/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_status_dao.dart`
- `lib/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_word_status_dao.dart`
- `lib/features/esp_jpn_word_status/domain/i_word_status_repository.dart`
- `lib/features/jpn_esp_word_status/domain/i_jpn_esp_word_status_repository.dart`
- `lib/features/esp_jpn_word_status/data/wordstatus_repository.dart`
- `lib/features/jpn_esp_word_status/data/jpn_esp_word_status_repository.dart`
- `lib/features/esp_jpn_word_status/domain/usecase/update_status/update_status_interactor.dart`
- `lib/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/update_jpn_esp_status_interactor.dart`
- `lib/features/esp_jpn_word_status/di/di.dart`
- `lib/features/jpn_esp_word_status/di/di.dart`
- 関連test

### スコープ外（Stage 1では触らない）

- `legacy_unowned`固定のaccount scopingを実accountIdへ変更すること（my_word/rankingも同じ定数を使っており、単一datasetだけ先行変更すると一貫性が崩れる。Stage 2で横断的に扱う）
- 旧remote push（`updateRemoteWordStatus`呼び出し）の削除・変更
- `SyncEspJpnWordStatusInteractor`、旧`SyncService`登録の変更
- `DatasetSyncHandler`実装、registry登録
- `applicationLifecycleEffectsProvider`のtrigger配線

### 実装方針

1. `ILocalWordStatusDataSource`/`ILocalJpnEspWordStatusDataSource`に`Future<T> runInTransaction<T>(Future<T> Function() action)`を追加し、Drift実装は`DatabaseAccessor.transaction()`へ委譲する。
2. 両DAOの`applyStatusPatch`で`local_revision`を書き込み時に+1する（新規行は1から開始）。
3. `IWordStatusRepository.updateLocalWordStatus`/`IJpnEspWordStatusRepository.updateLocalWordStatus`に`required String? accountId`を追加する（`null`はguestを意味し、outbox enqueueをskipする）。
4. Repository実装に`OutboxWriter`と`Uuid`を注入し、`runInTransaction`内でDAO更新とoutbox enqueueを実行する。`fieldMask`/`payload`は`FieldUpdate.set`されたfieldのみ含める。`entityId`は`wordId.toString()`、`dataset`は`SyncDataset.espJpnWordStatus`/`jpnEspWordStatus`、`localRevision`はDAOが返した更新後の値を使う。
5. 各usecase（`UpdateStatusInteractor`/`UpdateJpnEspStatusInteractor`）で`_currentSession.accountIdOrNull`をlocal更新呼び出し前に解決し、`accountId`として渡す。既存の「ログインユーザーのみremote push」ロジックはそのまま残す。
6. DIで`driftOutboxWriterProvider`（`app/bootstrap/sync_composition.dart`）をRepositoryへ注入する。

### 検証

```powershell
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check
flutter test test/unit/features/word_status/
flutter test test/unit/core/domain/usecase/update_status_interactor_test.dart
flutter test test/unit/features/sync/
```

### contexts更新方針

- Stage 1完了後、[`../next-phase-guide.md`](../next-phase-guide.md)のLocal-first 5節へ「outbox enqueueは書き込み時のみ実装済み、handler未実装のためoutboxは蓄積されるだけで消費されない」旨を追記する。（対応済み）
- [`../current.md`](../current.md)は全体結論が変わる場合のみ更新する（Stage 1単独では大きな結論変更ではないため見送り可）。
- Stage 2以降の設計判断（account scoping migration方式、guest scope方針）は本ファイルへ追記して次回セッションが参照できるようにする。

### Stage 1 実施結果（2026-08-06）

- 変更ファイル: 本節冒頭の対象パス一覧どおり。加えて`tool/import_boundaries/baseline.json`に`no_feature_cycle`違反3件を追加（`esp_jpn_word_status`/`jpn_esp_word_status`が`features/sync/application/**`のport/model型に依存するようになったため。逆方向の`features/sync/di.dart -> features/esp_jpn_word_status/di/di.dart`importと合わさってcycle扱いになる。Stage 4で旧sync usecase登録を`features/sync/di.dart`から外せば自然に解消する）。
- 新規test: `test/unit/features/word_status/status_outbox_enqueue_test.dart`（両directionで、署名ユーザーの単一field変更が正しいfield mask/payload/localRevisionでoutboxへ1件だけ積まれること、guest/remote-origin適用ではenqueueされないこと、複数回連続編集がcoalesceしてlocal_revisionが進むこと、unchangedコマンドがno-opであることを検証）。
- 検証結果: `dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check`は0件（baseline更新後）。`flutter test`は`test/unit/features/word_status/`、`test/unit/core/domain/usecase/update_status_interactor_test.dart`、`test/unit/features/sync/`で計59件すべて成功。
- 未対応（次回セッションへの引き継ぎ）: Stage 2〜5は未着手のまま。特にStage 2の「account scoping migration方式」は、`my_word`/`ranking`も同じ`legacy_unowned`定数を使っているため、word statusだけを先行させると一貫性が崩れる。次回はまずaccount scoping migrationの設計（既存`legacy_unowned` rowをsign-in時にどう扱うか）を横断的に決めることを推奨する。

## 完了条件（本タスク全体、Stage 1では一部のみ満たす）

- [ ] statusのread/writeがDriftだけを通る（Stage 1では変更なし、既存のまま）
- [ ] 通常status RepositoryにFirebase操作がない（Stage 1では未達、Stage 3/4で対応）
- [x] 両directionが同一のoutbox enqueue契約を持つ（Stage 1で対応）
- [ ] 両directionがSyncEngineへ登録されている（Stage 4で対応）
- [ ] 旧status listenerと旧sync UseCaseがdataset registryから外れている（Stage 4で対応）
- [ ] failure、retry、conflict、account切替testが通る（Stage 3/4で対応）
