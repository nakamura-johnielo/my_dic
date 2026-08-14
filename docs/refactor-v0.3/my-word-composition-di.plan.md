# MyWord Composition DIリファクタ実装計画

> Implementation status (2026-08-14): completed with the stricter generalized
> composition rule. `port/composition.dart` is SDK-free, imports only the
> canonical `my_word_composition_factory.dart` internal bridge, and receives a
> core nested-account-document gateway instead of `FirebaseFirestore`.

## 1. 目的

MyWordの通常機能と同期機能に残るopaque dependency resolverを廃止し、Riverpodを
app composition rootのDIコンテナとして使用する。

最終状態では次を実現する。

- `MyWordDependencyReader`と`SyncDependencyQueryPort`によるMyWord依存解決を廃止する
- enum keyと`as T`による実行時castをMyWord compositionから除去する
- MyWordが必要とするruntime dependencyを型付きbundleで明示する
- Riverpodはapp bootstrapでshared dependencyとcompleted capabilityを管理する
- DAO、data source、repository、dataset adapterの構築責任はMyWord internal factoryに残す
- sync registryは完成済み`IDatasetSyncHandler` Providerを登録するだけにする
- featureからappへの逆依存と、appからMyWord internalへの直接依存を作らない

このリファクタでは同期protocol、DB schema、Firestore wire format、業務挙動を変更しない。

## 2. 現状

### 通常MyWord graph

```text
myWordPortsProvider
  -> MyWordDependencyReader
  -> enum switch + as T
  -> createMyWordPorts(read)
  -> createInternalMyWordPorts(read)
  -> DAO / data source / repository / application adapter
```

依存は`database`と`outboxWriter`だが、Factory signatureから具体的な型を判別できない。

### MyWord sync graph

```text
syncDatasetHandlersProvider
  -> _featureQueryPort(ref)
  -> _readFeatureDependency(ref, Object key)
  -> enum switch + as T
  -> createMyWord*DatasetSyncHandler(read, runtime)
  -> local / remote data source / dataset adapter / handler
```

MyWord同期が必要とする依存は`database`、`firestore`、
`remoteMutationExecutor`、`runtime`である。他featureも同じresolverを利用しているため、
MyWord移行時に共通resolver全体は削除せず、MyWordの分岐だけを段階的に外す。

## 3. 目標構造

```text
app/bootstrap/my_word_composition.dart
  ├─ myWordPortsProvider
  │    └─ createMyWordPorts(MyWordDependencies)
  ├─ myWordDatasetSyncHandlerProvider
  │    └─ createMyWordDatasetSyncHandler(MyWordSyncDependencies, runtime)
  └─ myWordStatusDatasetSyncHandlerProvider
       └─ createMyWordStatusDatasetSyncHandler(MyWordSyncDependencies, runtime)

app/bootstrap/sync_composition.dart
  └─ syncDatasetHandlersProvider
       ├─ ref.watch(myWordDatasetSyncHandlerProvider)
       └─ ref.watch(myWordStatusDatasetSyncHandlerProvider)

features/my_word/port/composition.dart
  ├─ MyWordDependencies
  ├─ MyWordSyncDependencies
  └─ typed factory functions

features/my_word/port/composition_contract.dart
  └─ pureなMyWordPorts bundle

features/my_word/internal/composition/**
  └─ constructor DIでinternal graphを生成
```

Riverpod Providerの境界は`MyWordPorts`と2つの`IDatasetSyncHandler`とする。MyWord専用DAO、
data source、repository、dataset adapterはProvider化しない。

## 4. 公開composition API案

```dart
final class MyWordDependencies {
  const MyWordDependencies({
    required this.database,
    required this.outboxWriter,
  });

  final DatabaseProvider database;
  final IOutboxWriter outboxWriter;
}

final class MyWordSyncDependencies {
  const MyWordSyncDependencies({
    required this.database,
    required this.firestore,
    required this.remoteMutationExecutor,
  });

  final DatabaseProvider database;
  final FirebaseFirestore firestore;
  final IRemoteMutationExecutor remoteMutationExecutor;
}

MyWordPorts createMyWordPorts({
  required MyWordDependencies dependencies,
});

IDatasetSyncHandler createMyWordDatasetSyncHandler({
  required MyWordSyncDependencies dependencies,
  required ISyncHandlerRuntime runtime,
});

IDatasetSyncHandler createMyWordStatusDatasetSyncHandler({
  required MyWordSyncDependencies dependencies,
  required ISyncHandlerRuntime runtime,
});
```

`composition.dart`はtechnical seamであり、`my_word.dart`からre-exportしない。
既存の`MyWordPorts` contractは変更しない。

