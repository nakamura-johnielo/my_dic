# Gate A 詳細 — strict concept 構造完了

## 1. 実装規律

Gate A の各 package は「公開 contractを置く → internal実装を接続する → callerを切り替える → 旧path/shimを削除する → 対象ruleを0にする」という縦スライスで行う。directory moveだけのPRや、callerを旧exportへ残したままの「移動済み」判定は作らない。

Gate B の behavior fix と同じファイルを触る場合も、原則として次の二つのchange setに分ける。

1. Gate A: owner/path/importだけを変更し、characterizationを維持
2. Gate B: final path上で挙動期待を追加して修正

ただし red reproduction と修正は分離しない。Gate A の移動中に偶然直った挙動を未試験のまま取り込まない。

## 2. A-DB — neutral runtime と owner persistence

### A-DB1. annotation と物理Tableをneutral化

対象:

- `lib/core/infrastructure/database/drift/database_provider.dart`
- `lib/features/my_word/data/data_source/local/my_words.dart`
- `lib/features/my_word/data/data_source/local/my_word_status.dart`
- `lib/features/ranking/data/data_source/local/rankings_entity.dart`
- 対応 generated files

手順:

1. P0 decision recordでDB案1が採用済みであることを確認する。
2. generated DAO getterがproduction/testから参照0であることを、型名ごとの `rg` と analyzerで再確認する。
3. `MyWords`、`MyWordStatus`、`Rankings` の物理Table宣言を current core `tables/` 配下へ移す。SQL table名、Dart table/DataClass/Companion名、column順、constraintは変えない。
4. `@DriftDatabase.daos` から feature DAO 5件を外す。core所有 `EsEnConjugacionDao` はA-DB3でQuizへ移すまで維持してよい。
5. codegenし、消えるDAO getter以外の table/DataClass/Companion名、17 accessor mixin、emitted SQLをbefore oracleと比較する。
6. fresh-native、asset-upgrade-native、fresh-web、existing-webの各baselineでP0 DB testを実行する。

完了条件:

- `database_provider.dart` の feature import 8件が0。
- schemaVersion、DB/IndexedDB名、起点別schema、migration/seed/wire差分0。
- feature DAOを `Dao(DatabaseProvider)` として直接構築できる。

stop:

- generated type rename、table SQL差分、asset既存fileの再作成が起きたらこのpackageをrollbackする。
- 起点別migration後のrow数/sentinel値、account・UUID対応、PK/FK relation、revision/deletedAt、outbox/checkpoint値がbefore oracleと一つでも違えば止める。
- 6517 seed row、asset hash、copy-once、ATTACH/DETACH後cleanup、二重実行、reopen、native/Web既存DB名のいずれかが崩れた場合も期待値を更新せず止める。

### A-DB2. core data DIからCatalog wiringを分離

対象:

- `lib/core/di/data/data_di.dart`
- `lib/features/catalog/port/composition.dart`（新規または拡張）
- `lib/features/catalog/internal/**/composition`（新規）
- `lib/app/bootstrap/catalog_composition.dart`

手順:

1. coreにはDB lifecycle/connection providerだけを残す。
2. Catalog DAO provider 10件をCatalog internal compositionへ移す。
3. Catalog public composition facadeはpure input/outputだけを公開し、Riverpod providerをexportしない。
4. app bootstrapはCatalog port factoryを利用し、Catalog internalを直接importしない。

完了条件:

- `core/di/data/data_di.dart` のfeature import 10件が0。
- A-DB対象の `core_no_feature` 18件が0。
- DB lifecycleがProviderContainerごとに一つという現行保証を維持。

### A-DB3. DAO registrationを外し、ownerへ引き渡す

