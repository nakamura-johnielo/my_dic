# Phase 2-4: Coordinator / Navigator から `Ref` を除去する実装プラン

状態: 実装未着手
作成日: 2026-08-07

## 目的

- `AppAuthCoordinator`、`AppUserCoordinator`、`AppNavigatorService` が `Ref` を service locator として保持する構造をなくす。
- 認証・プロフィール更新の依存を UseCase、`AuthLifecycleController`、明示的な method 引数へ収束させる。
- ユーザー操作起点の navigation を Widget が所有し、query / command ViewModel から GoRouter 実装を排除する。
- `AuthLifecycleState` とそこから派生する `AppSession` を Auth / User の唯一の可読状態とし、参照元のない可変 Store への手動同期を撤去する。
- 対象 ViewModel と application orchestration を ProviderContainer なしの plain unit test で生成できるようにする。

## 前提と依存状態

- Phase 1-4 により、Router / UI 向けには `appSessionProvider`、application の account 解決には `CurrentSession` が導入済みである。
- Phase 2-1 により Auth / User の操作は application UseCase に移動済みである。
- Phase 2-2 により command state と one-shot effect が導入済みであり、成功・失敗表示の契約は Coordinator から独立している。
- Phase 2-3 により `WordPageViewModel` の初期 load は provider lifecycle が所有しており、本計画ではその load 契約を変えない。
- 2026-08-07 時点の直近 context では `flutter analyze` と全 `flutter test` が成功している。実装着手時にはこれを baseline として再確認する。

## 現行依存と副作用の棚卸し

### `AppAuthCoordinator`

| method | 読む依存 | state 書き込み | 外部副作用 | 判断 |
| --- | --- | --- | --- | --- |
| `observeAuthState` | `IObserveAuthStateUseCase` | なし | auth stream 購読 | active caller がなく、実際の購読は auth lifecycle effect が所有するため削除 |
| `signIn` | `ISignInUseCase` | なし | Firebase sign-in、成功ログ | UI の実働入口は `AuthLifecycleController.signIn`。Coordinator 経由 API は削除 |
| `signUp` | `ISignUpUseCase` | なし | Firebase account 作成 | verification / profile ensure を含む lifecycle が実働入口のため削除 |
| `signOut` | `ISignOutUseCase` | なし | Firebase sign-out | profile UI から `AuthLifecycleController.signOut` を使い、session 遷移を一箇所にする |
| `verifyEmail` | `IVerifyEmailUseCase` | なし | verification mail | lifecycle が再送・失敗・再試行状態を所有済みのため削除 |
| `resetEmailPassword` | `IResetEmailPasswordUseCase` | なし | password reset mail | Coordinator を介さず `SignInViewModel` へ UseCase を直接注入 |

`Ref` field は現在未使用であり、Coordinator 自体も logging 以外は UseCase の転送に留まる。`Ref` だけを外して class を残す理由はないため、active `AppAuthCoordinator` を削除する。

### `AppUserCoordinator`

| method | 読む依存 | state 書き込み | 外部副作用 | 判断 |
| --- | --- | --- | --- | --- |
| `updateUser` | `appUserStoreNotifierProvider`、`IUpdateUserUseCase` | `AppUserStoreNotifier.setUser` | profile 永続化 | `AppSessionReady.profile` を Widget から明示引数で渡し、ViewModel が `copyWith` 後に UseCase を呼ぶ |
| `createUser` | `ICreateNewUserUseCase` | `AppUserStoreNotifier.setUser` | profile 作成、ログ | active caller がなく、profile provision は `IEnsureUserExistsUseCase` を lifecycle が所有するため削除 |
| `refresh` | `IGetUserUseCase` | `AppUserStoreNotifier.setUser` | profile 取得、ログ | active caller がなく、live profile provider が query を所有するため削除 |
| `clear` | なし | `AppUserStoreNotifier.clear` | なし | sign-out / account switch は lifecycle と session provider が所有するため削除 |

更新成功後の表示は `watchedUserProfileProvider(accountId)` から `appSessionProvider` へ流れるため、presentation Store を命令的に同期しない。`AppUserCoordinator` は全 method が不要になり、class と provider を削除する。

### `AppNavigatorService`

| method 群 | lookup する依存 | caller | 判断 |
| --- | --- | --- | --- |
| `toWordDetail` / `toFlashCard` | `routerProvider`、`entryPointProvider` | Search、Quiz、Ranking、WordPage の ViewModel / Widget | route contract は維持し、タップ元 Widget から GoRouter を呼ぶ |
| `pushToProfile` / `toProfile` | `routerProvider` | `MainActivity` | Widget の `BuildContext` から named route へ遷移 |
| `clear*BranchHistoryAndGoRoot` | entry point と各 NavigatorKey provider | `MainActivity` | 所有済みの `StatefulNavigationShell` で branch root へ戻す。現行挙動を characterization test で先に固定する |
| `pop` | `routerProvider` | active caller なし | 削除 |