`MyWordPorts`はpureな`composition_contract.dart`へ分離し、`composition.dart`からexportする。
internal factoryは`composition.dart`をimportせず、このpure contractだけをimportする。
public Factoryはdependency bundleを展開してinternal factoryの明示的なnamed parameterへ渡す。
これによりpublic facadeとinternal factory間の循環importを作らない。

## 5. 実装フェーズ

### Phase 0: Characterizationと変更範囲の固定

目的は、DI配線だけを変更し、挙動変更を混入させないことである。

対象:

- `test/unit/features/my_word/port/composition_test.dart`
- 必要に応じて新規`test/unit/app/bootstrap/my_word_composition_test.dart`
- 既存MyWord sync handler test

固定する契約:

- `MyWordPorts.reader`、`commands`、`statusCommands`の共有関係が維持される
- `guestMigration`が同じdatabase／outbox writerで構築される
- MyWord handlerのdatasetが`SyncDataset.myWords`である
- MyWordStatus handlerのdatasetが対応する既存stable IDである
- 両handlerが渡された同一`ISyncHandlerRuntime`を使用する
- localは指定database、remoteは指定Firestore／mutation executorを使用する

このphaseではproduction APIを変更しない。

### Phase 1: 型付きdependency bundleの追加

変更対象:

- `lib/features/my_word/port/composition.dart`
- 新規`lib/features/my_word/port/composition_contract.dart`

作業:

1. `MyWordPorts`をpureな`composition_contract.dart`へ移す。
2. `composition.dart`から`composition_contract.dart`をexportする。
3. `MyWordDependencies`を追加する。
4. `MyWordSyncDependencies`を追加する。
5. Factoryをnamed parameter形式へ変更する。
6. Factory内でbundleを展開し、internal factoryへ明示的な引数として渡す。
7. 一時的に旧reader APIを併存させず、同一phase内で全consumerを更新する。

判断:

- dependency bundleはimmutableな`final class`とする。
- 通常graphとsync graphはlifetimeと利用者が異なるため、別bundleにする。
- `runtime`はSync所有の実行policyであり、MyWord sync dependency bundleへ混ぜず、
  Factoryの明示的な別引数として維持する。
- SDK／database型はtechnical composition seamだけに現れ、business facadeには公開しない。

削除候補:

- `MyWordDependency`
- `MyWordDependencyReader`
- `MyWordSyncDependency`
- MyWordからの`SyncDependencyQueryPort` import

### Phase 2: MyWord internal factoryをconstructor DIへ変更

変更対象:

- `lib/features/my_word/internal/composition/my_word_ports_factory.dart`
- `lib/features/my_word/internal/composition/my_word_sync_factory.dart`
- `lib/features/my_word/internal/infrastructure/my_word/firebase/my_word_sync_remote_factory.dart`
- `lib/features/my_word/internal/infrastructure/my_word_status/firebase/my_word_status_sync_remote_factory.dart`

作業:

1. `createInternalMyWordPorts`は`DatabaseProvider`と`IOutboxWriter`を
   required named parameterとして受け取る。
2. 2つのsync factoryは`DatabaseProvider`、`FirebaseFirestore`、
   `IRemoteMutationExecutor`、`ISyncHandlerRuntime`をrequired named parameterとして受け取る。
3. internal factoryは`port/composition.dart`ではなく、pureな
   `port/composition_contract.dart`だけをimportする。
4. remote factoryはgeneric readerではなく、`FirebaseFirestore`と
   `IRemoteMutationExecutor`を明示的に受け取る。
5. internal graph内に`Ref`、Provider、resolverを渡さない。

期待する内部コードの形:

```dart
final local = MyWordDriftDataSource(
  MyWordDao(database),
);
final remote = createInternalFirebaseMyWordRemoteDataSource(
  firestore: firestore,
  remoteMutationExecutor: remoteMutationExecutor,
);
final adapter = MyWordDatasetSyncAdapter(local: local, remote: remote);
return AdapterDatasetSyncHandler(adapter: adapter, runtime: runtime);
```

このphaseでrepository、use case、sync algorithmの実装は変更しない。

### Phase 3: App-owned MyWord Providerの構築

変更対象:

- `lib/app/bootstrap/my_word_composition.dart`
- 必要に応じて`lib/app/bootstrap/firebase_providers.dart`
- `lib/app/bootstrap/sync_infrastructure_providers.dart`はimport利用だけを確認する

追加／更新するProvider:

```dart
final myWordPortsProvider = Provider<MyWordPorts>(...);
final myWordDatasetSyncHandlerProvider =
    Provider<IDatasetSyncHandler>(...);
final myWordStatusDatasetSyncHandlerProvider =
    Provider<IDatasetSyncHandler>(...);
```

配線:

- `myWordPortsProvider`
  - `databaseProvider`
  - `driftOutboxWriterProvider`
