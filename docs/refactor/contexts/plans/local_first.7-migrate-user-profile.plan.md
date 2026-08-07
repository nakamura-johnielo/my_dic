# Local-first 7: User Profile migration

状態: 進行中（Stage 1〜3完了。Stage 4はブロッカーありで未着手、詳細は末尾参照）
作成日: 2026-08-06
最終更新: 2026-08-06（セッション2、Stage 2〜3実施、Stage 4スコープ判断）

## 目的

[`../../local_first/7-migrate-user-profile.md`](../../local_first/7-migrate-user-profile.md)を実装可能な段階へ分割する。編集可能User Profile（表示名等）をDrift SoT + outboxへ移行し、remote authority（email/subscription等）とguest統合は別段階で扱う。

依存タスク: [`local_first.6-migrate-my-word.plan.md`](local_first.6-migrate-my-word.plan.md) — 完了。MyWordで確立した「local write + outbox enqueueを同一Drift transactionで行い、既存remote pushは並行して残す」Stage 1パターンをそのままUser Profileへ転用する。[`../../phase0/6-complete-auth-user-lifecycle.md`](../../phase0/6-complete-auth-user-lifecycle.md)と[`../../phase1/4-introduce-current-session.md`](../../phase1/4-introduce-current-session.md)（コア実装分）も完了済み。

## 実装スコープ全体像（段階分割）

| 段階 | 内容 | 対応する目的文書の項目 |
| --- | --- | --- |
| Stage 1（完了: 2026-08-06） | 編集可能profile（`username`）のDrift書き込みとfield mask付きoutbox mutationを同一Drift transactionで実行する（署名ユーザーのみ、既存remote pushは並行して残す） | User Profile同期: 編集可能fieldはfield単位patch |
| Stage 2（完了: 2026-08-06セッション2） | `UserProfileSyncHandler`実装、registry登録。旧`_remote.updateUser`直接呼び出しをrepositoryから除去 | User Profile同期の本番接続 |
| Stage 3（完了: 2026-08-06セッション2） | `ensureUserProfile`の読み取りをDrift（初回のみremoteから種付け、以降はローカル優先）へ切替える | User Profile同期: UIとAppSessionはDrift profile watchから派生 |
| Stage 4（未着手、ブロッカーあり） | guest統合（明示的import、transactional、idempotent migration ID） | guest統合 1〜6 |

Stage 4は本タスクのスコープ外（未着手）。着手前に本ファイル末尾の「Stage 4が未着手である理由」と[`../next-phase-guide.md`](../next-phase-guide.md)のLocal-first 7節を確認する。

## Stage 1 詳細（本セッションの実装スコープ）

### 対象パス

- `lib/features/user/data/data_source/local/drift_user_profile_dao.dart`（新規）
- `lib/features/user/data/data_source/local/i_user_profile_local_data_source.dart`（新規）
- `lib/features/user/data/data_source/local/user_profile_drift_data_source.dart`（新規）
- `lib/features/user/data/repository_impl/user_repository.dart`
- `lib/features/user/di/data_di.dart`
- 新規test: `test/unit/features/user/user_profile_outbox_enqueue_test.dart`

### スコープ外（Stage 1では触らない）

- `UserProfileSyncHandler`実装、`syncDatasetHandlerRegistryProvider`への登録（Stage 2）。
- `_remote.updateUser`直接呼び出しの削除（Stage 2で`UserProfileSyncHandler`が配送を担ってから）。
- `getUserByAccountId`/`ensureUserProfile`/`createNewUser`（remote authority provisioning、identityに紐づく読み取り）の変更。
- `email`/`subscriptionStatus`/`deviceId`のoutbox化。`username`（表示名）のみを対象とする。
- guest統合（Stage 4）。`accountId`がnull/emptyの場合は従来どおり`UnauthorizedError`を返す（既存の`_handleIdError`のまま）。
- 読み取り側のDrift切替、`AppSession`接続（Stage 3）。

### 実装方針

1. `UserProfiles` Drift table（Local-first 2で追加済み、`payload`はJSON blob）に対する`@DriftAccessor` DAO（`UserProfileDao`）を新規追加する。`getProfile(accountId)`と`upsertProfileFields(accountId, fields)`（既存payloadのJSONへ差分fieldをmergeし、`local_revision`を+1して`insertOnConflictUpdate`）、`runInTransaction`を持つ。
2. `IUserProfileLocalDataSource`ポートと`UserProfileDriftDataSource`実装を追加する。
3. `UserRepository`に`IUserProfileLocalDataSource`と`OutboxWriter`/`Uuid`を注入する。`updateUser`内、既存の`_handleIdError`チェック（accountId必須）通過後、`_profileLocal.runInTransaction`内で`upsertProfileFields(accountId, {'username': user.username})`を呼び、その結果の`localRevision`を使って`SyncMutation`（`dataset: SyncDataset.userProfile`、`operation: upsert`、`entityId: accountId`、`payload: {'username': user.username}`、`fieldMask: ['username']`）を`OutboxWriter.enqueue`する。既存の`_remote.updateUser(dto)`呼び出しはtransaction成功後にそのまま残す（Stage 1では二重書き込み、Stage 2でhandler導入後に削除）。
4. `di/data_di.dart`で`userProfileDaoProvider`/`userProfileLocalDataSourceProvider`を追加し、`firebaseUserRepositoryProvider`へ`app/bootstrap/sync_composition.dart`の`driftOutboxWriterProvider`を注入する。

