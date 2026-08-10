# P0 詳細 — 規則・互換契約・技術 spike・挙動基準

## 1. P0 の出口

P0 は production directory を大量移動する phase ではない。次の証拠が揃うまで P1 を開始しない。

- D1 の全境界を表現する checker rule と allow/deny fixture が green。
- DB/schema/native/Web/asset/Firebase/Sync wire の before oracle が green。
- DB ownership の採用案が runtime SQL と import graph の証拠で一つに決まっている。
- 各 feature の owner、port signature、presentation entry、composition seam、route path が一意。
- B1〜B7 の各 scenario に test owner と test level がある。
- 現在正しい挙動は green characterization、既知 defect は「red reproduction と修正を同一 change set」に割り当て済み。
- baseline の `violations` は空で、広い例外や一時的な成功値を追加していない。

## 2. P0-DECISIONS — public contract を固定する

### 2.1 共通 contract rule

実装開始前に次の形を decision baseline へ記録する。

```text
port/model|command|query|reader|route.dart
  pure Dart の値・interfaceのみ

port/composition.dart
  pure Dart interface/factoryのみ
  同一featureのinternal factoryを呼ぶfacadeは可
  Provider/Override/DatabaseProvider/FirebaseFirestore/GoRouter/Widgetはsignatureに出さない

port/presentation_entry.dart
  Widget/WidgetBuilderを返す唯一の入口
  引数はpure input、callbacks、pure composition
  Provider/Overrideをexportしない

internal/**
  Riverpod/Drift/Firebase実装、owner DI、presentationを保持

app/routing/**
  GoRouterとdestination route変換を所有。feature presentationはcallbackのみ
```

最初の proof は Search で作る。app は Catalog raw port を実装する low-level bridge を Search の pure composition factory へ渡し、factory が internal use case を組み立てる。app bridge が Search result/paging/warning policy を実装しないことを contract test で確認する。この proof が通るまで同じ pattern を全 feature に複製しない。

DB/Firebase の framework instance は public composition へ渡さない。feature internal DI は core の neutral runtime/provider または owner infrastructure を直接利用し、app は lifecycle と pure factory の選択だけを担当する。

### 2.2 session contract

新規 pure value を `lib/core/session/session_scope_key.dart` に置く。

```dart
final class SessionScopeKey {
  const SessionScopeKey({required this.accountScope, required this.epoch});
  final String accountScope;
  final int epoch;

  @override
  bool operator ==(Object other) =>
      other is SessionScopeKey &&
      other.accountScope == accountScope &&
      other.epoch == epoch;

  @override
  int get hashCode => Object.hash(accountScope, epoch);
}
```

- `accountScope` は authenticated account ID または既存 `guestAccountScope`。
- `epoch` は account が同じでも session が再開始されるたびに変わる単調 token。
- epochの唯一の発行元は最終path `lib/app/workflows/session_lifecycle/session_epoch_coordinator.dart`（新規）のapp-internal coordinatorとする。現 `lib/app/bootstrap/session_composition.dart` の `_SessionEpochTracker` をここへ移し、`lib/app/session/session_providers.dart` と `lib/app/bootstrap/sync_infrastructure_providers.dart` の既存producer/fenceを同じeventへ接続する。
- coordinatorは一つのscope activationにつき一度だけepochを進め、同じeventからpresentation用 `SessionScopeKey` とSync/guest migrationのsession fenceを発行する。同じstable ready accountのprofile rebuildやstable signed-out反復では進めず、intermediate detach後の再activationでは同accountでも進める。A-SYNCはこのepochを消費するだけで発行せず、A-SESSIONがlifecycle producerを移した後もcounterを作り直さない。
- Riverpod family/map keyとして使うため、`accountScope` と `epoch` によるvalue equality/hashCodeを必須にする。object identityへ依存しない。
- stableな `AuthLifecyclePhase.signedOut` だけを `guestAccountScope` と新epochを持つguest keyへ写像し、guest dataをreloadする。現 `AppSessionSignedOut` はcreating/signing-in/signing-outも表すため、classだけでguest activationを判定しない。initializing/creating/signing-in/signing-out/email-unverified/profile-loading/failureへ入った時点で旧owner entry/providerをinvalidateして旧account dataを即時detachし、その間はqueryを開始しない。stable ready/signed-outへ遷移した時だけ新keyを渡す。
- feature use case は `CurrentSession` を constructor injection せず、実行する command/query または presentation entry から key/account scope を受け取る。
- 永続 write は開始時に確定した account scope へ行う。session switch 後に旧 completion を rollback するのではなく、新 UI state/effect への publish を token で拒否する。
- app の `CurrentSession`/`AppSession` は workflow implementation detail とし、feature port から参照しない。

