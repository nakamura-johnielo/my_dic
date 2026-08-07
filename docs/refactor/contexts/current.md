# current.md: current context entry

最終更新: 2026-08-06

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
2. `features/sync/application`と`features/sync/infrastructure`にはLocal-first 1〜4の共通基盤があり、`syncDatasetHandlerRegistryProvider`はword status（Esp-Jpn/Jpn-Esp）とMyWord/MyWordStatus向けの本番`DatasetSyncHandler`4件を登録済み（Local-first 5、2026-08-06／Local-first 6、2026-08-06セッション2）。User Profile向けhandlerのみ未登録。
3. word status・MyWord・MyWordStatusの自動同期は新`SyncEngine`（`syncSchedulerProvider.foreground(...)`、`AppSessionReady`遷移時とapp resume時にtrigger）が担当するようになった。旧`features/sync/sync_service.dart`の`syncServiceProvider`は空配列となり実質無効化された（MyWord/MyWordStatus向け旧`ISyncUseCase`実装クラス自体とdi provider定義は`test/unit/features/sync/`のtestが直接参照するため未削除。esp_jpn word status向け旧`SyncEspJpnWordStatusInteractor`は専用interface・di provider・test参照ごと完全削除済み、2026-08-06セッション3）。
4. Drift schema v6でaccount scope、revision、tombstone、`sync_outbox`、`sync_checkpoints`、`user_profiles`は入っている。word status・MyWord・MyWordStatusの通常usecase書き込みパスはoutbox経由に一本化済み（直接remote呼び出しはすべて除去）。word status（Esp-Jpn/Jpn-Esp）はRepositoryインターフェース自体からもremoteメソッドを全除去済み。MyWord/MyWordStatusのRepositoryインターフェースは旧sync usecase向けのremoteメソッドを引き続き公開している（Local-first 8で削除予定）。Ranking/Userは未着手。
5. route contractは`app/routing/contracts`へ抽出済み。GoRouter定義はまだ`lib/router/**`が主で、`app/routing/router.dart`は旧router exportのbridge。
6. Auth lifecycleは`core/application/auth_lifecycle`が現在の中心。Phase 1-4で`app/session`（`appSessionProvider`/`currentSessionProvider`）を導入し、Router、autoSync、profile UI、user向けmutation usecase 9件はそこから派生するようになった。`AuthStoreNotifier`、`AppUserStoreNotifier`は単一writerのまま残る。legacy同期usecase（jpn_esp/my_wordのsync系）とuser向けprofile表示は意図的に未変更（esp_jpnの旧sync usecaseはLocal-first 5でクラスファイルごと完全削除済み）。詳細は[`phase1.4-introduce-current-session.plan.md`](plans/phase1.4-introduce-current-session.plan.md)。
7. `tool/import_boundaries`は導入済み。baselineは既存違反を固定する台帳であり、違反があること自体は現状を表す。
8. Phase 1-5 slice 1（活用検索結果itemのcatalog化）が完了し、`feature:quiz`<->`feature:search`の双方向importと関連する`core_no_feature`違反3件を解消した。WordPageがQuiz/Searchの`di`層へ直接依存する3箇所と、`CardView`のsearch/quiz間再利用は未対応のまま残る。詳細は[`plans/phase1.5-define-catalog-ownership.plan.md`](plans/phase1.5-define-catalog-ownership.plan.md)と[`next-phase-guide.md`](next-phase-guide.md)。
9. Local-first 5（word status）はStage 1〜5すべてが完了し、Esp-Jpn/Jpn-Espともoutbox→`DatasetSyncHandler`→Firestoreのpush/pullが本番接続された。read側account scoping（Stage 2）はセッション4で完全実装し、`legacy_unowned`固定を撤廃してDAO/datasource/repository/Fetch・Watch usecase/sync handlerのpullがすべて実accountId（guestは`guestAccountScope`定数）でスコープされるようになった。guestからaccountへのtransactional移管フロー（guest統合本体）のみLocal-first 7 Stage 4へ意図的に残す。旧`SyncEspJpnWordStatusInteractor`（専用interfaceとdi provider定義を含む）は完全に削除し、`WordStatusRepository`/`JpnEspWordStatusRepository`および両Repository interfaceからもFirebase操作メソッドを全除去した（2026-08-06セッション3・4）。詳細は[`plans/local_first.5-migrate-word-status.plan.md`](plans/local_first.5-migrate-word-status.plan.md)。
10. Local-first 6（MyWord）はStage 1〜5すべてが完了し、`MyWordRepository`（create/update/delete）と`MyWordStatusRepository`（update）がDrift transaction+outbox enqueueへ切り替わり、`MyWordSyncHandler`/`MyWordStatusSyncHandler`がoutbox→Firestoreのpush/pull（`deletedAt`tombstoneの双方向伝播を含む）を本番接続した。`DatasetPlan`でMyWordStatusはMyWordに依存させた。read側account scopingはLocal-first 7へ先送り。詳細は[`plans/local_first.6-migrate-my-word.plan.md`](plans/local_first.6-migrate-my-word.plan.md)。
11. Local-first 7（User Profile）はStage 1〜3が完了した。`UserRepository.updateUser`が編集可能field（`username`）についてDrift transaction＋field mask付きoutbox mutation（`dataset: userProfile`）を行い、`UserProfileSyncHandler`がoutbox→Firestoreのpush/pull（1 account=1 entityの単発`getUserById`比較）を本番接続、旧remote直接呼び出しは除去済み。`ensureUserProfile`は初回のみremoteを種付けし以降はDriftの`username`を優先する。guest統合（Stage 4）は、5 dataset共通のread側account scopingが前提として未実装のため未着手と判断し、別タスクとして先に読み取り側scopingを実施することを推奨する形でcontextsに引き継いだ。詳細は[`plans/local_first.7-migrate-user-profile.plan.md`](plans/local_first.7-migrate-user-profile.plan.md)。

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