# Phase 1-4: CurrentSessionと認証状態の単一source of truthを導入する

- 状態: 未着手
- 優先度: 高 / 認証境界
- 依存タスク: [`../phase0/6-complete-auth-user-lifecycle.md`](../phase0/6-complete-auth-user-lifecycle.md)
- 関連タスク: [`../phase2/4-remove-ref-from-coordinators.md`](../phase2/4-remove-ref-from-coordinators.md)
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
4. User Profile providerは認証済みUIDに依存してwatch/loadし、sign-outで自動的に破棄・切替されるようにする。
5. Router向けにAuthとProfileから派生する`AppSession`を公開する。新しい可変Storeにはしない。
6. application層へ`CurrentSession` portを定義し、`requireAccountId`またはnullable session取得を用途別に提供する。
7. 各featureのAuth Repository直接依存を`CurrentSession`へ置き換える。
8. 同期、cache、checkpointはUID変更を明示的なsession transitionとして扱う。

## 必須テスト

- cold startでInitializingから正しい状態へ進む
- sign-in、sign-out、別account切替で状態が一貫する
- 未確認userがReadyや同期開始へ進まない
- profile load失敗がSignedOutへ化けない
- sign-out後に前accountのprofileを表示しない
- feature UseCaseがFirebase/Auth Repositoryなしでfake sessionを使える

## 完了条件

- [ ] 認証状態のwriterがFirebase stream由来の1つだけ
- [ ] 空accountIdの未認証objectを作らない
- [ ] AuthとUser Profileが別Repositoryとして保たれる
- [ ] `AppSession`が派生状態であり、Router/UIの入口になる
- [ ] featureがaccountId取得のためAuth Repositoryへ直接依存しない
- [ ] account切替を含むsession testが通る

## LLMへの引き継ぎ事項

「AuthとUserを分けたこと」を問題とみなして再統合しない。問題は複数writerと手続き的同期である。認可用role/subscriptionをクライアントStoreだけで信用せず、Security Rules/backendの強制を維持する。