この判断は変更量より correctness を優先する。live reader を長寿命 use case に保持すると、B1/B3/B5 の stale instance 問題が再発するためである。

### 2.3 paging contract

各 owner feature に次の二種類をimmutable valueとして定義し、全fieldによるequality/hashCodeを持たせる。

- `PageIdentity`: logical result set と page。MyWord は session key/page/pageSize、Ranking は session key/filter/page/pageSize、Search/Quiz VMは session key/normalized query/direction/filter/page/pageSize。Search/QuizのCatalog port query自体はaccount fieldを持たない。
- `RequestToken`: result-set generation、対象 `PageIdentity`、attempt sequence。await 後の publish 可否だけに使う。

共通 rule:

1. current result set内のpage requestは直列化し、一度に一つだけactiveにする。旧generationのrequestが未完でも、新generationのpage 0は開始できる。
2. 同じ `PageIdentity` が in-flight の間は重複 request を拒否する。
3. failed `PageIdentity` の唯一の正本はowner VM stateとする。controllerは未advanceのzero-based page番号とtrigger/resetだけを持ち、business identity/errorを保持しない。retryはVMのidentityを再利用しattempt tokenだけを更新する。
4. page 0 は replace、後続 page は stable item identity で dedupe して append。
5. owner entryのresetはVM generation/in-flight/failed identity/state clearとcontroller page/scroll resetを一つのcoordinated operationとして呼ぶ。保存ownerは混ぜない。
6. await 後は `mounted && token == activeToken` を満たす時だけ、await前のstate snapshotではなくpublish時点のcurrent stateへmergeする。別pageを並列prefetchする将来変更ではsingle tokenを使わず、`Map<PageIdentity, RequestToken>`へ明示的に拡張する。

`PageIdentity` を一つの shared business typeにはしない。共通 controller は page/load trigger/reset generationと未advanceのcurrent pageだけを扱い、account/query/filter semantics、failed identity、request attemptは owner VM に残す。result-set generationとrequest attempt sequenceを同じcounterにしない。

### 2.4 Sync contract

Sync policy を feature port へ漏らさないため、P0 で一つの MyWord handlerを使って次を proof する。

- `sync/port` に pure `DatasetSyncHandler`、`DatasetSyncAdapter`、`SyncHandlerRuntime`、context/result/cursor/mutation/fenceを置く。
- feature internal の dataset adapter は dataset 固有 read/apply/serialize だけを実装する。
- `SyncHandlerRuntime.run(context, adapter)` の実装は Sync internal にあり、retry/backoff/error classification/execution guard/queue/checkpointを所有する。
- owner feature の `port/composition.dart` は pure dependencies と `SyncHandlerRuntime` から `DatasetSyncHandler` を返す facade を公開する。
- app registry は feature port factory の戻り値だけを登録し、feature internal も Sync internal も import しない。
- app workflow向けrunnerはinternal `SyncReport` interpretationを漏らさず、pure `SyncRunOutcome` を返す。最低caseは `success`、durable retryが既にarmされた `retryScheduled(nextAttempt)`、手動判断可能な `nonRetryableFailure`、session/cancel由来の `cancelled` とする。

proof で callback/error 型が policy detail を公開し始めた場合は止め、adapter operation をさらに raw な capability へ分割する。`RetryPolicy`、`ExponentialBackoff`、`SyncErrorClassifier`、`SyncExecutionGuard` を port へ移して解決してはならない。

### 2.5 Search/Quiz bridge contract

```text
Catalog port: raw hit/detail/conjugation/meaning/ranking metadata
      ↓
app/integration: raw port の組合せと owner gateway への値写像
      ↓
Search/Quiz internal: query解釈、paging、enrichment、warning/failure policy
```

