# Local-first 5: Word status migration

状態: 完了（Stage 1〜5すべて完了。Stage 2はセッション4で縮小方針を撤回し、read/write両方の実accountId row-level scopingとguestスコープの正式化を完全実装した。ガイド統合フロー〔Local-first 7 Stage 4〕はスコープ外のまま）
作成日: 2026-08-06
最終更新: 2026-08-06（セッション4）

## Stage 2完全実装（2026-08-06 セッション4）

「Stage2を一部ではなく完璧な状態にリファクタしてください」という依頼を受け、セッション2の縮小スコープ決定を再検討した。調査の結果、次のことが判明したため、read側account scopingを完全実装することにした。

- Firebase remoteは元々`users/{accountId}/...`パスでaccount単位に分離されている。account混在のリスクは**ローカルDriftのみ**に存在した（write・read双方が`legacy_unowned`固定だったため、同一端末で複数accountがサインインすると同じrowを共有してしまう実データ分離バグがあった）。
- 影響範囲はesp_jpn_word_status/jpn_esp_word_status feature内に閉じており、`my_word`/`ranking`/`user`は独立したDAO・テーブルであるため一切変更不要だった。
- presentation層（status button widget）はRiverpod DIプロバイダ経由でusecaseを取得しており、`ref.watch(currentSessionProvider)`をdi.dart側でusecaseに注入するだけでUIコード自体は無変更のまま最新accountへ追従できた（`updateStatusUseCaseProvider`が既に同じパターンを使用済みだったため踏襲）。

### 実装内容

- `lib/core/shared/consts/account_scope.dart`（新規）: `guestAccountScope`定数（値は既存の`'legacy_unowned'`を継続利用）。ローカルrow scope専用であり、Firebaseへは一切送らない。guestスコープを正式なfallbackとして位置づけ、guest→account自動移行は行わない（Local-first 7の設計方針を維持）。
- `EspJpnWordStatusDao`/`JpnEspWordStatusDao`: `watchWordStatus`、`watchChangedWordIdsWithFilter`、`applyStatusPatch`、`getStatusById`、`getWordStatusAfter`、`exist`、`applyRemoteFields`すべてに`accountId`引数を追加し、`tbl.accountId.equals(legacyOwner)`固定を撤廃。`legacyOwner`定数は`guestAccountScope`のエイリアスとして維持（後方互換）。
- `ILocalWordStatusDataSource`/`ILocalJpnEspWordStatusDataSource`とDrift実装: 同様に`accountId`引数を追加。
- `IWordStatusRepository`/`IJpnEspWordStatusRepository`: 読み取り系（`watchWordStatusById`、`getWordStatusById`、`getLocalWordStatusAfter`、`getLocalWordStatusById`、`watchLocalChangedIds`）に`required String accountId`を追加。`updateLocalWordStatus`のシグネチャ（`required String? accountId`、nullableのまま）は変更せず、実装内部で`accountId ?? guestAccountScope`をDAO呼び出し用scopeとして解決するようにした（outbox enqueueの可否判定は従来どおり`accountId != null`のまま）。
- `FetchEspJpnWordStatusInteractor`/`WatchEspJpnWordStatusInteractor`/`WatchJpnEspWordStatusInteractor`: `CurrentSession`をコンストラクタ注入し、`accountIdOrNull ?? guestAccountScope`をrepository呼び出しのscopeとして解決するようにした。`UpdateStatusInteractor`/`UpdateJpnEspStatusInteractor`は無変更（既にrepositoryへnullable accountIdを渡す設計だったため）。
- `esp_jpn_word_status/di/di.dart`・`jpn_esp_word_status/di/di.dart`: `fetchEspJpnWordStatusUsecaseProvider`/`watchEspJpnWordStatusUsecaseProvider`/`watchJpnEspWordStatusUsecaseProvider`へ`ref.watch(currentSessionProvider)`を注入。sign-in/sign-out時にproviderが再構築され、UIが自動的に現在のaccountスコープへ切り替わる。
- `EspJpnWordStatusSyncHandler`/`JpnEspWordStatusSyncHandler`のpullループ: `_local.applyRemoteFields(...)`へ`accountId: context.accountId`を渡すよう変更（syncは常に署名済みaccountに対して実行されるため、pull結果は正しいaccountのローカルrowへ反映される）。