- MyWord sync handler providers
  - `databaseProvider`
  - `firestoreDBProvider`
  - `remoteMutationExecutorProvider`
  - `syncHandlerRuntimeProvider`

すべてProvider body内で`ref.watch`を使う。依存Providerがoverride／refreshされた場合に、
completed capabilityも再構築される状態を保つ。

DAO、data source、repository、adapterの個別Providerは追加しない。

### Phase 4: Sync registryを完成済みProviderへ切り替える

変更対象:

- `lib/app/bootstrap/sync_composition.dart`

変更前:

```dart
my_word.createMyWordDatasetSyncHandler(
  _featureQueryPort(ref),
  runtime: runtime,
)
```

変更後:

```dart
ref.watch(myWordDatasetSyncHandlerProvider)
```

作業:

1. MyWordの2 handler生成をregistryから除去する。
2. `my_word_composition.dart`のcompleted Providerをwatchする。
3. `_readFeatureDependency`から`MyWordSyncDependency`の3分岐を削除する。
4. MyWord alias importが不要なら削除する。
5. WordStatusとUserProfileが移行前なら、`_featureQueryPort`と
   `SyncDependencyQueryPort`はそれらのために残す。

このphaseではhandlerのregistry順序と`DatasetPlan.localFirst`を変更しない。

### Phase 5: Testの型付きDI／Provider DIへの移行

変更対象:

- `test/unit/features/my_word/port/composition_test.dart`
- 新規`test/unit/app/bootstrap/my_word_composition_test.dart`
- 必要に応じてsync registry test

Factory test:

- `MyWordDependencies`を直接生成し、reader closureと`as T`を削除する。
- `MyWordSyncDependencies`を直接生成し、2 handlerのdatasetを確認する。
- missing key testは不要になる。required constructor parameterがcompile-timeに保証する。

Provider test:

- `ProviderContainer`でdatabase、Firestore、mutation executor、runtime、outboxをoverrideする。
- `myWordPortsProvider`と2 handler Providerをreadし、生成できることを確認する。
- completed Provider自体をfakeへoverrideできることをconsumer側testで確認する。
- containerを必ずdisposeし、in-memory databaseもtearDownでcloseする。

回帰test:

- MyWord application adapter／use case test
- MyWord／MyWordStatus dataset sync adapter test
- guest migration test
- sync engine／registry test

### Phase 6: Boundary checkerとarchitecture testの更新

変更対象:

- `tool/check_import_boundaries.dart`
- `test/tool/import_boundaries/check_import_boundaries_test.dart`
- 必要に応じて`test/tool/feature_dependencies/check_feature_dependencies_test.dart`

追加／調整する規則:

1. `app/bootstrap/**/*_composition.dart`のRiverpod importをpositive fixtureで許可する。
2. business port、domain、application、infrastructureからRiverpodを禁止する。
3. featureから`lib/app/**`へのimportを禁止する。
4. app compositionからMyWord internalへの直接importを禁止する。
5. MyWord `port/composition.dart`から許可するsame-feature bridgeを
   `internal/composition/my_word_*_factory.dart`に限定する。
6. `T Function<T>(Object ...)`型のopaque resolverがMyWord compositionへ再導入されないよう検査する。
7. `port/composition.dart`がbusiness facadeからexportされていないことを維持する。
8. MyWord `port/composition.dart`では`DatabaseProvider`、`FirebaseFirestore`、
   `IOutboxWriter`、`IRemoteMutationExecutor`、`ISyncHandlerRuntime`等、Factory入力に必要な
   technical typeだけをcontrolled importとして許可する。
9. `composition_no_provider_types`相当の検査は`DatabaseProvider`をRiverpod Providerと
   誤認しないよう修正し、`Provider`、`Ref`、`Override`、`ProviderContainer`、
   `ProviderListenable`を禁止対象として維持する。
10. Firebase canonical-source規則にはMyWord compositionの型参照だけを限定例外として追加し、
    Firebase API呼び出しは引き続き`internal/infrastructure/**/firebase/**`だけに置く。

既存の`composition_no_framework`は、business portのframework禁止とfeature compositionの
controlled technical importを区別できる規則へ変更する。Riverpod許可対象はapp compositionであり、
feature compositionへ`Ref`やProvider型を導入する変更ではない。

### Phase 7: 旧DI APIの完全削除と文書同期

参照確認:

```powershell
rg -n "MyWordDependencyReader|MyWordDependency|MyWordSyncDependency" lib test tool
rg -n "SyncDependencyQueryPort" lib/features/my_word test/unit/features/my_word
rg -n "features/my_word/internal" lib/app lib/integration
```

完了時には上記のMyWord旧API参照が0であることを確認する。

文書:

- `docs/architecture/composition-rule.md`
- `docs/architecture/feature-design-rules.md`のComposition節から新ルールへリンクする
- 必要ならMyWord public surface／remaining-workの完了状態を更新する