- Catalog port に Search/Quiz DTO、SQL、Drift rowを出さない。
- app integration に page計算、snippet、star表示、warning policyを置かない。
- Search/Quiz の high-level source は owner internal に置き、`port/composition.dart` の pure factoryで構築する。
- Search と Quiz が共有するのは Catalog raw DTO だけで、互いの internal/portを経由しない。

### 2.6 presentation/navigation contract

- shared card shell は feature DTO/providerを知らず、display value、callbacks、status slotを受け取る。
- WordStatus/MyWord の状態、command、effect listenerは owner entry 内に置く。
- WordDetail highlight は `WordDetailPresentationInput` の optional ephemeral field とする。Search から遷移した時だけ app navigation callback が渡し、refresh/deep linkでは null。route identityやURL必須fieldにしない。
- feature presentation は route name resolver、GoRouter、app providerをimportせず、navigation callbackを entry input で受ける。
- source featureがcallbackへ渡すpayloadは `CatalogWordRef`、optional display hint、source-owned pure valueまでとする。Search/Ranking/WordDetail/Quizはdestination featureのroute型をimportせず、app routerだけがpayloadを `QuizGameRoute` / `WordDetailRoute` へ変換する。これによりWordDetail↔Quizのport cycleを作らない。

### 2.7 Quiz route contract

canonical と legacy を分ける。

```text
canonical: quiz-game/:catalog/:wordId?word=<optional-hint>
legacy:    quiz-game/:wordId?word=<optional-hint>
```

- canonical `catalog` は `CatalogId.wireValue`。
- legacy は `CatalogId.espJpnMain`。
- unknown catalog、空、非正整数は parse failure。
- explicit `jpnEspMain` は未対応 failure。
- display hint は空なら null、identity判定には使わない。
- app graph が二つの path alias を feature port の同じ parse/entryへ接続する。

### 2.8 P0-PUBLIC-SURFACE deliverable

実装時に `docs/refactor-v0.2/public-surface.md`（新規）へ次のmanifestを作り、各行にexact file、public symbol、consumer、framework可否、削除する旧pathを記録する。

| feature | 最小public面 |
|---|---|
| Catalog | `CatalogId`/`CatalogWordRef`、detail/conjugation/raw search/raw quiz readers、pure composition |
| Search | query/direction/page/result/warning、Catalog gateway、composition、presentation entry |
| Quiz | candidate query/page/result/source、`QuizGameQuery(CatalogWordRef)`、sealed game load result（ready/notFound/noConjugation/source failure）、route、composition、presentation entry。A-QUIZで型/adapterを配置し、B4で全caseの意味を実装 |
| Sync | dataset/context/cursor/mutation/result、queue/checkpoint/fence、adapter/handler/runtime/runner、pure `SyncRunOutcome`（success/retryScheduled/nonRetryableFailure/cancelled）、composition |
| Auth | identity、auth commands/readers、composition、presentation entry |
| UserProfile | profile DTO/query、ensure/live profile、guest migration/sync contribution、composition、entry |
| MyWord | command/query/result、guest migration/sync contribution、status entry、composition |
| WordStatus | model/command/query、guest migration/sync contribution、status entry、composition |
| Ranking | filter/query/result（stable `rankingId`を含む）、composition、presentation entry |
| WordDetail（現 `word_page`） | route、query/result、ephemeral presentation input、composition、entry |

manifestで解決できないsignatureが一つでも残る場合、そのfeatureのdirectory moveを開始しない。productionに空のport skeletonだけを先行配置せず、各縦スライスでcontract testと一緒に追加する。

### 2.9 P0-COMPOSITION-PROOF / P0-SYNC-PROOF

manifestだけでwiring可能と仮定しない。P0-DB-SPIKEでDB ownership/lifecycle案を採用した後に二つの隔離spikeを実行し、採用signatureと棄却案をdecision logへ残す。DB案未決のfake-only proofをproduction wiringの実証として扱わない。

`P0-COMPOSITION-PROOF`:

- Search形状のpure gateway/query/compositionとFlutter presentation entryを最小実装する。責務は、Catalog internalがneutral DB runtimeを利用してCatalog raw portを実装、app bridgeがCatalog portをSearch-owned pure gatewayへ写像、Search internalがそのgatewayを受け取る、の3段に分ける。
- app相当callerはportだけをimportし、internal factory/presentation、Provider/Overrideを参照しない。Search internalからcore DB/Drift/Catalog internalへのimportはdeny fixtureで拒否する。
- 同じProviderContainer内のCatalog/Search/Quiz相当consumerが同一neutral DB runtime instanceを共有し、container disposeでexactly once closeされることをtestする。factory内でDBを新規生成する実装は不合格とする。
- internal側が受け取ったpure dependencyだけで構築でき、entryがbuild/disposeできることをtestする。
- checker fixture、compile test、widget build/dispose/DB lifecycle testを通す。
- 結果を `docs/refactor-v0.2/decisions/composition-seam.md`（新規）へ記録する。

`P0-SYNC-PROOF`:

- MyWord handler一つを代表に、`DatasetSyncAdapter` + `SyncHandlerRuntime` seamを隔離実装する。
- owner側importはSync portだけ、retry/backoff/classifier/guardはSync internalだけであることをcheckerで実測する。
- queue/checkpoint/outboxとowner adapterがP0-DB-SPIKE採用済みの同一DB lifecycleを共有し、app/factoryが別connectionを生成せず、owner disposeでDBを早期closeしないことを実測する。
- cancel、retry分類、checkpoint/queue呼出順の既存testをproof形状で通す。
- 結果を `docs/refactor-v0.2/decisions/sync-handler-runtime.md`（新規）へ記録する。

spikeは一時branchで行い、productionへ半端なSearch/Sync surfaceを残さない。mergeするのは再利用するchecker fixture/test helperとdecision logだけとし、本実装はA-SEARCH/A-SYNCの縦スライスで行う。これらはADR監査の代用を主張せず、今回のdecision baselineに限定する。

## 3. P0-CHECKER — 規則を実行可能にする

### 3.1 checker 機能

現行 JSON rule だけでは「同一 feature」と「他 feature」や exact facade direction を表現できない。`tool/check_import_boundaries.dart` に path から feature ownerを抽出する semantic rule を追加する。

最低限、次を独立 rule ID とする。

1. `feature_external_only_port`
2. `feature_top_level_only_port_internal`（importがないlegacy Dart fileもfilesystem scanで検出）
3. `feature_no_app`
4. `core_no_feature`（portを含む全feature target。auth lifecycle allowlistもP0で削除し、現10 importを既知debt snapshotへ出す）
5. `no_feature_cycle`
6. `business_port_no_framework`
7. `presentation_entry_exact_facade`
8. `composition_exact_facade`
9. `composition_no_provider_types`
10. `firebase_canonical_infrastructure_only`
11. `database_schema_registration_exact_exception`（spikeが必要性を証明した時だけ有効）
12. `feature_presentation_navigation_callback_only`（feature presentationからGoRouter、app/core/legacy router、route-name resolver、他feature route portを拒否）

import だけでなく `export`、`part`、`part of` も同じlibrary graphで検査する。conditional import/exportは先頭URIだけでなく全branch URIを抽出する。portのlocal barrel/re-exportを経由してframework packageを隠せないよう、public libraryについてはlocal export closureを辿り、到達したforbidden packageも元portの違反にする。generated files は production rule から除外してよいが、生成元と emitted SQL/type の別検査を P0-DB-CONTRACT で持つ。

testのwhite-box例外は `test/**/features/<feature>/internal/**` から同じ `<feature>/internal/**` への方向だけに限定する。public contractとcross-layer testはportだけをimportする。他feature internalやappからのproduction importを許すためにtest allowlistを流用しない。

### 3.2 fixture matrix

`test/tool/import_boundaries/fixtures/` に最低限次を用意する。