navigation はすべてユーザー操作 callback から起動されており、application orchestration の途中で遷移する箇所はない。そのため新しい `AppRouterPort` は追加せず、ViewModel から navigation method と GoRouter 依存を除去する。将来 application command の成功に連動する遷移が必要になった場合は、Phase 2-2 の one-shot effect を Widget が処理する。

## 採用する設計

```text
Firebase auth stream
  -> AuthLifecycleController
  -> AuthLifecycleState
  -> appSessionProvider
       -> profile Widget / Router redirect / CurrentSession

profile Widget
  -> UserProfileViewModel.save(currentProfile, patch)
  -> IUpdateUserUseCase
  -> Repository
  -> watchedUserProfileProvider
  -> appSessionProvider

tap callback + current EntryPoint
  -> pure route-name resolver
  -> BuildContext / GoRouter
```

以下を設計上の制約とする。

- provider factory は UseCase / ViewModel の構築だけに `Ref` を使い、生成物へ `Ref`、`WidgetRef`、`ProviderContainer`、それらを capture する callback を渡さない。
- `Ref` を GetIt、static singleton、global callback など別の service locator へ置き換えない。
- ViewModel は query / command state と application 呼び出しだけを所有し、GoRouter、route name、NavigatorKey、`BuildContext` を知らない。
- Auth の sign-in / sign-up / sign-out / verification / profile provision は `AuthLifecycleController` を唯一の命令入口とする。password reset だけは lifecycle state を変えない独立 command として `SignInViewModel` に残す。
- profile の source of truth は `AppSessionReady.profile` と live profile projection とし、更新用 ViewModel 内に profile copy を保持しない。
- route URL、`WordDetailRoute`、`QuizGameRoute`、route name、shell branch 構成は変更しない。

## 実装スコープ

### 削除する active Coordinator / Navigator

- `lib/features/auth/auth_coordinator.dart`
- `lib/features/user/user_coodinator.dart`
- `lib/router/navigator_service.dart`
- `authCoordinatorProvider`
- `appUserCoordinatorProvider`
- `appNavigatorServiceProvider`

### Auth / User の手動 Store 同期の撤去

現行検索では `AuthStoreNotifier` と `AppUserStoreNotifier` の production reader はなく、`AuthLifecycleController` が書き込みと同じ値の保持を重複している。`AuthLifecycleState` 自身が identity と profile を保持し、`AppSession` がそこから派生するため、次を削除する。

- `lib/features/auth/presentation/view_model/auth_store.dart`
- `lib/features/auth/di/store.dart`
- `lib/features/user/presentation/view_model/app_user_store.dart`
- `lib/features/user/di/service.dart`
- `AuthLifecycleController` constructor の `AuthStoreNotifier` / `AppUserStoreNotifier`
- sign-in、sign-out、account switch、profile provision 時の Store `set` / `clear`

`AuthLifecycleController` の公開 phase、identity、profile、error、notice の遷移は維持する。store assertion を行う既存 test は、controller state と `AppSession` projection の assertion へ置換する。

### Auth command composition

- `SignInViewModel` の constructor を `AppAuthCoordinator` から `IResetEmailPasswordUseCase` へ変更する。
- `SignInViewModel.signIn`、`signUp`、`signOut` は active UI caller がないため削除する。
- `resetEmailPassword` の `CommandState`、成功 / 失敗 notice effect、二重 submit 防止は維持する。
- `signInViewModelProvider` は `resetEmailPasswordInteractorProvider` を直接注入する。
- Email/password UI の sign-in、sign-up、verification、sign-out は引き続き `authLifecycleProvider.notifier` を使う。

### Profile command composition

- `UserProfileViewModel` の依存を `IUpdateUserUseCase` 一つにする。
- `save` は `AppUser currentProfile` を必須引数で受け、編集可能 field を `copyWith` した完全な entity を UseCase へ渡す。
- `ProfilePage` は `AppSessionReady.profile` を `save` 時に渡す。session が Ready でなければ save callback を有効化しない。
- profile sign-out は `UserProfileViewModel` から削除し、Widget が `authLifecycleProvider.notifier.signOut` を呼ぶ。
- save の `CommandState` / effect は維持し、永続化失敗時に success notice を出さない。
- `userProfileViewModelProvider` は `updateUserInteractorProvider` を直接注入する。

