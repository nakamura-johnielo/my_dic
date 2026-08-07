# current.md: current context entry

最終更新: 2026-08-07

## Phase 2-1: application use-case migration complete

- Orchestration UseCases for Word status, MyWord/MyWordStatus, User/Auth,
  Search/Ranking, core catalog fetches, and Quiz fetches now live in their
  respective `application` layers.  Feature and core domain layers retain
  entities, value objects, repository ports, and domain-facing command data
  only.
- `CurrentSession`, account/guest scope, UTC timestamps, validation, filter
  and page requests are now resolved by application services.  Repository
  ports no longer import application request/DTO types; the application layer
  expands its inputs into domain enums, `FieldUpdate<bool>`, primitives, or
  domain command models.
- Legacy domain Presenter/UI callback contracts and their orchestration DTOs
  were removed for the migrated slices.  MyWord status adapter conversion of
  `FieldUpdate<bool>` to Drift `0/1/null` remains at the infrastructure
  boundary.  Existing local-first sync UseCases deliberately remain outside
  this migration, per the Phase 2-1 scope.
- Validation on 2026-08-07: `flutter analyze` reported no issues and the full
  `flutter test` suite passed (267 tests).  The import-boundary test is part
  of that successful suite.

## Phase 1-7 remote revision/server ack update

- All five dataset adapters now use a shared Firestore transaction request/ack
  contract. Remote documents carry `revision`, `lastMutationId`,
  `clientUpdatedAt`, server `updatedAt`, and `schemaVersion`; duplicate and
  stale mutations are returned as explicit acknowledgements.
- `SyncMutation.clientUpdatedAt` is required and UTC-normalized. Drift v7
  persists it in `sync_outbox` and backfills v6 rows from `created_at`.
  Handlers atomically guard local revision, persist remote metadata, and ack
  the lease; a superseded mutation is removed and the subsequent pull applies
  the authoritative remote snapshot. MyWord tombstones remain terminal.
- `firestore.rules` and Emulator configuration were added. Emulator Rules
  tests remain unexecuted because the installed JDK 8 cannot run the current
  firebase-tools requirement (JDK 21+); install the compatible JDK and add/run
  the Rules test harness in CI before treating Emulator coverage as complete.
  The remote contract, migration/queue, handler, import-boundary, and full
  Flutter suites passed on 2026-08-07 (270 tests); `flutter analyze` reported
  no issues.

## Convergence update: word status presentation boundary

- The shared status controls remain in `features/word_status`, while the
  dataset-specific view-model resolution now lives in `app/presentation`.
  This removes the reverse feature dependency and lets consuming features use
  an app-level composition adapter instead of importing another feature's
  presentation or DI layer.
- The import-boundary baseline no longer contains the resolved ranking status
  dependency or the Esp-Jpn/Jpn-Esp feature-cycle entries. The remaining
  baseline entries are intentionally unchanged.
- `FakeEspRankingRepository` now implements `getRankingById`, restoring test
  compilation after the repository contract expansion.

## Phase 1-7 convergence update

- `syncDatasetHandlerRegistryProvider`はEsp-Jpn、Jpn-Esp、MyWord、MyWordStatus、User Profileの5 handlerを本番登録済み。各handlerは`SyncExecutionGuard`でremote read/write、queue ack/retry/dead-letter、pull apply/checkpointをsession fenceし、pull transaction内の失効は例外でrollbackして`DatasetSyncCancelled`へ変換する。
- retryは`MutationLease.attemptCount`とDrift/Fake queue contractを通してactual attemptに接続済み。固定`delayForAttempt(1)`ではない。
- guest migrationはprompt承認後とtransaction開始/commit直前にaccount+epochを再検証し、失効時はrowとoutboxを同時rollbackする。
- User Profileはaccount-scoped Drift `watchProfile`をSoTとして`appSessionProvider`へ投影され、Profile UIもlive sessionをwatchする。
- import checkerは`lib/**`と`test/**`を走査する実装へ更新され、analyzerの`test/**`除外も削除された。2026-08-07の現working treeでimport checker、`flutter analyze`（0 issues）、全`flutter test`（270 test）は成功した。clean checkoutとCIでの再現は未確認。
- remote revision/server acknowledgment/mutation冪等性は7-2で実装済み。複雑なMyWord rebase/競合UI、Firestore Emulator Rules実行、routing、bootstrap composition、word-status契約統合の残件は完了扱いにしない。