| fixture | 期待 |
|---|---|
| app/other feature → `feature/port/model.dart` | allow |
| core → `feature/port/**` を含む全feature target | deny |
| app/core/other feature → `feature/internal/**` | deny |
| importがない `feature/application|data|domain|di|presentation/**.dart` | deny |
| feature → app | deny |
| core → feature | deny |
| feature A port/internal → feature B port | allow、cycleがなければ |
| feature A → feature B internal | deny |
| business port → Flutter/Riverpod/Drift/Firebase/GoRouter | deny |
| exact `port/presentation_entry.dart` → Flutter `Widget`/`WidgetBuilder` | allow |
| exact `port/presentation_entry.dart` → Riverpod/Provider/Override/Drift/Firebase/GoRouter | deny |
| exact `port/presentation_entry.dart` → same internal presentation | allow |
| other port file → internal presentation | deny |
| exact `port/composition.dart` → same internal factory | allow |
| composition public signature/source → Provider/Override | deny |
| canonical internal Firebase adapter → Firebase package | allow |
| application/domain/port → Firebase package | deny |
| app DB composition → exact schema adapter | spike採用時だけallow |
| same-feature white-box test path → same feature internal | allow |
| cross-layer/other-feature test → feature internal | deny |
| conditional import/exportのforbidden branch | deny |
| `part`/`part of`でbusiness portとframework libraryを接続 | deny |
| feature internal presentation → GoRouter / `app/routing` / `core/di/router` / legacy `lib/router` | deny |
| feature A presentation → feature B `port/route.dart` | deny |
| feature presentationがneutral `CatalogWordRef`をcallbackへ渡す | allow |

fixture directory 全除外の現仕様では fixture 自身への repository scan と fixture test の責務を混同しない。test harness は temporary root に fixture をコピーして `check(root:)` を呼ぶ既存方式を維持する。

### 3.3 production rule rollout

- fixture と rule engineを同じ change set で green にする。
- production rulesを有効化し、JSON reportを P0 debt snapshotとして保存する。
- baseline updateを実行しない。
- P3まで checker jobが非0になる場合は draft integration branchで積み、CI ruleを一時無効化しない。

## 4. P0-DB-CONTRACT — DB/wire oracle

### 4.1 schema snapshot

fresh schemaVersion 7 DB から次を正規化して snapshot する。

- 19 table の `sqlite_master.sql`
- fresh create が生成する3 custom index
- `PRAGMA table_info` の column順、type/affinity、notnull、default、PK順
- `PRAGMA foreign_key_list` の参照先、列、ON DELETE/UPDATE
- CHECK、複合PK、unique constraint
- generated Dart table/data class名と `@DriftDatabase` emitted schema

SQL空白やquote差は正規化するが、identifier、order、constraintは無視しない。before/afterを同じ normalizerで比較する。

重要: 現在の native asset、fresh native、fresh/existing Web は既に完全一致ではない。native assetには fresh create にない legacy index 4件があり、`rankings.has_conj` 等にも起点差がある。「差分0」は起点同士を強制的に同一化する意味ではなく、**各起点の変更前と変更後が同じ**という意味で判定する。oracle は最低でも `fresh-native`、`asset-upgrade-native`、`fresh-web`、`existing-web` に分ける。

### 4.2 migration fixtures

履歴を確認できる v1、v4、v5、v6 と、v7 reopen の fixtureを作る。v2/v3 の独立schema履歴は現 repository にないため、migration code が v1 と同じ入力を前提にしていることを確認した上で「v1 schema alias」と明記したfixtureを作る。履歴を推測して別schemaを捏造しない。各 fixture はそのversionで存在した tableへ代表 rowを入れ、次を確認する。

- row/account ID、UUID移行、revision、deletedAt
- primary/foreign key と cascade
- default/CHECK/null semantics
- outbox/checkpoint の cursor、attempt、lease
- upgrade後の再openで同じ rowが読める
- seed処理が二度走っても重複しない

既存 MyWord-only/outbox-only migration test は削除せず、全 schema fixtureへ補完する。

### 4.3 native/Web/asset

Native:

- `kotobank.db`、release/debug application-support path、初回copy、既存file優先を固定。
- 実 asset copyの代表DBを一度開き、upgrade/reopen後のschemaとrowを確認。
- `getAppDir()` のcompile-time `kReleaseMode` 分岐を、`applicationSupportRoot` と `isRelease` を受けるpure path resolver（予定 `database_path_resolver.dart`）へ分離する。production wrapperだけが `kReleaseMode` を渡し、unit testでrelease/debug両方のexact pathを通す。
- v1/v2-alias/v3-aliasの各fixtureは `DatabaseProvider.forTesting(..., seedEsEnConjugacionsOnUpgrade: true)` 相当でproductionのasset copy→ATTACH→insert→DETACH→temporary file delete分岐を実行する。実 `assets/es_en_conjugacions.db` 由来の6517 row、二重実行で重複0、reopen、temporary seed DB不存在まで固定する。default `false` のtest pathだけでは合格にしない。

Web:

- IndexedDB名 `my_dic_db`、Wasm URI、既存store再openを固定。
- seederを二回実行し row count とPKを確認。
- `kotobank.json.gz` と `es_en_conjugacions.json.gz` の import結果を検査。
- `_importMyWordStatus` の3 row skipは既知 defectとして別記し、Gate A oracleの「望ましい結果」にしない。構造移動前後で予期せず変わっていないことだけを観測する。
- current codeで作成してcurrent codeで再openするだけでは互換証明にしない。`test/fixtures/database/web_legacy_schema/`（新規）に固定旧schema creatorを置き、旧creatorが同じ `my_dic_db` に作ったv1/v2-alias/v3-alias/v4/v5/v6/v7をnew codeが開く二世代harnessにする。legacy creatorはcurrent `DatabaseProvider`/table定義をimportしない。

Assets:

- `pubspec.yaml` の5 pathと asset file hashを P0 evidenceに記録する。
- refactor change set で hash変更を禁止する。
- `assets/mydic.db` は登録されているがruntime参照が見つからない。削除せず、P0 asset manifestで「registered/unreferenced」と記録し、seeding oracleへ誤って含めない。

### 4.4 Firebase/Sync wire

network不要の mapper/contract testで次を固定する。

- `Users/{uid}` と4 subcollection/document path
- 全 field名、required/optional、timestamp conversion
- revision/tombstone semantics。現行 tombstone 対象は MyWords であり、他datasetへ要件を広げない
- remote mutation/outbox/checkpoint serialization
- 5 `SyncDataset.stableId`

Firestore emulator rules testは維持するが、Dart mapper contractの代用にはしない。

helper置換前のFirestore emulator characterizationは、置換後にDart production `FirebaseRemoteMutationExecutor` を通す同じ契約testへ向ける。次をすべて固定する。

- 同じ `lastMutationId` は `duplicate`、既存 `clientUpdatedAt` 以後でないmutationは `superseded`、それ以外は `applied`。
- revisionは欠落/不正時0から開始し、applied時だけ1増える。duplicate/supersededでは増えない。
- `createdAt` は新規documentだけ、`updatedAt` はserver timestamp、`clientUpdatedAt` はrequest UTC値、`schemaVersion` は1。
- identity fieldsとfield maskだけを `merge: true` でwriteし、document ID型、field value/typeを変えない。
- commit後readbackのauthoritative `updatedAt`、revision、`lastMutationId` をackへ返す。
- 現状どおり `baseRemoteRevision` を判定に使わない。別仕様へ変える場合はrefactor外の明示decision/change setに分離する。

### 4.5 test owner と予定path

helperとtestを次へ分ける。最終feature rename時は対応するtest pathも同じchange setで移す。

| path（新規） | 責務 |
|---|---|
| `test/support/database/schema_snapshot.dart` | sqlite_master/PRAGMAの正規化。期待値自体を生成して上書きしない |
| `test/unit/core/infrastructure/database/drift/fresh_schema_contract_test.dart` | fresh v7の19 table、index、constraint、generated名 |
| `test/unit/core/infrastructure/database/drift/migration_compatibility_test.dart` | v1/v2-alias/v3-alias/v4/v5/v6→v7、v7 reopen、sentinel row |
| `test/unit/core/infrastructure/database/drift/database_path_resolver_test.dart` | injected support rootからrelease/debug exact pathを両分岐で検証 |
| `test/integration/database/native_database_reuse_test.dart` | asset temporary copy、copy-once、既存file非上書き、v1〜v3 real seed branch、6517 row、DETACH/cleanup。path providerはdirectory seamへ注入 |
| `test/integration/database/web_database_reuse_test.dart` | 固定旧schema→new codeのv1〜v7 IndexedDB migration/reopen、sentinel、二重seedなし。Chromeで実行 |
| `test/unit/features/sync/port/wire_contract_test.dart` | stableId、cursor/mutation/outbox/checkpoint wire |
| `test/unit/features/<owner>/internal/infrastructure/**/firebase/*_contract_test.dart` | path/field/timestamp/revision/tombstone mapper。各owner white-box pathに一致 |
| `test/integration/firebase/remote_mutation_transaction_contract_test.dart` | Dart production executorをFirestore emulatorへ接続し、applied/duplicate/superseded、metadata、merge、readbackを固定 |