- `EsEnConjugacionDao` は物理 `EsEnConjugacions` tableをcoreに残し、利用者である Quiz internal infrastructureへ移す。同時に `@DriftDatabase.daos` の残る登録も外す。
- `lib/core/di/data/data_di.dart` の `esEnConjugacionDaoProvider` も同change setでQuiz internal compositionへ移し、`lib/features/quiz/di/data_di.dart` のcallerを切り替える。A-DB2のCatalog provider分離完了後にA-DB3を行う。
- Catalogの現internal DAOと、MyWord/Ranking/WordStatus/UserProfileの現local Drift DAOがgenerated getterなしで `DatabaseProvider` から直接構築できる状態にする。A-DBは後者を一括移動せず、最終pathへの移動は各owner packageへexact file list付きで引き渡す。
- Syncのqueue/checkpoint/outboxとdataset adapterはA-DBの編集対象外とし、A-SYNCが `sync/internal/infrastructure/**` へ移す。Firebase transaction seamはA-FIREBASE-SEAM、owner固有のFirebase/sync adapter移動は各owner packageが所有する。
- neutral runtimeはfeature repository/mapperをexportしない。
- annotation/table/EsEn DAO move単位ごとにbuild_runnerと対象DAO testを実行する。

完了条件:

- core DBはphysical runtime/schemaだけを所有し、feature DAO getter/registrationを持たない。
- feature→coreは許可されたneutral runtime参照のみ、core→featureは0。

owner予約表。A-DBが変更するのは物理table/annotation、Catalog composition、EsEn DAO/providerまでであり、次のlocal persistenceは移動先ownerが変更する。

| 後続owner | A-DBから引き渡すexact current path |
|---|---|
| A-MYWORD | `data/data_source/local/drift_my_word_dao.dart`、`drift_my_word_status_dao.dart`、`i_my_word_local_data_source.dart`、`i_my_word_status_local_data_source.dart`、`my_word_drift_data_source.dart`、`my_word_status_drift_data_source.dart`、`data/query/drift_my_word_item_query_repository.dart`、`data/repository_impl/my_word_repository.dart`、`my_word_status_repository.dart` と `test/unit/features/my_word/my_word_item_projection_test.dart`。物理`my_words.dart`/`my_word_status.dart`はA-DBがcoreへ移動済み |
| A-RANKING | `data/data_source/local/ranking_dao.dart`、`data/query/drift_ranking_query_repository.dart`、`ranking_query_row.dart`。物理`rankings_entity.dart`はA-DBがcoreへ移動済み |
| A-USER | `data/data_source/local/drift_user_profile_dao.dart`、`i_user_profile_local_data_source.dart`、`user_profile_drift_data_source.dart`、`data/repository_impl/user_profile_provisioner.dart`、`user_repository.dart`。SharedPreferences filesはA-USERだけが所有 |
| A-WORDSTATUS | `internal/infrastructure/esp_jpn/drift/{esp_jpn_word_status_dao,esp_jpn_word_status_local_data_source,esp_jpn_word_status_local_store}.dart` とJpnEsp側の同3 file。既にfinal internal配下なのでA-DBは移動しない |
| A-SYNC | `features/sync/infrastructure/persistence/drift/{drift_sync_queue,drift_sync_checkpoint_store,drift_outbox_writer}.dart`。A-DBは編集しない |

この表のfileをA-DBと後続ownerが同時編集しない。generated fileはsource ownerのchange setがbuild runnerと一緒に所有する。

## 3. A-SEARCH — port + bridge 縦スライス

### A-SEARCH1. Search port と Catalog raw capability

Search portへ移す現行契約:

- `search/application/query/search_direction.dart`
- `search/application/query/search_query.dart`
- `search/application/query/search_result_item.dart`
- `search/application/query/search_result_page.dart`
- `search/application/query/conjugation_search_item.dart`
- `search/application/query/search_conjugation_match_key.dart`
- `search/application/query/search_catalog_word_ref.dart`
- Search query repository/source interface

最終配置は `lib/features/search/port/model/**`、`lib/features/search/port/query.dart`、`lib/features/search/port/reader.dart` とする。Search warning/issue型もSearchが所有する。Flutter/Riverpod/Driftをimportしない。

Catalog portへ provider-neutral な次を追加する。

- primary raw hit reader
- raw conjugation hit reader
- bulk meaning/headword reader
- ranking metadata reader

Catalog portにSearch DTO、SQL、Drift rowを出さない。旧 Search application contractのre-exportは同一stack内だけ許し、checker例外にはしない。

Tests:

- Search model/query contract
- Catalog raw reader contract
- pure-port allow/deny fixture
- serialization/equality/zero-based page

