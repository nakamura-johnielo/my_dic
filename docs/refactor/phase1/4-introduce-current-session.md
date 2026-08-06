# Phase 1-4: CurrentSessionと認証状態の単一source of truthを導入する

- 状態: 進行中（コア実装完了。詳細は[`../contexts/plans/phase1.4-introduce-current-session.plan.md`](../contexts/plans/phase1.4-introduce-current-session.plan.md)を参照）
- 優先度: 高 / 認証境界
- 依存タスク: [`../phase0/6-complete-auth-user-lifecycle.md`](../phase0/6-complete-auth-user-lifecycle.md)
- 関連タスク: [`../local_first/4-build-sync-engine.md`](../local_first/4-build-sync-engine.md)、[`../local_first/7-migrate-user-profile.md`](../local_first/7-migrate-user-profile.md)、[`../phase2/4-remove-ref-from-coordinators.md`](../phase2/4-remove-ref-from-coordinators.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 8.3

## 目的

Firebase認証streamをAuthenticationの唯一のsource of truthとし、各featureがAuth Repositoryや可変Auth Storeを直接操作せず、必要最小限のsession情報をport経由で取得できるようにする。

## 境界定義

- Authentication: UID、provider、email verificationなど「誰か」
- User Profile: 表示名、設定、学習プロフィールなどアプリ固有データ
- Authorization: role、subscription、操作権限。最終判定はSecurity Rules/backend

AuthとUser Profileは別Repositoryのまま維持する。両者を一つの永続entityへ統合せず、application層で読み取り専用`AppSession`として合成する。

## 現在の問題

- Firebase auth stream、`AuthStoreNotifier`、`AppAuthCoordinator`、`authEffectProvider`が認証状態を書き換える
- sign-outが`null`と空accountIdの`AppAuth`で二重表現される
- `isLogined`と`isAuthenticated`の意味が曖昧
- User Profileを認証変更effectから命令的にrefreshする
- MyWordなどのfeatureがaccountId取得のためAuth Repositoryへ直接依存する

## 目標モデル

```text
AuthRepository.watchIdentity()
        -> authIdentityProvider
             -> userProfileProvider(uid)
             -> appSessionProvider
                  -> Router / UI / Sync

CurrentSession port
        -> application UseCaseがuidを取得
```

推奨状態:

```text
Initializing
SignedOut
EmailUnverified(identity)
LoadingProfile(identity)
Ready(identity, profile)
SessionFailure(error)
```

## 実装方針

1. `AuthIdentity`をUID、provider、email、emailVerifiedなど事実を表す値へ整理する。
2. Firebase streamから`AuthIdentity?`を公開し、手動`setAuth`を廃止する。
3. 未認証は`null`または`SignedOut`の一種類にする。
4. User Profile providerは認証済みUIDと`UserProfileSource` portに依存し、sign-outで自動的に破棄・切替されるようにする。UIからremoteへ直接fetchせず、Local-first 7でsource adapterをDriftへ置換できる境界にする。
5. Router向けにAuthとProfileから派生する`AppSession`を公開する。新しい可変Storeにはしない。
6. application層へ`CurrentSession` portを定義し、`requireAccountId`またはnullable session取得を用途別に提供する。
7. 各featureのAuth Repository直接依存を`CurrentSession`へ置き換える。
8. 同期、cache、outbox、server cursorはUID変更を明示的なsession transitionとして扱う。
9. `SyncContext`へaccountIdとsession epochを渡し、UID変更時は旧epochのSyncEngine cycleをcancelする。
10. guest dataはsign-inだけで自動移管せず、Ready後の明示的統合フローへ渡す。

## 必須テスト

- cold startでInitializingから正しい状態へ進む
- sign-in、sign-out、別account切替で状態が一貫する
- 未確認userがReadyや同期開始へ進まない
- profile load失敗がSignedOutへ化けない
- sign-out後に前accountのprofileを表示しない
- feature UseCaseがFirebase/Auth Repositoryなしでfake sessionを使える
- account切替中の旧SyncEngine cycleが新accountのDriftへ反映しない
- sign-inだけではguest dataがaccountへ自動帰属しない

## 完了条件

- [x] 認証状態のwriterがFirebase stream由来の1つだけ（`AuthLifecycleController`のみ）
- [x] 空accountIdの未認証objectを作らない（既存のまま維持）
- [x] AuthとUser Profileが別Repositoryとして保たれる
- [x] `AppSession`が派生状態であり、Router/UIの入口になる（`appSessionProvider`をRouter/autoSync/profile UIへ接続済み）
- [ ] featureがaccountId取得のためAuth Repositoryへ直接依存しない（現行mutation usecase 9件は`CurrentSession`化済み。legacy同期usecase 3件は意図的に未対応、Local-first 5/6へ）
- [x] SyncEngineがaccountIdとsession epochを明示的に受け取る（`InMemorySessionFence`へのepoch配線を追加。production trigger未接続はLocal-first 5-7のまま）
- [ ] account切替で旧accountのQueue、cursor、cycleが停止する（production dataset handler未接続のため実データでの検証は未実施。fence配線のみ完了）
- [x] account切替を含むsession testが通る（`test/unit/app/session/app_session_test.dart`、既存`sync_engine_test.dart`のfenceケース）

実装詳細とスコープ外事項は[`../contexts/phase1.4-introduce-current-session.plan.md`](../contexts/plans/phase1.4-introduce-current-session.plan.md)を参照。

## LLMへの引き継ぎ事項

「AuthとUserを分けたこと」を問題とみなして再統合しない。問題は複数writerと手続き的同期である。認可用role/subscriptionをクライアントStoreだけで信用せず、Security Rules/backendの強制を維持する。
