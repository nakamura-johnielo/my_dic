# Next Phase Guide

最終更新: 2026-08-07

この文書は、分割されたcontextを使って次フェーズの作業対象を判断するためのガイドである。

## Local-first 8 handoff: Stage 5 complete

Stages 2–4 are complete. Stage 4 removed legacy remote listener/writer APIs,
moved the Esp-Jpn and Jpn-Esp status remote adapters to feature-owned
`data/sync/remote` boundaries, and confined Firestore SDK conversion to DTO
mappers. Status pagination is inclusive on `(updatedAt, documentId)`, with
focused boundary and handler tests covering the tie-break and continued pull.

Stage 5 Release A removes `lastSync_wordStatus` and `sync_checkpoint.v1.*`
during bootstrap. It never reads or copies legacy cursors, writes its marker
only after cleanup succeeds, and treats cleanup failure as non-fatal so it can
retry at a later bootstrap.

Stage 5 Release B removed the legacy SharedPreferences sync-status checkpoint
adapter/type/provider chain and its dedicated test. Release A cleanup remains
for supported upgrades. The user explicitly authorized this progression before
the original rollout gate; this does not claim a supported Release A shipped
or that telemetry/acceptance was collected. The Release B acceptance scan has
no `SharedPreferencesSyncStatus`, `ISyncStatus`, `SyncStatusRepository`, or
`SyncCheckpointKey` references in `lib` or `test`; remaining old-key literals
are confined to the Release A cleanup implementation and its bootstrap tests.
Stage 6 completed the zero import-boundary baseline; Stage 7 owns the full
five-dataset upgrade integration proof. Firebase SDK imports are now limited
to auth data, bootstrap, and feature `data/sync/remote` adapters. Core
Firebase sources and the legacy MyWord/User remote paths were moved or
removed. The boundary check, `flutter analyze`, and the targeted
sync/word-status/MyWord/User/app unit suite (161 tests) passed. FlutterFire
must generate the ignored options file at
`lib/app/bootstrap/firebase_options.dart`.

## Generated sources

`lib/__generated/**`はbuild outputであり、責務の正本ではない。

| generated area | 内容 |
| --- | --- |
| `__generated/core/infrastructure/database/drift/database_provider.g.dart` | Drift database generated code |
| `__generated/core/infrastructure/database/drift/daos/**.g.dart` | Drift DAO generated code |
| `__generated/features/my_word/data/data_source/local/**.g.dart` | MyWord Drift DAO generated code |
| `__generated/features/ranking/data/data_source/local/ranking_dao.g.dart` | Ranking Drift DAO generated code |
| `__generated/core/shared/utils/result.freezed.dart` | `Result<T>` freezed generated code |

## Phase 2-5 query-projection handoff (complete)

The new query contracts are intentionally feature-owned: Search and Ranking
own their screen projection ports and Drift adapters, and WordPage owns
`LoadWordDetailQuery` plus sealed detail view data. Search, Ranking, Quiz, and
WordPage now consume the typed query contracts, legacy read paths are removed,
and repository-wide `flutter analyze` passes. Preserve the established
WordPage contract: dictionary errors are primary failures, empty dictionaries
are empty query states, conjugation errors are optional issues, and status
remains a live `word_status` projection rather than a detail snapshot.

Phase 3 follow-up is deliberately separate from the completed ownership
migration: SQL query-count and query-plan work, Search FTS/index evaluation,
performance measurement, and rename/copy-file cleanup. These changes must not
reintroduce UI framework imports into the application query models or status/
ranking snapshots into WordPage detail data.

## Local-first 5: word status

先に読む文書:

- [runtime-and-status.md](runtime-and-status.md)
- [phase-scaffolding.md](phase-scaffolding.md)
- [feature-map.md](feature-map.md)
- [core-map.md](core-map.md)
- [`plans/local_first.5-migrate-word-status.plan.md`](plans/local_first.5-migrate-word-status.plan.md)

作業対象の中心:

- `features/esp_jpn_word_status`
- `features/jpn_esp_word_status`
- `core/infrastructure/datasource/*word_status*`
- `core/infrastructure/database/firebase/daos/*word_status*`

状態（Stage 1〜5すべて完了、read側account scopingも完全実装: 2026-08-06）:

- `WordStatusRepository`/`JpnEspWordStatusRepository`の`updateLocalWordStatus`が、業務row更新とfield mask付きoutbox mutation enqueueを同一Drift transactionで実行するようになった（署名ユーザーのみ、`accountId`が`null`のguestとremote-origin適用ではenqueueしない）。
- 両DAOの`local_revision`列を書き込み時に+1するようにした。
- `EspJpnWordStatusSyncHandler`/`JpnEspWordStatusSyncHandler`を実装し、`syncDatasetHandlerRegistryProvider`へ登録済み。push（field mask付きFirestore patch）とpull（checkpoint差分取得→pending mutationとのfield単位merge→Drift反映+checkpoint更新を同一transaction）の両方が動く。`applicationLifecycleEffectsProvider`から`AppSessionReady`遷移時とapp resume時に`syncSchedulerProvider.foreground(...)`を呼ぶforeground triggerも配線済み。
- 旧`SyncEspJpnWordStatusInteractor`は先行セッションでクラスファイル自体・専用interface（`ISyncEspJpnWordStatusUseCase`）・`syncEspJpnWordStatusUseCaseProvider`・`result_propagation_test.dart`内の直接参照ごと削除済み。Local-first 8 Stage 2では残っていたlegacy sync DI全体も削除した。これに伴い`IWordStatusRepository`/`IJpnEspWordStatusRepository`（Jpn-Esp側も対称的に）から`updateRemoteWordStatus`/`updateBatchRemoteWordStatus`/`getRemoteWordStatusAfter`/`getRemoteWordStatusById`/`watchRemoteChangedIds`を削除し、`WordStatusRepository`/`JpnEspWordStatusRepository`はFirebase操作を一切持たないローカル専用Repositoryになった（`DatasetSyncHandler`はもともとRepositoryではなくdatasourceを直接注入されているため影響を受けない）。`UpdateStatusInteractor`/`UpdateJpnEspStatusInteractor`も直接remote pushを行わなくなり、配送はoutbox+handlerへ一本化した。
- `features/esp_jpn_word_status`・`features/jpn_esp_word_status`が`features/sync/application/**`へ依存する一方、旧legacy sync DIの逆方向importは削除済みである。Stage 1で追加した`no_feature_cycle`違反3件は解消し`baseline.json`から除去済み。
- セッション4でStage 2（read側account scoping）を完全実装: `EspJpnWordStatusDao`/`JpnEspWordStatusDao`の全メソッド（read/write）が`accountId`引数を受け取るようになり、`legacy_unowned`固定を撤廃した。`lib/core/shared/consts/account_scope.dart`の`guestAccountScope`定数（値は従来どおり`'legacy_unowned'`）をguest専用scopeとして正式化し、guest→account自動移行は行わない設計を維持。`Fetch/WatchEspJpnWordStatusInteractor`・`WatchJpnEspWordStatusInteractor`が`CurrentSession`からscopeを解決し、DIで`ref.watch(currentSessionProvider)`を注入。sync handlerのpullも`context.accountId`を local `applyRemoteFields`へ渡すよう変更。新規test`status_account_scope_test.dart`で2アカウント間のrow分離とguest隔離、interactorのscope解決を検証。
- guestからaccountへのtransactional移管UI/UseCase（guest統合フロー本体）はLocal-first 7 Stage 4に明示的に残置。read側scopingが前提としていた課題は本セッションでword status分について解消した。
- 発見した無関係の既存不具合: `test/helpers/fake_my_word_repository.dart`が現行`IMyWordRepository`と食い違っており、`test/unit/features/my_word/domain/usecase/load_my_word_interactor_test.dart`と`test/unit/features/ranking/domain/usecase/load_rankings_interactor_test.dart`がcompile errorで読み込み失敗する。Local-first 5とは無関係で未修正のまま。

注意:

- `FieldUpdate`契約は維持する。
- pushのretry backoffが`attempt=1`固定の簡略実装、pauseエラーをretryと同一扱いにしている点は既知の簡略化（詳細はplanファイル参照）。
- 未対応（次スライス、詳細は[`plans/local_first.5-migrate-word-status.plan.md`](plans/local_first.5-migrate-word-status.plan.md)参照）: account切替（session epoch）を跨いだhandler単体end-to-end test。guest→accountのtransactional移管はLocal-first 7 Stage 4。`my_word`/`ranking`/`user profile`のread側account scopingは各タスクの判断に委ねる（word status分は本セッションで解消済み）。

