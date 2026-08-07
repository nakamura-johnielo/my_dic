# Phase 1-7: Phase 2移行前の安全性・境界・品質ゲートを収束させる

- 状態: 進行中（Stage 1、Stage 2のlocal品質ゲート、retry契約、Stage 4の実装は収束。remote protocolとPhase 1境界、clean checkout/CI確認は未完了）
- 優先度: P0 / Phase 2移行ゲート
- 依存タスク: [`1-create-composition-root.md`](1-create-composition-root.md)〜[`6-unify-word-status.md`](6-unify-word-status.md)、[`../local_first/1-define-local-first-contract.md`](../local_first/1-define-local-first-contract.md)〜[`../local_first/7-migrate-user-profile.md`](../local_first/7-migrate-user-profile.md)
- 後続タスク: [`../local_first/8-cut-over-and-remove-legacy-sync.md`](../local_first/8-cut-over-and-remove-legacy-sync.md)、Phase 2
- 作成日: 2026-08-06

## 目的

Phase 0、Phase 1、Local-first 1〜7で作った足場とproduction接続を監査結果どおりに収束させ、次を同時に満たす状態を作る。

1. account切替後に旧accountの同期処理がack、Drift反映、checkpoint更新を行わない。
2. `flutter analyze`、import境界チェック、`flutter test`のCI 3 checkがclean checkoutで成功する。
3. retry、server acknowledgment、mutation冪等性、revision競合がLocal-first契約どおりに動く。
4. guest移管が現在sessionに対して安全かつtransactionalで、Profile表示がDriftのlive stateから派生する。
5. Phase 1-1〜1-6のcomposition、import、routing、ownership、word status統合の残件を閉じる。
6. contextsと各タスク文書を現行実装・検証結果へ一致させる。

このタスクは単一の巨大変更として実装しない。以下のStageを順番に実施し、各Stageの終了条件を満たしてから次へ進む。

## 参照する計画書とcontexts

- [`1-create-composition-root.md`](1-create-composition-root.md)〜[`6-unify-word-status.md`](6-unify-word-status.md)
- [`../local_first/index.md`](../local_first/index.md)とLocal-first 1〜7
- [`../local_first/8-cut-over-and-remove-legacy-sync.md`](../local_first/8-cut-over-and-remove-legacy-sync.md)
- [`../contexts/current.md`](../contexts/current.md)
- [`../contexts/runtime-and-status.md`](../contexts/runtime-and-status.md)
- [`../contexts/phase-scaffolding.md`](../contexts/phase-scaffolding.md)
- [`../contexts/app-routing.md`](../contexts/app-routing.md)
- [`../contexts/feature-map.md`](../contexts/feature-map.md)
- [`../contexts/next-phase-guide.md`](../contexts/next-phase-guide.md)
- [`../summary.md`](../summary.md)

## 監査時点からの収束状況（2026-08-07）

- 5つのproduction handlerは共通`SyncExecutionGuard`を注入済み。remote read後かつwrite前、remote commit後かつack前、remote例外後かつretry/dead-letter前、pull transaction内のapply/checkpoint/commit直前でsessionを再検証する。transaction内の失効は`SyncExecutionCancelled`を投げてDriftをrollbackし、handler境界で`DatasetSyncCancelled`へ変換する。
- `MutationLease.attemptCount`、Drift/Fake queueのretry遷移、`delayForAttempt(lease.attemptCount + 1)`を接続済み。backoffの下限・上限・jitterとDrift queueのattempt増加testも存在する。
- remote patchへ`mutationId`、revision、`baseRemoteRevision`が接続されていない。
- import境界検査器は`lib/**`に加えて`test/**`も走査し、fixture専用除外、test sourceのrule mapping、Windows/relative/package path、2/3 feature cycleを検査する。`analysis_options.yaml`の`test/**`除外も削除済み。2026-08-07に現working treeでbaseline照合、`flutter analyze`、全`flutter test`が成功した。clean checkoutとCIでの再現は未確認である。
- `FakeEspRankingRepository.getRankingById`は現行interfaceへ追従済み。ただし全testの最終結果はこの文書では確定しない。
- guest migrationはdialog承認後にもaccount+epochを確認し、usecase開始時・transaction開始時・commit直前にも`SessionFence`を検証する。失効時は`GuestMigrationSessionChanged`で全row/outboxをrollbackする。
- account-scoped `watchProfile`から`appSessionProvider`が`AppSessionLoadingProfile`/`AppSessionFailure`/`AppSessionReady`を派生し、Profile UIも`appSessionProvider`をwatchする。Drift変更が再ログインなしでsession/UIへ伝播するtestが存在する。
- GoRouter本体の移設、bootstrap lifecycle、word statusのdomain/application契約統合などPhase 1境界の残件は未完了である。
- `next-phase-guide.md`、`current.md`、`phase-scaffolding.md`、Local-first 6/7文書に実装済み状態と食い違う記述がある。

