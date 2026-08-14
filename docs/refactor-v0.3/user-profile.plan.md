# UserProfile feature リファクタ実装計画

## 1. 目的

`user_profile`のprofile contract、永続化、同期contribution、presentationをowner境界へ整理し、
唯一のbusiness facadeと型付きcompositionを確立する。公開中のFirestore DTOとopaque dependency
resolverを除去しつつ、profile、guest migration、sync、sessionの現行挙動を維持する。

## 2. 現状と解消対象

- business facadeがなく、外部が`user_profile.dart`、`auth_lifecycle.dart`、`live_user_profile.dart`、
  `guest_migration.dart`、`user_dto.dart`をdeep importしている。
- `port/user_dto.dart`がFirestore collection/field、`Map<String, dynamic>`、serializationを公開している。
- MyWordとWordStatusのFirebase DAOが`UserDTO.collectionName`へ依存する。
- `port/composition.dart`に`UserProfileDependencyReader`、enum key、
  `SyncDependencyQueryPort`があり、app/integration側で`as T` castしている。
- guest migration portが`IOutboxWriter`とclockをoperation引数へ漏らしている。
- `internal/di/**`と`internal/infrastructure/firebase/firebase_dependencies.dart`にRiverpodが残る。
- `IUser*`、`UserDao`、`*Adapter`等の名称が命名規則と一致しない。
- checkerはUserProfile sole facadeとopaque resolverを検査していない。

## 3. Ownership matrix

| Owner | 所有するもの | 所有しないもの |
|---|---|---|
| UserProfile | profile値、default、validation、profile lifecycle、local/remote mapping、profile sync payload/conflict、guest profile migration contribution | Auth identityの正本、session phase/epoch、migration workflow UI、generic sync policy |
| Auth | account identity、email verificationの事実 | profileの正本、username、subscription |
| Sync | queue、outbox contract、retry、checkpoint、handler runtime | UserProfile payload、Firestore field、profile conflict rule |
| MyWord / WordStatus | 各featureのnested collection、payload、sync mapping | UserProfile DTOとprofile field |
| app guest/session workflow | profile capabilityの実行順、current account、warning/retry/UI policy | profile永続化、wire mapping |
| `app/bootstrap` | database、SharedPreferences、Firestore/remote runtime、completed capabilityのlifetime | profile semantics |
| shared Firebase account namespace owner | top-level account document pathのtechnical contract | 各featureのnested payloadと業務field |

`Users` top-level collectionは複数featureのremote pathに影響するため、Phase 0でownerをADRに確定する。
UserProfileのwire DTOを共有contractとして残す案は禁止する。

## 4. 変えてはいけない挙動とnon-goals

- profile default、email由来username、device ID生成、local profile優先順位を変更しない。
- ensure profileのidempotency、update、watch、absence/error semanticsを変更しない。
- local writeとoutbox enqueueのtransaction、mutation ID、field maskを変更しない。
- guest data検出、OR/merge、clock利用、migration result、post-migration syncを変更しない。
- `user_profile` dataset stable ID、revision、cursor、Firestore collection/document/fieldを変更しない。
- Auth/session phase、route、UI文言、loading/error/effect挙動を変更しない。
- schema、migration、serialization protocol、機能を追加・変更しない。
- subscriptionやaccount/device modelを再設計しない。

## 5. 目標構造

```text
lib/features/user_profile/
├─ port/
│  ├─ user_profile.dart             # 唯一のbusiness facade
│  ├─ command.dart
│  ├─ query.dart
│  ├─ result.dart
│  ├─ model/profile.dart
│  ├─ guest_migration.dart
│  ├─ composition_contract.dart
│  ├─ composition.dart              # typed technical seam
│  └─ presentation_entry.dart
└─ internal/
   ├─ application/
   ├─ domain/
   ├─ infrastructure/
   │  ├─ drift/
   │  ├─ shared_preferences/
   │  ├─ firebase/
   │  ├─ sync/
   │  └─ guest_migration/
   ├─ presentation/
   └─ composition/

lib/app/bootstrap/user_profile_composition.dart
```

Firestore DTO、field key、wire conversionは`internal/infrastructure/firebase/**`だけに置く。

## 6. 依存関係と実装順

- Syncのtyped technical contractsとruntime factoryを先に安定させる。
- Authのpublic identity/session inputをfacade越しに利用し、Auth internalへ依存しない。
- `Users` account namespaceのADRを確定するまで`UserDTO.collectionName` consumerを削除しない。
- UserProfile compositionのopaque resolver除去は、通常graphとsync graphを別bundleで同じphaseに移行する。
- MyWord/WordStatusのremote path consumerは、それぞれのowner担当と同一縦スライスで切り替える。

## 7. 実装phase

### Phase 0: Characterization、ownership、shared remote path ADR

- ensure/update/watch、local precedence、outbox、guest migration、dataset syncをtestで固定する。
- `UserDTO`の全field、Firestore timestamp変換、revision/cursor/field maskをprotocol manifestへ記録する。
- top-level `Users` account document pathのownerをADRで決める。
  - UserProfile wire DTOを他featureへ公開しない。
  - SDK `DocumentReference`やraw wire mapをbusiness portへ公開しない。
  - 各featureのnested payload ownershipを統合しない。
- current external importsと削除条件をmanifest化する。

完了条件:

- schema/wireを変更せずに`UserDTO` deep dependencyを除去する行き先がADRで一意である。
- 現行profile/session/sync/guest migration挙動がcharacterization testで固定される。

### Phase 1: sole business facadeと公開DTOの純化

- `port/user_profile.dart`をsole facadeとし、profile model、Query/Command Port、Result/error、
  guest migration capabilityを明示exportする。
