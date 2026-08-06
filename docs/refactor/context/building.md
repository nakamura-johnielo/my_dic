# 将来フェーズ用の実装メモ

## 目的

この文書は、Phase 0-1〜0-6、Local-first 1〜4、Phase 1-1〜1-3のリファクタ中に作られたが、現時点ではまだ本格利用していない、または後続フェーズで育てる前提のファイルを見失わないためのメモである。

Phase 0の主目的はデータ消失・機密情報・不成立フローの止血、Local-first 1〜4の主目的は共通sync contract/schema/queue/engineの構築、Phase 1-3までの主目的はcomposition root、import境界、route contractの入口を作ることだった。そのため、production dataset切替、CurrentSession導入、feature ownership整理、旧sync削除までは意図的に踏み込んでいない足場が残っている。

## 読み方

- 「今の状態」は、Phase 0、Local-first 1〜4、Phase 1-3完了時点でどこまで接続されているかを示す。
- 「将来の使い道」は、後続phaseでこのファイルをどう扱うかを示す。
- ここに載っているファイルは、未使用に見えても削除候補ではなく、後続phaseの接続点として確認する。

## Phase 0: 止血で固定した契約

Phase 0の成果は、後続リファクタで壊してはいけない安全契約である。大きく動かす前に、ここで追加された型・テスト・境界を確認する。

### [lib/core/shared/utils/logger.dart](../../../lib/core/shared/utils/logger.dart)

今の状態:

- `AppLogger.event`が構造化eventを出力し、context内のtoken、password、Authorization、credential、secret、cookie、email、UID、account/user/device IDをkey単位で再帰的にredactする。
- Phase 0-1で、認証成功/失敗やprofile/sync周辺のログから秘密値・個人識別子・生例外を出さない方針に寄せた。
- [test/unit/core/shared/utils/logger_test.dart](../../../test/unit/core/shared/utils/logger_test.dart) と [test/security/sensitive_auth_logging_test.dart](../../../test/security/sensitive_auth_logging_test.dart) が再混入検査の土台になっている。

将来の使い道:

- SyncEngine、dataset handler、CurrentSession、profile provisioningのログを追加する時は、まず`AppLogger.event`を使う。
- Phase 2-6で`SyncReport`をUIへ出す時も、remote payloadやtokenをreport/logへ含めない基準にする。

注意点:

- redactionは防御線であり、秘密値を渡してよいという意味ではない。新しいログcontextは識別子そのものではなく、状態名・error type・dataset名を中心にする。

### [lib/core/infrastructure/database/drift/database_provider.dart](../../../lib/core/infrastructure/database/drift/database_provider.dart)

今の状態:

- `DatabaseProvider.forTesting`により、旧SQLite fixtureを現行Drift migrationで開くテスト経路がある。
- Phase 0-2でv5 migrationのMyWord ID変換と孤立status検出が固定され、Local-first 2でschema v6、account scope、sync tableが追加された。
- [test/unit/core/infrastructure/database/drift/database_provider_migration_test.dart](../../../test/unit/core/infrastructure/database/drift/database_provider_migration_test.dart) がmigration fixtureの中心になる。

将来の使い道:

- schemaを上げる時は、v1〜現行versionからのfixture migrationをここに追加する。
- Local-first 5〜7でproduction datasetをDrift SoTへ切り替える前に、旧user-owned rowが`legacy_unowned`として残ること、現在UIDへ暗黙帰属しないことを確認する。

注意点:

- migrationで対応不能な関連を黙ってdropしない。旧table dropやcursor削除は、件数・関連・値の検証後だけにする。

### [lib/core/domain/entity/sync_checkpoint.dart](../../../lib/core/domain/entity/sync_checkpoint.dart)

今の状態:

- Phase 0-3で`SyncCheckpointKey(accountId, dataset)`と`SyncCheckpoint(lastSuccessfulAt, remoteCursor)`が追加され、legacy sync checkpointもaccount/dataset scopedになった。
- [lib/core/infrastructure/database/shared_preferences/shared_preferences_syncstatus_dao.dart](../../../lib/core/infrastructure/database/shared_preferences/shared_preferences_syncstatus_dao.dart) は`sync_checkpoint.v1.<encoded accountId>.<dataset>` namespaceで保存する。
- [test/unit/core/infrastructure/database/shared_preferences/shared_preferences_syncstatus_dao_test.dart](../../../test/unit/core/infrastructure/database/shared_preferences/shared_preferences_syncstatus_dao_test.dart) がSharedPreferences版checkpointの分離を固定している。

将来の使い道:

- Local-first 5〜7では、旧SharedPreferences checkpointをそのままDrift cursorへコピーしない方針を維持する。
- Drift版[lib/features/sync/infrastructure/persistence/drift/drift_sync_checkpoint_store.dart](../../../lib/features/sync/infrastructure/persistence/drift/drift_sync_checkpoint_store.dart)へ切り替える時も、account/dataset分離と完全成功時だけ進める保証を引き継ぐ。

注意点:

- `remoteCursor`は後続のserver cursor移行用に確保された互換フィールド。client時刻だけを新しい進捗根拠に戻さない。

### [lib/core/shared/value_objects/field_update.dart](../../../lib/core/shared/value_objects/field_update.dart)

今の状態:

- Phase 0-5で、部分更新の`unchanged`と`set(false)`を区別する値objectとして追加された。
- Esp-Jpn/Jpn-Esp status update inputとrepository inputがこの差分契約を使う。
- [test/unit/features/word_status/status_update_contract_test.dart](../../../test/unit/features/word_status/status_update_contract_test.dart) が、bookmark/learned/hasNoteの部分更新と`set(false)`の扱いを固定している。

将来の使い道:

- Local-first 5でword statusをoutbox patchへ移す時、`fieldMask`生成の正本にする。
- User Profileの編集可能fieldをpatch化する時も、同じ「未指定」と「明示的false/空値」の区別を再利用できる。

注意点:

- domain/application層へDB固有の`0 / 1 / null`表現を戻さない。
- 変更fieldがないcommandはtimestampを進めないno-opとして扱う現行契約を維持する。

### [lib/core/application/auth_lifecycle](../../../lib/core/application/auth_lifecycle)

今の状態:

- Phase 0-6で`AuthLifecycleController`と`AuthLifecycleState`が追加され、Auth identityとUser Profile provisioningを別Repositoryのまま調停している。
- `initializing / signedOut / creatingAccount / sendingVerificationEmail / emailUnverified / reloadingIdentity / provisioningProfile / ready`などの状態と、再試行可能な失敗状態を持つ。
- [lib/features/sync/di.dart](../../../lib/features/sync/di.dart) のlegacy `autoSyncProvider`は`authLifecycleProvider.select((s) => s.isReady)`を開始条件にしている。

将来の使い道:

- Phase 1-4で`CurrentSession`を導入する時の入力源にする。
- Local-first 7でUser ProfileをDrift SoTへ移す時、profile provisioning完了後だけsyncを始める契約を維持する。
- Phase 2-4でCoordinatorから`Ref`を外す時、可変Storeではなくlifecycle stateと明示portへ依存を寄せる。

注意点:

- 未認証を空accountIdの`AppAuth`で表現しない。`signedOut`/`null`系の表現へ寄せる。
- email未確認やprofile provisioning失敗を`ready`扱いにしない。

### [test/unit/features/sync/result_propagation_test.dart](../../../test/unit/features/sync/result_propagation_test.dart) と [test/unit/features/sync/sync_checkpoint_scoping_test.dart](../../../test/unit/features/sync/sync_checkpoint_scoping_test.dart)

今の状態:

- Phase 0-3/0-4で、checkpointを部分失敗時に進めないこと、Repository failureを`success(null)`や空配列へ変換しないことがcharacterization test化された。
- legacy sync UseCaseはまだ残っているが、failure伝播とaccount/dataset分離の契約は固定済み。

将来の使い道:

- Local-first 5〜7で旧UseCaseから新handlerへ置き換える時、同じ失敗伝播・checkpoint非更新の期待値を移植する。
- Phase 2-6で`SyncReport`を消費する時、failure datasetを成功扱いに潰していないか確認する。

注意点:

- `Result.runtimeType`で失敗種別を判定する実装を戻さない。
- nullable lookupの不存在は`Result.success(null)`だけで表し、`Result.failure(NotFoundError)`をcreate pathへ変換しない。

## Local-first 1〜4: 完了済み共通基盤

Local-first 1〜4では、production dataset handlerを登録せず、共通基盤だけを完成させている。後続のLocal-first 5〜7では、ここにあるcontract/schema/queue/engineへdatasetを1つずつ接続する。

### Local-first 1: contractとdataset ID

主なファイル:

- [lib/core/shared/enums/sync_dataset.dart](../../../lib/core/shared/enums/sync_dataset.dart)
- [lib/features/sync/application/model](../../../lib/features/sync/application/model)
- [lib/features/sync/application/port](../../../lib/features/sync/application/port)
- [lib/features/sync/application/policy](../../../lib/features/sync/application/policy)

今の状態:

- `esp_jpn_word_status`、`jpn_esp_word_status`、`my_words`、`my_word_status`、`user_profile`のstable IDが固定された。
- `SyncContext`、`SyncCursor`、`SyncMutation`、`MutationLease`、`DatasetSyncResult`、`SyncReport`、handler/queue/checkpoint/session portがある。
- [test/unit/features/sync/application/sync_contract_test.dart](../../../test/unit/features/sync/application/sync_contract_test.dart) がstable ID、cursor順序、immutable contractを固定している。

将来の使い道:

- feature固有handlerはこのcontractへ合わせ、独自の文字列dataset IDや独自cursor表現を増やさない。
- remote documentの`revision`、`updatedAt`、`lastMutationId`、`deletedAt`、`schemaVersion`を扱う時の共通語彙にする。

### Local-first 2: Drift v6 schema

主なファイル:

- [lib/core/infrastructure/database/drift/tables/sync/sync_outbox.dart](../../../lib/core/infrastructure/database/drift/tables/sync/sync_outbox.dart)
- [lib/core/infrastructure/database/drift/tables/sync/sync_checkpoints.dart](../../../lib/core/infrastructure/database/drift/tables/sync/sync_checkpoints.dart)
- [lib/core/infrastructure/database/drift/tables/sync/user_profiles.dart](../../../lib/core/infrastructure/database/drift/tables/sync/user_profiles.dart)
- [lib/core/infrastructure/database/drift/tables/esp_jpn/word_status.dart](../../../lib/core/infrastructure/database/drift/tables/esp_jpn/word_status.dart)
- [lib/core/infrastructure/database/drift/tables/jpn-esp/jpn_esp_word_status.dart](../../../lib/core/infrastructure/database/drift/tables/jpn-esp/jpn_esp_word_status.dart)

今の状態:

- schema v6でuser-owned rowにaccount scope、local/remote revision、tombstone列が追加された。
- `sync_outbox`と`sync_checkpoints`がDrift管理になり、queue/cursorをtransactionで守れる形になった。
- 既存unscoped rowは`legacy_unowned`へ寄せる方針になっている。

将来の使い道:

- Local-first 5〜7で、業務row更新とoutbox enqueue、remote反映とcheckpoint更新を同一Drift transactionへ入れる。
- guest統合やaccount切替では、`legacy_unowned`、signed-in account、別accountのrowを混ぜない検証に使う。

### Local-first 3: Drift SyncQueue

主なファイル:

- [lib/features/sync/infrastructure/persistence/drift/drift_outbox_writer.dart](../../../lib/features/sync/infrastructure/persistence/drift/drift_outbox_writer.dart)
- [lib/features/sync/infrastructure/persistence/drift/drift_sync_queue.dart](../../../lib/features/sync/infrastructure/persistence/drift/drift_sync_queue.dart)
- [test/support/contracts/sync_queue_contract.dart](../../../test/support/contracts/sync_queue_contract.dart)
- [test/helpers/sync/fake_sync_queue.dart](../../../test/helpers/sync/fake_sync_queue.dart)
- [test/unit/features/sync/drift_sync_queue_contract_test.dart](../../../test/unit/features/sync/drift_sync_queue_contract_test.dart)

今の状態:

- pending mutationのlease、ack、retry、deadLetter、expired lease releaseがDrift永続queueとして実装されている。
- fake実装とDrift実装へ同じcontract testを適用する構造がある。

将来の使い道:

- dataset handlerのpush処理はこのqueueを通し、server-confirmed acknowledgment後だけackする。
- remote failure後の再送、process kill後の復旧、古いackで新revisionを消さない保証の中心にする。

### Local-first 4: SyncEngineとSyncReport

主なファイル:

- [lib/features/sync/application/sync_engine.dart](../../../lib/features/sync/application/sync_engine.dart)
- [lib/features/sync/application/sync_scheduler.dart](../../../lib/features/sync/application/sync_scheduler.dart)
- [lib/features/sync/application/in_memory_session_fence.dart](../../../lib/features/sync/application/in_memory_session_fence.dart)
- [lib/features/sync/application/single_flight_coordinator.dart](../../../lib/features/sync/application/single_flight_coordinator.dart)
- [test/unit/features/sync/application/sync_engine_test.dart](../../../test/unit/features/sync/application/sync_engine_test.dart)

今の状態:

- `SyncEngine.runOnce(SyncContext)`がdataset別の`SyncReport`を返す。
- 同一accountのsingle-flight、rerun request、session epoch cancel、依存dataset skip、handler exceptionのfailure化が実装されている。
- [lib/app/bootstrap/sync_composition.dart](../../../lib/app/bootstrap/sync_composition.dart) ではregistryを空にしてあり、production dataset handlerはまだ登録していない。

将来の使い道:

- Local-first 5〜7でdataset handlerを追加し、旧`SyncService`からdataset単位に切り替える。
- Phase 1-4の`CurrentSession`から`accountId`と`sessionEpoch`を渡し、account切替時に旧cycleをcancelする。

注意点:

- Local-first 1〜4の完了は「共通基盤ができた」状態であり、「production syncが新Engineへ切り替わった」状態ではない。

## app/bootstrap: composition rootの足場

### [lib/app/bootstrap/app_dependencies.dart](../../../lib/app/bootstrap/app_dependencies.dart)

今の状態:

- `Firebase.initializeApp`と`SharedPreferences.getInstance`のように、`ProviderScope`より前に一度だけ必要な依存を束ねる。
- Drift DBやGoRouterなど、Riverpod providerがlifecycleを持つべき長寿命resourceはここに入れない設計になっている。

将来の使い道:

- Phase 1-1/Phase 2-3で、起動前初期化とprovider所有resourceの境界を崩さないための基準にする。
- test bootstrapでは`AppBootstrapper`を差し替え、Firebaseや実SharedPreferencesへ接続しない検証に使う。

注意点:

- 便利だからといってDB、Router、SyncEngineを`AppDependencies`へ詰め込まない。生成・破棄責務がRiverpodから外れる。

### [lib/app/bootstrap/bootstrap.dart](../../../lib/app/bootstrap/bootstrap.dart)

今の状態:

- `main()`から`AppBootstrap`が呼ばれ、Firebase/SharedPreferences初期化後に`ProviderScope`を作る。
- `AppReadinessGate`がDB probeと`applicationLifecycleEffectsProvider`の起動を担当する。
- `MyApp.build()`自体は`MaterialApp.router`描画に寄っているが、readiness providerにはまだDB probeが残る。

将来の使い道:

- Phase 1-1のcomposition root本体として、DB lifecycle、router、横断effect、sync schedulerの所有をここから辿れる状態にする。
- Phase 2-3で、起動時I/Oの成功・失敗・disposeをbootstrap testで固定する。

注意点:

- `AppReadinessGate`は移行用の入口であり、今後は「build中に副作用を増やさない」方向で整理する。

### [lib/app/bootstrap/lifecycle_effects.dart](../../../lib/app/bootstrap/lifecycle_effects.dart)

今の状態:

- アプリ横断effectの所有者。
- 既存の`authEffectProvider`とlegacy `autoSyncProvider`を起動している。
- 新しい`SyncEngine` triggerはまだ本格接続していない。`syncSchedulerProvider`は生成されるだけで、具体的な`SyncContext`を渡していない。

将来の使い道:

- Phase 1-4で`CurrentSession`/session epochと接続する。
- Local-first 5〜7で、startup、resume、network復帰、local mutation wakeを`SyncScheduler`へ流す。
- 旧`autoSyncProvider`をLocal-first移行完了後に外す。

注意点:

- Widgetやfeatureから横断effectを直接watchしない。ここを単一起動点にする。

### [lib/app/bootstrap/sync_composition.dart](../../../lib/app/bootstrap/sync_composition.dart)

今の状態:

- 新Local-first基盤のcompositionだけが先に置かれている。
- `DriftSyncQueue`、`DriftSyncCheckpointStore`、`DriftOutboxWriter`、`InMemorySessionFence`、`SingleFlightCoordinator`、`SyncEngine`、`SyncScheduler`のproviderがある。
- `syncDatasetHandlerRegistryProvider`は`DatasetHandlerRegistry(const [])`なので、本番dataset handlerはまだ登録されていない。

将来の使い道:

- Local-first 5でword status、6でMyWord、7でUser Profileの`DatasetSyncHandler`をここへ登録する。
- `app/bootstrap`だけがfeature固有sync adapterを組み立てる、というimport境界の実例にする。

注意点:

- registryが空のため、今の`SyncEngine.runOnce()`はdatasetごとに`handler unavailable`でskipする。未使用に見えるのは意図された中間状態。
- feature/UI/通常UseCaseからremote adapterやqueueを直接resolveしない。

## app/routing: route contractの足場

### [lib/app/routing/contracts/route_parse_result.dart](../../../lib/app/routing/contracts/route_parse_result.dart)

今の状態:

- route parameter parseの成功/失敗を表すpure Dart型。
- `state.extra as ...`のような強制castを避けるための共通結果型。

将来の使い道:

- route builderでinvalid/missing parameterをerror pageへ落とす標準型として使う。
- route contract追加時は、例外ではなく`RouteParseFailure`を返す形に揃える。

### [lib/app/routing/contracts/word_detail_route.dart](../../../lib/app/routing/contracts/word_detail_route.dart)

今の状態:

- word detail画面のURL復元可能なcontract。
- `wordId`はpath、`type`と`hasConj`はquery parameterで表す。
- Widget/View型への依存はない。

将来の使い道:

- Search、Ranking、Quiz、WordPageからword detailへ遷移する時の共有契約として維持する。
- Phase 1-5のcatalog ownership整理で、`WordType`やdetail表示に必要な値の所有者を再確認する。

注意点:

- contractにViewModelやWidgetを入れない。
- deep link/refresh testを追加する時は、このparse結果とerror routeを直接検証する。

### [lib/app/routing/contracts/quiz_game_route.dart](../../../lib/app/routing/contracts/quiz_game_route.dart)

今の状態:

- quiz game画面のURL復元可能なcontract。
- `wordId`はpath、`word`はquery parameterで表す。
- Widget/View型への依存はない。

将来の使い道:

- Search、Ranking、WordPageからquizへ遷移する時の共有契約として維持する。
- Phase 1-5/Phase 2-5で、`word`をqueryで持つべきか、IDからquery projectionで再取得すべきかを見直す。

注意点:

- 大きな一時objectを`extra`で渡す方向へ戻さない。URLから復元できる値を優先する。

### [lib/app/routing/router.dart](../../../lib/app/routing/router.dart)

今の状態:

- 既存[lib/router/router.dart](../../../lib/router/router.dart)をexportする移行用entry point。
- `MyApp`はこのapplication-level entry pointをimportしている。

将来の使い道:

- Phase 1-3以降、routing利用側は`lib/router/**`ではなく`app/routing`側へ寄せる。
- 最終的にはGoRouter生成やroute定義も`app/routing`配下に移し、旧`lib/router/**`を削除候補にする。

注意点:

- これは完成形ではなく、参照方向を先に固定するためのbridge。

## features/sync/application: 新SyncEngine contract

### [lib/features/sync/application/sync_engine.dart](../../../lib/features/sync/application/sync_engine.dart)

今の状態:

- dataset順序、依存datasetのskip、session fence、cancellation、single-flight、rerun requestを扱う新sync実行器。
- 旧[lib/features/sync/sync_service.dart](../../../lib/features/sync/sync_service.dart)とはまだ置き換わっていない。

将来の使い道:

- Local-first 5〜7でdataset handlerを追加し、旧`SyncService`から段階的に切り替える。
- Phase 2-6でUI/ViewModelがdataset別の`SyncReport`を消費できるようにする。

注意点:

- handler未登録datasetはskipになる。これはproduction未接続を安全に表すための挙動。
- handler例外は`DatasetSyncResult.failed`へ変換されるため、呼び出し側は例外前提にしない。

### [lib/features/sync/application/sync_scheduler.dart](../../../lib/features/sync/application/sync_scheduler.dart)

今の状態:

- lifecycle adapterから呼ぶ薄い入口。
- `foreground(SyncContext)`だけがあり、Firebase/Drift/feature固有処理は持たない。

将来の使い道:

- `lifecycle_effects.dart`、CurrentSession、network/resume/local mutation wakeをSyncEngineへ接続する場所。
- trigger種別が増えても、feature側へscheduler責務を漏らさないための境界にする。

### [lib/features/sync/application/dataset_handler_registry.dart](../../../lib/features/sync/application/dataset_handler_registry.dart)

今の状態:

- `SyncDataset`ごとの`DatasetSyncHandler`を引けるregistry。
- 重複dataset handlerを拒否するtestがある。

将来の使い道:

- Local-first 5〜7で各dataset handlerを登録する。
- feature固有handlerの追加時に、登録先を`app/bootstrap/sync_composition.dart`へ限定する。

### [lib/features/sync/application/model](../../../lib/features/sync/application/model) と [lib/features/sync/application/port](../../../lib/features/sync/application/port)

今の状態:

- `SyncContext`、`SyncReport`、`DatasetSyncResult`、`SyncMutation`、`SyncCursor`、`MutationLease`がある。
- `DatasetSyncHandler`、`SyncQueue`、`OutboxWriter`、`SyncCheckpointStore`、`SessionFence`のportがある。
- collectionの不変化、cursor順序、dataset stable IDはtestで一部固定済み。

将来の使い道:

- feature handlerはこのportとmodelだけに依存し、Drift/Firebaseの詳細をapplication contractへ漏らさない。
- `SyncMutation`は業務row更新と同一transactionでoutboxへ積むためのcontractとして使う。

注意点:

- `SyncDataset.stableId`は永続化/remote protocolのIDなので、enum indexに依存しない。
- `SyncCursor`はserver timestamp + document IDのcursorとして扱い、client現在時刻だけを差分cursorにしない。