### protocol Stageの中断判断

repository内にはremote revision、server-confirmed acknowledgment、`lastMutationId`/`schemaVersion`、Firestore transaction/precondition、および対応するSecurity Rules/backend契約が存在しない。したがってStage 3のremote acknowledgment/revision/idempotencyとMyWordの`baseRemoteRevision`競合・rebase・tombstone競合は、中断条件に該当する未実装事項として残す。local schemaに`remoteRevision`/`lastMutationId`列があることやoutboxに`mutationId`があることだけで、remote protocolが完成したとは扱わない。

## 実装スコープ

### 同期安全性・protocol

- `lib/features/sync/application/**`
- `lib/features/sync/infrastructure/persistence/drift/**`
- `lib/app/bootstrap/session_composition.dart`
- `lib/app/bootstrap/sync_composition.dart`
- 次の5 handlerと対応するlocal/remote adapter
  - Esp-Jpn word status
  - Jpn-Esp word status
  - MyWord
  - MyWordStatus
  - User Profile

### guest migration・Profile session

- `lib/app/guest_migration/**`
- `lib/app/bootstrap/guest_migration_composition.dart`
- `lib/app/session/**`
- `lib/core/application/auth_lifecycle/**`
- `lib/features/user/data/data_source/local/**`
- `lib/features/user/data/repository_impl/user_repository.dart`
- `lib/features/user/presentation/**`

### Phase 1境界

- `lib/app/bootstrap/**`
- `lib/app/routing/**`、`lib/router/**`、`lib/main_activity.dart`
- `lib/features/word_page/**`、`search/**`、`quiz/**`、`word_status/**`
- `lib/features/esp_jpn_word_status/**`、`jpn_esp_word_status/**`
- `tool/import_boundaries/**`、`analysis_options.yaml`、`.github/workflows/quality.yml`
- 対応する`test/**`

### 文書

- `docs/refactor/index.md`
- `docs/refactor/phase1/**`
- `docs/refactor/local_first/5-migrate-word-status.md`〜`7-migrate-user-profile.md`
- `docs/refactor/contexts/**`

## スコープ外

- Local-first 8の旧`SyncService`・旧sync UseCase削除。Phase 1-7完了後に実施する。
- Phase 2のUseCase移設、ViewModel state標準化、query projection分離、`SyncReport`のUI利用。
- OS background taskの追加。
- 新dataset、認可field、subscription/roleのlocal authority化。
- UIデザイン変更、無関係なrename、大型component分割。
- CIを通す目的での新規baseline違反追加、lint/test除外拡大、失敗testのskip。

## 実装上の不変条件

- remote commit自体をcancelできない場合でも、session失効後はackしない。outboxを残し、同一accountの有効なsessionで安全に再送できるようにする。
- remote pullとcheckpoint更新は同一Drift transactionで行い、transaction commit直前にもsessionを検証する。
- remoteへの再送は`mutationId`で冪等にする。Firebase SDKのlocal cache受付だけではackしない。
- account Aのrow、outbox、checkpoint、guest dataをaccount Bへ暗黙に帰属させない。
- import境界baselineは既存債務の台帳であり、新規違反を通すために増やさない。解消済みrecordだけを削除する。
- Profileのeditable fieldはDriftをSoTとし、identityはFirebase Auth、認可はbackend/Security Rulesをauthorityとする。

## Stage 1: handler内のsession fenceを完成させる

現行実装: guardと5 handlerへの接続、transaction rollback、remote commit後のack抑止は実装済み。5 datasetでremote read中の失効を固定する回帰testも追加済み。pull待機中・transaction各境界を網羅する共通contract testの最終確認は品質ゲートと合わせて残る。

### 実装

1. `SessionFence`と`SyncContext`から、handlerが共通利用できる`SyncExecutionGuard`（名称は実装時に確定）を`features/sync/application`へ追加する。
2. 5 handlerへguardを注入し、最低限次の直前と直後で`accountId + sessionEpoch`を検証する。
   - mutation lease取得後、remote呼び出し前
   - remote commit後、Queue ack/retry/dead-letter前
   - pull取得後、Drift transaction開始前
   - remote row適用後、checkpoint更新前とtransaction commit前