### 新規/更新テスト

- `test/unit/features/word_status/status_account_scope_test.dart`（新規）: Esp-Jpn/Jpn-Esp両方向で、(1) 2つの署名済みaccountが同一wordIdでも互いのrowを上書き・参照しないこと、(2) guest書き込み（`accountId: null`）が`guestAccountScope`へ隔離され、実accountからは見えないこと、(3) `FetchEspJpnWordStatusInteractor`/`WatchEspJpnWordStatusInteractor`/`WatchJpnEspWordStatusInteractor`が`CurrentSession`からguest/signed-inのscopeを正しく解決してrepositoryへ渡すこと、を検証。
- `test/unit/features/word_status/word_status_sync_handler_test.dart`: DAO直接呼び出しのfixture（`seed`/`read`/`exists`）に、テスト用固定accountId（`account-a`）を渡すよう更新（挙動は既存のまま、シグネチャ追従のみ）。
- `status_outbox_enqueue_test.dart`/`status_update_contract_test.dart`/`update_status_interactor_test.dart`は、いずれもrepository経由（`updateLocalWordStatus`）またはmock repositoryのみを使用しており、シグネチャ変更が読み取り専用メソッドに限定されていたため無変更で成功。

### 検証

```powershell
flutter test test/unit/features/word_status/ test/unit/core/domain/usecase/update_status_interactor_test.dart   # 39件全て成功
flutter test test/unit/features/sync/                                                                          # 36件全て成功
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check              # exit code 0、既存baseline違反のみ
flutter analyze <変更ディレクトリ>                                                                              # 既存の指摘5件のみ（本セッションの変更と無関係）
```

### 意図的にスコープ外のまま残したもの

- **guestからaccountへのtransactional移管フロー**（sign-in時にguestスコープのrowをaccountスコープへ承認付きで移すUI/UseCase）は、[`../../local_first/7-migrate-user-profile.md`](../../local_first/7-migrate-user-profile.md)のStage 4（guest統合）に明示的に残す。理由: (1) 5 dataset横断の設計判断であり本タスク単体を超える、(2) 実データの不可逆に近い移行操作でありUI承認フロー設計とセットで慎重に行うべき、という従来の判断は変わらない。今回実装したのは「読み取りが正しいaccountだけを見る」ことのみであり、「guestのデータを後からaccountへ引き継ぐ」ことではない。
- `my_word`/`ranking`/`user profile`のread側account scoping（同じ`legacy_unowned`固定パターン）は今回変更していない。word status feature内で完結する変更であり、他datasetへの波及は本タスクのスコープ外（Local-first 6/7側で同様のパターンを適用するかは各タスクの判断に委ねる）。
- account切替（session epoch）を跨いだsync handlerのend-to-end testは引き続き未実装（Stage 3〜5実施結果の既知の未対応事項のまま）。

## Stage 2スコープ決定（2026-08-06 セッション2、セッション4で撤回）

> 以下はセッション2時点の判断記録であり、セッション4で「read側scopingをword status feature内に閉じて完全実装する」方針に更新された。経緯の参考として残す。

「リファクタ全ステージを完了させる」依頼を受け、着手前に実装範囲を再調査した結果、Stage 2（実rowレベルaccount scoping）を素朴に実装すると、書き込み系だけでなく`EspJpnWordStatusDao`/`JpnEspWordStatusDao`の**読み取り系**（`watchWordStatusById`、`getWordStatusById`、`getLocalWordStatusAfter`等）も含めて全メソッドが`legacy_unowned`固定であることが判明した。読み取り系までaccount scopeを通すと、UI側の`FetchEspJpnStatusInteractor`/`WatchEspJpnWordStatusInteractor`/`WatchJpnEspWordStatusInteractor`経由でpresentation層（status button widget群）まで配線が必要になり、これは[`../../local_first/7-migrate-user-profile.md`](../../local_first/7-migrate-user-profile.md)が明示的に「guest統合はsign-inだけで自動化せず、Ready後の明示的フローで扱う」と定めている領域と重なる。

