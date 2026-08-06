# Runtime and Current Status

最終更新: 2026-08-06

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
2. `features/sync/application`と`features/sync/infrastructure`にはLocal-first 1〜4の共通基盤があり、`syncDatasetHandlerRegistryProvider`はword status（Esp-Jpn/Jpn-Esp）向けの本番`DatasetSyncHandler`2件を登録済み（Local-first 5、2026-08-06）。MyWord/User Profile向けhandlerは未登録。
3. word statusの自動同期は新`SyncEngine`（`syncSchedulerProvider.foreground(...)`）が担当する。MyWord/MyWordStatusは引き続き`features/sync/sync_service.dart`と旧`ISyncUseCase`群が担当している。
4. Drift schema v6で`account_id`、`local_revision`、`remote_revision`、tombstone、`sync_outbox`、`sync_checkpoints`、`user_profiles`は入っている。ただしRepositoryの多くはlocal更新とFirebase更新を同じRepositoryから直接呼んでいる。
5. route contractは`app/routing/contracts`へ抽出済み。GoRouter定義はまだ`lib/router/**`が主で、`app/routing/router.dart`は旧router exportのbridge。
6. Auth lifecycleは`core/application/auth_lifecycle`が現在の中心。Phase 1-4で`app/session`（`appSessionProvider`/`currentSessionProvider`）を導入し、Router/autoSync/profile UI/user向けmutation usecase 9件はそこから派生する。legacy同期usecaseとguest統合は未対応（[`phase1.4-introduce-current-session.plan.md`](plans/phase1.4-introduce-current-session.plan.md)参照）。
7. `tool/import_boundaries`は導入済み。baselineは既存違反を固定する台帳であり、違反があること自体は現状を表す。

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
                 on AppSessionReady / app resume (word status datasets only)
      -> MyApp
          -> routerProvider from lib/router/router.dart
          -> MaterialApp.router + DatabaseLoadingOverlay
```

## 同期の現在地

```text
active legacy path (MyWord/MyWordStatus):
  authLifecycleProvider.isReady
    -> autoSyncProvider
    -> SyncService
    -> legacy ISyncUseCase implementations (SyncMyWordInteractor, SyncMyWordStatusUsecase)
    -> Repository reads/writes local and remote directly

active new-engine path (Esp-Jpn/Jpn-Esp word status, Local-first 5):
  appSessionProvider becomes AppSessionReady, or app resumed
    -> applicationLifecycleEffectsProvider triggers syncSchedulerProvider.foreground(...)
    -> SyncEngine.runOnce
    -> DatasetPlan.localFirst
    -> DatasetHandlerRegistry([EspJpnWordStatusSyncHandler, JpnEspWordStatusSyncHandler])
    -> DriftSyncQueue / DriftSyncCheckpointStore (push field-mask patches, pull+merge remote snapshots)

prepared but inactive (MyWord/User Profile handlers, Local-first 6-7):
  same SyncEngine, but DatasetHandlerRegistry has no handler for myWords/myWordStatus/userProfile yet
```

## 読み替えの注意

- `SyncEngine`は現在word status 2 datasetの本番同期を担う。MyWord/User Profileはまだ新Engineへ切り替わっていない。
- `WordStatusRepository`/`JpnEspWordStatusRepository`の通常usecase経由の書き込みはoutbox+`DatasetSyncHandler`を通る。旧`SyncEspJpnWordStatusInteractor`は`SyncService`から外れ、実行経路には残っていない（クラスファイル自体は削除していない）。
- 旧`SyncService`、旧sync usecase、Repository内のremote直書きは、MyWord/MyWordStatusについて依然として現役経路である。
- `app/routing/contracts`があることは、GoRouter本体が移動済みであることを意味しない。