他featureに残るresolverはこのphaseで削除せず、別の追跡項目として記録する。

## 6. 推奨コミット単位

各コミットはbuild可能な状態を維持する。

1. `docs: define Riverpod composition and DI rules`
2. `refactor(my-word): replace opaque readers with typed dependencies`
3. `refactor(bootstrap): provide completed MyWord capabilities`
4. `refactor(sync): register composed MyWord handlers`
5. `test: cover typed MyWord factories and Riverpod composition`
6. `tool: enforce composition dependency direction`

Phase 1とPhase 2で一時的にcompile不能になる場合は同一コミットにまとめる。

## 7. 検証順序

Flutter／Dart commandはリポジトリのAGENTS.mdに従い、直接sandbox外で実行する。

1. Format

   ```powershell
   dart format lib/app/bootstrap/my_word_composition.dart `
     lib/app/bootstrap/sync_composition.dart `
     lib/features/my_word/port/composition.dart `
     lib/features/my_word/internal/composition `
     lib/features/my_word/internal/infrastructure/my_word/firebase/my_word_sync_remote_factory.dart `
     lib/features/my_word/internal/infrastructure/my_word_status/firebase/my_word_status_sync_remote_factory.dart `
     test/unit/features/my_word/port/composition_test.dart `
     test/unit/app/bootstrap/my_word_composition_test.dart
   ```

2. Focused tests

   ```powershell
   flutter test test/unit/features/my_word/port/composition_test.dart
   flutter test test/unit/app/bootstrap/my_word_composition_test.dart
   flutter test test/unit/features/my_word
   flutter test test/unit/features/sync
   ```

3. Boundary tests

   ```powershell
   flutter test test/tool/import_boundaries/check_import_boundaries_test.dart
   flutter test test/tool/feature_dependencies/check_feature_dependencies_test.dart
   dart run tool/check_import_boundaries.dart
   ```

4. Analyze

   ```powershell
   dart analyze lib/app/bootstrap `
     lib/features/my_word `
     test/unit/app/bootstrap `
     test/unit/features/my_word
   ```

5. Full regression

   ```powershell
   flutter test
   ```

`test/unit/app/bootstrap/my_word_composition_test.dart`を追加しなかった場合は、検証commandから
除外する。

## 8. 完了条件

- [ ] `MyWordDependencyReader`が削除されている
- [ ] `MyWordDependency`が削除されている
- [ ] `MyWordSyncDependency`が削除されている
- [ ] MyWord production／testコードにgeneric dependency lookupと`as T`がない
- [ ] `createMyWordPorts`が型付きdependenciesを受け取る
- [ ] MyWordの2 sync factoryが型付きdependenciesを受け取る
- [ ] `MyWordPorts`がpureな`composition_contract.dart`にあり、internal factoryとの循環importがない
- [ ] `myWordPortsProvider`がapp-owned dependencyを`ref.watch`する
- [ ] MyWordの2 completed handler Providerが`my_word_composition.dart`にある
- [ ] sync registryがcompleted handler Providerをwatchするだけになっている
- [ ] app／integrationから`features/my_word/internal/**`へのimportが0
- [ ] MyWord internalから`lib/app/**`とRiverpodへのimportが0
- [ ] schema、wire format、dataset stable ID、sync順序に差分がない
- [ ] focused test、boundary test、targeted analyze、full testがgreen
- [ ] composition ruleと実装が一致している

## 9. リスクと対策

### Technical typeがcomposition seamへ現れる

`DatabaseProvider`や`FirebaseFirestore`はbusiness APIには不適切だが、ここでは
technical composition seamの入力である。`my_word.dart`からexportせず、利用場所をcheckerで
app compositionへ限定する。

### Provider再構築でinstanceが変わる

`ref.watch`したdependencyがrefreshされればcompleted capabilityも再生成される。これは期待する
挙動だが、disposeが必要な実装を追加する場合はProviderで`ref.onDispose`を登録する。

### 他featureのresolverと移行が混ざる

WordStatus、UserProfile、Sync coreのresolver廃止は対象外とする。MyWord分岐だけを外し、共通APIの
削除は最後の利用featureを移行する別計画で行う。

### Dirty worktreeとの競合

MyWordには進行中の変更があるため、実装開始前に対象ファイルの最新差分を再確認する。
既存変更をrevertせず、composition DIに必要な最小差分だけを重ねる。

## 10. 対象外

- MyWord／MyWordStatusのaggregate分割
- sync retry、queue、checkpoint policyの変更
- dataset順序の変更
- DB schema migration
- Firestore collection／field名の変更
- outbox payload／field maskの変更
- Riverpod code generation導入
- 全featureのopaque resolver一括廃止
- DAO、data source、repositoryの全面Provider化
