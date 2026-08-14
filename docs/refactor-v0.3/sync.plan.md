# Sync feature リファクタ実装計画

## 1. 目的

`sync`をgeneric同期runtimeのownerとして明確化し、唯一のbusiness facade、限定されたdataset SPI、
型付きcompositionを確立する。opaque dependency resolver、deep port import、禁止命名、
feature固有semanticsの逆流を段階的に除去する。

この計画では同期algorithmやprotocolを変更しない。現在のqueue、retry、checkpoint、ordering、
cursor、wire、dataset結果を同じまま新しい境界へ接続する。

## 2. 現状と解消対象

- `port/sync.dart`がなく、app、integration、各featureが多数の`port/**`をdeep importしている。
- `port/composition_contract.dart`が`T Function<T>(Object)`、opaque keyを公開し、bootstrapで`as T`する。
- `port/composition.dart`から`internal/composition/sync_composition_factory.dart`へのbridgeが
  `composition_exact_facade`に抵触する。
- `ISyncRunner`、`ISyncQueue`、`IDatasetSyncHandler`等の`I` prefixと、
  `AdapterDatasetSyncHandler`等が命名規則外である。
- `DatasetSyncRecord.payload`が`Object`で、feature adapterがruntime castする。
- `RemoteMutationTarget`が全feature datasetを列挙し、remote executorがUserProfile provisioningまで持つ。
- `app/infrastructure/firebase/firebase_remote_mutation_executor.dart`がSDK transactionとacknowledgement mechanicsだけを所有し、feature固有remote semanticsは各dataset ownerが所有する。
- checkerはSync sole facadeとgeneric opaque resolverを検査していない。

## 3. Ownership matrix

| Owner | 所有するもの | 所有しないもの |
|---|---|---|
| Sync | context/cancellation、dataset execution plan、queue/lease/outbox contract、checkpoint、retry/backoff/classification、single-flight、scheduler、telemetry、generic run outcome | feature payload、Firestore collection/field、feature conflict rule、UserProfile provisioning |
| 各dataset feature | dataset固有payload、local/remote mapper、field mask、conflict/ack semantics、feature adapter | queue/retry/checkpoint/scheduler policy |
| app/bootstrap | database、session fence、completed runtime/runner/handler Provider、handler registryへの登録 | sync algorithm、dataset payload semantics |
| external-system infrastructure | Firebase client/lifetimeとSDK実装 | feature業務policy |
| app workflow/presentation | trigger、warning、retry UI、manual-sync表示 | queue/checkpoint、dataset mapping |
| `lib/integration` | 公開contract間の値/error変換とtechnical wiring | SDK操作、wire解釈、paging/warning/filtering、domain truth |

ADR 0001の「Syncはengineを所有し、dataset payloadの意味は各featureが所有する」を優先する。

## 4. 変えてはいけない挙動とnon-goals

- `SyncDataset` stable IDと実行順、依存graphを変更しない。
- queue lease/coalesce/ack/retry/dead-letter、attempt、UTC、transaction境界を変更しない。
- checkpointのinclusive boundary、cursor ordering、remote apply/ack semanticsを変更しない。
- retry分類、backoff/jitter、single-flight、coalesced rerun、session fence/cancellationを変更しない。
- `SyncRunOutcome` precedence、reason code、telemetry allowlistを変更しない。
- Firestore collection/document/field、payload、field mask、revision、mutation IDを変更しない。
- manual sync、guest migration、lifecycle trigger、notice/retry UI、routeを変更しない。
- dataset追加、同期機能追加、schema/migration変更を行わない。

## 5. 公開surfaceの分類

```text
lib/features/sync/port/
├─ sync.dart                       # sole business facade
├─ command.dart / result.dart
├─ model/                          # context, outcome等のpure model
├─ dataset_contract.dart           # 許可されたfeature dataset SPI
├─ composition_contract.dart       # pure completed-capability bundle
└─ composition.dart                # typed app composition seam
```