3. session失効時は`DatasetSyncCancelled`を返す。remote commit済みmutationはackせずlease timeoutまたは明示releaseで再送可能にする。
4. `sessionFenceEffectProvider`とschedulerの責務を確認し、account変更時に進行中cycleの`CancellationToken`もcancelする。guardを最終防衛線として残す。

### 必須テスト

- 各5 handlerに共通contract testを適用する。
- remote write待機中、pull待機中、Drift transaction直前の各時点でepochを変更する。
- 旧accountのmutationがackされない、checkpointが進まない、別account rowへ反映されないことを確認する。
- remote commit後にsessionが変わった場合、mutationが再送可能な状態で残ることを確認する。

### Stage終了条件

- account切替handler testが5 datasetすべてで成功する。
- Local-first 4、Phase 1-4、Local-first 5/6に残るaccount切替未完了条件をcloseできる。

## Stage 2: CIの3失敗を解消し、検査器を契約どおりにする

現行実装: ranking fake追従、analyzerの`test/**`除外削除、import検査器の`lib/**`+`test/**`走査と検査器test追加、analyzer issue解消まで反映済み。2026-08-07の現working treeでimport checker専用7 test、baseline照合、`flutter analyze`（0 issues）、全`flutter test`（266 test）が成功した。lint無効化、test除外、test skip、新規baseline違反追加は行っていない。

### 実装

1. `FakeEspRankingRepository`を現行interfaceへ追従させ、全testを最後まで実行可能にする。
2. `analysis_options.yaml`から`test/**`除外を削除し、本体とtestをanalyzer対象にする。
3. import検査器が`lib/**`と`test/**`を走査するようにし、fixture専用の明示的除外だけを許可する。
4. package/relative/Windows path、generated除外、全Rule ID、baseline追加/解消、2/3 feature cycleを検査器testで固定する。
5. import境界の13新規違反はbaselineへ追加せず、Stage 5のpublic API/application port化で解消する。解消済みbaseline 3件は対応実装と同じ変更で削除する。
6. `flutter analyze`のissueを、機械的修正と意味変更を分けて小さいsliceで解消する。依存未宣言、unused、不正API、test compile問題を先に直し、rename-onlyやdeprecated UI変更を別sliceにする。
7. CIコマンドを弱めない。最終的に既存の3コマンドがそのままexit code 0になることを求める。

### Stage終了条件

```powershell
flutter analyze
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check
flutter test
```

上記がclean checkoutで成功し、CIでも同じ結果になる。

## Stage 3: retry・ack・revision・競合契約を完成させる

現行実装: retryのactual attemptとqueue contractは接続済み。remote acknowledgment/revision/idempotencyとdataset競合は上記中断判断により未実装。

### retry

1. `MutationLease`またはQueueのlease結果へ現在の`attemptCount`を含める。
2. handlerは`delayForAttempt(actualAttempt)`を使う。retry遷移とattempt増加の基準を0/1始まりのどちらかへ統一する。
3. auth failureはpause/release、network failureはbackoff retry、validation/schema failureはdead-letterに分類する。
4. fake queueにもattempt、`nextAttemptAt`、lease timeoutを実装し、Drift/Fake共通contract testを維持する。

### remote acknowledgmentとrevision

1. remote documentの共通metadataを確定する。
   - `revision`
   - `updatedAt`（server timestamp）
   - `lastMutationId`
   - `schemaVersion`
   - tombstone対象では`deletedAt`
2. remote replica portのpush結果を型付きackへ変更し、server-confirmed revisionとmutation IDをhandlerへ返す。
3. Firestore transactionまたは同等のpreconditionで、同一`mutationId`の再送をno-op成功にし、revisionを原子的に進める。
4. ack後、Driftの`remoteRevision`/`lastMutationId`をoutbox ackと整合する形で更新する。途中失敗時に新しいlocal editを消さない。
5. metadataのない既存remote documentはrevision 0 / schema v1として読み、破壊的な一括migrationを要求しない後方互換を持たせる。

### dataset競合

- Word status/User Profile: field mask単位のmergeを維持し、同一fieldはserverが受理したrevision順で決着する。
- MyWord: `baseRemoteRevision`不一致を検出し、remote最新版へ未送信local fieldをrebaseして新revisionとして再送する。tombstoneを古いupdateで復活させない。
- MyWordStatus: 親MyWord成功後だけ同期し、field競合規則はword statusと揃える。

### 必須テスト

