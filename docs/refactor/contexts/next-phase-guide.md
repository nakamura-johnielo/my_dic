# Next Phase Guide

最終更新: 2026-08-06

この文書は、分割されたcontextを使って次フェーズの作業対象を判断するためのガイドである。

## Generated sources

`lib/__generated/**`はbuild outputであり、責務の正本ではない。

| generated area | 内容 |
| --- | --- |
| `__generated/core/infrastructure/database/drift/database_provider.g.dart` | Drift database generated code |
| `__generated/core/infrastructure/database/drift/daos/**.g.dart` | Drift DAO generated code |
| `__generated/features/my_word/data/data_source/local/**.g.dart` | MyWord Drift DAO generated code |
| `__generated/features/ranking/data/data_source/local/ranking_dao.g.dart` | Ranking Drift DAO generated code |
| `__generated/core/shared/utils/result.freezed.dart` | `Result<T>` freezed generated code |

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
- 旧`SyncEspJpnWordStatusInteractor`は`features/sync/di.dart`の`syncServiceProvider`から除去し、実行経路から外れた後、セッション3でクラスファイル自体・専用interface（`ISyncEspJpnWordStatusUseCase`）・`syncEspJpnWordStatusUseCaseProvider`・`result_propagation_test.dart`内の直接参照をすべて削除した。これに伴い`IWordStatusRepository`/`IJpnEspWordStatusRepository`（Jpn-Esp側も対称的に）から`updateRemoteWordStatus`/`updateBatchRemoteWordStatus`/`getRemoteWordStatusAfter`/`getRemoteWordStatusById`/`watchRemoteChangedIds`を削除し、`WordStatusRepository`/`JpnEspWordStatusRepository`はFirebase操作を一切持たないローカル専用Repositoryになった（`DatasetSyncHandler`はもともとRepositoryではなくdatasourceを直接注入されているため影響を受けない）。`UpdateStatusInteractor`/`UpdateJpnEspStatusInteractor`も直接remote pushを行わなくなり、配送はoutbox+handlerへ一本化した。
- `features/esp_jpn_word_status`・`features/jpn_esp_word_status`が`features/sync/application/**`へ依存する一方、旧`features/sync/di.dart -> features/esp_jpn_word_status/di/di.dart`の逆方向importが消えたため、Stage 1で追加した`no_feature_cycle`違反3件は解消し`baseline.json`から除去済み。
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
- 旧`SyncMyWordInteractor`（`sync_my_word_interactor copy.dart`）・`SyncMyWordStatusUsecase`は`features/sync/di.dart`の`syncServiceProvider`から除去し、実行経路から外れた（`syncServiceProvider`は空配列。クラスファイルと対応するdi provider定義、`test/unit/features/sync/`内の直接参照は削除していない）。
- `features/my_word`が`features/sync/application/**`へ依存する一方、旧`features/sync/di.dart -> features/my_word/di/usecase_di.dart`の逆方向importが消えたため、`no_feature_cycle`違反2件は解消し`baseline.json`から除去済み。
- 新規test: `test/unit/features/my_word/my_word_outbox_enqueue_test.dart`（create/update/delete outbox enqueue）、`my_word_sync_handler_test.dart`（push/pull/tombstone契約）、`my_word_status_outbox_enqueue_test.dart`、`my_word_status_sync_handler_test.dart`。

未対応（次フェーズ、詳細は[`plans/local_first.6-migrate-my-word.plan.md`](plans/local_first.6-migrate-my-word.plan.md)参照）:

- read側account scoping（`legacy_unowned`固定）はword status Stage 2と同じ理由でLocal-first 7以降へ引き続き先送り。
- account切替（session epoch）を跨いだMyWord/MyWordStatus handler単体のend-to-end testは未実装。
- `baseRemoteRevision`を使った明示的な本文競合検出（現状はfield mask patchのmerge writeのみ）。
- 旧`SyncMyWordInteractor`/`SyncMyWordStatusUsecase`クラスファイル自体の削除はLocal-first 8へ引き継ぎ。

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