- `UserDTO`をFirebase internalへ移し、公開profile modelからcollection/field/Map conversionを除く。
- Query/Commandにaccount scopeを含める場合も、現行empty-ID failureとvalidation時点を維持する。
- app/session、guest workflow、integration、test fakeをfacade importへ移す。
- `UpdateUserProfilePort`等をUserProfile QueryPort/CommandPort命名へ整理する。

完了条件:

- business facade closureがpure Dartで、wire/SDK/DB/Widget stateを含まない。
- feature外のbusiness deep importが0である。
- `UserDTO`はpublic surfaceから消え、UserProfile internalだけでprofile fieldを解釈する。

### Phase 2: typed compositionとinternal factory

- 通常graph用`UserProfileDependencies`とsync graph用`UserProfileSyncDependencies`をimmutableな
  `final class`、required named fieldsで定義する。
- completed `UserProfilePorts`をpureな`composition_contract.dart`へ置く。
- Factoryはnamed parameterでbundleを受け、internal factoryへ具体型をconstructor DIする。
- `app/bootstrap/user_profile_composition.dart`がdatabase、SharedPreferences、remote runtime、
  outbox writer、sync runtimeとcompleted capability Providerを所有する。
- sync registryは完成済みUserProfile handler Providerをwatchするだけにする。

完了条件:

- `UserProfileDependencyReader`、`UserProfileDependency`、`UserProfileSyncDependency`、
  `SyncDependencyQueryPort`、`as T`がUserProfile graphから0になる。
- appはUserProfile internalをimportせず、featureはapp Providerを読まない。
- DAO/data source/repository/mapperを個別Provider化していない。

### Phase 3: guest migration capabilityの完成品化

- outbox writerとclockをoperation引数から外し、typed composition dependencyとしてowner factoryへ渡す。
- app workflowへは「検出」「migration実行」の完成済みcapabilityだけを公開する。
- workflow policy、prompt、retry/warning、post-sync判断はappに残す。
- migration内部のtransaction、mutation payload、deterministic IDは変更しない。

完了条件:

- business callerがSync infrastructure contractやclockを組み立てない。
- guest migration acceptance testの結果とside effectが現行一致する。

### Phase 4: remote DTOとcross-feature path dependencyの除去

- Phase 0 ADRのtechnical contractへMyWord/WordStatusのaccount document path参照を移す。
- 各featureは自分のnested collection、DTO、field、queryを引き続きowner internalに保持する。
- UserProfile Firebase DTO/mapperはprofile fieldsだけを所有し、外部へexportしない。
- `UserDTO.collectionName`のproduction/test参照が0になってから旧public fileを削除する。

完了条件:

- MyWord/WordStatusからUserProfile port DTOへのimportが0である。
- Firestore path、collection、document、field、query boundary testに差分がない。
- integrationにSDK操作、wire interpretation、feature policyを移していない。

### Phase 5: legacy DI、presentation、命名整理

- presentation view modelをnew completed portsへ接続する。
- `internal/di/**`、feature-owned Firestore Providerを参照0確認後に削除する。
- Riverpodをapp bootstrapとpresentation専用wiringに限定する。
- `I*`、`Impl`、`Adapter`、曖昧な`UserDao`を規則上のDAO/DataSource/Repository/Service名へ変更する。
- `presentation_entry.dart`はcontrolled Widget/state/callbackだけを公開する。

完了条件:

- domain/application/infrastructureのRiverpod importが0である。
- internal provider/view modelをappや他featureへ公開していない。
- 旧DIと禁止命名の参照が0である。

### Phase 6: checker、manifest、legacy削除

- 両checkerへUserProfile sole facade、technical seams、opaque resolver、wire DTO漏出のfixtureを追加する。
- public-surface manifest、ownership ADR、remote path ADRを実装と同期する。
- 旧port、shim、DTOを`rg`でproduction/test参照0確認後に削除する。

完了条件:

- checkerがexternal internal/deep-port、不正composition、Riverpod/wire漏出を自動検出する。
- 文書、facade export、実装、test importが一致する。

## 8. 検証順

1. UserProfile port validation/public contract test
2. `test/unit/features/user_profile/data/user_repository_ensure_profile_test.dart`
3. `test/unit/features/user_profile/user_profile_outbox_enqueue_test.dart`
4. UserProfile composition factory / app Provider override test
5. `test/unit/features/user_profile/user_profile_sync_handler_test.dart`
6. `test/unit/features/user_profile/presentation/view_model/user_profile_view_model_test.dart`
7. `test/unit/app/session/app_session_test.dart`
8. `test/integration/gate_b/guest_migration_workflow_test.dart`
9. MyWord/WordStatus remote path、sync、outbox focused tests
10. checker fixture tests
11. focused `dart analyze`
12. repository-wide boundary checks
13. full `flutter test`

## 9. 最終完了条件

- sole facade、pure public model、typed composition、controlled presentation entryが確立している。
- public surfaceにFirestore DTO、wire key、SDK型、opaque resolverがない。
- cross-feature `UserDTO`依存、legacy DI、deep import、shimが0である。
- UserProfileがprofile payloadを、Syncがgeneric runtimeを所有する境界が維持される。
- schema/wire/protocol/session/UIのcharacterization testに差分がない。
- checker、manifest、ADRが最終実装と一致する。

## 10. 停止条件

- `Users` root pathのownerを既存ADRと整合して決められない。
- schema、Firestore path/field、sync stable ID/order/cursor/field maskの変更が必要になる。
- Auth/session、guest workflow、route、UI挙動の変更が必要になる。
- remote path解決のためにwire DTOやSDK objectをbusiness portへ公開する必要が生じる。
- MyWord/WordStatus担当と同一consumer fileで競合し、build可能な縦スライスを保てない。
- 機能追加やデータmigrationへscopeが拡大する。

