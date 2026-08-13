# CompositionとDIの設計ルール

## 1. 目的

この文書は、RiverpodをDIコンテナとして使用しながら、`app`、`feature`、
`integration`の依存方向を一方向に保つための規則を定める。

Compositionの目的は、業務ロジックを実装することではなく、次を一箇所で決定することである。

- concrete implementationの選択
- object graphの組み立て
- instanceの共有範囲と破棄タイミング
- environmentやtestによる差し替え
- feature間adapterの接続

Riverpodはこのうち、app runtime上のobject graph、lifetime、overrideを管理する。
domainやapplication serviceがRiverpodを使って依存を探索することはDIではなく
service locatorになるため禁止する。

## 2. 用語

- **composition root**: 実装の選択と最終的なobject graphを所有する最外周の場所
- **app composition**: `lib/app/bootstrap/**/*_composition.dart`に置くRiverpodベースの配線
- **feature composition seam**: `lib/features/<feature>/port/composition.dart`に置く、
  featureの完成品を生成するための型付きFactory API
- **internal factory**: feature自身のDAO、data source、repository、adapter等を組み立てる実装
- **completed capability**: app workflowがそのまま利用できるport bundle、handler、runner等
- **runtime dependency**: database、SDK client、clock、session fence等、appが実体とlifetimeを所有する依存

## 3. 基本方針

### 3.1 Riverpodを使う場所

Riverpodは次のtechnical wiringで使用してよい。

- `lib/app/bootstrap/**`
- `lib/integration/**/*_providers.dart`
- presentation専用のprovider wiring

特に、app全体のDI composition rootは`lib/app/bootstrap/**/*_composition.dart`とする。
ここではProviderの宣言、`ref.watch`による依存の合成、完成品Providerのregistry登録を行ってよい。

Riverpodを次へ持ち込んではならない。

- featureのdomain
- featureのapplication service／use case
- repository、DAO、data source、同期adapter本体
- business port、Query、Command、Result
- pure integration adapter本体

### 3.2 依存方向

許可する依存方向は次のとおりである。

```text
app/bootstrap
  ├─> feature/port/composition.dart
  ├─> feature/port/<feature>.dart
  ├─> integration provider
  └─> shared runtime provider

feature/port/composition.dart
  └─> same feature internal factory

same feature internal factory
  ├─> same feature internal implementation
  └─> required technical contracts
```

次は禁止する。

```text
feature/internal  ─X─> app/bootstrap
feature/port      ─X─> app/bootstrap
feature A         ─X─> feature B/internal
app/bootstrap     ─X─> feature/internal
business code     ─X─> Riverpod Provider
```
<!-- 将来的には feature A   ─X─> feature B -->

`app -> feature`は外側から内側への正しい依存だが、appがfeature internalを直接組み立てると
featureの内部構造がappへ漏れる。appは原則としてfeature composition seamだけを呼び、
DAOやdata sourceの構築順序はfeature internal factoryへ任せる。

## 4. App compositionとfeature factoryの責務

### 4.1 App compositionが所有するもの

app compositionは次を所有する。

- Riverpod Providerの宣言
- app-owned Providerからruntime dependencyを取得すること
- feature factoryへ依存を明示的に渡すこと
- completed capabilityのlifetime
- completed capabilityをregistryやworkflowへ登録すること
- test、flavor、environment用override point

例:

```dart
final myWordDatasetSyncHandlerProvider =
    Provider<IDatasetSyncHandler>((ref) {
  return my_word.createMyWordDatasetSyncHandler(
    dependencies: MyWordSyncDependencies(
      database: ref.watch(databaseProvider),
      firestore: ref.watch(firestoreDBProvider),
      remoteMutationExecutor:
          ref.watch(remoteMutationExecutorProvider),
    ),
    runtime: ref.watch(syncHandlerRuntimeProvider),
  );
});
```

Providerは宣言時に生成済みになるわけではない。Riverpodは原則lazyであり、上位Providerから
最初にwatchされた時点でobject graphを生成する。「bootstrapで準備する」とは、Providerを
登録し、依存経路を確定させることを意味する。