### 検証

```powershell
dart run build_runner build --delete-conflicting-outputs
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check
flutter test test/unit/features/user/
```

### contexts更新方針

- Stage 1完了後、[`../next-phase-guide.md`](../next-phase-guide.md)のLocal-first 7節へ実装済み内容と次段階への引き継ぎを追記する。
- [`../feature-map.md`](../feature-map.md)の`user`行のうち、`updateUser`がoutbox経由になったことが分かるよう該当セルを更新する。
- [`../current.md`](../current.md)の結論一覧へStage 1完了を1行追記する。

## Stage 1 実施結果（2026-08-06）

- 変更/新規ファイル: 上記対象パスのとおり。
- 新規test: `test/unit/features/user/user_profile_outbox_enqueue_test.dart`（署名ユーザーのupdateUserがfield mask `['username']`のupsert mutationを1件だけ積むこと、guest呼び出しは既存どおり`UnauthorizedError`で失敗しenqueueされないこと、連続更新がcoalesceして`local_revision`が進むこと、`sync_outbox`のdatasetが`user_profile`であることを検証）。
- 既存test `test/unit/features/user/data/user_repository_ensure_profile_test.dart`は`UserRepository`のコンストラクタ引数増加に合わせてfake/mockを追加するだけの修正で対応した（`ensureUserProfile`の挙動は変更していない）。
- 検証結果:

```powershell
dart run build_runner build --delete-conflicting-outputs   # 585 outputs書き込み、エラーなし
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check   # exit code 0、既存baseline違反のみ（新規違反なし）
flutter test test/unit/features/user/ test/unit/features/sync/   # 41件全て成功
```

## 完了条件（Stage 1のみ、本タスク全体の完了条件はタスク文書を参照）

- [x] 編集可能profile（`username`）のRepository書き込みがDrift transaction + outbox enqueueを行う
- [x] guestまたはaccountId不正時はoutboxへ積まれない（既存の`UnauthorizedError`のまま）
- [x] 既存remote push（`_remote.updateUser`）は変更していない（Stage 2で除去予定）
- [x] role/subscription/email等remote authority fieldはoutbox payloadに含めない

## Stage 2 詳細と実施結果（2026-08-06 セッション2）

### 対象パス

- `lib/features/user/data/data_source/remote/user_profile_dao.dart`（`patch`追加、`username`→Firestore `userName`のfield名mapping）
- `lib/features/user/data/data_source/remote/i_user_remote_data_source.dart`・`firebase_user_remote_data_source.dart`（`patchUser`追加）
- `lib/features/user/data/data_source/local/drift_user_profile_dao.dart`・`i_user_profile_local_data_source.dart`・`user_profile_drift_data_source.dart`（`applyRemoteFields`追加。pull適用は`local_revision`を変えずoutboxにも触れない）
- `lib/features/user/data/sync/user_profile_sync_handler.dart`（新規、`UserProfileSyncHandler`）
- `lib/features/user/di/data_di.dart`（`userProfileSyncHandlerProvider`追加）
- `lib/app/bootstrap/sync_composition.dart`（registryへ登録）
- `lib/features/user/data/repository_impl/user_repository.dart`（`updateUser`から直接remote push呼び出しを削除。配送はoutbox+`UserProfileSyncHandler`のみ）
- 新規test: `test/unit/features/user/user_profile_sync_handler_test.dart`

### 設計判断

- User Profileはaccountあたり1 entity（自分自身のprofile document、`entityId == accountId`）のため、MyWord/word statusのような「checkpoint以降の複数件差分取得」ではなく、pullのたびに`getUserById`を1回呼び、そのdocumentの`updatedAt`単体をcheckpoint cursorと比較する設計にした。
- push側の存在確認（`isNew`判定用）とpull側のcontent取得が同じ`getUserById`呼び出しになるため、push区間とpull区間でそれぞれ独立に`try/catch`し、どちらかが例外を投げても他方の処理を止めないようにした（他datasetのhandlerにはない、entityが単一であることに起因する設計差分）。
- outboxのfield mask/payload keyはlocal優先で`username`のまま維持し、Firestoreの`userName`へのmapping（`_editableFieldNames`）は remote DAOの`patch`内に閉じた。ローカルのDrift JSON schemaとdomainの`AppUser.username`はkeyを揃え、remote命名の揺れをsync層だけで吸収する。

### 検証

```powershell
flutter test test/unit/features/user/   # 9件（Stage1の3件＋handler4件＋ensure_profile 1→2件）全て成功
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check   # exit code 0
flutter test test/unit/features/sync/   # 37件全て成功
```