ユーザーとの協議の結果、**Stage 2は縮小し、Stage 1の状態（outbox enqueueのみaccountId認識、read側は`legacy_unowned`固定のまま）を維持したまま、Stage 3〜5を実装する**方針を採用した。read側account scopingとguest統合フローはLocal-first 6/7の範囲として明示的にスコープ外へ残す。

理由:
- `my_word`/`ranking`は独立Driftテーブルであり、word statusだけread側account scopingを先行させても技術的なデータ破損リスクは低い（以前のcontextsが懸念していたほど深刻ではないと判明）。ただしread側配線がpresentation層まで広がる点は変わらず、Local-first 5単体のレビュー容易性を著しく下げる。
- 元task文書（[`../../local_first/5-migrate-word-status.md`](../../local_first/5-migrate-word-status.md)）の必須テスト「direction、account、guest scopeを跨いでrowが混在しない」は、esp_jpn/jpn_esp間で別テーブルである時点で満たされており、単一account前提のままでもStage 3のhandler実装・contract test自体は成立する。

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
| Stage 1（完了: 2026-08-06） | local status行更新とfield mask付きoutbox mutationを同一Drift transactionで書き込む（署名ユーザーのみ、既存remote pushは並行して残す） | 2 |
| Stage 2（縮小スコープで現状維持を選択: 2026-08-06セッション2） | 実rowレベルaccount scopingへの移行とguest scope設計は、read側がpresentation層まで配線が広がりLocal-first 6/7の担当領域と重なるため見送り。Stage 1の状態（書き込み時のみaccountId認識）を維持する | 8完了条件「direction/account/guest scopeを跨いでrowが混在しない」は別途評価（下記参照） |
| Stage 3（完了: 2026-08-06セッション2） | Esp-Jpn/Jpn-Esp共通の`DatasetSyncHandler`実装（push: leasePending→field mask付きFirestore patch→ack、pull: checkpoint cursor→server差分取得→field単位merge→Drift反映+checkpoint更新を同一transaction） | 4, 5, 6 |
| Stage 4（完了: 2026-08-06セッション2） | `syncDatasetHandlerRegistryProvider`へ両handlerを登録し、旧`SyncEspJpnWordStatusInteractor`/旧status向けremote pushを`SyncService`から外す | 7 |
| Stage 5（完了: 2026-08-06セッション2） | `applicationLifecycleEffectsProvider`から`syncSchedulerProvider.foreground(...)`を実際に呼ぶforeground trigger配線 | （タスク文書に明記はないが本番切替に必須） |

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

## Stage 3〜5 実施結果（2026-08-06 セッション2）

### 対象パス（追加分）