- 1回目、2回目、上限到達時のbackoffとjitter範囲。
- remote成功後・local ack前のprocess停止を模した同一mutation再送。
- 同じmutation IDの重複deliveryでrevisionと最終値が変わらない。
- 二端末の同一field競合、別field merge、MyWord revision conflict、tombstone対古いupdate。
- remote metadataなしの既存documentとの互換。
- 可能ならFirebase Emulatorでtransaction/preconditionを含むadapter integration testをCIへ追加する。

### Stage終了条件

- Local-first 1〜4のmutation ID、revision、server ack、retry、競合に関する必須testが実装と一致する。
- `baseRemoteRevision`が生成されるだけで未消費の状態ではない。

## Stage 4: guest移管とProfile live sessionを完成させる

現行実装: guest移管のcurrent-session再検証とtransaction rollback、Drift Profile live streamからの`AppSession`/Profile UI派生は実装済み。全accept/cancel/retry/collision UI testの最終網羅性は品質ゲート時に再評価する。

### guest移管

1. guest profileを移管対象に含める現実装と、対象外とした`contexts/plans/localfirst.plan.md`の判断を先に再確認する。guest profile writerが存在しないなら対象から外し、存在するなら生成経路と競合規則を文書化する。
2. Promptはdialog表示前・承認後・migration開始直前に現在の`AppSessionReady.accountId`とepochを再確認する。
3. migration transaction内でもcommit直前にsession guardを確認し、失効時は全row/outbox変更をrollbackする。
4. word statusはboolean OR、MyWordはUUID re-key、MyWordStatusは親移管後、Profileは決定したfield規則に従う。
5. collision、二重tap、再実行、cancel、途中失敗を安全に扱う。成功時だけguest rowを削除する。

### Profile live session

1. `UserProfileDao`/local datasourceへaccount-scoped `watchProfile`を追加する。
2. Firebase identityとDrift profile streamから`AppSession`を派生させる。profile未準備、failure、readyを型で区別する。
3. Profile UIは`appUserStoreNotifierProvider`のsnapshotではなく`appSessionProvider`または専用read projectionをwatchする。
4. sync pull、local edit、guest importが再ログインなしでUIへ反映されることを保証する。
5. `AuthStoreNotifier`/`AppUserStoreNotifier`を互換bridgeとして残す場合もwriterを増やさず、参照0になった時点で後続削除対象を記録する。

### 必須テスト

- Detect usecaseの5 dataset集計。
- Esp-Jpn/Jpn-Esp OR merge、MyWord re-key/collision、MyWordStatus親順序、outbox atomicity、rollback、二重実行no-op。
- dialog accept/cancel、account switch、二重表示防止、migration failure retry。
- Drift local edit・sync pull・guest importごとの`AppSessionReady.profile`/Profile UI live更新。

### Stage終了条件

- Local-first 7のguest統合とProfile live streamの未完了checkboxをcloseできる。
- account切替中にguest dataが古いaccountへ移管されない。

## Stage 5: Phase 1-1〜1-6の境界残件を完了する

### composition root

1. DB probeと横断effect起動をWidget `build()`から明示的bootstrap lifecycleへ移す。
2. DB、Router、SyncEngine、Queue、handler、schedulerの生成・disposeを`app/bootstrap`から追跡可能にする。
3. rebuildでDB open、listener、scheduler triggerが増えず、container disposeでresourceが閉じるtestを追加する。

### import境界とfeature ownership

1. feature間連携用の明示的public API/application port規則を定義する。必要なら検査器に`allowedTargetPaths`を追加し、任意のDI/presentation内部importは引き続き禁止する。
2. WordPageからQuiz/Search DIを直接操作する箇所をapp-level orchestrationまたは所有featureのportへ置換する。
3. `CardView`の所有権をdesign systemか所有featureへ確定し、Search/Quiz間のpresentation共有を解消する。
4. baselineは修正と同時に減らし、Phase 1対象ruleの違反を0にする。

### routing

1. GoRouter本体を`app/routing`のcompositionへ寄せ、旧`lib/router` bridgeの責務を縮小する。
2. tab選択のSoTを`StatefulNavigationShell.currentIndex`と明示mappingへ統一し、`entryPointProvider`、last-index provider、`+2`等の二重状態/magic numberを除く。
3. nested pathを実Routerで検証し、直接URL、browser refresh、invalid parameter、back、deep link、tab復元のwidget testを追加する。

### word status統合