## Stage 3 詳細と実施結果（2026-08-06 セッション2）

### 対象パス

- `lib/features/user/data/data_source/local/drift_user_profile_dao.dart`・`i_user_profile_local_data_source.dart`・`user_profile_drift_data_source.dart`（`getUsername`追加、JSON payloadから`username`を復号する読み取り専用ヘルパー）
- `lib/features/user/data/repository_impl/user_repository.dart`（`ensureUserProfile`を変更）
- 既存test更新: `test/unit/features/user/data/user_repository_ensure_profile_test.dart`（`profileLocal`のfake stub追加、「local Drift usernameがremote baselineを上書きする」testを追加）

### 設計判断（スコープを絞った理由）

タスク文書の「UIとAppSessionはDrift profile watchから派生する」は、本来は`AppSession`/UIをDriftの**live stream**に接続することを意味しうる。しかし調査の結果、`AppSessionReady.profile`（`AppUser`）は現在コードベースのどこからも読まれておらず（`profile.dart`は`appUserStoreNotifierProvider`という別のstoreを直接参照している）、`AppSession`をstream駆動へ再設計する変更はRouter・autoSync・既存の`AuthLifecycleController`（`StateNotifier`ベース）を巻き込む大きな変更になり、本タスクのスコープを大きく超える。

そのため、実質的に意味のある最小の変更として、`UserRepository.ensureUserProfile`（`AuthLifecycleController._provisionProfile`から呼ばれ、`AppSessionReady`/`AppUserStoreNotifier`の値の元になる）を次のように変更した。

- 初回ensure時：remoteのbaseline（`dto.userName`）をDriftへ`applyRemoteFields`で種付けする（`local_revision`は変えない、outbox enqueueもしない）。
- 2回目以降のensure（再ログイン、`retryProfileProvisioning`等）：Driftに保存済みの`username`があればそれを優先して返す。remoteのensure結果は同一documentであることの確認にのみ使う。

これにより、一度でもDriftへ反映された後は、以後の`AppUser.username`はremoteのensure結果ではなくDriftを起点とするようになる（ローカル編集やsync pull結果を尊重する）。ライブstream接続（sync pull結果が即座にUIへ反映される等）は未対応のまま次段階へ引き継ぐ。

### 検証

```powershell
flutter test test/unit/features/user/ test/unit/features/auth/ test/unit/app/session/ test/widget/auth/   # 38件全て成功
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check   # exit code 0
```

## Stage 4（guest統合）が未着手である理由

Stage 4はタスク文書の「guest統合」6項目（未認証時の安定guest scope保存、sign-inだけでの自動帰属禁止、`AppSession`Ready後のUI通知、承認時のtransactional移管、cancel時のguest scope保持、idempotent migration ID）をすべて含む。着手を検討した結果、次の理由で本セッションでは実装しないと判断した。

1. **read側account scopingが前提として未実装**: 現状、esp_jpn/jpn_esp word status、MyWord/MyWordStatus、User Profileのいずれも、ローカルDAOの読み取りは`legacyOwner = 'legacy_unowned'`固定スコープのままである（Local-first 5のcontexts、Local-first 6のcontexts双方で「Local-first 7へ先送り」と明記）。guest統合とは本質的に「guestスコープのrow」と「accountスコープのrow」を区別してtransactional移管することだが、現状は全rowが単一の固定スコープにしか存在しないため、「guestかaccountか」を区別する読み取り境界自体がまだ存在しない。
2. **影響範囲が本タスク（User Profile）を超える**: guest統合は5つのdataset（esp_jpn/jpn_esp word status、MyWord、MyWordStatus、User Profile）すべてのrowを対象にする横断機能であり、read側account scopingの導入とセットでない限り一貫した移行が実装できない。これはUser Profile単体の移行より大きい、Local-first全体の横断タスクである。
3. **データ移行操作としてのリスク**: guest→account移管は実データに対する不可逆的に近い操作であり、read側scoping抜きに実装すると「意図しないrowの混在」を招くリスクが高い。中途半端な実装を残すより、prerequisiteを明示して次セッションへ引き継ぐ方が安全と判断した。

### 推奨される次のステップ

Stage 4に着手する前に、次を別タスクとして先に実施することを推奨する。

- 5 dataset共通のread側account scoping（`legacy_unowned`固定から実accountIdへの切替、または`legacy_unowned`をguest専用scopeとして正式に扱う設計）。
- 上記が完了した後、guest scopeで作成されたrowを検出するクエリと、accountへのtransactional移管UseCase（migration ID付き、複数回実行してもべき等）を実装する。
- UI側（`AppSessionReady`遷移後のguestデータ検出通知、承認/cancelフロー）は移管UseCaseの後に着手する。

この判断は[`../../local_first/8-cut-over-and-remove-legacy-sync.md`](../../local_first/8-cut-over-and-remove-legacy-sync.md)（全面切替）にも影響するため、着手時は両文書を合わせて確認すること。