### 4.2 Feature composition seamが所有するもの

feature composition seamは次を所有する。

- featureが必要とする依存を表すimmutableな型付きdependency bundle
- feature外へ返すcompleted capabilityの型
- internal factoryへ委譲する公開Factory

feature composition seamはRiverpodの`Ref`、Provider名、`ProviderContainer`を受け取らない。
依存は名前付き引数または型付きdependency bundleで明示する。

```dart
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

IDatasetSyncHandler createMyWordDatasetSyncHandler({
  required MyWordSyncDependencies dependencies,
  required ISyncHandlerRuntime runtime,
}) => createInternalMyWordDatasetSyncHandler(
      database: dependencies.database,
      firestore: dependencies.firestore,
      remoteMutationExecutor: dependencies.remoteMutationExecutor,
      runtime: runtime,
    );
```

`port/composition.dart`はbusiness facadeではなくtechnical seamである。そのためFactoryに
必要なtechnical contractを型として表してよい。ただしbusiness facadeからre-exportしては
ならず、利用者はapp compositionと許可されたtechnical testに限定する。

databaseやSDK clientのconcrete typeをdependency bundleで使う場合は、
`port/composition.dart`に限ってcontrolled technical importとして許可する。許可は
Factory入力に必要な型へ限定し、SDK操作、Provider宣言、業務処理を置いてはならない。
checkerでは全framework importを一括許可せず、対象composition seamとpackageを明示する。

### 4.3 Internal factoryが所有するもの

internal factoryはfeature内部のobject graphを所有する。

- DAO
- local／remote data source
- repository
- use case／application adapter
- dataset adapter
- feature-owned mapper

internal factoryは受け取った依存をコンストラクターで各実装へ渡す。Riverpod、app Provider、
opaque resolverを内部オブジェクトへ渡してはならない。

## 5. Providerの粒度

Provider化する基準は、次のいずれかである。

- app全体または複数featureで共有する
- lifecycle／disposeをRiverpodに管理させる
- reactiveに差し替わる依存をwatchする
- testやenvironmentで独立して差し替える必要がある
- app workflowが利用するcompleted capabilityである

通常、次はProviderにする。

- database、SDK client、session fence等のshared runtime
- featureのport bundle
- `IDatasetSyncHandler`、`ISyncRunner`等のcompleted capability

通常、次は個別Providerにしない。

- feature専用DAO
- feature専用data source
- repository implementation
- mapper
- completed capabilityの内部だけで使うadapter

これらはinternal factory内で通常のconstructor DIにより生成する。個別にlifetimeやoverride pointが
必要になった場合だけProviderへの昇格を検討し、その理由を記録する。

## 6. 依存の明示性と型安全性

次のopaque dependency resolverは禁止する。

```dart
typedef DependencyReader = T Function<T>(Object key);

final database = read<DatabaseProvider>(Dependency.database);
```

この形式はkeyと`T`の組み合わせをコンパイラが保証できず、依存一覧もFactory signatureから
読み取れない。実行時castに依存するため、新規実装では使用しない。既存実装はfeature単位で
型付きdependency bundleへ移行する。

dependency bundleは次を満たすこと。

- `final class`かつimmutable
- required named parameterを使う
- optional dependencyには明確なabsence semanticsを持たせる
- `Object`、`dynamic`、generic lookupを使わない
- Providerや`Ref`をfieldに保持しない
- 同一lifetime／同一生成物に必要な依存だけをまとめる

## 7. `ref.watch`、`ref.read`、eager initialization

Providerから別Providerを合成するときは原則として`ref.watch`を使う。依存がoverride、refresh、
または再生成された場合、完成品も正しく再構築されるためである。

`ref.read`は次に限定する。

- user actionやcallback実行時の一回限りの取得
- Providerの再構築を意図的に不要とすることを説明できる場合

Providerは原則lazy initializationとする。起動完了前に初期化が必要なサービスだけ、
`ProviderScope`直下のreadiness gate等から明示的にwatch／awaitする。単に「事前生成したい」
という理由で全Providerをeager化しない。