- business facade: app workflowが利用するrunner、context、cancellation、run outcome。
- dataset SPI: dataset ownerが実装するadapter/handler contractと、feature compositionに必要なruntime contract。
- composition seam: app bootstrapだけが利用するtyped factory。
- queue、checkpoint、outbox等を他featureが必要とする場合は、stable provided capabilityとしてfacadeへ
  明示するか、feature compositionだけに許可するtechnical contractへ分類する。分類なしのdeep importは禁止する。

## 6. 依存関係と実装順

- Sync typed compositionをAuth/UserProfile等のcomposition移行より先に安定させる。
- sole facadeとtechnical SPIの分類を先に決めてから、全consumerを縦スライス移行する。
- interface renameはcontract移行後に機械的に行い、algorithm変更と同じphaseに混ぜない。
- payloadの型安全化とremote executor ownershipは全dataset featureへ影響するため、MyWord、WordStatus、
  UserProfileのowner factoryが安定した後に行う。
- Firebase wire/schemaを変えずにowner infrastructureへ移せない場合は、明示ADRを作り停止する。

## 7. 実装phase

### Phase 0: Characterization、surface分類、protocol manifest

- dataset IDs/order、queue contract、checkpoint boundary、cursor、retry、error classification、report、
  telemetry、session cancellationを既存testで固定する。
- 全`port/**`型をbusiness facade、dataset SPI、composition-only、internal候補へ分類する。
- feature固有payload/target/provisioningのownerと移行先をADR follow-upへ記録する。
- external consumer/import一覧と削除条件を作る。

完了条件:

- public surface manifestが全型のownerと許可consumerを示す。
- schema/wire/protocolを変えずに進められるphase境界が明確である。

### Phase 1: sole business facadeと限定dataset SPI

- `port/sync.dart`を作り、workflow向けのpure contract/modelだけを明示exportする。
- dataset owner向けcontractを小さい`dataset_contract.dart`へ集約し、利用場所をcheckerで限定する。
- app workflow、presentation、integrationはbusiness facadeへ移す。
- feature internal/compositionは許可されたdataset SPIへ移し、個別model fileのdeep importをなくす。
- technical seamをbusiness facadeからre-exportしない。

完了条件:

- business consumerのimportは`port/sync.dart`だけである。
- dataset SPIのconsumerは許可されたfeature internal factory/infrastructureとtechnical testだけである。
- facadeとSPI closureはFlutter、Riverpod、Drift、Firebaseを含まない。

### Phase 2: typed compositionとcompleted capability

- `SyncDependencies`をimmutableな`final class`、required named database/session-fence fieldsで定義する。
- queue、checkpoint store、outbox writer、handler runtime等のcompleted bundleを
  `composition_contract.dart`へ定義する。
- `port/composition.dart`はtyped dependenciesをinternal factoryへ渡すだけにする。
- app bootstrapがshared runtime、completed capability、runner Providerとdisposeを所有する。
- sync registryは完成済みdataset handler Providerをwatchして並べるだけにする。

完了条件:

- `SyncDependencyQueryPort`、`SyncCompositionDependencies`、`Object` key、generic lookup、`as T`が0である。
- Factory signatureだけで依存とlifetime境界を理解できる。
- registry内でDAO、queue、adapter、runtimeを構築しない。

### Phase 3: 命名規則への機械移行

- `I` prefixを除き、契約は責務に応じたPort/Gateway名へ変更する。
- workflow read/write contractはQueryPort/CommandPort、completed runnerは公開能力として明確に命名する。
- 実装の`Adapter`、`Impl`、`Internal`、`Port` suffixをService、Repository、DAO、DataSourceへ変更する。
- typedef shimは同一phaseの移行用に限定し、参照0後に削除する。

完了条件:

- source/testの旧interface・implementation名参照が0である。
- renameだけのphaseとしてprotocol/algorithm testに差分がない。

### Phase 4: payload境界の型安全化

