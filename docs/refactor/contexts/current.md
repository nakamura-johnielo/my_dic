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
2. `features/sync/application`と`features/sync/infrastructure`にはLocal-first 1〜4の共通基盤があるが、`syncDatasetHandlerRegistryProvider`は空で、production dataset handlerは未登録。
3. 実際の自動同期はまだ`features/sync/sync_service.dart`と旧`ISyncUseCase`群が担当している。
4. Drift schema v6でaccount scope、revision、tombstone、`sync_outbox`、`sync_checkpoints`、`user_profiles`は入っている。ただしRepositoryの多くはlocal更新とFirebase更新を同じRepositoryから直接呼んでいる。
5. route contractは`app/routing/contracts`へ抽出済み。GoRouter定義はまだ`lib/router/**`が主で、`app/routing/router.dart`は旧router exportのbridge。
6. Auth lifecycleは`core/application/auth_lifecycle`が現在の中心。`AuthStoreNotifier`、`AppUserStoreNotifier`、旧Coordinatorも残っており、Phase 1-4でCurrentSessionへ整理する余地がある。
7. `tool/import_boundaries`は導入済み。baselineは既存違反を固定する台帳であり、違反があること自体は現状を表す。

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