Web testは次を必須commandとし、実行できるChrome環境をquality workflowへ追加する。単なるDart fakeで「existing IndexedDB reuse」を代用しない。

```powershell
flutter test --platform chrome test/integration/database/web_database_reuse_test.dart
```

## 5. P0-DB-SPIKE — ownership を決める

### 5.1 比較方法

三案とも production全体を移さず、代表として Catalog table/DAO、MyWord table/DAO、Ranking table/DAOを含む最小 branchで検証する。

| 案 | 検証 |
|---|---|
| 1. neutral core runtime | feature DAOを `@DriftDatabase.daos` から外し、feature所有の物理Table宣言をcore tablesへ移しても、DAOを直接構築できるか |
| 2. feature descriptor | Drift annotationの静的列挙、migration、generated SQLを保ったままdescriptor登録できるか |
| 3. app registration | feature→app 0、app→internalがexact schema adapter 1方向だけ、pure factory注入でDAOを構築できるか |

全案で P0-DB-CONTRACTと、**DB sliceに起因する** core→feature 0 / feature→app 0 / new edge 0を実測する。DB外に既存するFirebase DAO→app helper等のglobal違反はこのspikeの不合格理由にせず、A-FIREBASE-SEAM以降のowner packageで解消する。

### 5.2 推奨 default

案1を default とする。ただし名称移動はせず、現在の `lib/core/infrastructure/database/drift/` を neutral physical runtime として使う。

予定する最小差分:

1. feature DAOの generated getterにproduction/test参照が0であることを再確認。
2. `@DriftDatabase.daos` から feature DAO 5件を外し、core所有DAOだけを残す。
3. `MyWords`、`MyWordStatus`、`Rankings` の物理Table宣言を current core `tables/` へ移す。Dart class/data class/table名は維持する。
4. Catalogの既存internal DAOとMyWord/Ranking等の業務DAOをgenerated getterから独立して直接構築可能にする。旧top-level `data/**` のpath移動はA-DBへ混ぜず、各owner packageで行う。
5. Quizだけが使う `EsEnConjugacionDao` は物理tableをcoreに残したまま Quiz internalへ移す。
6. `core/di/data/data_di.dart` の Catalog DAO provider 10件を Catalog internal compositionへ移す。
7. codegen後に generated getter削除以外の table/DataClass/Companion名、17 DAO mixin、emitted SQL差分がないことを確認。

案1で runtime SQL差分、DAO構築不能、native/Web再利用失敗のいずれかが出た時だけ案2へ進む。案3は案1/2が成立せず、exact例外をfixtureで証明できる場合に限る。

### 5.3 decision record

`docs/refactor-v0.2/decisions/db-runtime.md`（実装時に新規）へ次を残す。

- 各案の最小patch概要
- import graph before/after
- generated type/SQL diff
- native/Web/migration test結果
- 採用理由と棄却理由
- checker例外の有無とexact path

## 6. P0-BEHAVIOR — Gate B characterization

### 6.1 test level

追加 dependencyを避け、通常の `flutter test` で動く cross-layer testを `test/integration/gate_b/`（新規）に置く。

並列ownerが同じfileを編集しないようfeature/change ID単位に予約する。

