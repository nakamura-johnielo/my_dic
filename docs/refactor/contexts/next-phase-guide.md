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

作業対象の中心:

- `features/esp_jpn_word_status`
- `features/jpn_esp_word_status`
- `core/infrastructure/datasource/*word_status*`
- `core/infrastructure/database/firebase/daos/*word_status*`

注意:

- 現Repositoryはlocalとremoteを直接持つため、業務row更新 + outbox enqueueを同一Drift transactionに移す。
- `FieldUpdate`契約は維持する。
- 旧`sync_esp_jpn_word_status_interactor.dart`と旧`SyncService`は、新handlerへ移植してから削除する。

## Local-first 6: MyWord / MyWordStatus

先に読む文書:

- [feature-map.md](feature-map.md)
- [phase-scaffolding.md](phase-scaffolding.md)
- [runtime-and-status.md](runtime-and-status.md)

作業対象の中心:

- `features/my_word/data/repository_impl/**`
- `features/my_word/data/data_source/local/**`
- `features/my_word/data/data_source/remote/**`

注意:

- 現Repositoryにはremote直書き、`legacy_unowned`、未実装local sync streamが残る。
- 親dataset `my_words`、子dataset `my_word_status`の順序を`DatasetPlan`で固定する。
- `copy.dart`系と大型modalはproduction切替後のPhase 3で整理する。

## Local-first 7: User Profile

先に読む文書:

- [feature-map.md](feature-map.md)
- [core-map.md](core-map.md)
- [runtime-and-status.md](runtime-and-status.md)

作業対象の中心:

- `features/user/data/repository_impl/user_repository.dart`
- `core/application/auth_lifecycle/**`

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
- 未対応: legacy同期usecase（`sync_esp_jpn_word_status_interactor.dart`、`sync_myword_status_usecase.dart`、`sync_my_word_interactor copy.dart`）は`IAuthRepository`依存のまま。`AppAuth`の命名整理、guest data統合も未対応。

## Phase 1-5/1-6: ownership整理

先に読む文書:

- [feature-map.md](feature-map.md)
- [core-map.md](core-map.md)
- [app-routing.md](app-routing.md)
- [`plans/phase1.5-define-catalog-ownership.plan.md`](plans/phase1.5-define-catalog-ownership.plan.md)

状態:

- Phase 1-5 slice 1（完了）: 活用検索結果item（旧`features/quiz/domain/entity/quiz_searched_item.dart`）をcatalog概念として`core/domain/entity/verb/conjugacion/conjugacion_search_result_item.dart`へ移設。Search domainがQuiz entityを返す問題と、core repository/converterがQuiz entityへ依存する`core_no_feature`違反3件、`feature:quiz`<->`feature:search`の双方向importを解消済み。`tool/import_boundaries/baseline.json`も実態に合わせて更新済み。
- 未対応（次スライス）: WordPageがQuiz/Searchの`di`層へ直接依存している3箇所（`conjugacion_fragment.dart`→search query参照、`dictionary_fragment.dart`→`quizWordProvider`書き込み、`word_page_fragment.dart`→`quizGameViewModelProvider`初期化）。いずれもUIの実際の埋め込み・状態共有であり、route contractまたはapp-level portの新規設計判断が必要。
- 未対応: `quiz_search_fragment.dart`が`search`の`CardView`を再利用している。`CardView`自体が`esp_jpn_word_status`のstatus button widgetへ依存しているため、design systemへ移す前にPhase 1-6のstatus button ownership整理が先に必要（試行して`core_no_feature`違反が新たに発生することを確認済み。移動は見送った）。
- `esp_jpn_word_status/components/status_button`に和西/MyWord adapterがある状態を整理する（Phase 1-6）。
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

- `app/bootstrap/sync_composition.dart`、`features/sync/application/**`、`features/sync/infrastructure/**`、`core/infrastructure/database/drift/tables/sync/**`は未接続でもLocal-first 5〜7用の足場。削除しない。
- `core/application/auth_lifecycle/**`はCurrentSession導入前の正本。削除しない。
- `router/**`は旧だが現役。`app/routing/**`へ移し切るまでは削除しない。
- `sync_service.dart`と旧sync usecaseは現役。新SyncEngineへdatasetを切り替えるまでは削除しない。
- `copy.dart`、コメントアウトCoordinator、typo file、未使用Presenterは削除候補だが、Phase 3で挙動固定後に扱う。