### A-SEARCH2. policy移植とcomposition切替

対象:

- `lib/features/catalog/internal/infrastructure/integration/search/drift_search_query_repository.dart`
- 同 directory の `search_query_dao.dart`、`search_query_mapper.dart`、`search_ranking_lookup.dart`
- `lib/features/search/application/usecase/**`
- `lib/features/search/domain/**`、`data/**`、`di/**`、`presentation/**`
- `lib/app/bootstrap/catalog_composition.dart`
- `lib/app/integration/catalog_search/**`（新規）

owner分割:

- Catalog internal: raw SQL/readだけ
- app integration: Catalog raw gatewayの組合せとpure value mappingだけ
- Search internal: page/hasNext、page0 suggestion、meaning抽出、star/snippet、enrichment順、partial failure/warning

Searchの application/domain/data/DI/presentationを `search/internal/**` へ移し、`port/composition.dart` と `port/presentation_entry.dart` から限定facadeする。

Tests:

- 現 `drift_search_query_repository_test.dart` をCatalog raw read、app bridge mapping、Search policyに分割
- primary order、page、EspJpn/JpnEsp、page0 suggestion、3種partial failure、primary failure
- 既存 Search VM characterization

完了条件:

- Catalog→Search 0、Search外→Search internal/non-port 0。
- Search semanticsがapp/Catalogにない。
- 旧 `search/application/**` import/re-export 0。
- feature cycleのCatalog↔Search 2 edgeが0。

## 4. A-QUIZ — port + bridge 縦スライス

### A-QUIZ1. candidate contract と policy

`lib/features/quiz/application/candidate_search/**` の query/page/result/sourceを `quiz/port/**` へ移す。`QuizCandidateEnrichment`、high-level source、meaning/star/failure policyは `quiz/internal/**` へ移す。

対象Catalog integration:

- `lib/features/catalog/internal/infrastructure/integration/quiz_candidate/drift_quiz_candidate_source.dart`
- `quiz_candidate_enrichment.dart`
- `quiz_candidate_mapper.dart`

Catalogは raw conjugation/meaning/headword/ranking capabilityだけを提供する。`lib/app/integration/catalog_quiz/**`（新規）はraw valueの写像だけを担当する。Quiz内部全体を `quiz/internal/**` へ移す。

現時点の Quiz→Search import は0なので、解消作業を発明せず0を維持する。

Tests:

- candidate query/page/result contract
- trim、paging、conjugation優先meaning、partial failure、primary failure
- Catalog raw/app bridge/Quiz policyのowner別test
- Quiz Search VM characterization

完了条件:

- Catalog→Quiz 0、Quiz→Search 0、Quiz外→Quiz internal/non-port 0。
- Catalog↔Quiz cycle 2 edgeが0。
- 旧 candidate path shim 0。

### A-QUIZ2. game public contractだけを最終形へ置く

P0 manifestで確定した `QuizGameQuery(CatalogWordRef)`、aggregate loader、sealed `QuizGameLoadResult`（ready、notFound、noConjugation、source付きfailure）を `quiz/port/**` に置く。現状に `LoadQuizGame` は存在せず、`FetchEnglishConjInteractor`、`FetchEnglishConjSubInteractor`、Catalog conjugation mapper、asset providers、game VMへ分散しているため、これらを `quiz/internal/**` へ移し、その現provider graph上に新規aggregate facade/compatibility adapterを置く。presentation entryはこのaggregate contractだけを公開する。

このchange setは構造移動であり、現行のnull/empty/placeholder変換を密かに修正しない。互換adapterはcurrent characterizationと同じ表示結果を返し、final resultの未到達caseを期待値から削除しない。B-QUIZ-GAMEがrepository signatureとaggregate implementationを変更して全caseを到達可能にし、failure/no-data semanticsを完成させる。

Tests:

- pure result/source/equality contract
- current game behavior characterizationをfinal port経由で維持
- portにFlutter/Riverpod/Drift/Firebase型0

完了条件:

- P0 public-surface manifestのQuiz game signatureがproductionに一意に存在する。
- B4のerror分類をA-QUIZで先取りせず、旧provider pathを外部callerが参照しない。

