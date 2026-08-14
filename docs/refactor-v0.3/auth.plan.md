# Auth feature リファクタ実装計画

## 1. 目的

`auth`をFeature設計、命名、Composition/DIの各ルールに適合させる。認証の業務契約を
唯一のpure Dart facadeへ集約し、Firebase Authの実体とlifetimeをapp compositionが所有する
型付きDIへ移行する。

この計画は構造、依存方向、命名、公開surfaceだけを変更する。認証機能、画面、session遷移、
Firebase Authの挙動は変更しない。

## 2. 現状と解消対象

- business facadeがなく、外部が`port/app_auth.dart`、`auth_commands.dart`、
  `auth_readers.dart`をdeep importしている。
- `SignInPort`等が`<ドメイン><能力>QueryPort/CommandPort`命名になっていない。
- `port/composition.dart`が`internal/composition`へ直接bridgeしており、現checkerの
  `composition_exact_facade`に抵触する。
- `createAuthLifecyclePorts()`のsignatureからruntime dependencyを判別できず、feature内部で
  `FirebaseAuth.instance`を取得している。
- `internal/di/**`と`internal/infrastructure/firebase/firebase_auth_dependencies.dart`に
  Riverpod Providerが残り、DAO、repository、use caseをservice locator graphで構築している。
- `AuthRepositoryImpl`、`IAuthRepository`、`I*UseCase`等が命名規則と不一致である。
- `AppAuth`の`isLogined`、`isAuthenticated`、`emailVerified`は互換性を持つ一方、意味が重複している。
- auth固有のsole-facade規則とopaque composition検査がcheckerにない。

## 3. Ownership matrix

| Owner | 所有するもの | 所有しないもの |
|---|---|---|
| Auth | 認証identity、provider、email verificationの事実、credential command、Firebase Auth mapping、認証error正規化 | usable sessionの状態機械、profile provisioning、routing、画面policy |
| UserProfile | profileの正本、profile provisioning結果 | credential、email verificationの正本 |
| app/session workflow | AuthとUserProfileの結果を合成したsession phase、epoch、再試行・表示判断 | Auth/UserProfileの永続化・SDK mapping |
| `lib/integration/session_lifecycle_workflow` | 公開contract間の合成と値の受け渡し | Auth internal、Firebase SDK、profile永続化 |
| `app/bootstrap` | `FirebaseAuth`実体、completed Auth capabilityのlifetime、override | credential validation、認証semantics |

## 4. 変えてはいけない挙動とnon-goals

- sign-in/sign-upのtrim、validation条件、error message/codeを変更しない。
- verification email送信、reload、sign-out、password resetの成功・失敗semanticsを変更しない。
- signed-out、email-unverified、profile-provisioning、ready、failureのsession遷移を変更しない。
- 二重submit抑止、notice/effectの一回消費、再試行条件を変更しない。
- route、Widget構造、文言、デザインを変更しない。
- Firebase project、provider設定、SDK操作順、認証protocolを変更しない。
- 新しい認証方式、password policy、account機能を追加しない。
- `AppAuth`の互換fieldは全consumer移行前に削除しない。意味の統合が挙動変更になる場合は別計画へ送る。

## 5. 目標構造

```text
lib/features/auth/
├─ port/
│  ├─ auth.dart                    # 唯一のbusiness facade
│  ├─ command.dart
│  ├─ query.dart
│  ├─ model/auth_identity.dart
│  ├─ composition_contract.dart
│  ├─ composition.dart             # typed technical seam
│  └─ presentation_entry.dart
└─ internal/
   ├─ application/
   ├─ domain/
   ├─ infrastructure/firebase/
   ├─ presentation/
   └─ composition/

lib/app/bootstrap/auth_composition.dart
```

`auth.dart`はbusiness contractだけを明示exportする。`composition.dart`と
`presentation_entry.dart`はexportしない。

## 6. 依存関係と実装順

- Auth public contractを先に安定させ、その後session lifecycle consumerをfacadeへ移す。
- UserProfileの型やinternalへAuthから依存しない。両featureの合成は既存integration workflowに残す。
- `FirebaseAuth` Providerをapp bootstrapへ確立してから旧feature-owned Providerを削除する。
- password resetは旧presentation graphの最後の利用者なので、正式なAuth command contractへ接続してから
  `internal/di/**`を削除する。

## 7. 実装phase

### Phase 0: Characterizationと公開契約の確定

- 現行のsign-in/sign-up validation、Firebase error mapping、observe/reload、verification、sign-out、
  password resetを既存testで固定する。
- `AppAuth`の各fieldとnull/absence semantics、auth-state stream errorの現行挙動を記録する。
- ownership matrix、public surface、移行中だけ残す互換型を文書化する。

完了条件:

- 変更してはいけない認証・session挙動がtest名と期待値で読める。
- 新contractへの名称対応表と削除条件が確定している。

