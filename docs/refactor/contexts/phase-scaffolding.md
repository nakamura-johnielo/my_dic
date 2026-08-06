# Phase Scaffolding

最終更新: 2026-08-06

この文書は、未使用または未接続に見えるが後続フェーズで使う足場をまとめる。削除判断の前に確認する。

## Phase 0で固定済みの安全契約

| file / area | 責務 | 後続での扱い |
| --- | --- | --- |
| `core/shared/utils/logger.dart` | `AppLogger.event`でtoken/password/email/UID等をredactするログ境界 | SyncEngine、Auth、profile、remote adapterのログはここを使い、識別子やpayloadを生で出さない |
| `core/infrastructure/database/drift/database_provider.dart` | Drift DB、migration、web seed、v5/v6 migration、DB lifecycleの正本 | schema更新時はmigration fixture testを追加。旧rowを暗黙に現在accountへ帰属させない |
| `core/domain/entity/sync_checkpoint.dart` | legacy checkpointを`accountId + dataset`でscopeする値 | Local-first移行時にSharedPreferences cursorへ戻らない。Drift cursorへ段階移行 |
| `core/shared/value_objects/field_update.dart` | 部分更新で`unchanged`と`set(false)`を区別する値 | word statusやprofile patchのfield mask生成に使う |
| `core/application/auth_lifecycle/**` | Auth identity、email verification、User profile provisioningを調停 | Phase 1-4のCurrentSession入力源。未認証を空IDで表現しない |

## Local-first 1〜4で作られた共通基盤

| file / area | 責務 | 現在の接続状態 |
| --- | --- | --- |
| `core/shared/enums/sync_dataset.dart` | stable dataset IDの正本 | 永続化/remote protocol用。enum indexに依存しない |
| `features/sync/application/model/**` | `SyncContext`、`SyncCursor`、`SyncMutation`、`SyncReport`などの契約 | handler実装が使う想定。production handlerは未接続 |
| `features/sync/application/port/**` | queue/checkpoint/outbox/session/handler port | Drift実装は存在。feature固有remote adapterはまだ未接続 |
| `features/sync/application/sync_engine.dart` | dataset順序、依存skip、cancel、single-flight、report生成 | registryが空なので本番同期は走らない |
| `features/sync/infrastructure/persistence/drift/**` | Drift永続outbox、queue、checkpoint store | Local-first 5〜7で業務row更新と同一transactionへ接続する |
| `app/bootstrap/sync_composition.dart` | 新SyncEngine基盤のcomposition | registryは`const []`。未使用に見えても削除しない |

## Phase 1-1〜1-3の入口

| file / area | 責務 | 現在の接続状態 |
| --- | --- | --- |
| `app/bootstrap/app_dependencies.dart` | ProviderScope前に必要なFirebase/SharedPreferences初期化 | DB/Router/SyncEngineは入れない方針 |
| `app/bootstrap/bootstrap.dart` | `AppBootstrap`、readiness gate、bootstrap error/loading UI | DB probeとeffect起動がまだここに残る |
| `app/bootstrap/lifecycle_effects.dart` | アプリ横断effectの単一起動点 | 旧auth effectと旧auto syncを起動。新SyncEngine triggerは未実装 |
| `app/routing/contracts/**` | URL復元可能なpure route contract | `word_detail`と`quiz_game`は導入済み |
| `app/routing/router.dart` | 旧router exportのbridge | routing本体はまだ`lib/router/router.dart` |
| `tool/import_boundaries/**` | import境界の検査器・rules・baseline | 新規違反を増やさないために使う |

## 足場か残骸かの見分け方

- Local-first 1〜4の基盤は、production handler未登録でも足場である。
- Auth lifecycleはCurrentSession導入前の中心であり、削除対象ではない。
- 旧routerは現役で、`app/routing`へ移し切るまでは削除しない。
- コメントアウトCoordinator、`copy.dart`、typo file、未使用PresenterはPhase 3で扱う削除候補である。