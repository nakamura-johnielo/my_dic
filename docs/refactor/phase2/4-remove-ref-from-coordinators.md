# Phase 2-4: CoordinatorからRefを除き依存を明示する

- 状態: 実装プラン作成済み（未着手。詳細は[`../contexts/plans/phase2.4-remove-ref-from-coordinators.plan.md`](../contexts/plans/phase2.4-remove-ref-from-coordinators.plan.md)を参照）
- 優先度: 中〜高 / test容易性
- 依存タスク: [`../phase1/4-introduce-current-session.md`](../phase1/4-introduce-current-session.md)
- 関連タスク: [`../phase1/1-create-composition-root.md`](../phase1/1-create-composition-root.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 7.7

## 目的

CoordinatorとNavigatorが`Ref`をservice locatorとして使う状態を解消し、constructorから依存関係と副作用が分かるようにする。

## 現在の問題

- `AppAuthCoordinator`、`AppUserCoordinator`、`AppNavigatorService`が`Ref`を保持する
- 内部でStore notifier、provider、routerをlookupするため依存が隠れる
- 単体テストにProviderContainer全体が必要になる
- CoordinatorがUseCase調停、Store更新、navigationなど複数責務を持つ

## 対象範囲

- `lib/features/auth/auth_coordinator.dart`

## Completion update (2026-08-07)

- Removed `AppAuthCoordinator`, `AppUserCoordinator`, `AppNavigatorService`,
  their providers, the old Auth/User presentation Stores, and the
  comment-only coordinator definitions that referenced them.
- `AuthLifecycleController` is the sole active path for sign-in, sign-up,
  sign-out, and verification. `SignInViewModel` now owns only the
  `IResetEmailPasswordUseCase` command and its notice effect.
- `ProfilePage` supplies `AppSessionReady.profile` to
  `UserProfileViewModel.save(currentProfile, patch)`. The ViewModel patches a
  copy and calls `IUpdateUserUseCase`; sign-out calls the lifecycle controller
  directly from the widget.
- Navigation has moved to widget callbacks and the pure route-name resolver;
  ViewModels no longer receive an `AppNavigatorService` dependency.
- Verification: `flutter test test/unit/features/auth test/unit/features/user`
  passed (29 tests); focused `flutter analyze` passed; the old
  coordinator/store/provider names have zero `lib`/`test` references.

- `lib/features/user/user_coodinator.dart`
- `lib/router/navigator_service.dart`
- 関連providerとtest

## 実装方針

1. 各Coordinatorのmethodごとに、読む依存、書く状態、外部副作用を一覧化する。
2. Phase 1-4でAuth/User Storeへの手動同期を減らし、不要になったmethodを削る。
3. 残るapplication orchestrationは必要なportをconstructor注入する。
4. Router操作が必要なら、小さな`AppRouterPort`またはcallbackを注入する。
5. store writerを注入するより、Repository/providerの派生stateを優先する。
6. `Ref`はprovider factory内だけで依存解決に使い、生成物へ保持させない。
7. 単にCoordinator classを残す必要がなければ、Application UseCaseへ統合する。

## 推奨テスト

- Coordinator/Application serviceをplain Dartのfakeで生成できる
- ProviderContainerなしでsign-in orchestrationをtestできる
- navigation success/failureをfake routerで確認できる
- constructorにない依存へアクセスしない

## 完了条件

- [ ] 長寿命Coordinator/Navigatorが`Ref`をfieldに持たない
- [ ] 依存がconstructorまたは明示引数から分かる
- [ ] Auth/Userの手動Store同期が残っていない
- [ ] plain unit testで主要orchestrationを検証できる
- [ ] 不要なCoordinatorが削除されている

## LLMへの引き継ぎ事項

`Ref`を別のglobal service locatorへ置き換えない。依存数が多すぎる場合は、そのclassが複数責務を持つ兆候として先に分割する。