- `lib/features/sync/application/port/sync_queue.dart`（`peekPending`追加）
- `lib/features/sync/infrastructure/persistence/drift/drift_sync_queue.dart`（`peekPending`実装）
- `test/helpers/sync/fake_sync_queue.dart`（`peekPending`実装）
- `lib/core/infrastructure/datasource/word_status/i_remote_word_status_data_source.dart`・`firebase_word_status_data_source.dart`、jpn_esp側も同様（`patchWordStatus`追加）
- `lib/core/infrastructure/database/firebase/daos/firebase_word_status_dao.dart`・`jpn_esp/firebase_jpn_esp_word_status_dao.dart`（`patch`メソッド追加：fieldMaskのみをmerge writeし、新規docのみ`createdAt`も書く）
- `lib/core/infrastructure/datasource/word_status/i_local_word_status_data_source.dart`・`drift_word_status_data_source.dart`、jpn_esp側も同様（`applyRemoteFields`追加）
- `lib/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_status_dao.dart`・`jpn_esp/jpn_esp_word_status_dao.dart`（`applyRemoteFields`追加：local_revisionを変更せず、outboxにも触れない）
- `lib/features/esp_jpn_word_status/data/sync/esp_jpn_word_status_sync_handler.dart`（新規）
- `lib/features/jpn_esp_word_status/data/sync/jpn_esp_word_status_sync_handler.dart`（新規）
- `lib/features/esp_jpn_word_status/di/di.dart`・`lib/features/jpn_esp_word_status/di/di.dart`（handler provider追加）
- `lib/app/bootstrap/sync_composition.dart`（`syncDatasetHandlerRegistryProvider`へ両handler登録）
- `lib/features/sync/di.dart`（`syncEspJpnWordStatusUseCaseProvider`を`syncServiceProvider`から除去）
- `lib/features/esp_jpn_word_status/domain/usecase/update_status/update_status_interactor.dart`・`lib/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/update_jpn_esp_status_interactor.dart`（直接remote push呼び出しを削除。配送はoutbox+handlerへ一本化）
- `lib/features/sync/application/in_memory_session_fence.dart`（`epochFor`追加）
- `lib/app/bootstrap/lifecycle_effects.dart`（`AppSessionReady`遷移時とapp resume時に`syncSchedulerProvider.foreground(...)`を呼ぶtrigger追加）
- `test/unit/core/domain/usecase/update_status_interactor_test.dart`（legacy remote pushを検証していた2testを「呼ばれないことを検証するtest」へ置き換え）
- `test/unit/features/word_status/word_status_sync_handler_test.dart`（新規、両direction共通のhandler contract test）
- `tool/import_boundaries/baseline.json`（Stage 1で追加した`no_feature_cycle`違反3件のうち、`features/sync/di.dart -> features/esp_jpn_word_status/di/di.dart`の逆方向importが消えたことで解消された3件を除去）

### 設計判断の要点

- **push**: `SyncQueue.leasePending`でリースしたmutationごとに、remoteの既存doc有無（`getWordStatusById`）を見て`isNew`を決め、`patchWordStatus`でfieldMaskのfieldだけをFirestore `set(..., merge: true)`する。成功したら`ack`。失敗は`SyncErrorClassifier`で分類し、`deadLetter`分類のみdead-letterへ、それ以外（retry/pauseとも）は`retry`へ回す（pauseとretryを同一扱いにする簡略化は次回改善余地としてメモ）。
- **pull**: `SyncCheckpointStore`のcursorから`getWordStatusAfter`で差分取得し、`SyncQueue.peekPending`でこの時点の未ack mutationのfieldMaskを集計。取得した各remote itemについて、pending mutationが存在するfieldは書き込みをskipし（`applyRemoteFields`の該当引数へ`null`を渡す）、それ以外のfieldのみ反映する。反映とcheckpoint書き込みは`ILocalWordStatusDataSource.runInTransaction`で同一Drift transactionにまとめる。
- **checkpoint**: 新しい`SyncCheckpointStore`（`sync_checkpoints`テーブル）を使う。旧`ISyncStatusRepository`（`sync_status`系）とは別物であり、干渉しない。
- **remote applyがoutboxを生成しない**: `applyRemoteFields`はDAOの直接呼び出しであり、`OutboxWriter`を一切経由しない。
- **旧remote push撤去**: `UpdateStatusInteractor`/`UpdateJpnEspStatusInteractor`からの直接`updateRemoteWordStatus`呼び出しを削除。配送はoutbox+`DatasetSyncHandler`のみに一本化した。`WordStatusRepository`/`JpnEspWordStatusRepository`クラス自体は`updateRemoteWordStatus`等のFirebase操作メソッドを引き続き実装している（旧`SyncEspJpnWordStatusInteractor`が依然として参照するため）。
- **旧sync usecaseの扱い**: `SyncEspJpnWordStatusInteractor`は`features/sync/di.dart`の`syncServiceProvider`から除去し、実行経路からは完全に外れた。ただしクラスファイル・`esp_jpn_word_status/di/di.dart`内の`syncEspJpnWordStatusUseCaseProvider`定義・`test/unit/features/sync/result_propagation_test.dart`の直接参照は削除していない（削除すると無関係なテストファイルの構造まで変更する必要があり、本セッションのスコープを超えるため）。次回、これらを完全削除してよい。
- **foreground trigger**: `InMemorySessionFence`に`epochFor(accountId)`を追加し、`lifecycle_effects.dart`で`appSessionProvider`が`AppSessionReady`になった時とアプリresume時に`syncSchedulerProvider.foreground(SyncContext(...))`を呼ぶ。例外はログのみで握りつぶし、UIをブロックしない。