## 8. Overrideの用途

overrideは次の用途に限定する。

- unit／widget／integration testのfake
- flavorやenvironmentごとの実装差し替え
- widget subtreeに閉じたscoped value
- bootstrap以前に非同期取得した値の注入

通常のproduction object graphを、未実装Providerとroot overrideの組み合わせだけで構成しては
ならない。override漏れが実行時failureになり、依存関係がProviderScopeまで分散するためである。

testでは最小の有効単位をoverrideする。

- feature内部の構築も検証するtest: databaseやSDK clientをoverrideする
- consumerだけを検証するtest: completed capability Providerをfakeへoverrideする

## 9. Sync compositionへの適用

Syncは次の責務分担を維持する。

```text
ISyncHandlerRuntime
  └─ queue、retry、checkpoint、cancellation等の共通policy

IDatasetSyncAdapter
  └─ feature固有のpush、pull、ack、remote apply

IDatasetSyncHandler
  └─ runtimeとadapterを接続したcompleted capability
```

app compositionはshared runtimeとfeature factoryを接続し、完成済みhandler Providerを
registryへ登録する。registry内でDAO、data source、adapterを組み立ててはならない。

## 10. ファイル配置

推奨配置は次のとおりである。

```text
lib/app/bootstrap/
├─ my_word_composition.dart       # MyWord completed Provider
├─ sync_composition.dart          # handler registryとrunner
└─ sync_infrastructure_providers.dart

lib/features/my_word/
├─ port/
│  ├─ my_word.dart                # business facade
│  ├─ composition_contract.dart   # pureなcompleted capability bundle
│  └─ composition.dart            # typed dependenciesとFactory
└─ internal/
   └─ composition/
      ├─ my_word_ports_factory.dart
      └─ my_word_sync_factory.dart
```

`app/bootstrap/my_word_composition.dart`はMyWordの全completed Providerを所有する。
`sync_composition.dart`はそれらをwatchしてregistryへ並べるだけにする。

## 11. 自動検査

CIのimport boundary checkerで最低限次を検査する。

- featureのdomain／application／infrastructureからRiverpod importが0
- business portからFlutter、Riverpod、SDK importが0
- feature compositionのtechnical importが明示されたdatabase／SDK型だけである
- feature compositionに`Ref`、Provider、Override、ProviderContainer型がない
- featureから`lib/app/**`へのimportが0
- appからfeature internalへの直接importが0
- feature外から`port/composition.dart`をimportできる場所がapp compositionと許可testに限定される
- `port/composition.dart`から同一feature internal factory以外へのinternal bridgeが0
- opaque dependency resolverの新規追加が0
- app compositionからRiverpodを使うpositive fixtureが通る
- feature internalからapp Providerを読むnegative fixtureが失敗する

## 12. Review checklist

### Dependency direction

- [ ] featureからappをimportしていない
- [ ] appはfeature internalではなくcomposition seamを呼んでいる
- [ ] business codeがProviderを読んでいない
- [ ] cross-feature接続は公開portまたはintegration adapter越しである

### DI API

- [ ] Factory signatureだけで必要な依存を列挙できる
- [ ] generic lookup、`Object` key、`as T`がない
- [ ] dependency bundleがimmutableである
- [ ] internal objectへ`Ref`やProviderを渡していない

### Provider design

- [ ] Providerはshared runtimeまたはcompleted capabilityを表す
- [ ] DAO／data sourceをProvider化する明確なlifecycle・override理由がある
- [ ] Provider合成では原則`ref.watch`を使っている
- [ ] production配線をroot overrideへ過度に分散していない

### Tests and lifecycle

- [ ] Factory testで内部graphの最低限の契約を確認している
- [ ] Provider testでoverrideと再構築を確認している
- [ ] disposeが必要なobjectのownerが明確である
- [ ] lazy／eager initializationの選択理由が明確である

## 13. 例外

この規則から外れる場合は、対象path、理由、owner、終了条件をADRまたは追跡文書へ記録する。
「Providerにすると便利」「既存コードがそうなっている」だけでは例外理由にならない。