Search/QuizはCatalog raw port設計と `catalog_composition.dart` を共有する。A-SEARCH1とA-QUIZのraw capability追加は同じintegration ownerが直列で行い、その後のowner policy移植だけを並列化する。

## 5. A-SESSION-SEAM — 上向きsession依存を先に反転

対象の現行直接依存:

- MyWordの7 use caseとDI/view model
- Ranking `load_rankings_interactor.dart` とDI/view model
- UserProfile `user_usecases.dart` とDI
- WordStatus `fetch/update/watch_word_status.dart` とprovider
- `lib/app/session/current_session.dart`
- `lib/app/bootstrap/session_composition.dart` の `_SessionEpochTracker`
- `lib/app/session/session_providers.dart`
- `lib/app/bootstrap/sync_infrastructure_providers.dart` の `syncSessionFenceProvider`
- 最終owner `lib/app/workflows/session_lifecycle/session_epoch_coordinator.dart`（新規）

手順:

1. P0で固定した pure `SessionScopeKey` を追加する。
2. `_SessionEpochTracker` を最終pathの `SessionEpochCoordinator` へ移す。これをrepository内でepochを増やせる唯一のownerとし、同じscope activation eventからcurrent `SessionScopeKey`、Sync session fence、guest migration contextを派生させる。
3. `session_providers.dart` はraw `AppSessionSignedOut` classではなくauth lifecycle phaseを見てstable signed-out/readyだけをactivateする。creating/signing-in/signing-out等のintermediate phaseではcurrent keyをnull/inactiveにし、旧entryを即時detachする。
4. `sync_infrastructure_providers.dart` の既存fenceは同じcoordinator eventを受ける暫定adapterにする。別counter/providerでepochを再生成しない。
5. feature use caseから`CurrentSession` fieldを除き、query/command引数としてaccount scopeまたはsession keyを受け取る。
6. long-lived VM/providerはsession keyをfamily/entry inputに含め、`ref.read`で古いuse case/session snapshotを保持しない。
7. app presentation/compositionがsession key変化でowner entryを再構築する。
8. guest/account/signed-outの既存repository mappingをcharacterizationで維持する。
9. 全caller切替後、featureから `app/session/**` importを0にする。`CurrentSession` はapp workflow内部に残してよいが、feature向けre-exportは作らない。

後続handoffを固定する。A-SYNCはcoordinator eventをSync portの `SessionFence` へ適合させ、`syncSessionFenceProvider` のinternal importを除くが、epochを発行・incrementしない。A-SESSIONはauth lifecycle producerを最終workflowへ移すだけで、coordinatorのinstance、transition規則、epoch系列を置換しない。


完了条件:

- 対象 application/usecase/DIのfeature→app session import 0。
- account IDが同じ新sessionでも旧completionを識別できるcontractがある。
- `_SessionEpochTracker` と独立counterが残らず、epoch発行元が最終workflow pathの一つだけである。

A-SESSION-SEAMはcoordinator、explicit input、provider family/entry rekey、intermediate stateでの旧entry detachまでを一度だけ所有し、上記session transition acceptanceを同change setで通す。B-MYWORD/B-RANKING/B-STATUSはこのrekeyを再実装せず、各request token/pagination/command completion fenceとUI publishだけを追加する。

## 6. A-FIREBASE-SEAM — SDK rule と pure mutation seam

### 6.1 current 4 violations

WordStatusの次4ファイルは既に正しいowner internal infrastructureにある。

- `word_status/internal/infrastructure/esp_jpn/firebase/esp_jpn_word_status_mapper.dart`
- `word_status/internal/infrastructure/esp_jpn/firebase/firebase_esp_jpn_word_status_dao.dart`
- `word_status/internal/infrastructure/jpn_esp/firebase/jpn_esp_word_status_mapper.dart`
- `word_status/internal/infrastructure/jpn_esp/firebase/firebase_jpn_esp_word_status_dao.dart`

これらを再移動せず、checker allowlistをexact canonical pathへ変える。同時に application/domain/portから同SDK packageをimportするdeny fixtureを追加する。

### 6.2 feature→app transaction helper

次5 DAOの `app/bootstrap/firebase_remote_mutation_transaction.dart` importを除く。