### [lib/features/sync/application/policy](../../../lib/features/sync/application/policy)

今の状態:

- `DatasetPlan`、`RetryPolicy`、`ExponentialBackoff`、`SyncErrorClassifier`がある。
- `DatasetPlan.localFirst`は全datasetを対象にするが、handler未登録ならskipする。

将来の使い道:

- dataset依存順序、retry/dead-letter/pause判定をhandler実装から切り離す。
- MyWord -> MyWordStatusのような親子dataset順序をLocal-first 6で固定する。

注意点:

- error classifierは安定したqueue state用codeへ変換する境界。Firebase/HTTPの生errorをqueue stateへ漏らさない。

## features/sync/infrastructure: Drift永続化の足場

### [lib/features/sync/infrastructure/persistence/drift/drift_outbox_writer.dart](../../../lib/features/sync/infrastructure/persistence/drift/drift_outbox_writer.dart)

今の状態:

- `OutboxWriter`のDrift実装。
- 同一`accountId`、`dataset`、`entityId`のpending mutationをmergeし、payload/fieldMask/localRevisionを更新する。

将来の使い道:

- Local-first 5〜7で、業務row更新と同一Drift transaction内でenqueueするために使う。
- dirty flagの二重管理ではなく、`sync_outbox`を唯一の未送信queueにする。

注意点:

- 現状はproviderとして組み立て済みだが、production UseCaseからはまだ使っていない。
- enqueueを業務更新後の別呼び出しに分けない。atomicity testを置いてから接続する。

### [lib/features/sync/infrastructure/persistence/drift/drift_sync_queue.dart](../../../lib/features/sync/infrastructure/persistence/drift/drift_sync_queue.dart)

今の状態:

- `SyncQueue`のDrift実装。
- pending lease、expired lease release、ack、retry、deadLetterを持つ。
- `MutationLease`はlease tokenとleased local revisionでack/retry対象を守る。

将来の使い道:

- Local-first 5〜7のpush配送で使う。
- process kill後のlease復旧、remote failure後のretry、server ack後だけ削除する保証の中心にする。

注意点:

- Firebase SDKのlocal cache受付をack扱いしない。server-confirmed acknowledgment後だけ`ack`する。

### [lib/features/sync/infrastructure/persistence/drift/drift_sync_checkpoint_store.dart](../../../lib/features/sync/infrastructure/persistence/drift/drift_sync_checkpoint_store.dart)

今の状態:

- `(accountId, dataset)`単位のserver cursorを読む/書くDrift実装。
- cursorは`seconds`、`nanoseconds`、`documentId`で保持する。

将来の使い道:

- pull反映と同一transactionでcursorを進める。
- dataset別部分失敗時に、失敗datasetのcursorを進めないことをtestで固定する。

### [lib/core/infrastructure/database/drift/tables/sync/sync_outbox.dart](../../../lib/core/infrastructure/database/drift/tables/sync/sync_outbox.dart) と [lib/core/infrastructure/database/drift/tables/sync/sync_checkpoints.dart](../../../lib/core/infrastructure/database/drift/tables/sync/sync_checkpoints.dart)

今の状態:

- schema v6で追加されたLocal-first用テーブル。
- `sync_outbox`はmutation、state、attempt、lease、error codeを保持する。
- `sync_checkpoints`は`accountId + dataset`をprimary keyにしたcursor table。

将来の使い道:

- Local-first 5〜7でproduction datasetを移す前に、migration fixtureとqueue contract testの正本にする。
- account切替時にrow、cursor、未送信mutationが混在しないことを検証する。

## tool/import_boundaries: 依存境界の検査器

### [tool/check_import_boundaries.dart](../../../tool/check_import_boundaries.dart)

今の状態:

- Dart CLIとしてimportを走査し、rules/baselineと比較する。
- package import、relative import、Windows separator、generated除外、feature cycleを扱う。
- 現在の走査対象は`lib/**`中心。Phase 1-2計画にある`test/**`対象化は後続確認が必要。

将来の使い道:

- Phase 1-5/1-6/Phase 2以降でfeature移動やownership整理を行う前後に必ず実行する。
- baselineを減らすPRでは、消えた違反が`removed baseline violation`として出ることを確認する。

### [tool/import_boundaries/rules.json](../../../tool/import_boundaries/rules.json)

今の状態:

- `domain_no_framework`、`core_no_feature`、`no_cross_feature_presentation`、`firebase_at_boundaries`、`sync_adapter_composition_only`を定義している。
- `core/application/auth_lifecycle/**`と`core/application/effects/**`はPhase 1-4までの一時例外。

将来の使い道:

- CurrentSession移設後、一時例外を削除する。
- Local-first remote adapterが入ったら、許可境界が`app/bootstrap`とsync remote adapterだけになっているか確認する。

### [tool/import_boundaries/baseline.json](../../../tool/import_boundaries/baseline.json)

今の状態:

- Phase 1-2導入時点の既存違反台帳。
- owner/trackingIssue付きで、既存違反を増やさないために使う。

将来の使い道:

- Phase 1後半からPhase 3にかけて、違反解消ごとにbaselineを削る。
- baseline追加は通常の実装PRでは行わず、理由と返済先を明示する。

### [docs/architecture/import-boundaries.md](../../architecture/import-boundaries.md) と [.github/workflows/quality.yml](../../../.github/workflows/quality.yml)

今の状態:

- ローカル実行コマンドとbaseline運用が文書化されている。
- CIで`flutter pub get`、`flutter analyze`、import境界check、`flutter test`を実行する設定がある。

将来の使い道:

- 境界違反を直す作業では、この文書を正本にする。
- Phase 1-5以降のfeature ownership整理で、新しい依存方向を増やさない安全網として使う。

## 旧実装との関係

### [lib/features/sync/sync_service.dart](../../../lib/features/sync/sync_service.dart) と [lib/features/sync/di.dart](../../../lib/features/sync/di.dart)

今の状態:

- 旧sync経路としてまだ稼働している。
- `lifecycle_effects.dart`からlegacy `autoSyncProvider`が起動される。
- 新`SyncEngine`とはまだproduction datasetを共有していない。

将来の使い道:

- Local-first 5〜7でdataset単位に新SyncEngineへ切り替える時、比較対象として確認する。
- Local-first 8で旧sync UseCaseと一緒に削除する。

注意点:

- 同じdatasetを旧`SyncService`と新`SyncEngine`で同時にproduction処理しない。
- Firestore listenerは最終的にwake signalだけにし、直接Drift更新へつながない。

## 次フェーズで最初に確認するチェックリスト

- Phase 1-4: `app/session`を作る前に、`auth_lifecycle`、`InMemorySessionFence`、`lifecycle_effects.dart`の責務分担を決める。
- Phase 1-5: `WordDetailRoute`/`QuizGameRoute`が持つ値のownerを確認し、必要ならquery projectionへ寄せる。
- Phase 1-6: word status datasetを統合する前に、`SyncDataset`のstable IDと既存remote pathの互換性を確認する。
- Local-first 5: 最初のproduction `DatasetSyncHandler`を追加する時は、`sync_composition.dart`のregistry登録、outbox atomicity test、cursor atomicity testを同じ作業単位で確認する。
- Phase 2-3: `AppReadinessGate`と`applicationLifecycleEffectsProvider`の起動がWidget rebuildで増えないtestを追加する。
- Phase 2-6: `SyncReport`をUI/Applicationへ返す時、失敗datasetを空配列や成功扱いへ潰さない。
- Phase 3: `lib/router/**`、旧`SyncService`、baseline例外を削る時は、先にdeep link test、sync contract test、import boundary checkを通す。