1. `features/word_status`に共通domain/application contractと外部公開APIを置く。
2. direction差はinfrastructure adapterへ限定する。2 dataset ID、remote collection、cursorは分離したまま維持する。
3. `word_status_di.dart`からEsp-Jpn/Jpn-Esp/MyWordのDI・presentation直接参照を除く。compositionは`app/bootstrap`で行う。
4. 両directionへ同じload/update/watch/sync contract testを適用し、旧provider/feature参照を0にする。

### Stage終了条件

- Phase 1-1〜1-6の未完了checkboxを、実装とtest根拠を付けてすべて再評価できる。
- `domain_no_framework`、`core_no_feature`、`no_cross_feature_presentation`、`no_feature_cycle`のPhase 1対象baselineが0になる。
- 実GoRouterとbootstrap lifecycleの必須testが成功する。

## Stage 6: 文書を現行実装へ同期する

1. 実装前に文書を完了扱いにしない。各Stage終了時に該当タスクへ検証結果を追記する。
2. 最終Stageで最低限次を更新する。
   - `contexts/current.md`
   - `contexts/runtime-and-status.md`
   - `contexts/phase-scaffolding.md`
   - `contexts/app-routing.md`
   - `contexts/feature-map.md`
   - `contexts/next-phase-guide.md`
   - Local-first 5/6/7本体と対応plan
   - Phase 1-1〜1-6本体と対応plan
3. MyWord account scoping、5 handler registry、guest migration、旧sync providerの実際の接続状態をコードから再確認して記録する。
4. 完了条件、既知の制約、Local-first 8の削除対象、Phase 2の入口を相互リンクする。

## 検証順序

各Stageで最小testを先に実行し、最終的に次をこの順で完走させる。

```powershell
flutter test test/unit/features/sync/ test/unit/features/word_status/ test/unit/features/my_word/ test/unit/features/user/
flutter test test/unit/app/session/ test/unit/app/guest_migration/ test/unit/app/bootstrap/ test/unit/app/routing/
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check
flutter analyze
flutter test
```

remote transactionを導入した場合は、対応するFirebase Emulator integration testを全体test前に実行する。

## contexts更新方針

- `current.md`には「完了した事実」と「次の実行ゲート」だけを記載する。
- `next-phase-guide.md`は古いセッション履歴を現在状態として残さず、経緯が必要なものはplanへ移す。
- 未対応事項には、問題、根拠、実施しなかった理由、所有する後続フェーズを必ず付ける。
- Phase 1-7完了後の次タスクはLocal-first 8とする。Phase 2へ直接進めない。

## 完了条件

- [x] 5 dataset handlerがaccount/session失効後にack、local apply、checkpoint更新を行わない（guardとrollbackを実装済み）。
- [ ] account切替をhandlerの各待機点で再現するcontract testが通る。
- [x] retry delayが実attempt回数に基づき、queue attempt・分類・上限・jitterの実装/testが存在する（全体品質ゲートは別途確認）。
- [ ] remote writeがmutation ID、revision、schema versionを扱い、重複deliveryが冪等である。
- [ ] MyWordの`baseRemoteRevision`競合、field merge、tombstone競合testが通る。
- [ ] guest migrationがcurrent sessionへだけtransactionalに適用され、accept/cancel/retry/rollback/collisionがtestされている。
- [x] `AppSession`とProfile UIがFirebase identity + Drift profile live streamから派生する。
- [ ] Phase 1のcomposition、routing、ownership、word status統合の未完了条件が解消されている。
- [x] `test/**`がanalyzerとimport境界検査の対象である。
- [ ] import境界baselineへ新規違反を追加せず、Phase 1対象違反が0である。
- [ ] clean checkoutとCIで`flutter analyze`、import境界チェック、`flutter test`が成功する。
- [ ] contextsとPhase 1/Local-first文書が現行実装・検証結果と一致する。
- [ ] Local-first 8の開始条件と削除対象が明確で、Phase 2が未着手のままである。

## 中断条件

次の場合は推測で実装を続けず、該当Stageを停止して設計判断を記録する。

- remote revision導入にSecurity Rules/backend変更が必要だが、repository内に契約が存在しない。
- guest profileの生成経路・所有権が確認できず、移管対象に含めるか決められない。
- public API例外がfeature間の任意importを再許可する形になる。
- CIを通すために挙動変更を伴う大量rename/削除が必要になり、Stageの責務を超える。
- migrationまたは競合処理に既存remote dataを破壊する可能性がある。

## LLMへの引き継ぎ事項

Stageを飛ばさない。特にimport baseline更新、test skip、analyzer除外、旧sync削除を「先に通す」目的で行わない。安全性をcharacterization testで固定し、protocolを完成させ、境界を閉じてから文書を完了へ更新する。