| exact path | owner |
|---|---|
| `test/integration/gate_b/my_word_presentation_test.dart` | B-MYWORD |
| `test/integration/gate_b/ranking_presentation_test.dart` | B-RANKING |
| `test/integration/gate_b/status_mutation_test.dart` | B-STATUS integration owner一人。MyWord/WordStatus workerはunitだけを分担 |
| `test/integration/gate_b/guest_migration_workflow_test.dart` | B-GUEST / A-APP integration owner |
| `test/integration/gate_b/search_acceptance_test.dart` | B-SEARCH |
| `test/integration/gate_b/quiz_search_acceptance_test.dart` | B-QUIZ-SEARCH |
| `test/integration/gate_b/quiz_game_acceptance_test.dart` | B-QUIZ-GAME |
| `test/integration/gate_b/word_detail_presentation_test.dart` | B-WORDDETAIL1 |
| `test/integration/gate_b/word_detail_router_test.dart` | B-WORDDETAIL2 / app routing owner |

platform deviceが必要なものだけ将来 `integration_test/` へ分ける。P0では ProviderContainer、widget、fake repository/reader、deferred `Completer` を使う。

### 6.2 green characterization

先に固定するもの:

- DB offset/account mapping、route legacy parse、WordDetail query aggregation
- Search/Quiz の現在正しい primary order、partial warning model、generation guard
- guest migration transaction rollback、fence、成功後no-op
- Sync single-flight/outbox/checkpoint
- WordDetail partial success/no-conjugation/Jpn方向の application mapping

### 6.3 defect reproduction

次は壊れた期待を恒久 green にしない。

- MyWord initial call 0
- Quiz query change後に古い `QueryLoading` が残る既存期待
- errorを null/empty/placeholder successへ潰す Quiz game
- warning/effectがUIへ届かない状態
- account/filter reset後に古いcompletionが勝つ状態

各 defect は対象 Gate B change set 内で red reproductionを追加し、最小修正と同じPRでgreenにする。mainへ failing/skipped testを残さない。

## 7. B-SCROLL への設計引渡し — shared controller 契約

`lib/core/presentation/components/infinityscroll.dart` はB1/B2/B5が共有するため、P0では次の期待とtest ownerを固定する。production修正はGate Bの最初の `B-SCROLL` change setで行い、P0/Gate Aの完了条件へ混ぜない。

- `reset()` が controller generationを増やし、旧 `onLoadMore` completionから `_hasMore`、page、loadingを更新させない。
- failure時にcontrollerはpageを進めない。owner VMの`retryFailed()`だけがfailed identityを持ち、controllerの`retryCurrentPage()`は同じzero-based pageを機械的に再triggerする。
- reset後は `hasMore` とinitial pageを確実に復元する。
- controllerはitem merge、account/query/filter identityを持たない。
- auto initial loadは同一generationで一度だけ。

P0では現在正しい部分をgreen characterizationにし、reset中completion等のdefect reproductionは `B-SCROLL` の修正と同じchange setでgreenにする。B-SCROLLがgreenになるまでB-MYWORD/B-SEARCH/B-QUIZ-SEARCH/B-RANKINGを開始しない。

## 8. P0 完了チェック

- [ ] decision baseline の全項目に owner、exact target path、signatureがある
- [ ] checker allow/deny fixtureがD1/D3と一致
- [ ] production full-rule JSON snapshot取得、baseline violations空
- [ ] 19 table、fresh index、native legacy indexを起点別に記録したschema snapshot green
- [ ] v1/v2-alias/v3-alias/v4/v5/v6→v7 migration と v7 reopen green
- [ ] v1〜v3 real asset seed branchで6517 row、duplicate 0、DETACH/temporary cleanup/reopen green
- [ ] pure path resolverのrelease/debug両branchがexact pathでgreen
- [ ] fixed legacy creator→production openerの全Web versionをChromeでgreen
- [ ] native/Web/asset/wire before oracle green
- [ ] Dart production remote mutation transactionをFirestore emulatorで通し、applied/duplicate/superseded/metadata/readback green
- [ ] DB案1の採否がdecision recordに確定
- [ ] SyncHandlerRuntime proof green
- [ ] Search composition proof green
- [ ] B1〜B7のtest owner/level/defect change set確定
- [ ] B-SCROLLの期待、test owner、defect reproduction change set確定
- [ ] Web seeder既知defectがsilent fix/frozen specになっていない