### Navigation ownership

- `app/routing` に、`EntryPoint` と destination から既存 named route を返す pure resolver を追加する。少なくとも Word Detail と Quiz Game の現行 mapping を一箇所へ集約する。
- resolver は Riverpod、Flutter Widget、GoRouter を import しない。route contract / route name の既存正本を再利用し、文字列を各画面へ複製しない。
- Search、Quiz Search、Quiz Game、Ranking、WordPage の ViewModel から navigator field、constructor 引数、`goTo*` method を削除する。
- 各 View は tap 時に現在の `EntryPoint` を読み、resolver で named route を解決し、`WordDetailRoute.pathParameters/queryParameters` または `QuizGameRoute.pathParameters/queryParameters` を渡して遷移する。
- `RankingCard` は service provider を直接読むのをやめ、親から quiz callback を受け取る。quiz 初期化と遷移の順序は現行どおり callback 内で維持する。
- `MainActivity` の profile button は Widget context から profile route へ遷移する。
- current branch 再選択時の stack clear は `StatefulNavigationShell.goBranch(..., initialLocation: true)` を第一候補とし、characterization test で現行の「active branch のみ root へ戻る」挙動を満たさない場合だけ、必要な NavigatorKey を Widget 側で明示的に読む最小実装にする。

### DI の収束

次の provider から `appNavigatorServiceProvider` の read/importと ViewModel constructor 引数を削除する。

- `lib/features/search/di/view_model_di.dart`
- `lib/features/quiz/di/view_model_di.dart`
- `lib/features/ranking/di/view_model_di.dart`
- `lib/features/word_page/di/view_model_di.dart`

UseCase provider の `watch` / `read` 方針や autoDispose / family の lifecycle はこのフェーズで変更しない。

## API・型の変更

- 削除: `AppAuthCoordinator` と全 public method。
- 削除: `AppUserCoordinator` と全 public method。
- 削除: `AppNavigatorService` と全 public method。
- 削除: 上記3 class の provider。
- 削除: `AuthStoreNotifier`、`AppUserStoreNotifier` と provider。
- 変更: `SignInViewModel(AppAuthCoordinator)` → `SignInViewModel(IResetEmailPasswordUseCase)`。
- 変更: `SignInViewModel` の public command は password reset のみに縮小。
- 変更: `UserProfileViewModel(AppUserCoordinator, AppAuthCoordinator)` → `UserProfileViewModel(IUpdateUserUseCase)`。
- 変更: `save({email, username})` → current profile を明示的に受ける API。
- 変更: Search / Quiz / Ranking / WordPage ViewModel constructor から navigator 引数を削除。
- 追加: entry point と destination から既存 named route を解決する pure routing helper。
- 維持: application UseCase / Repository interface、`AppSession` variants、`CurrentSession`、route path / query schema、DB / sync schema。

## 実装手順

### 0. Baseline と characterization を固定する

1. `flutter analyze`、対象 test、全 test の開始時結果を記録する。
2. `rg` で Coordinator / Navigator / Store の production caller を再確認し、新規 caller が増えていないことを確認する。
3. route resolver を変更する前に、各 `EntryPoint` から Word Detail / Quiz Game へ使われる route name、path parameter、query parameter を table-driven test で固定する。
4. MainActivity の branch 再選択について、active branch の nested detail から root に戻ること、他 branch の stack を消さないことを Widget test で固定する。
5. Auth lifecycle の sign-in、unverified、ready、profile failure、sign-out、stale profile completion の状態遷移を既存 test で確認する。

### 1. Auth lifecycle から重複 Store を外す

1. `AuthLifecycleController` の constructor と fields から Auth/User Store を外す。
2. `handleAuthStateChange`、sign-up、profile provision、sign-out の Store mutation を削除し、同じ情報を controller state だけへ反映する。
3. provider composition から Store provider dependency を削除する。
4. lifecycle / session / auth widget test を controller state と `AppSession` の結果に更新する。
5. production / test の参照が0になったことを確認して Auth/User Store の class と DI file を削除する。

### 2. Auth Coordinator を削除する

1. `SignInViewModel` を password reset UseCase の直接注入へ変更する。
2. 未使用の sign-in / sign-up / sign-out command と Coordinator import を削除する。
3. provider factory を更新し、password reset の command / effect test を plain fake UseCase で追加する。
4. `authCoordinatorProvider` と `auth_coordinator.dart` を削除する。
5. lifecycle が sign-in / sign-up / sign-out / verification の唯一の active command path であることを `rg` と test で確認する。

