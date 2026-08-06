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

## Phase 1-4: CurrentSession

先に読む文書:

- [runtime-and-status.md](runtime-and-status.md)
- [core-map.md](core-map.md)
- [feature-map.md](feature-map.md)

注意:

- 入力源は`authLifecycleProvider`。
- `AuthStoreNotifier`、`AppUserStoreNotifier`、Router redirect、auto sync start conditionをCurrentSessionから派生させる。
- 未認証を空IDの`AppAuth`で表さない。

## Phase 1-5/1-6: ownership整理

先に読む文書:

- [feature-map.md](feature-map.md)
- [core-map.md](core-map.md)
- [app-routing.md](app-routing.md)

注意:

- Search/Quiz/Ranking/WordPageのcatalog read model所有者を決める。
- `esp_jpn_word_status/components/status_button`に和西/MyWord adapterがある状態を整理する。
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