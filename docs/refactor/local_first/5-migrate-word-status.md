# Local-first 5: Word statusを最初のdatasetとして移行する

- 状態: 進行中（Stage 1・3・4・5完了、read側account scoping/guest統合はLocal-first 6/7へ先送り。詳細は[`../contexts/plans/local_first.5-migrate-word-status.plan.md`](../contexts/plans/local_first.5-migrate-word-status.plan.md)）
- 優先度: P0 / 最初のproduction切替
- 依存タスク: [`4-build-sync-engine.md`](4-build-sync-engine.md)、[`../phase0/5-fix-status-update-contract.md`](../phase0/5-fix-status-update-contract.md)、[`../phase1/1-create-composition-root.md`](../phase1/1-create-composition-root.md)、[`../phase1/2-enforce-import-boundaries.md`](../phase1/2-enforce-import-boundaries.md)、[`../phase1/4-introduce-current-session.md`](../phase1/4-introduce-current-session.md)
- 関連タスク: [`../phase1/6-unify-word-status.md`](../phase1/6-unify-word-status.md)

## 目的

Esp-JpnとJpn-Espのstatus更新をDriftだけへ書き込み、outbox経由でFirebaseへ非同期配送する最初の縦切りdatasetを完成させる。

## 実装方針

1. status commandをnullable boolやDBの0/1ではなく、変更fieldを明示する業務型にする。
2. Driftのstatus row更新とfield mask付きoutbox mutationを同一transactionで保存する。
3. UIとViewModelはDrift watchだけから状態を取得する。
4. Esp-Jpn/Jpn-Espそれぞれにremote adapterを用意し、同じ`DatasetSyncHandler` contractを満たす。
5. remote patchは指定fieldだけを更新し、未指定fieldをfalseやnullで上書きしない。
6. remote pullはpending local patchと別fieldならmergeし、同一fieldはserver受付順で解決する。
7. dataset registryで旧status同期を無効化してから新handlerを有効化する。
8. 両directionの移行完了後にPhase 1-6のfeature統合へ進む。

## 必須テスト

- bookmarkだけ変更してlearnedとhasNoteが保持される
- learnedだけ変更して他fieldが保持される
- 別端末が別fieldを同時変更してmergeされる
- 同じfieldの競合がserver受付順へ収束する
- remote failure後にoutboxが残り、retry成功後にackされる
- Esp-Jpn/Jpn-Espが同じcontract testを通る
- direction、account、guest scopeを跨いでrowが混在しない
- remote applyが新しいoutboxを生成しない

## 完了条件

- [x] statusのread/writeがDriftだけを通る（通常usecaseの書き込みパスからremote直接呼び出しを除去済み）
- [ ] 通常status RepositoryにFirebase操作がない（Repositoryクラス自体はFirebase操作メソッドを保持したまま。旧`SyncEspJpnWordStatusInteractor`削除後に完全達成）
- [x] 両directionがSyncEngineへ登録されている
- [x] 旧status listenerと旧sync UseCaseがdataset registryから外れている
- [ ] failure、retry、conflict、account切替testが通る（retry/dead-letter/pull/field merge-skipは検証済み。account切替を跨ぐhandler単体end-to-end testは未実装）

## LLMへの引き継ぎ事項

このタスクではfeature統合を同時に行わない。両directionの挙動と同期保証を揃えた後、Phase 1-6で重複を除去する。

