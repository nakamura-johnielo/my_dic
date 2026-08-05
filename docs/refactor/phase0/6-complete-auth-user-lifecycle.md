# Phase 0-6: Sign Up・メール確認・User作成フローを成立させる

- 状態: 完了
- 優先度: P1 / 認証フロー
- 依存タスク: [`4-fix-result-propagation.md`](4-fix-result-propagation.md)
- 関連タスク: [`../phase1/4-introduce-current-session.md`](../phase1/4-introduce-current-session.md)、[`../local_first/7-migrate-user-profile.md`](../local_first/7-migrate-user-profile.md)、[`../phase2/4-remove-ref-from-coordinators.md`](../phase2/4-remove-ref-from-coordinators.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) P1-1

## 目的

Sign Up後の実処理とUI表示を一致させ、メール未確認、確認済み、User Profile未作成、作成済みを再試行可能な状態遷移として扱う。

## 現在の問題

- `lib/features/auth/domain/usecase/signup.dart`はFirebase Auth userを作るだけである
- `AppAuthCoordinator.verifyEmail()`は存在するが、実働フローから呼ばれていない
- `lib/features/auth/presentation/view/sign_up.dart`は確認メールを送信していないのに「送信しました」と表示する
- `authEffectProvider`は認証変化時にUser refreshを未awaitで開始する
- Firebase認証stream、Auth Store、User Store、Coordinatorがそれぞれ状態を書き換える
- 未認証が`null`と空accountIdの`AppAuth`で表現される

## Phase 0での対象範囲

- Sign Up直後の確認メール送信
- UIメッセージとResultの一致
- email verification後のreload/再判定
- User Profileのidempotentなensure/upsert
- logout時のAuth/User状態clear
- 主要な結合テスト

## Phase 0での対象外

- Auth/User provider構造の最終形。Phase 1-4で単一source of truthへ移行する
- 表示名、設定、学習プロフィールのDrift SoT化。Local-first 7で扱う
- guestデータのaccount統合。Local-first 7で明示的な確認フローとして扱う
- Coordinatorから`Ref`を除く全面変更。Phase 2-4で扱う
- role/subscription認可のbackend再設計

## 推奨状態遷移

```text
SignedOut
  -> creatingAuthAccount
  -> sendingVerificationEmail
  -> EmailUnverified
  -> reloadingFirebaseUser
  -> ensuringUserProfile
  -> Ready
```

各stepは失敗状態とretry操作を持つ。Firebase Authとprofile DBは同一transactionにできないため、profile作成は`ensureProfile(uid)`として何度実行しても安全にする。

## 実装方針

1. `createUserWithEmailAndPassword`成功後に`sendEmailVerification`を実行する。
2. メール送信成功後だけ送信済みUIを表示する。
3. 未確認userを通常のReady状態へ進めず、専用画面と再送操作を提供する。
4. 確認完了操作ではFirebase Userをreloadし、`emailVerified`を再取得する。
5. 確認済みUIDに対してUser Profileをidempotentにensureする。
6. profile ensure失敗時はAuth userを削除せず、retry可能な中間状態にする。
7. logoutはFirebase signOutを起点とし、未認証表現を一種類にする。空IDのAuth objectを書き戻さない。
8. `isLogined`と`isAuthenticated`の意味を整理し、可能なら`emailVerified`など事実を表す名前へ寄せる。

ここで行うprofile ensureはremote account/profile documentのprovisioningである。表示名や設定など編集可能Profileの通常read/writeをFirebaseへ固定せず、Local-first 7でDrift SoTへ移行する。role、subscription、entitlementはoutbox対象にしない。

## 必須テスト

- Sign Up成功後に確認メール送信が呼ばれる
- メール送信失敗時に送信済みと表示しない
- 未確認userがReadyや同期開始へ進まない
- 確認後のreloadでprofile ensureが実行される
- profile作成失敗後にretryできる
- 既存profileに対するensureが重複作成しない
- sign-out後にAuthとUserが一貫して未認証になる

## 完了条件

- [x] UI文言が実際のメール送信Resultに基づく
- [x] 未確認と確認済みの状態が明確に分かれる
- [x] profile ensureがidempotentで再試行可能
- [x] 未確認userで同期を開始しない
- [x] sign-out表現が一種類である
- [x] 結合テストが主要状態遷移を覆う

## LLMへの引き継ぎ事項

AuthとUser Profileを一つのentityへ統合しない。別Repositoryのままライフサイクルだけを調停する。最終的なprovider構造はPhase 1-4へ、編集可能Profileのlocal-first化はLocal-first 7へ委ね、Phase 0では虚偽表示と不成立フローを確実に修正する。