## Local-first 6: MyWord / MyWordStatus

先に読む文書:

- [feature-map.md](feature-map.md)
- [phase-scaffolding.md](phase-scaffolding.md)
- [runtime-and-status.md](runtime-and-status.md)
- [`plans/local_first.6-migrate-my-word.plan.md`](plans/local_first.6-migrate-my-word.plan.md)

作業対象の中心:

- `features/my_word/data/repository_impl/**`
- `features/my_word/data/data_source/local/**`
- `features/my_word/data/data_source/remote/**`

状態（Stage 1〜5完了: 2026-08-06）:

- `MyWordRepository.registerWord`/`updateWord`/`deleteWord`が、`my_words`業務row更新（create/update/tombstone delete）とfield mask付きoutbox mutation enqueue（`upsert`/`patch`/`delete`）を同一Drift transactionで実行するようになった（署名ユーザーのみ。`OutboxWriter`/`Uuid`を注入済み）。直接remote呼び出しはすべて削除し、配送はoutbox+`MyWordSyncHandler`のみが担う。
- `MyWordDao`に`insertMyWordWithRevision`/`updateMyWordWithRevision`/`tombstoneMyWord`/`applyRemoteFields`を追加。`local_revision`は書き込み時に+1、削除は`deleted_at`を立てる論理削除（子`my_word_status`行はhard delete）。`getMyWordById`等の読み取り系はすべて`deleted_at IS NULL`でtombstoneを除外する。
- `MyWordStatusRepository.updateStatus`も同様にDrift transaction＋outbox enqueue化済み（`MyWordStatusDao.applyStatusPatch`/`applyRemoteFields`を追加）。直接remote呼び出しは削除済み。
- `MyWordSyncHandler`/`MyWordStatusSyncHandler`を実装し、`syncDatasetHandlerRegistryProvider`へ登録済み。push（field mask付きFirestore merge write、`patchMyWord`/`patchStatus`）とpull（checkpoint差分取得→pending mutationとのfield単位merge→Drift反映+checkpoint更新を同一transaction）の両方が動く。remoteの`deletedAt`（tombstone）もpullで検出し、ローカルへ論理削除を伝播する。
- `DatasetPlan.localFirst`に`dependencies: {SyncDataset.myWordStatus: {SyncDataset.myWords}}`を追加し、MyWord失敗時はMyWordStatusが`skipped`になるよう`SyncEngine`の既存依存解決ロジックへ接続した。
- Local-first 8 Stage 2で旧`SyncMyWordInteractor`（`sync_my_word_interactor copy.dart`）・`SyncMyWordStatusUsecase`、対応DI provider、`SyncService`、`ISyncUseCase`、`test/unit/features/sync/`内の直接参照を削除した。lifecycleの`autoSyncProvider`参照も撤去済みである。
- `features/my_word`が`features/sync/application/**`へ依存する一方、旧`features/sync/di.dart -> features/my_word/di/usecase_di.dart`の逆方向importが消えたため、`no_feature_cycle`違反2件は解消し`baseline.json`から除去済み。
- 新規test: `test/unit/features/my_word/my_word_outbox_enqueue_test.dart`（create/update/delete outbox enqueue）、`my_word_sync_handler_test.dart`（push/pull/tombstone契約）、`my_word_status_outbox_enqueue_test.dart`、`my_word_status_sync_handler_test.dart`。

未対応（次フェーズ、詳細は[`plans/local_first.6-migrate-my-word.plan.md`](plans/local_first.6-migrate-my-word.plan.md)参照）:

- read側account scoping（`legacy_unowned`固定）はword status Stage 2と同じ理由でLocal-first 7以降へ引き続き先送り。
- account切替（session epoch）を跨いだMyWord/MyWordStatus handler単体のend-to-end testは未実装。
- `baseRemoteRevision`を使った明示的な本文競合検出（現状はfield mask patchのmerge writeのみ）。
- Stage 5 is complete: Release A bootstrap cleanup still removes
  `lastSync_wordStatus` and `sync_checkpoint.v1.*` without reading or copying
  legacy cursors; Release B removed the legacy SharedPreferences sync-status
  checkpoint chain. The user authorized the early progression, so this does
  not claim shipment or telemetry/acceptance evidence. Stage 6 completed the
  zero import baseline; Stage 7 owns the full five-dataset upgrade integration
  proof.

