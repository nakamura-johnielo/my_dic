# Phase 1-4: CurrentSession導入

状態: コア実装完了（legacy同期・guest統合は未対応）
作成日: 2026-08-06

## 目的

[`phase1/4-introduce-current-session.md`](../phase1/4-introduce-current-session.md)を実装する。Firebase auth streamを唯一のsource of truthとして維持したまま、Router/UI向けの派生`AppSession`と、featureがaccountId解決に使う`CurrentSession` portを導入し、各featureのAuth Repository直接依存を置き換える。

依存タスク[`../phase0/6-complete-auth-user-lifecycle.md`](../phase0/6-complete-auth-user-lifecycle.md)は完了済み。

## 実装スコープ

1. `lib/app/session/current_session.dart`: 純Dartの`CurrentSession` port（`accountIdOrNull`、`requireAccountId()`）。domainから安全にimportできる。
2. `lib/app/session/app_session.dart`: `AuthLifecycleState`から派生するsealed `AppSession`（Initializing/SignedOut/EmailUnverified/LoadingProfile/Ready/Failure）。
3. `lib/app/session/session_providers.dart`: `appSessionProvider`（`authLifecycleProvider`から導出）、`currentSessionProvider`（`AppSession`から`CurrentSession`実装を作る）。`accountIdOrNull`は`AppSessionReady`の時だけ値を返す（emailUnverified/loadingProfileでは`null`）。
4. `lib/app/bootstrap/session_composition.dart`: account切替のたびにsession epochを進め、`InMemorySessionFence.setCurrent`/`remove`を呼ぶ`sessionFenceEffectProvider`。`lifecycle_effects.dart`から呼ぶ。
5. Router: [`router.dart`](../../../lib/router/router.dart)の`AuthChangeNotifier`と`redirect`を`authLifecycleProvider`直接参照から`appSessionProvider`へ切り替える。
6. Auto sync: [`features/sync/di.dart`](../../../lib/features/sync/di.dart)の`autoSyncProvider`を`appSessionProvider is AppSessionReady`判定へ切り替える。
7. UI: [`profile.dart`](../../../lib/features/user/presentation/view/profile.dart)のaccountId表示を`authStoreNotifierProvider.select`から`currentSessionProvider`へ切り替える（`AppUserStoreNotifier`経由のprofile表示はそのまま維持）。
8. 現行のuser向けmutation usecase 9件（下記）を`IAuthRepository`直接依存から`CurrentSession`依存へ置き換え、対応するDI providerとテストを更新する。
   - `esp_jpn_word_status`: `update_status_interactor.dart`
   - `jpn_esp_word_status`: `update_jpn_esp_status_interactor.dart`
   - `my_word`: `register_my_word_interactor.dart`、`update_my_word_interactor.dart`、`delete_my_word_interactor.dart`、`update_my_word_status_interactor.dart`
   - `user`: `get_user.dart`、`update_user.dart`、`create_new_user.dart`
9. `test/helpers/fake_current_session.dart`を追加し、上記interactorのfeature testをfake経由に更新する。
10. `test/unit/app/session/app_session_test.dart`で`AuthLifecycleState -> AppSession`の派生ロジックを検証する。

## スコープ外（未対応・将来フェーズへ）

- **legacy同期usecase**（`sync_esp_jpn_word_status_interactor.dart`、`sync_myword_status_usecase.dart`、`sync_my_word_interactor copy.dart`）: `IAuthRepository`依存のまま残す。Local-first 5/6で新`DatasetSyncHandler`へ置換される予定であり、二重に書き換えるのは無駄になる。`docs/refactor/contexts/next-phase-guide.md`のLocal-first 5/6注記を参照。
- **AppAuthの`AuthIdentity`への改名**: 影響ファイルが大きく（40+箇所）、`AppAuth`は既に事実ベースの値（accountId/email/emailVerified/provider）を持つため、今回はrenameしない。命名整理はPhase 3-4（[`phase3/4-normalize-names.md`](../phase3/4-normalize-names.md)）へ委ねる。
- **`AuthStoreNotifier`/`AppUserStoreNotifier`の削除**: 単一writer（`AuthLifecycleController`）は既に達成済み。既存の`AppUserStoreNotifier`によるprofile表示（`profile.dart`、`user_coodinator.dart`）はUser Profile読み取りであり、identityではないため維持する。
- **SyncEngineの実運用接続**（production dataset handler登録、legacy `SyncService`のcancellation）: `syncDatasetHandlerRegistryProvider`は空のままで、Local-first 5〜7のdataset切替まで空にしておく契約（[`local_first/index.md`](../local_first/index.md)）に従う。今回追加するのは、account切替時に`InMemorySessionFence`のepochを進める配線のみ。
- **guest data統合**: Local-first 7（[`local_first/7-migrate-user-profile.md`](../local_first/7-migrate-user-profile.md)）のスコープ。

## 実装手順

1. `lib/app/session/`にport/derived stateを追加する。
2. `session_providers.dart`と`session_composition.dart`を追加し、`lifecycle_effects.dart`から`sessionFenceEffectProvider`をwatchする。
3. Router、`autoSyncProvider`、`profile.dart`を`appSessionProvider`/`currentSessionProvider`へ切り替える。
4. 9件のinteractorとDI providerを`CurrentSession`へ置き換える。
5. `test/helpers/fake_current_session.dart`を追加し、影響するテストを更新する。
6. 新規`app_session_test.dart`を追加する。

## 検証

```powershell
flutter analyze
flutter test test/unit/app
flutter test test/unit/core/domain/usecase/update_status_interactor_test.dart
flutter test test/unit/features/sync
flutter test test/unit/features/auth
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check
```

## contexts更新方針

完了後、`docs/refactor/contexts/current.md`・`core-map.md`・`feature-map.md`・`next-phase-guide.md`の「Phase 1-4でCurrentSessionへ整理する余地がある」系の記述を「導入済み、legacy syncとguest統合は未対応」に更新する。

## 完了条件

- [x] `appSessionProvider`がRouter/autoSync/profile UIの入口になっている
- [x] 対象9 interactorが`IAuthRepository`を直接参照しない
- [x] legacy同期usecaseと`AppAuth`命名は意図的に未変更のまま記録されている
- [x] `flutter analyze`と対象テストが通る（`test/unit/features/my_word/domain/usecase/load_my_word_interactor_test.dart`のcompile失敗は本フェーズ着手前からの既存の別問題であり、`fake_my_word_repository.dart`が`IMyWordRepository`の現行シグネチャと不一致なことが原因。今回のCurrentSession変更とは無関係）
- [x] import境界チェックが新規違反を出さない（`no_cross_feature_presentation`/`no_feature_cycle`のbaseline差分はstash比較で本フェーズ着手前から存在する既存ドリフトと確認済み。`profile.dart -> features/auth/di/store.dart`の1件はこの実装で解消された）