- `DatasetSyncRecord.payload Object`とfeature側runtime castを除去する。
- Sync-owned envelopeはgeneric execution metadataだけを保持し、payloadのtyped model/codecは各featureが所有する。
- feature adapterのpush/pull/apply/ack failure単位とtransaction境界を維持する。
- JSON/Firestore map、SDK snapshot、feature DTOをSync business facadeへ公開しない。

完了条件:

- productionのdataset payload pathに`Object`/`dynamic`/unchecked castがない。
- 各featureのwire mapperはowner internalにあり、既存payload contract testが同値である。
- partial failure、ack、checkpoint、orderingに差分がない。

### Phase 5: feature固有remote semanticsのowner返却

- UserProfile provisioningをUserProfile owner contract/infrastructureへ移す。
- feature列挙型のremote targetをgeneric Sync business contractから除き、各dataset ownerが自身のtarget mappingを持つ。
- central Firebase executorを分割する場合もSDK transaction、field mask、ack metadata、wire値を維持する。
- pure cross-feature変換が必要な場合だけ`lib/integration`を使い、SDK操作やwire interpretationは置かない。
- 一時的な中央executorが必要なら、対象path、理由、owner、終了条件をADRに記録し最終phaseで除去する。

完了条件:

- Sync public/internal applicationがUserProfileや個別datasetの業務語彙を知らない。
- external-system adapterは各owner internal、または明示ADRの限定technical boundaryにある。
- wire/schema/protocol characterization testに差分がない。

### Phase 6: checker、manifest、legacy削除

- 両checkerをhard-code feature一覧に依存しないsole-facade検査へ拡張する。
- 全feature compositionにopaque resolver、Provider type、`as T`を禁止するfixtureを追加する。
- Sync dataset SPIのallowed consumerとnegative fixtureを追加する。
- public-surface manifestとownership ADRを更新する。
- 旧deep port、resolver、shim、中央feature-specific contractを参照0確認後に削除する。

完了条件:

- checkerがSync internal/deep-port、不正SPI利用、opaque compositionを検出する。
- baselineで新規違反を正当化せず、Sync関連違反が0である。

## 8. 検証順

1. `test/unit/features/sync/application/sync_contract_test.dart`
2. `test/unit/features/sync/application/remote_mutation_contract_test.dart`
3. queue contract: fake / Drift
4. `sync_handler_runtime_contract_test.dart`、`sync_engine_test.dart`
5. retry/error/execution-guard/scheduler/report tests
6. checkpoint、transaction、telemetry infrastructure tests
7. Sync facade / dataset SPI / composition factory tests
8. app bootstrap Sync Provider override/rebuild/dispose test
9. UserProfile、MyWord、WordStatus dataset sync handler tests
10. guest migration、manual sync、lifecycle trigger tests
11. checker fixture tests
12. focused `dart analyze`
13. repository-wide boundary checks
14. full `flutter test`

## 9. 最終完了条件

- sole business facade、限定dataset SPI、typed composition、completed registryが確立している。
- opaque resolver、runtime cast、external deep import、legacy shim、禁止命名が0である。
- Syncがgeneric runtimeだけを所有し、feature payload/mapping/conflict/provisioningがownerへ戻っている。
- Riverpodはapp bootstrap/technical wiringだけにあり、business/application/infrastructureへ漏れていない。
- schema、wire、stable ID/order、queue/retry/checkpoint/session/UI挙動に差分がない。
- checker、manifest、ADR、実装が一致する。

## 10. 停止条件

- stable dataset ID/order、cursor、queue、retry、checkpoint、field mask、ack semanticsの変更が必要になる。
- schema、Firestore wire、migration、route、session、UIの変更が必要になる。
- payload型安全化がwire format変更なしでは成立しない。
- external-system adapterのownerを既存ADRと整合して決められない。
- dataset owner担当との同一file競合によりbuild可能な縦スライスを維持できない。
- 機能追加または同期algorithm改善へscopeが拡大する。
