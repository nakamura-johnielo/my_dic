# Runtime and Current Status

最終更新: 2026-08-07

## 調査範囲

- 対象: `lib/**/*.dart`
- 手書きDart: 510 files
- 生成Dart: 18 files under `lib/__generated/**`
- 生成物は責務の正本ではなく、Drift/freezed/build_runnerの出力として扱う。

手書きファイルの分布:

| area | files | 現状の意味 |
| --- | ---: | --- |
| `lib/app` | 10 | 起動、composition root、routing contractの新しい入口 |
| `lib/core` | 195 | 旧横断レイヤ、辞書カタログ、DB、共通UI/enum/error/DI |
| `lib/features` | 296 | auth/status/my_word/quiz/ranking/search/sync/user/word_pageのfeature実装 |
| `lib/router` | 5 | 旧GoRouter定義とNavigator serviceの実体 |
| top-level files | 3 | `main.dart`、`main_activity.dart`、Firebase options |
| `lib/native_API` | 1 | Androidキーボード制御のplatform helper |

## 現在の大きな結論

1. `app/bootstrap`は新しいcomposition rootの入口になっているが、DB probeと横断effect起動が`AppReadinessGate`に残っている。
2. `features/sync/application`と`features/sync/infrastructure`にはLocal-first共通基盤があり、`syncDatasetHandlerRegistryProvider`はEsp-Jpn、Jpn-Esp、MyWord、MyWordStatus、User Profileの本番`DatasetSyncHandler`5件を登録済み。全handlerへ`SyncExecutionGuard`が注入される。
3. 5 datasetの自動同期は新`SyncEngine`（`syncSchedulerProvider.foreground(...)`）が担当する。handlerはremote commit後のack前、remote例外後のqueue遷移前、pull apply/checkpoint/transaction commit前にsessionを検証する。transaction内の失効はrollback後に`DatasetSyncCancelled`となる。
4. Drift schema v6で`account_id`、`local_revision`、`remote_revision`、tombstone、`sync_outbox`、`sync_checkpoints`、`user_profiles`は入っている。対象5 datasetの通常書き込みはDrift+outboxへ移行済み。一方、local列が存在してもremote revision/server acknowledgment/idempotency protocolは未実装である。
5. route contractは`app/routing/contracts`へ抽出済み。GoRouter定義はまだ`lib/router/**`が主で、`app/routing/router.dart`は旧router exportのbridge。
6. Auth lifecycleは`core/application/auth_lifecycle`が現在の中心。`appSessionProvider`はFirebase identityとaccount-scoped Drift `watchProfile`を合成し、Profile UIもこのlive stateをwatchする。guest migrationは承認後とtransaction開始/commit直前にsessionを再検証し、失効時は5 datasetのrow/outboxをrollbackする。
7. `tool/import_boundaries`は`lib/**`と`test/**`を走査する差分が入り、fixture専用除外とtest source mappingを持つ。`analysis_options.yaml`でも`test/**`は除外されていない。baseline照合・analyze・全testのclean checkout最終結果は未確定。

## 現在の実行経路

```text
main.dart
  -> AppBootstrap
      -> Firebase.initializeApp / SharedPreferences load
      -> ProviderScope(sharedPreferences override)
      -> AppReadinessGate
          -> databaseProvider SELECT 1
          -> applicationLifecycleEffectsProvider
              -> authEffectProvider
              -> legacy autoSyncProvider
              -> creates syncSchedulerProvider and triggers foreground sync
                 on AppSessionReady / app resume (5 local-first datasets)
      -> MyApp
          -> routerProvider from lib/router/router.dart
          -> MaterialApp.router + DatabaseLoadingOverlay
```

## 同期の現在地

```text
active new-engine path (5 datasets):
  appSessionProvider becomes AppSessionReady, or app resumed
    -> applicationLifecycleEffectsProvider triggers syncSchedulerProvider.foreground(...)
    -> SyncEngine.runOnce
    -> DatasetPlan.localFirst
    -> DatasetHandlerRegistry([
         EspJpnWordStatusSyncHandler, JpnEspWordStatusSyncHandler,
         MyWordSyncHandler, MyWordStatusSyncHandler, UserProfileSyncHandler
       ])
    -> SyncExecutionGuard(accountId + sessionEpoch + CancellationToken)
    -> DriftSyncQueue / DriftSyncCheckpointStore (push field-mask patches, pull+merge remote snapshots)

legacy compatibility surface:
  old SyncService / legacy ISyncUseCase classes and providers remain where tests
  or Local-first 8 removal work still references them; they are not the active
  production path for the five registered datasets
```

Retryはlease時点の`attemptCount`を運び、handlerが次のattemptに対応するbackoffを計算する。remote revision、server-confirmed ack、mutation ID重複deliveryのno-op、MyWordの`baseRemoteRevision`競合処理は未接続である。repository内に対応するbackend/Security Rules契約がないため、Phase 1-7の中断条件として設計判断を待つ。

## 読み替えの注意

- `SyncEngine`は現在5 datasetの本番同期を担う。
- `WordStatusRepository`/`JpnEspWordStatusRepository`の通常usecase経由の書き込みはoutbox+`DatasetSyncHandler`を通る。旧`SyncEspJpnWordStatusInteractor`は専用interface・di provider・test直接参照ごと完全に削除済み（2026-08-06セッション3）。両Repository/interfaceはFirebase操作メソッドを一切持たない。
- 旧`SyncService`、旧sync usecase/providerはLocal-first 8の削除対象として一部残るが、5 handler registryとは別の互換surfaceである。
- `app/routing/contracts`があることは、GoRouter本体が移動済みであることを意味しない。
- session guardとretry収束はremote protocol完成を意味しない。remote revision/idempotency、MyWord競合、routing/composition残件は未完了である。2026-08-07の現working treeではimport checker、`flutter analyze`（0 issues）、全`flutter test`（266 test）が成功したが、clean checkoutとCIでの再現は未確認。