注意:

- `copy.dart`系と大型modalはproduction切替後のPhase 3で整理する。

## Local-first 7: User Profile

先に読む文書:

- [feature-map.md](feature-map.md)
- [core-map.md](core-map.md)
- [runtime-and-status.md](runtime-and-status.md)
- [`plans/local_first.7-migrate-user-profile.plan.md`](plans/local_first.7-migrate-user-profile.plan.md)

作業対象の中心:

- `features/user/data/repository_impl/user_repository.dart`
- `features/user/data/data_source/local/*user_profile*`（新規）
- `core/application/auth_lifecycle/**`

状態（Local-first 7の既存Stage 1〜3に加え、Local-first 8 Stages 3–4でapp-facing repository local-only化、`UserProfileProvisioner`分離、status remote adapter cleanupを実施。Stage 5 Release Bも完了。Release A cleanupはsupported upgrade用に残り、この早期進行はユーザー承認済みだがship/telemetry/acceptance evidenceは主張しない: 2026-08-07）:

- `UserProfiles` Drift table（Local-first 2でschema追加済み、JSON payload blob）に対する`UserProfileDao`（`@DriftAccessor`）、`IUserProfileLocalDataSource`、`UserProfileDriftDataSource`を新規追加した。
- `UserRepository.updateUser`が、署名ユーザーの場合に`username`フィールドをDrift transaction内でJSON payloadへmergeし（`local_revision`を+1）、同一transactionでfield mask付きoutbox mutation（`dataset: userProfile`、`operation: upsert`、`fieldMask: ['username']`）を`OutboxWriter`へenqueueするようになった。
- `UserProfileSyncHandler`を実装し、`syncDatasetHandlerRegistryProvider`へ登録済み。push（field mask付きFirestore merge write、`patchUser`。local key`username`→Firestore field`userName`のmappingはremote DAO内に閉じる）とpull（1 account=1 entityのため、`getUserById`単発呼び出しの`updatedAt`をcheckpoint cursorと比較し、pending fieldがあればskip）の両方が動く。`updateUser`の旧remote直接呼び出しは削除し、配送はoutbox+handlerへ一本化した。
- `UserProfileProvisioner`が初回profile provisioningを担当し、`UserRepository`はapp-facingのlocal-only contractを維持する。既存のDrift profileの`username`優先動作は維持する。
- `email`/`subscriptionStatus`/`deviceId`はoutbox payloadに含めていない。`accountId`が`null`/emptyの場合は既存の`UnauthorizedError`のまま失敗し、enqueueされない。
- 新規test: `test/unit/features/user/user_profile_outbox_enqueue_test.dart`、`user_profile_sync_handler_test.dart`（push/retry/pull/pending field skipを検証）。既存`user_repository_ensure_profile_test.dart`にDrift username優先のtestを追加。

未対応（次段階、詳細は[`plans/local_first.7-migrate-user-profile.plan.md`](plans/local_first.7-migrate-user-profile.plan.md)参照）:

- Stage 4（guest統合）: 5 dataset（esp_jpn/jpn_esp word status、MyWord、MyWordStatus、User Profile）共通のread側account scoping（`legacy_unowned`固定）が前提として未実装のため着手不可と判断した。read側account scopingを別タスクとして先に実施することを推奨する。
- `AppSession`/UIをDrift profile watchのlive streamへ接続すること（現状は`ensureUserProfile`呼び出し時点のスナップショット読み取りのみ）。

注意:

- device IDのSharedPreferences local stateと、editable profileのDrift SoTを分けて扱う。
- role/subscription/entitlementのremote authorityはoutboxに入れない。

## Phase 1-4: CurrentSession（コア実装済み）

先に読む文書:

- [`phase1.4-introduce-current-session.plan.md`](plans/phase1.4-introduce-current-session.plan.md)

状態:

- `lib/app/session/`に`AppSession`（Router/UI向け派生状態）と`CurrentSession` port（accountId解決）を導入済み。
- Router redirect、`profile.dart`、user向けmutation usecase 9件（esp_jpn/jpn_esp status update、my_word register/update/delete/status update、user get/create/update）は`CurrentSession`/`appSessionProvider`経由に切り替え済み。`autoSyncProvider`はLocal-first 8 Stage 2で撤去済み。
- `InMemorySessionFence`へのepoch配線（account切替のたびにepochを進める）を`lib/app/bootstrap/session_composition.dart`に追加済み。production `SyncEngine` triggerは`AppSessionReady`遷移時とapp resume時に接続済みである。
- Local-first 8 Stage 2でlegacy同期usecase（`sync_myword_status_usecase.dart`、`sync_my_word_interactor copy.dart`）は削除済み。Stage 5 Release Bでlegacy SharedPreferences sync-status checkpoint chainも削除済み（Release A cleanupはsupported upgrade用に残る）。Stage 6のFirebase import allowlist / legacy-import baselineは0である。この早期進行はユーザー承認済みであり、ship/telemetry/acceptance evidenceは主張しない。`AppAuth`の命名整理、guest data統合（Local-first 7 Stage 4）、Stage 7の残件は各計画を参照。

## Phase 1-5/1-6: ownership整理

先に読む文書:

- [feature-map.md](feature-map.md)
- [core-map.md](core-map.md)
- [app-routing.md](app-routing.md)
- [`plans/phase1.5-define-catalog-ownership.plan.md`](plans/phase1.5-define-catalog-ownership.plan.md)

状態:

- Phase 1-5 slice 1（完了）: 活用検索結果item（旧`features/quiz/domain/entity/quiz_searched_item.dart`）をcatalog概念として`core/domain/entity/verb/conjugacion/conjugacion_search_result_item.dart`へ移設。Search domainがQuiz entityを返す問題と、core repository/converterがQuiz entityへ依存する`core_no_feature`違反3件、`feature:quiz`<->`feature:search`の双方向importを解消済み。`tool/import_boundaries/baseline.json`も実態に合わせて更新済み。
- 未対応（次スライス）: `conjugacion_fragment.dart`は依然としてSearch queryを直接参照し、WordPageのFABはQuiz route/card-stateへ結合している。辞書fragmentからの`quizWordProvider`書き込みとWordPageからの`quizGameViewModelProvider`直接初期化は削除済み。残る結合をroute contractまたはapp-level compositionへ寄せるには新規設計判断が必要。
- Phase 1-6 presentation slice（完了）: `CardView`を含むWordPage/Search/Quiz/Rankingのstatus UIは`features/word_status`へ移行済み。旧`esp_jpn_word_status/components/status_button/**`は削除した。
- 未対応（Phase 1-6次スライス）: `features/word_status/presentation/word_status_di.dart`が既存のEsp-Jpn/Jpn-Esp DIを参照する移行adapterである。entity/usecase/repository/datasource/sync handlerを一契約へ統合し、direction別adapterをinfrastructureへ閉じ込めるには、Phase 1-2のimport境界強制とapplication port設計が必要。
- coreへ型を逃がす前に、所有featureまたはapp-level contractを決める。


## Phase 2/3

先に読む文書:

- [core-map.md](core-map.md)
- [feature-map.md](feature-map.md)
- [app-routing.md](app-routing.md)

注意:

- `domain/**`からFlutter/Drift/Firebase/Riverpod/GoRouter importを消す。
- ViewModel stateをloading/data/empty/failureへ統一する。
- `build()`中のI/Oや副作用をbootstrap/effect providerへ寄せる。
- `copy.dart`、`new_`、typo、Presenter抽象、旧Coordinatorを挙動固定後に削除/renameする。

## 作業前後の推奨チェック

```powershell
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check
flutter analyze
flutter test
```

同期、DB migration、Auth lifecycleを触る場合は、全体testの前に対象unit/characterization testを先に走らせる。

## 削除してよいか迷った時の基準

- `app/bootstrap/sync_composition.dart`、`features/sync/application/**`、`features/sync/infrastructure/**`、`core/infrastructure/database/drift/tables/sync/**`は、word status（Local-first 5）向けには本番接続済み。MyWord/User Profile（Local-first 6〜7）向けにはまだ未接続の足場。削除しない。
- `core/application/auth_lifecycle/**`はCurrentSession導入前の正本。削除しない。
- `router/**`は旧だが現役。`app/routing/**`へ移し切るまでは削除しない。
- `sync_service.dart`と旧sync usecaseは現役。新SyncEngineへdatasetを切り替えるまでは削除しない。
- `copy.dart`、コメントアウトCoordinator、typo file、未使用Presenterは削除候補だが、Phase 3で挙動固定後に扱う。