### 検証

```powershell
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check
flutter test test/unit/features/word_status/
flutter test test/unit/core/domain/usecase/update_status_interactor_test.dart
flutter test test/unit/features/sync/
```

- import境界チェック: 0件（baseline更新後、`no_feature_cycle`の`esp_jpn_word_status<->sync`・`sync->esp_jpn_word_status`3件が自然解消したことを確認し、baselineから除去済み。`esp_jpn_word_status<->jpn_esp_word_status`の既存2件は無関係の別問題として残置）。
- `flutter test test/unit`: 全体では2ファイルが読み込み時compile errorで失敗（`test/unit/features/my_word/domain/usecase/load_my_word_interactor_test.dart`、`test/unit/features/ranking/domain/usecase/load_rankings_interactor_test.dart`）。原因は`test/helpers/fake_my_word_repository.dart`が`IMyWordRepository`の現行シグネチャ（`getById(String)`、`registerWord`の戻り値型等）と食い違っていることで、**本セッションの変更とは無関係の既存不具合**（`lib/features/my_word/**`・当該helperファイルは一切変更していない）。指摘のみ残し、修正はスコープ外。
- 対象範囲の`flutter test`（word_status/sync/update_status_interactor_test）は合計82件すべて成功。新規`word_status_sync_handler_test.dart`10件を含む。

### 未対応（次回セッションへの引き継ぎ）

- Stage 2（read側account scoping、guest統合）は引き続き未着手。Local-first 6/7で横断的に扱うことを推奨（本ファイル冒頭の「Stage 2スコープ決定」参照）。
- `WordStatusRepository`/`JpnEspWordStatusRepository`からFirebase操作メソッド自体を完全に除去するには、`SyncEspJpnWordStatusInteractor`とその関連di/testの削除が先に必要。
- pushのretry backoff計算が`attempt=1`固定の簡略実装（`MutationLease`が現在のattempt countを公開していないため）。将来的に`SyncQueue`が現attempt countを返すようにするか、handler側でretry回数を追跡する改善余地がある。
- pauseエラー分類（認証切れ等）を現在retryと同一に扱っている。長時間の無駄なretryを避けるには、pause専用のバックオフや一時停止ロジックを追加するとよい。
- account切替（session epoch）を跨いだhandler単体のend-to-end testは未実装（`SyncEngine`側のfenceテストはLocal-first 4で既存）。
- 発見した無関係の既存不具合（`test/helpers/fake_my_word_repository.dart`と`IMyWordRepository`の不整合によるcompile error）は別タスクとして起票を推奨。

## 完了条件（本タスク全体）