### 3. User Coordinator を削除する

1. `UserProfileViewModel` に `IUpdateUserUseCase` を直接注入する。
2. `save` に current profile を渡し、未指定 field を保持した更新 entity を作る。
3. `ProfilePage` の save callback を Ready session の profile と結び付ける。
4. sign-out callback を auth lifecycle controller へ移し、UserProfileViewModel の sign-out command を削除する。
5. update success / failure / double-submit と、元 profile field 保持を plain unit test で固定する。
6. `appUserCoordinatorProvider` と `user_coodinator.dart` を削除する。

### 4. ViewModel から navigation を外す

1. pure route-name resolver と table-driven test を追加する。
2. Search / Quiz Search / Quiz Game / Ranking / WordPage ViewModel から navigator dependency と navigation method を削除する。
3. provider constructor と既存 ViewModel test を更新する。`WordPageViewModel` test の `_Navigator` mock は不要になる。
4. View の既存 button / card callback へ遷移を移す。query load、quiz 初期化、route payload の順序は変えない。
5. `RankingCard` の direct provider lookup を callback 注入へ変更する。

### 5. MainActivity と branch 操作を移行する

1. profile button を Widget context から named route へ遷移させる。
2. branch 再選択を `StatefulNavigationShell` の API へ置換する。
3. `entryPointProvider` と last-index provider の全面再設計は行わず、現行 tab selection 挙動を維持する。
4. profile navigation、active branch reset、別 branch stack 維持を Widget test で確認する。

### 6. Navigator service と残存参照を削除する

1. `AppNavigatorService` の全 method に active caller がないことを確認する。
2. `appNavigatorServiceProvider` と `navigator_service.dart` を削除する。
3. unused import、mock、provider override を削除する。
4. import-boundary check と analyzer で、routing 実装が application / domain へ逆流していないことを確認する。

## テスト計画

### Plain unit test

- `SignInViewModel` を fake `IResetEmailPasswordUseCase` だけで生成できる。
- password reset の success / failure / submitting 中の二重送信 / effect consume を確認する。
- `UserProfileViewModel` を fake `IUpdateUserUseCase` だけで生成できる。
- username のみの更新で deviceId、email、subscription 等の既存 field が保持される。
- profile update failure で success notice が出ず、typed error が command state に残る。
- route-name resolver が既存 `EntryPoint` mapping を返し、path / query contract は `WordDetailRoute` / `QuizGameRoute` のままである。
- Search / Quiz / Ranking / WordPage ViewModel の constructor に framework navigation fake が不要である。

### Auth lifecycle / session test

- cold start、sign-in、unverified、profile provisioning、ready、failure、retry、sign-out の phase が Store なしで成立する。
- sign-out 後に identity / profile が controller state と `AppSession` から消える。
- 遅延した旧 profile load が sign-out / account switch 後の state を復元しない。
- `appSessionProvider` の Ready profile が live profile 更新を反映する。
- Auth/User Store provider を override せず auth/session test を構築できる。

### Widget / routing test

- Search item tap が正しい Word Detail route contract で一度だけ遷移する。
- Quiz Search / Ranking / WordPage の quiz tap が正しい Quiz Game contract で一度だけ遷移する。
- Ranking quiz tap は quiz state 初期化後に遷移する。
- Profile button が profile route へ遷移する。
- current tab の再選択で active branch だけが root へ戻り、別 branch の stack は維持される。
- rebuild だけでは navigation が発生しない。

### Static / architecture check

次を実装後に確認する。

```text
rg "AppAuthCoordinator|AppUserCoordinator|AppNavigatorService" lib test
rg "authCoordinatorProvider|appUserCoordinatorProvider|appNavigatorServiceProvider" lib test
rg "AuthStoreNotifier|AppUserStoreNotifier|authStoreNotifierProvider|appUserStoreNotifierProvider" lib test
rg "final Ref|Ref ref|WidgetRef" lib/features/auth lib/features/user lib/router
rg "goToQuiz|goToWordDetail|goToDetail" lib/features/*/presentation/view_model
```

最初の3検索は active production / test code で0件を完了条件とする。Phase 3-3 対象の全行コメントアウト済み `AuthUserCoordinator` とコメントアウトDIは本フェーズで削除せず、残存する文字列は別タスクの既知残骸として区別する。

## 検証順序

Flutter / Dart command はリポジトリ指示どおり sandbox 外で直接実行する。