状態（Stage 1〜3完了、Stage 4はブロッカーありで未着手: 2026-08-06）:

- `UserProfiles` Drift table（Local-first 2でschema追加済み、JSON payload blob）に対する`UserProfileDao`（`@DriftAccessor`）、`IUserProfileLocalDataSource`、`UserProfileDriftDataSource`を新規追加した。
- `UserRepository.updateUser`が、署名ユーザーの場合に`username`フィールドをDrift transaction内でJSON payloadへmergeし（`local_revision`を+1）、同一transactionでfield mask付きoutbox mutation（`dataset: userProfile`、`operation: upsert`、`fieldMask: ['username']`）を`OutboxWriter`へenqueueするようになった。
- `UserProfileSyncHandler`を実装し、`syncDatasetHandlerRegistryProvider`へ登録済み。push（field mask付きFirestore merge write、`patchUser`。local key`username`→Firestore field`userName`のmappingはremote DAO内に閉じる）とpull（1 account=1 entityのため、`getUserById`単発呼び出しの`updatedAt`をcheckpoint cursorと比較し、pending fieldがあればskip）の両方が動く。`updateUser`の旧remote直接呼び出しは削除し、配送はoutbox+handlerへ一本化した。
- `UserRepository.ensureUserProfile`を変更し、初回ensure時のみremote baselineをDriftへ種付け（`applyRemoteFields`、`local_revision`は変えない）、2回目以降はDriftの`username`を優先して返すようにした。ただし`AppSession`/UIをDriftのlive streamへ接続するアーキテクチャ変更（`AppSessionReady.profile`は現状どこからも参照されていないため）は行っていない。
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
- Router redirect、`autoSyncProvider`、`profile.dart`、user向けmutation usecase 9件（esp_jpn/jpn_esp status update、my_word register/update/delete/status update、user get/create/update）は`CurrentSession`/`appSessionProvider`経由に切り替え済み。
- `InMemorySessionFence`へのepoch配線（account切替のたびにepochを進める）を`lib/app/bootstrap/session_composition.dart`に追加済み。production `SyncEngine` triggerは未接続のまま（Local-first 5-7待ち）。
- 未対応: legacy同期usecase（`sync_myword_status_usecase.dart`、`sync_my_word_interactor copy.dart`）は`IAuthRepository`依存のまま（`sync_esp_jpn_word_status_interactor.dart`はLocal-first 5セッション3で完全削除済み）。`AppAuth`の命名整理、guest data統合も未対応。

## Phase 1-5/1-6: ownership整理

先に読む文書:

- [feature-map.md](feature-map.md)
- [core-map.md](core-map.md)
- [app-routing.md](app-routing.md)
- [`plans/phase1.5-define-catalog-ownership.plan.md`](plans/phase1.5-define-catalog-ownership.plan.md)

状態:

- Phase 1-5 slice 1（完了）: 活用検索結果item（旧`features/quiz/domain/entity/quiz_searched_item.dart`）をcatalog概念として`core/domain/entity/verb/conjugacion/conjugacion_search_result_item.dart`へ移設。Search domainがQuiz entityを返す問題と、core repository/converterがQuiz entityへ依存する`core_no_feature`違反3件、`feature:quiz`<->`feature:search`の双方向importを解消済み。`tool/import_boundaries/baseline.json`も実態に合わせて更新済み。
- 未対応（次スライス）: WordPageがQuiz/Searchの`di`層へ直接依存している3箇所（`conjugacion_fragment.dart`→search query参照、`dictionary_fragment.dart`→`quizWordProvider`書き込み、`word_page_fragment.dart`→`quizGameViewModelProvider`初期化）。いずれもUIの実際の埋め込み・状態共有であり、route contractまたはapp-level portの新規設計判断が必要。
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