- `my_word/data/sync/remote/myword/firebase_my_word_dao.dart`
- `my_word/data/sync/remote/status/firebase_my_word_status_dao.dart`
- `user/data/sync/remote/user_profile_dao.dart`
- WordStatus両方向のFirebase DAO

`sync/port` にSDK非依存の remote mutation executor contractを先行作成し、`lib/app/integration/sync/firebase_remote_mutation_executor.dart`（新規）のapp実装がFirebase transactionへ写像する。feature DAOは注入されたexecutorとpure request/resultだけを扱う。

このseamが使う `RemoteMutationRequest` / `RemoteMutationAck` / `RemoteMutationAckStatus` は本packageが `lib/features/sync/application/model/remote_mutation.dart` から `lib/features/sync/port/model/remote_mutation.dart` へ先行moveし、全callerを同じchange setで切り替える。旧application pathのre-export shimや同名型を作らず、A-SYNC1の移動一覧からこのfileを除外する。MyWord/UserProfile remote adapter自体のcanonical path移動は各owner packageが担当する。

DAOが `UserDTO.collectionName` 等の他feature internal定数を参照する場合は、wire pathをownerのpure Sync/Firebase contractへ写し、値を変えずcross-feature internal importを除く。


このpackageの局所完了条件:

- current Firebase rule 4件が0。
- feature→app transaction helper 0、wire差分0。
- old `sync/application/model/remote_mutation.dart` 参照/再export 0、remote mutation型の定義はSync portの一組だけ。
- expanded `firebase_canonical_infrastructure_only` が検出するAuth 3、MyWord 4、UserProfile 1の既存pathはowner packageへ割り当て済みで、新規debtがない。ここではglobal Firebase zeroを宣言しない。

stop: document ID型、identity field、required/optional/type、field mask、`lastMutationId`、client/server timestamp、`schemaVersion`、revision、またはduplicate/superseded/appliedの判定がbefore oracleと異なったらhelper削除を止める。新仕様へ合わせて期待値を更新しない。

## 7. A-SYNC — port/internal と registry を一回で切替

### A-SYNC1. public contract

移動:

- `sync/application/model/**`、`application/port/**`、`cancellation_token.dart` → `sync/port/**`
- `core/shared/enums/sync_dataset.dart` → `sync/port/sync_dataset.dart`

公開するのは `SyncDataset`、context/cursor/mutation/remote mutation/result/report、queue/checkpoint/outbox、cancellation/session fence、`DatasetSyncAdapter`、`DatasetSyncHandler`、`SyncHandlerRuntime`、public runner/composition contract、app workflow向けpure `SyncRunOutcome` である。outcomeは少なくともsuccess、durable retry済み、non-retryable failure、cancelledを区別し、`SyncDataset.stableId` は完全不変。

core旧enumのre-exportはcore→featureになるため作らず、全importを同じstackで切り替える。

### A-SYNC2. engine/policy/internal

移動:

- engine、scheduler、registry、dataset plan、retry、classifier、execution guard、single-flight、report interpreter → `sync/internal/application/**`
- current `sync/infrastructure/**` → `sync/internal/infrastructure/**`

owner feature handlerから `RetryPolicy`、`ExponentialBackoff`、`SyncErrorClassifier`、`SyncExecutionGuard` のimportを除く。dataset-specific adapterだけをfeature internalに残し、P0 proof済みruntimeへ渡す。

### A-SYNC3. handler factory/registry/workflow

- MyWord/UserProfile/WordStatusのadapter/factoryはowner internal + owner `port/composition.dart` facade。
- app registryはpublic factoryが返す `DatasetSyncHandler` だけを登録。
- `app/bootstrap/sync_composition.dart` と `sync_infrastructure_providers.dart` からfeature/Sync internal importを除く。
- `app/guest_migration/**` を `app/workflows/guest_migration/**` へ、foreground/manual/lifecycle triggerを `app/workflows/sync_trigger/**` へ移す。

完了条件:

- Sync internal→個別feature 0。
- feature→Syncはportのみ。
- app registry→feature internal、app→Sync internal 0。
- stableId/outbox/checkpoint/wire差分0。