このファイルは、長大な`lib/`責務調査メモを分割した後の短い入口である。詳細は目的別に分けた同階層の文書を参照する。

## まず読むもの

- [README.md](README.md): contexts全体の概要とindex
- [runtime-and-status.md](runtime-and-status.md): 現在の実行経路、同期経路、全体結論
- [phase-scaffolding.md](phase-scaffolding.md): Phase 0、Local-first 1〜4、Phase 1-1〜1-3で作った足場
- [app-routing.md](app-routing.md): top-level、`lib/app`、旧`lib/router`
- [core-map.md](core-map.md): `lib/core`配下の責務
- [feature-map.md](feature-map.md): `lib/features`配下の責務
- [next-phase-guide.md](next-phase-guide.md): 次フェーズ別の参照先、削除判断、チェックコマンド

## 現在の大きな結論

1. `app/bootstrap`は新しいcomposition rootの入口になっているが、DB probeと横断effect起動が`AppReadinessGate`に残っている。
2. `features/sync/application`と`features/sync/infrastructure`にはLocal-first 1〜4の共通基盤があり、`syncDatasetHandlerRegistryProvider`はword status（Esp-Jpn/Jpn-Esp）、MyWord/MyWordStatus、User Profileの本番`DatasetSyncHandler`5件を登録済み。handler内session guardとpull rollbackも接続済み。
3. word status・MyWord・MyWordStatus・User Profileの自動同期は新`SyncEngine`（`syncSchedulerProvider.foreground(...)`、`AppSessionReady`遷移時とapp resume時にtrigger）が担当するようになった。旧`features/sync/sync_service.dart`の`syncServiceProvider`は空配列となり実質無効化された（MyWord/MyWordStatus向け旧`ISyncUseCase`実装クラス自体とdi provider定義は`test/unit/features/sync/`のtestが直接参照するため未削除。esp_jpn word status向け旧`SyncEspJpnWordStatusInteractor`は専用interface・di provider・test参照ごと完全削除済み、2026-08-06セッション3）。
4. Drift schema v6でaccount scope、revision、tombstone、`sync_outbox`、`sync_checkpoints`、`user_profiles`は入っている。word status・MyWord・MyWordStatus・User Profileの通常usecase書き込みパスはoutbox経由に一本化済み。word status（Esp-Jpn/Jpn-Esp）はRepositoryインターフェース自体からもremoteメソッドを全除去済み。MyWord/MyWordStatusのRepositoryインターフェースは旧sync usecase向けのremoteメソッドを引き続き公開している（Local-first 8で削除予定）。Rankingは未移行。
5. route contractは`app/routing/contracts`へ抽出済み。GoRouter定義はまだ`lib/router/**`が主で、`app/routing/router.dart`は旧router exportのbridge。
6. Auth lifecycleは`core/application/auth_lifecycle`が現在の中心。`appSessionProvider`はFirebase identityとaccount-scoped Drift profile streamを合成し、profile loading/failure/readyを型で表す。Router、autoSync、Profile UI、user向けmutation usecaseはそこから派生する。`AuthStoreNotifier`、`AppUserStoreNotifier`は互換bridgeとして残る。
7. `tool/import_boundaries`は導入済み。baselineは既存違反を固定する台帳であり、違反があること自体は現状を表す。
8. Phase 1-5 slice 1（活用検索結果itemのcatalog化）が完了し、`feature:quiz`<->`feature:search`の双方向importと関連する`core_no_feature`違反3件を解消した。WordPageがQuiz/Searchの`di`層へ直接依存する3箇所と、`CardView`のsearch/quiz間再利用は未対応のまま残る。詳細は[`plans/phase1.5-define-catalog-ownership.plan.md`](plans/phase1.5-define-catalog-ownership.plan.md)と[`next-phase-guide.md`](next-phase-guide.md)。
9. Local-first 5（word status）はEsp-Jpn/Jpn-Espともoutbox→`DatasetSyncHandler`→Firestoreのpush/pullが本番接続された。read側は実accountId（guestは`guestAccountScope`）でスコープされ、guestからaccountへのtransactional移管もLocal-first 7で接続済み。旧`SyncEspJpnWordStatusInteractor`とRepository/interfaceのFirebase操作メソッドは削除済み。詳細は[`plans/local_first.5-migrate-word-status.plan.md`](plans/local_first.5-migrate-word-status.plan.md)。
10. Local-first 6（MyWord）は`MyWordRepository`と`MyWordStatusRepository`がDrift transaction+outbox enqueueへ切り替わり、`MyWordSyncHandler`/`MyWordStatusSyncHandler`がpush/pullを本番接続した。`DatasetPlan`でMyWordStatusはMyWordに依存し、read/account scopeとguest移管も接続済み。ただしremote revision競合とtombstone対古いupdateのremote protocolは未実装。詳細は[`plans/local_first.6-migrate-my-word.plan.md`](plans/local_first.6-migrate-my-word.plan.md)。
11. Local-first 7（User Profile）はproduction handler登録、guest統合、Profile live sessionまで実装済み。`MigrateGuestDataUseCase`は5 datasetを単一Drift transactionで移管し、session失効時は`GuestMigrationSessionChanged`でrow/outboxをrollbackする。`UserRepository.updateUser`のDrift+outbox書き込みと`UserProfileSyncHandler`のpush/pullも本番接続済み。ただしremote revision/idempotencyは未実装である。詳細は[`plans/local_first.7-migrate-user-profile.plan.md`](plans/local_first.7-migrate-user-profile.plan.md)。
12. Phase 1-6 presentation sliceが完了した。`features/word_status`がdictionary direction付きstatus button、両辞書のcommand/state/ViewModel、MyWord adapterを所有し、旧`esp_jpn_word_status/components/status_button/**`は削除済み。WordPage/Search/Quiz/Rankingは新featureを参照し、Jpn-Esp DIからEsp-Jpn presentation importを除去した。entity/usecase/repository/datasource/sync handlerの単一契約化は未対応であり、`word_status_di.dart`は既存DIへの移行adapterとして残る。詳細は[`plans/phase1.6-unify-word-status.plan.md`](plans/phase1.6-unify-word-status.plan.md)。

## 触る領域別の最短参照

| 作業対象 | 先に読む文書 |
| --- | --- |
| 起動、ProviderScope、横断effect | [runtime-and-status.md](runtime-and-status.md)、[app-routing.md](app-routing.md) |
| 新SyncEngine、outbox、checkpoint | [runtime-and-status.md](runtime-and-status.md)、[phase-scaffolding.md](phase-scaffolding.md) |
| word status local-first移行 | [feature-map.md](feature-map.md)、[next-phase-guide.md](next-phase-guide.md) |
| MyWord local-first移行 | [feature-map.md](feature-map.md)、[next-phase-guide.md](next-phase-guide.md) |
| User Profile、Auth lifecycle、CurrentSession | [feature-map.md](feature-map.md)、[core-map.md](core-map.md)、[next-phase-guide.md](next-phase-guide.md) |
| route contract、deep link、tab state | [app-routing.md](app-routing.md) |
| core import境界、catalog ownership | [core-map.md](core-map.md)、[feature-map.md](feature-map.md) |

## 注意

未接続に見えるLocal-first基盤は後続フェーズ用の足場であり、削除候補ではない。削除判断は[next-phase-guide.md](next-phase-guide.md)の「削除してよいか迷った時の基準」を先に確認する。