```text
flutter test test/unit/features/auth
flutter test test/unit/features/user
flutter test test/unit/app/session
flutter test test/unit/app/routing
flutter test test/unit/features/search
flutter test test/unit/features/quiz
flutter test test/unit/features/ranking
flutter test test/unit/features/word_page
flutter test test/widget/auth
flutter test test/widget
flutter test test/tool/import_boundaries/check_import_boundaries_test.dart
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check
flutter analyze
flutter test
```

存在しない test directory は実際に追加した path へ調整する。route / Widget test は対象を先に個別実行し、全 test は最後に一度通す。

## スコープ外

- `entryPointProvider`、last-index provider、GoRouter shell の二重 navigation state 全体の解消。これは元レビュー 8.4 の独立課題であり、本フェーズでは service locator 除去に必要な範囲だけ触る。
- route URL、nested route 構成、deep-link schema、route contract の再設計。
- Auth identity / User profile entity の統合。両者は分離し、`AppSession` で読み取り専用に合成する。
- `AuthLifecycleController` の Riverpod Notifier API への移行。
- Local-first sync、guest migration、DB schema、Repository 契約の変更。
- Phase 3-3 の全行コメントアウト済み `AuthUserCoordinator` と `core/di/coordinator/corrdinator.dart` の削除 / ADR化。
- Phase 3-4 の `coodinator`、`corrdinator` 等の rename-only 整理。active typo file は本フェーズで class ごと削除するが、横断 rename はしない。

## リスクと停止条件

- `AppUserStoreNotifier` に実装着手時点で新しい production reader が見つかった場合は、単純削除せず、その reader を `AppSession` / live profile projection へ移せるか先に判断する。Repository や DB ownership の変更が必要なら停止してスコープを再評価する。
- branch reset を `goBranch(initialLocation: true)` へ置換して別 branch の履歴まで失う、または browser back / deep link の挙動が変わる場合は、routing 全体を再設計せず現行 key 操作を Widget 側へ明示注入する最小案へ戻す。
- navigation を Widget へ移すために同じ route-name mapping が複数箇所へ複製される場合は実装を進めず、pure resolver へ集約する。
- lifecycle state だけでは既存 auth UI の表示契約を再現できないことが判明した場合は、Store を延命せず不足している state を明示し、Phase 1-4 の source-of-truth 方針と整合するか確認する。
- Coordinator 削除のために application / domain へ Flutter、Riverpod、GoRouter を importする必要が出た場合は境界違反として停止する。

## contexts 更新方針

- 実装中は本 plan の状態、完了項目、実行した test 数、未解決事項を更新する。
- 全 completion criteria と全体検証が通った時だけ `docs/refactor/phase2/4-remove-ref-from-coordinators.md` を完了へ変更する。
- `docs/refactor/contexts/current.md` には、active Coordinator / Navigator / manual Store の削除、navigation ownership、検証結果を短く追記する。
- `docs/refactor/contexts/app-routing.md` と `feature-map.md` の `AppNavigatorService` 記述を Widget-owned navigation / pure route resolver に更新する。
- Phase 3-3 のコメントアウト Coordinator は未対応のまま残し、同タスクの依存条件が満たされたことだけを future note に記録する。

## 完了条件

- [ ] active `AppAuthCoordinator`、`AppUserCoordinator`、`AppNavigatorService` と各 provider が削除されている。
- [ ] 長寿命 object が `Ref`、`WidgetRef`、ProviderContainer、Ref を capture する callback を保持していない。
- [ ] Auth / User の可変 Store と手動 Store 同期が production code から削除され、`AuthLifecycleState` / `AppSession` が表示と routing の入口である。
- [ ] sign-in / sign-up / sign-out / verification / profile provision の active command path が `AuthLifecycleController` に一意である。
- [ ] profile update は current profile と `IUpdateUserUseCase` の明示依存だけで実行される。
- [ ] Search、Quiz、Ranking、WordPage の ViewModel が navigation framework / service に依存しない。
- [ ] navigation は user callback または one-shot effect の処理箇所だけで発生し、rebuild では発生しない。
- [ ] route URL / parameters / shell branch とユーザー向け遷移挙動が維持されている。
- [ ] Auth / User command と主要 ViewModel を ProviderContainer なしの plain fake で test できる。
- [ ] import-boundary check、`flutter analyze`、全 `flutter test` が成功する。

## 実装単位

実装は「baseline」「Store 撤去」「Auth Coordinator 撤去」「User Coordinator 撤去」「ViewModel navigation 撤去」「MainActivity / routing 移行」「service / import 収束」「全体検証」の順で進める。各単位で対象 test が失敗したまま次へ進まない。特に Store 撤去と branch stack 操作は別単位にし、認証状態の退行と routing の退行を同時にデバッグしない。