## 8. A-SESSION — auth lifecycle/workflowを収束

このpackageのscaffoldingは先に置けるが、完了判定と旧core workflow削除は A-AUTH と A-USER のpublic port/internal化後に行う。app workflowから両feature internalを参照する一時構造を残さない。

- `lib/core/application/auth_lifecycle/**` と `core/application/effects/auth_effect_provider.dart` を `lib/app/workflows/session_lifecycle/**` へ移す。
- `app/bootstrap/lifecycle_effects.dart` をsession/auth effectとsync triggerへ分割する。
- P0で既に削除済みのcore auth lifecycle allowlistを復活させず、debt snapshotに出た10 importをcode移動で0にする。
- router/UI facing `AppSession` はapp ownershipを維持する。
- Auth/UserProfileのpure portを必要最小限先行し、app workflowがfeature internalへ依存しないようにする。

完了条件:

- `core/application/auth_lifecycle` 0、core workflow→feature 0。
- feature→app session 0。
- session lifecycleとsync engineのownerが分離。

## 9. 残featureの `port/internal` 化

共通手順:

1. portの最小public面とcontract testを追加。
2. external callerをportへ切替。
3. owner implementationを `internal/application|domain|infrastructure|presentation|di` へ移す。
4. `port/composition.dart` と `presentation_entry.dart` の限定facadeを接続。
5. testをpublic contractとsame-feature white-boxに分ける。
6. 旧top-level directory/exportを削除し、対象checker ruleを0にする。

### A-CATALOG

- 既存 `port/internal` をP0 pure ruleへ適合。
- Search/Quiz raw reader、DB compositionをfinalize。
- Catalogはpresentation routeやconsumer warning型を所有しない。

### A-AUTH

- identity DTO、auth command/reader、composition、presentation entryをportへ。
- `auth/data/data_source/remote/firebase_auth_dao.dart`、`data/dto/auth_dto.dart`、`data/repository_impl/firebase_auth_repository_impl.dart` のSDK mapping/adapterをcanonical internal infrastructureへ。pure Auth DTOはport/internal application側でSDK型を持たない。
- provider/usecase/presentationはinternalへ。
- session workflowからAuth internal参照0。

### A-USER

- profile DTO、ensure/live profile、guest migration/sync contribution、composition、presentation entryをportへ。
- `user/data/sync/remote/user_profile_dao.dart` をcanonical internal infrastructure Firebase adapterへ移す。
- current pathは `features/user` のまま。P3までは `user_profile` を並存させない。

### A-MYWORD

- command/query/result、guest migration/sync contribution、MyWord status entryをportへ。
- MyWord/MyWordStatus remoteのFirebase DAO/DTO 4ファイルをcanonical internal infrastructureへ移し、SDK型をmapper/adapter内に閉じる。
- application/data/domain/DI/presentationをinternalへ。
- `my_word.dart` と `my_word_status.dart` の `flutter/foundation.dart` は削除またはpure `meta`へ置換し、domain rule 2件を0にする。

### A-RANKING

- query/filter/resultとpresentation entryをportへ。
- result itemへ物理PK由来のstable `rankingId`を運ぶ。非group queryは `r.ranking_id`、既存`multiLemma`の`GROUP BY r.word_id` branchはdeterministic `MIN(r.ranking_id) AS ranking_id`を使う。table/schemaは変えず、DAO projection→query row→port itemのread fieldだけを追加する。
- read projectionを維持し、他feature tableへのwrite APIを追加しない。

### A-WORDSTATUS

- current application port/domain model、command、guest migration/sync contribution、presentation entryをportへ整理。
- direction別DB/Firebase/Sync adapterはinternal infrastructureで分離を維持。
- 空の `esp_jpn_word_status` / `jpn_esp_word_status` directoryに互換codeを作らない。

### A-WORDDETAIL

- current `features/word_page` 内に route/query-result/presentation input/entryをportとして作る。
- application/DI/presentationをinternalへ移す。
- renameはP3まで行わない。

### A-FIREBASE-ZERO

A-AUTH/A-USER/A-MYWORD/A-WORDSTATUS完了後、全featureのFirebase package importを再走査する。