### Phase 1: sole business facadeと命名準拠contract

- `port/auth.dart`を作り、公開identity、Query/Command Port、必要なResult/errorだけをexportする。
- read-only capabilityをAuth QueryPort、状態変更をAuth CommandPortとして分離する。
- primitive引数をCommand DTOへ移す場合も、validation時点、trim、error内容を維持する。
- session lifecycle、app/session、test fakeのdeep importをfacadeへ縦スライスで切り替える。
- 移行中の旧名shimは同一phase内だけ許可し、最終状態に残さない。

完了条件:

- feature外のbusiness importは`features/auth/port/auth.dart`だけである。
- facade closureはFlutter、Riverpod、Firebaseを含まない。
- query/write capabilityと命名が3ルールに一致する。

### Phase 2: 型付きcompositionとapp-owned runtime

- immutableな`AuthDependencies`へ必要なpure `AuthRuntimeGateway`をrequired named fieldで表す。
- completed capability bundleをpureな`composition_contract.dart`へ置く。
- `port/composition.dart`はtyped dependenciesを受けて同feature internal factoryへ委譲するだけにする。
- app-owned external-system adapterがFirebase data sourceを構築し、internal factoryがpure gatewayをrepository、application serviceへconstructor DIする。
- `app/bootstrap/firebase_providers.dart`が`FirebaseAuth`実体とSDK-free gateway Providerを所有し、`auth_composition.dart`がcompleted capability Providerを所有する。
- Provider合成は`ref.watch`を原則とし、override時の再構築をtestする。

完了条件:

- Factory signatureだけで依存を列挙でき、`Object`、`dynamic`、generic lookup、`as T`がない。
- feature internalで`FirebaseAuth.instance`やapp Providerを探索しない。
- appはAuth internalを直接importしない。

### Phase 3: legacy DIと命名debtの除去

- password resetを新CommandPortへ接続し、旧view model Provider graphへの業務依存をなくす。
- `internal/di/data_di.dart`、`usecase_di.dart`、feature-owned Firebase Providerを参照0確認後に削除する。
- Riverpodはpresentation wiringとapp bootstrapだけに限定する。
- `Impl`、interfaceの`I` prefix、実装の`Port/Adapter/Internal` suffixを責務に沿う名称へ変更する。
- Firebase例外はowner境界で既存のtyped errorへ正規化し、SDK例外をpublic境界へ漏らさない。

完了条件:

- domain/application/infrastructureのRiverpod importが0である。
- 旧DI、旧class名、旧deep portへのproduction/test参照が0である。
- 全実装名が命名規則のQueryService、CommandService、ApplicationService、DAO、DataSource、
  Repository、Serviceのいずれかで説明できる。

### Phase 4: presentation seam、checker、文書の固定

- `presentation_entry.dart`は制御されたWidget、state、callbackだけを公開し、Providerを公開しない。
- import boundary checkerとfeature dependency checkerへAuth sole facade、technical seam、
  opaque resolver、Riverpod禁止のfixtureを追加する。
- Auth public-surface manifestと必要なADR follow-upを追加する。
- 互換shimを参照0確認後に削除する。

完了条件:

- checkerがAuth internal/deep-port/不正compositionのnegative fixtureを検出する。
- productionで許可された外部入口はbusiness facade、app composition seam、presentation entryだけである。

## 8. 検証順

1. `test/unit/features/auth/application/usecase/signin_interactor_test.dart`
2. `test/unit/features/auth/data/firebase_auth_remote_data_source_test.dart`
3. Auth port contract / public facade / composition factory test
4. `test/unit/features/auth/presentation/view_model/**`
5. `test/unit/features/auth/presentation/view_model/auth_view_model_test.dart`
6. `test/unit/app/session/app_session_test.dart`
7. `test/widget/auth/auth_state_display_test.dart`
8. app bootstrap Auth Provider override/rebuild test
9. checker fixture tests
10. focused `dart analyze`
11. repository-wide boundary checks
12. full `flutter test`

## 9. 最終完了条件

- sole business facade、typed composition、controlled presentation entryが確立している。
- Auth内部にRiverpod service locator、SDK singleton探索、opaque resolverがない。
- external deep import、legacy shim、旧DI、禁止命名の参照が0である。
- 認証、session、UIのcharacterization testに差分がない。
- checker、manifest、ADR、実装が一致する。

## 10. 停止条件

次の場合は実装を続けず、phaseを停止して判断をメインスレッドへ返す。

- Firebase Auth操作順やerror code/messageの変更が必要になる。
- session phase、route、Widget挙動の変更が必要になる。
- `AppAuth`互換fieldの削除が未移行consumerを壊す。
- UserProfile internalへの依存、またはappからAuth internalへの直接importが必要になる。
- schema、wire、protocol、機能追加へscopeが拡大する。
- 他担当の未完了変更と同じfileで競合し、縦スライスをbuild可能に保てない。
