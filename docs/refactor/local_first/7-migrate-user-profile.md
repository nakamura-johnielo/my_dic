# Local-first 7: 編集可能User Profileとguest統合を移行する

- 状態: 未着手
- 優先度: P1 / session data
- 依存タスク: [`6-migrate-my-word.md`](6-migrate-my-word.md)、[`../phase0/6-complete-auth-user-lifecycle.md`](../phase0/6-complete-auth-user-lifecycle.md)、[`../phase1/4-introduce-current-session.md`](../phase1/4-introduce-current-session.md)
- 関連タスク: [`8-cut-over-and-remove-legacy-sync.md`](8-cut-over-and-remove-legacy-sync.md)

## 目的

表示名、設定、学習プロフィールなどアプリ固有の編集可能データをDriftから読み書きし、Auth identity・認可・account provisioningと分離したままFirebaseへ同期する。

## 対象範囲

### local-first対象

- 表示名
- ユーザー設定
- 学習プロフィール
- その他ユーザーが編集できる非認可field

### remote authorityのまま維持

- Firebase UID、provider、email verification
- role、subscription、entitlement
- Security Rulesで強制される操作権限
- account/profile documentの初期provisioning

remote authority fieldをlocal編集commandやoutbox payloadへ含めない。

## guest統合

1. 未認証時は安定したguest owner scopeで保存する。
2. sign-inだけではguest rowをaccountへ自動帰属させない。
3. `AppSession`がReadyになった後、guestデータの存在をUIへ通知する。
4. ユーザーが統合を承認した場合だけ、guest rowとoutboxをaccount scopeへtransactionalに移管する。
5. cancel時はguest scopeを保持する。
6. 同じguestデータを複数回importしても重複しないmigration IDを使う。

## User Profile同期

- UIと`AppSession`はDrift profile watchから派生する。
- remote profile pullはDriftへ反映してからproviderへ通知する。
- 編集可能fieldはfield単位patchとする。
- remote authority fieldがremoteから変化してもeditable profile rowへコピーして認可判断に利用しない。

## 必須テスト

- profile read/writeがofflineで完了する
- remote failure後もlocal profileとoutboxが残る
- sign-out後に前account profileを表示しない
- account A/Bのprofileが混在しない
- guest統合のaccept/cancel/再試行が冪等である
- role/subscriptionをlocal mutationから変更できない
- profile load failureがSignedOutへ化けない

## 完了条件

- [ ] editable profileのSoTがDriftである
- [ ] AuthとProfileが別Repositoryとして維持されている
- [ ] authorization fieldがsync mutationに含まれない
- [ ] guest統合が明示的かつtransactionalである
- [ ] `AppSession`がDrift profileとFirebase identityから派生する

## LLMへの引き継ぎ事項

「Profileをlocal-first化すること」と「認可情報をクライアントへ移すこと」を混同しない。認可の最終判定は常にSecurity Rules/backendへ残す。