- 許可: exact canonical `features/<owner>/internal/infrastructure/**/firebase/**` とapp SDK composition実装。
- 禁止: port/domain/application/presentation、legacy `data/**`、他feature wire constant、feature→app helper。
- 全mapper/path/timestamp/revision/MyWords tombstone contractを再実行する。

完了条件はexpanded Firebase rule 0である。allowlistを `features/*/internal/**` のように広げず、SDKを実際に使うcanonical directoryだけをpath pattern + deny fixtureで許可する。

Phase完了条件:

- 全feature top-levelが `port/internal` のみ。
- feature外→internal/non-port 0、business port framework import 0。
- public contract testがinternalをimportせず、white-box test以外の旧path参照0。

## 10. A-FACADE — active app presentation facade解消

現行参照:

- `app/presentation/search_card.dart`: Quiz 1 caller
- `app/presentation/search_view_models.dart`: WordDetail 1 caller
- `app/presentation/word_status_buttons.dart`: Search 2、Quiz 1、Ranking 1、WordDetail 1

手順:

1. `CardView` のfeature-neutral見た目を `lib/core/ui/search_result_card_shell.dart`（新規）へ移し、status providerを埋め込まずstatus slot/callbackを受ける。
2. Search/Quiz wrapperは各internal presentationに置く。
3. WordStatus/MyWordのentryへ既存state/command wiringを挙動不変で移す。B-STATUSの最終owner pathを `my_word/internal/presentation/status/{my_word_status_command,my_word_status_entry}.dart` と `word_status/internal/presentation/dictionary_status/{dictionary_word_status_command,dictionary_word_status_entry}.dart` に予約する。effect listener、submitting disable、retry、session completion fenceは追加しない。
4. Ranking/WordDetail/Search/Quizはstatus entryだけを使う。
5. WordDetail conjugationからSearch provider購読を除き、optional `WordDetailPresentationInput.highlight` またはlocal stateへ置換。
6. caller 0後にfacade 3件を削除する。

完了条件:

- feature→`app/presentation` 0、WordDetail→Search 0、facade 3件参照0。
- status mutationのbehavior fixを含まず、B-STATUSが編集するfinal owner entry pathが一意。

## 11. A-ROUTE — feature-owned pure route と navigation callback

手順:

1. `RouteParseResult` を `core/result/route_parse_result.dart` へ移す。
2. WordDetail routeを当面 `word_page/port/route.dart`、Quiz routeを `quiz/port/route.dart` へ移す。
3. Quizを `CatalogWordRef` + optional display hintへ変更し、canonical/legacy aliasを実装する。
4. callerを全切替する: Search 2、Quiz Search、Ranking、WordDetail、router、tests。source featureはdestination route型を構築せず、`CatalogWordRef` + optional hint等のneutral callback payloadだけをappへ渡し、appがrouteへ変換する。
5. feature presentationの `route_name_resolver.dart`、`entryPointProvider`、GoRouter importをnavigation callbackへ置換する。WordDetail→QuizとQuiz→WordDetailの相互route port importを作らない。
6. app旧route contract shimを参照0後削除する。

完了条件:

- route DTO pure Dart、feature→app routing 0。
- feature presentation→他feature route port 0、WordDetail↔Quiz cycle 0、navigation framework専用rule 0。
- Quiz public constructorにraw identity-only `wordId`なし。
- legacy pathを削除せずrefresh/deep link test green。

## 12. A-APP — routing/compositionをgraphだけにする

対象:

- `lib/app/routing/router.dart`（現状は旧router export）
- `lib/router/router.dart`、`study.dart`、`word_detail.dart`、`route_names.dart`
- `lib/core/di/router/router.dart`
- top-level app shell `lib/main_activity.dart`
- `lib/app/bootstrap/**`

手順:

1. app/routing export shimを実装へ置換し、旧router graphをappへ移す。
2. navigation state providerをcore DIからapp routingへ移す。
3. routerは各 feature `port/presentation_entry.dart` とroute contractだけをimportする。
4. redirect/invalid route/named route graphをappに保持する。
5. bootstrapはpure feature composition factoryだけを使う。P0 DB decisionで証明したexact例外以外のinternal importを除く。
6. guest migration/session/sync triggerはapp workflows、engineはSync featureに維持。
7. 全caller切替後 `lib/router/` を削除する。