- [x] statusのread/writeがDriftだけを通る（通常usecaseの書き込みパスからは達成。`UpdateStatusInteractor`/`UpdateJpnEspStatusInteractor`は直接remote pushを行わなくなり、配送はoutbox+`DatasetSyncHandler`のみが担う）
- [x] 通常status RepositoryにFirebase操作がない（セッション3で完全達成。旧`SyncEspJpnWordStatusInteractor`と専用interface`ISyncEspJpnWordStatusUseCase`を削除し、`syncEspJpnWordStatusUseCaseProvider`と関連import（`features/esp_jpn_word_status/di/di.dart`）を除去した。`IWordStatusRepository`/`IJpnEspWordStatusRepository`から`updateRemoteWordStatus`/`updateBatchRemoteWordStatus`/`getRemoteWordStatusAfter`/`getRemoteWordStatusById`/`watchRemoteChangedIds`をすべて削除し、`WordStatusRepository`/`JpnEspWordStatusRepository`から`_remote`フィールドとコンストラクタ引数、対応する実装メソッドを削除した。両datasetの`DatasetSyncHandler`はもともとRepositoryではなくdatasource（`ILocalWordStatusDataSource`/`IRemoteWordStatusDataSource`等）を直接注入されていたため、Repository変更の影響を受けない。テスト側は`test/unit/features/word_status/status_outbox_enqueue_test.dart`・`status_update_contract_test.dart`のRepositoryコンストラクタ呼び出しからmock remote datasource引数を削除し、`test/unit/core/domain/usecase/update_status_interactor_test.dart`の`verifyNever(repository.updateRemoteWordStatus(...))`を削除し、`test/unit/features/sync/result_propagation_test.dart`から旧interactorに依存していた1テストと`_MockWordStatusRepository`を削除した）
- [x] 両directionが同一のoutbox enqueue契約を持つ（Stage 1で対応）
- [x] 両directionがSyncEngineへ登録されている（Stage 4で対応。`syncDatasetHandlerRegistryProvider`に`EspJpnWordStatusSyncHandler`/`JpnEspWordStatusSyncHandler`を登録済み）
- [x] 旧status listenerと旧sync UseCaseがdataset registryから外れている（完全達成。`SyncEspJpnWordStatusInteractor`クラス自体、di provider定義、テスト直接参照も削除済み）
- [x] read/writeともに実accountId row-level scopingが効いている（セッション4で完全達成。DAO・datasource・repository・Fetch/Watch usecase・sync handlerのpullがすべて`accountId`を明示的に受け取るようになり、`legacy_unowned`は「guest専用scope」として`guestAccountScope`定数に明文化された。2アカウントの同一wordIdが互いのrowを上書き・参照しないこと、guest書き込みが実accountから隔離されることを`status_account_scope_test.dart`で検証済み）
- [ ] failure、retry、conflict、account切替testが通る（`test/unit/features/word_status/word_status_sync_handler_test.dart`でretry/dead-letter/pull/field-level merge-skipは検証済み。account切替（session epoch）specificなhandler testと、真の「同一fieldがserver受付順で収束する」複数端末シナリオのend-to-end testは未実装）

## セッション3実施結果（2026-08-06）

旧`SyncEspJpnWordStatusInteractor`削除の影響範囲を調査した結果、この旧interactorが唯一の実運用参照元であり、`WordStatusRepository`/`JpnEspWordStatusRepository`のremote系メソッド（`updateRemoteWordStatus`等）はJpn-Esp側も含めてすべて未使用のdead codeであることを確認した（`EspJpnWordStatusSyncHandler`/`JpnEspWordStatusSyncHandler`はRepositoryではなくdatasourceを直接注入されているため無関係）。このため、Esp-JpnとJpn-Esp両方のRepository/interfaceから対称的にFirebase操作を削除した。

検証:

```powershell
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check   # exit code 0、既存baseline違反のみ
flutter test test/unit/features/word_status/ test/unit/core/domain/usecase/update_status_interactor_test.dart test/unit/features/sync/   # 68件全て成功
flutter analyze（変更ディレクトリのみ）   # 既存の指摘4件のみ（unused_import、file_names、curly_braces、いずれも本セッションの変更と無関係の既存コード）
```

未対応（次回セッションへの引き継ぎ、変更なし）:

- account切替（session epoch）を跨いだhandler単体のend-to-end testは未実装。
- pushのretry backoff計算が`attempt=1`固定の簡略実装。
- pauseエラー分類をretryと同一に扱っている。