完了条件:

- global feature→app 0、core→feature 0、app→feature internal/non-port 0。
- router→internal presentation 0、`lib/router` 0。

## 13. A-RENAME — 最終名称へ一度だけ移す

### WordDetail

- `features/word_page` → `features/word_detail`
- `WordPageLoadKey`、`WordPageViewModel`、`WordPageState`、provider、fragment、file/test名を意味が同じ範囲でWordDetailへ。

### UserProfile

- `features/user` → `features/user_profile`
- generated path、`part` directive、database generated referenceを同じchange setで更新。

旧directory互換shimは作らない。external URL keyの `word_detail`、legacy queryはコード名称renameと別で維持する。

Tests/完了条件:

- codegen、両feature全test、schema/wire snapshot。
- 旧path import 0、generated型/SQLの無承認差分0。
- 空の方向別WordStatus directoryを削除（tracked fileがなければ作業不要）。

## 14. A-DEAD — API/shimをpath単位で削除

### Catalog

定義以外参照0を再確認後、次のwrite methodを削除する。

- EspJpn/JpnEsp word DAOのinsert/update/delete
- conjugation DAOのinsert/update/delete
- example/idiom/part-of-speech-list/supplement DAOのinsert/update/delete

Catalog production public surfaceにwrite APIがないことをsource-level testで固定する。

### MyWord

local interface/data source/DAOの次だけを候補にする。

- `insertMyWord`
- `deleteMyword`
- `updateMyWord`
- local `getMyWordsAfter`
- `watchMyWordIdsAfter`

remote `getMyWordsAfter`、repository `updateWord/deleteWord`、revision-aware insert/update/tombstone、outbox/ack/applyRemoteは現役なので削除しない。同名検索だけで判定せず、path + symbol referenceで証拠を取る。

### shims

- Search/Quiz/Sync旧application exports
- old provider aliases/composition paths
- app route contracts/router export
- presentation facade
- 未使用 `card_view_copy.dart`、`app/presentation/quiz_view_models.dart` は参照0なら削除

完了条件:

- 削除symbolごとの参照0記録。
- Catalog read、MyWord create/update/delete/outbox/tombstone/sync test green。
- schema/wire差分0。

## 15. A-CHECKER-ZERO / A-FINAL

### checker zero

P0で固定した全ruleをproduction全体へ適用し、次を0にする。

- feature外→non-port/internal
- feature→app
- core→feature
- feature cycle
- business port/domain→framework
- 不正な presentation/composition facade
- 非canonical Firebase import
- 未証明DB例外

`tool/import_boundaries/baseline.json` の `violations` は空。rule削除、pathの過広allowlist、generated除外の拡大で0にしない。

### final command order

path/annotation変更があれば先に:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

その後:

```powershell
dart run tool/check_import_boundaries.dart --check --baseline tool/import_boundaries/baseline.json
dart analyze
flutter analyze
flutter test test/tool/import_boundaries/check_import_boundaries_test.dart
flutter test
```

P0のnative/schema/wire対象testに加え、次のChrome Web DB、Node rules、Dart production transaction emulator suiteをGate Aの必須commandにする。`quality.yml` に独立jobとして固定し、Chrome/emulatorがない環境でskipして完了扱いにしない。

```powershell
flutter test --platform chrome test/integration/database/web_database_reuse_test.dart
npm --prefix firebase-tests ci
npx --yes firebase-tools@13.35.1 --config firebase-tests/firebase.json emulators:exec --project my-dic-sync --only auth,firestore "npm --prefix firebase-tests test"
npx --yes firebase-tools@13.35.1 --config firebase-tests/firebase.json emulators:exec --project my-dic-sync --only auth,firestore "flutter test --platform chrome test/integration/firebase/remote_mutation_transaction_contract_test.dart"
```

Gate A完了条件:

- 全rule 0 / exit 0、両analyze 0 issues、全test green。
- 起点別DB/schema、asset、Firebase/Sync wire差分0。
- 一時shim/legacy owner path 0。
- test削除・skip・期待値弱体化なし。
- ADRを読まずにAccepted扱いしていない。
