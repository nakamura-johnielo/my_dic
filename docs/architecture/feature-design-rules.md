# Feature設計ルール

この文書は、`lib/features/**` を独立した論理moduleとして設計・改修する際の
共通規範である。Catalogで採用した境界設計を一般化し、新規feature、既存feature
のリファクタ、feature間連携のレビューに適用する。

個別featureのADRに、この文書より具体的な決定がある場合は個別ADRを優先する。
例外は暗黙に作らず、理由、対象path、終了条件をADRまたは追跡文書に記録する。

## 1. 目的

この設計が守るものは、directoryの見た目ではなく次の性質である。

- featureの業務用語、identity、invariant、変更理由にownerがいる
- consumerはownerが公開したcontractだけに依存する
- DB、SDK、framework、他featureの都合をfeatureの業務contractへ漏らさない
- feature間の変換とruntime wiringを業務policyから分離する
- 境界をcode reviewだけでなく自動検査とcontract testで維持する

## 2. 規範用語

- **MUST**: 原則として必須。違反には明示的な例外決定が必要
- **MUST NOT**: 原則として禁止
- **SHOULD**: 通常採用する。採用しない理由を説明できなければならない
- **MAY**: 状況に応じて選択可能
- **owner feature**: 用語、identity、invariant、公開contract、永続化mappingの変更責任を持つfeature
- **consumer feature**: owner featureの能力を利用し、自身のuse caseや表示policyを実現するfeature
- **provided port**: owner featureが外部へ提供する能力
- **required port**: consumer featureが外部へ要求する能力
- **integration adapter**: provided portとrequired portのcontractを変換して接続するadapter

## 3. Ownershipを先に決める

ファイル移動やinterface設計より先に、対象概念のownerを決定する。現在のtable配置、
既存import、同じ画面で表示されることだけをownershipの根拠にしてはならない。

ownerは次の観点で判断する。

1. source of truthはどこか
2. identityを誰が定義するか
3. invariantとvalidationを誰が変更するか
4. create、update、deleteのlifecycleは何に従属するか
5. persistence、transaction、syncの変更理由は何と一致するか
6. consumerやUIから独立した変更理由を持つか

一つのread queryが複数ownerの情報を必要とする場合でも、write ownershipを統合しては
ならない。consumer、application workflow、またはread projectionが公開contract越しに
合成する。

### Ownership matrixを残す

featureのリファクタ計画またはADRには、最低限次を記録する。

| Owner | Owns | Does not own |
|---|---|---|
| owner feature | 正本、identity、invariant、提供能力 | consumer固有policy、他ownerの状態 |
| consumer feature | query解釈、use case、warning、表示policy | providerの永続化と内部model |
| `lib/integration` | contract間の値・error変換 | domain truth、pagingや表示policy |
| `app/bootstrap` | runtimeとlifetimeの組み立て | featureの業務semantics |

## 4. Featureの基本構造

feature直下は原則として`port`と`internal`に分ける。

```text
lib/features/<feature>/
├─ port/
│  ├─ <feature>.dart
│  ├─ reader/
│  ├─ command/
│  ├─ query/
│  ├─ result/
│  ├─ model/
│  ├─ error/
│  ├─ composition.dart
│  └─ presentation_dependencies.dart
└─ internal/
   ├─ application/
   ├─ domain/
   ├─ infrastructure/
   ├─ presentation/
   └─ composition/
```

すべてのdirectoryを機械的に作る必要はない。必要な責務だけを作る。ただし、外部へ公開するcontractと内部実装の境界は曖昧にしない。

## 5. 公開surface

### 5.1 唯一のbusiness facade

feature外のbusiness codeは、原則として次のfacadeだけをimportする。

```dart
import 'package:my_dic/features/<feature>/port/<feature>.dart';
```

facadeは外部利用を意図した型だけを明示的にre-exportする。公開value object、identity、
Query、Command、Result、Event、ReaderPort、Gateway、errorは、外部利用前にfacadeへ
追加しなければならない。

次は禁止する。

- feature外から`internal/**`をimportする
- feature外から`port/**`の定義ファイルをdeep importする
- facadeからinternal実装、DAO、repository実装、SDK型をexportする
- 一時的な便利さのために巨大なcatch-all barrelを作る
- internal entityを公開DTOとしてそのまま使う

### 5.2 技術的seam

RiverpodやFlutterを使う既存featureでは、必要に応じて次をbusiness facadeから分離する。

- `port/composition.dart`: application composition専用
- `port/presentation_dependencies.dart`: presentation wiring専用
- `port/presentation_entry.dart`: 制御されたFlutter entry専用

これらはbusiness APIではない。利用場所をcheckerで限定し、business facadeから
re-exportしない。ReaderPort、Query、Command、Result、model、errorはSHOULDとして
pure Dartを維持する。

framework-free compositionへの移行は望ましいが、既存runtimeとの接続を理由にscopeが
過大になる場合は別phaseにできる。その場合もframework依存を技術的seam以外へ拡散
させてはならない。

## 6. Port設計

### 6.1 Provided portはproviderの語彙で定義する

owner featureのprovided portは、そのfeatureが提供する安定した業務能力を表す。
consumer名や画面名をcontractへ含めてはならない。

```dart
// Good: providerの能力
abstract interface class ArticleSummaryReaderPort {}

// Bad: consumerのuse caseをproviderが所有している
abstract interface class QuizArticleCandidateReaderPort {}
```

providerがconsumerの型をimportしていなくても、consumer固有名、consumer固有paging、
warning、表示都合を持てば意味上の逆依存である。

### 6.2 Required portはconsumerが所有する

consumer featureは、自身のuse caseに必要なcontractを自身の`port`に定義する。

```dart
abstract interface class SearchArticleGateway {
  Future<Result<SearchArticlePage>> search(SearchArticleQuery query);
}
```

required portのQuery、Result、errorはconsumerが所有する。providerのinternal DTOや
永続化modelをrequired portへ流用してはならない。

providerが所有するstable identity valueだけは、意味とserializationの正本を一つに
保つため共有してよい。共有を認めるidentityは個別ADRまたはpublic surface manifestへ
明記する。

### 6.3 Interface segregation

一つの巨大なportへ無関係なoperationを集めない。次のいずれかが異なる場合はportまたは
operationを分ける。

- 変更理由
- 権限
- failureの単位
- consistency要件
- consumer
- performance特性

複数の細粒度portを一つのapplication scopeから提供する場合は、composition専用bundleへ
まとめてよい。

```dart
final class FeatureReadPorts {
  const FeatureReadPorts({
    required this.detail,
    required this.search,
    required this.summary,
  });

  final DetailReaderPort detail;
  final SearchReaderPort search;
  final SummaryReaderPort summary;
}
```

### 6.4 ReaderPortはread-only Query Serviceとする

`ReaderPort`はrepositoryの公開aliasではなく、外部consumer向けのread-only application
Query Serviceとする。

- 入力はowner featureのQuery DTO
- 出力はowner featureのResult DTO
- infrastructure rowやdomain entityを返さない
- write operationを持たない
- infrastructure例外を直接投げない
- ownerが保証する検索・集約semanticsだけを持つ

write use caseは`CommandPort`等として明示的に分離する。公開repositoryは、その抽象が
本当に外部contractである場合を除きSHOULD NOTとする。

## 7. Result、validation、error

### 7.1 Resultを境界で使う

非同期portは原則として`Result<T>`を返し、DB、network、SDKの例外をfeature境界から
漏らさない。owner featureは実装境界でinfrastructure errorをowner所有のerrorへ正規化
する。

consumer required portも`Result<T>`を返し、integration adapterがprovider errorを
consumer errorへ変換する。consumer internalはprovider固有errorを知らない。

### 7.2 Validationと実行時failureを分ける

QueryまたはCommand DTOが単独で保証できる不変条件は生成時に検証する。

- pageやsizeの範囲
- 空文字
- IDの形式
- 相互排他的なoption

programming errorに相当する不正なDTO生成は`ArgumentError`等でfail-fastしてよい。
I/O、not found、data corruptionなど実行時の状態は`Result.failure`で表す。

### 7.3 absenceを仕様化する

次を曖昧にしない。

- 単一aggregateが存在しない: typed not-found failure
- optional capabilityがない: `success(null)`または明示的variant
- collectionが0件: empty success
- batchの一部だけ存在しない: missing keyまたはitem-level result
- 部分失敗を許容するenrichment: failure単位ごとにoperationを分ける

## 8. 公開DTOと変換

公開DTOは業務上の意味を持つ型で表現し、保存・通信・表示形式を漏らさない。

公開してはならない代表例:

- Drift generated row
- SQL column名
- Firestore document snapshot
- HTML断片
- JSON map
- wire keyだけを意味として使う`String`
- providerやwidget state

enum、sealed type、value objectにできる値は型付けする。wire valueが必要な場合、ownerが
変換を所有し、consumerへwire文字列の解釈を要求しない。

HTMLからplain textや業務値を抽出する処理、DB sentinelをoptional valueへ変換する処理、
複数sourceの優先順位はowner featureのinternal mapperまたはQuery Serviceに置く。

## 9. Cross-feature integration

cross-feature adapterは`lib/integration/**`に置く。

```text
lib/integration/<provider>_<consumer>/
├─ <provider>_backed_<consumer>_gateway.dart
└─ <provider>_<consumer>_providers.dart
```

adapter本体とframework wiringはSHOULDとして分離する。

- adapter本体: feature facade、pure DTO、Result変換だけをimport
- provider file: Riverpodとapp-owned providerを使って組み立てる

`lib/integration`が担当してよいもの:

- provider DTOからconsumer DTOへの値変換
- provider errorからconsumer errorへの変換
- 複数の公開portの単純な呼び出しと結果の受け渡し

担当してはならないもの:

- paging policy
- warningやpartial-failure policy
- filtering、候補選定、業務validation
- HTMLやwire formatの解釈
- DAO、SQL、transaction、SDK操作
- feature domain truth

cross-feature integrationと外部system adapterを混同しない。Drift、Firebase、REST、file等の
provided port実装は、owner featureの`internal/infrastructure/**`に置く。

## 10. Composition

`app/bootstrap`はruntime instance、lifetime、override、feature間adapterを組み立てる。
featureのinternal factoryは自身のinfrastructure graphを組み立てる。
型付きdependency bundle、completed capability Provider、Riverpodの配置に関する詳細は
[CompositionとDIの設計ルール](./composition-rule.md)に従う。

```text
app/bootstrap
  -> feature port composition seam
  -> feature internal factory
  -> feature internal infrastructure
```

appからfeature internalを直接importしてはならない。feature internalからappをimportしては
ならない。

既存のopaque dependency resolverを使う場合は、composition factoryに閉じ込め、domain、
application service、ReaderPort実装へ渡さない。resolverの改善はfeature移行とは別phaseに
してよいが、service locatorを業務コードへ拡散させない。

## 11. Paging、部分失敗、複数source

### Paging

データsource上に次のrowが存在するかという事実はproviderが返す。UIの「もっと見る」や
自動load等のpolicyはconsumerが所有する。

offset pagingで`hasMore`が必要なら、providerは原則として`size + 1`件を取得し、公開itemsを
`size`件へ切り詰める。`items.length == size`だけで次pageの存在を推測しない。

### 部分失敗

一部のenrichmentが失敗しても基本結果を返す必要がある場合、failure単位を保てるport設計
にする。一つの巨大なsummary callにまとめ、どれか一つの失敗ですべてを失わせない。

warningへ変換するか、画面全体をfailureにするかはconsumerが決める。providerは事実と
typed failureを返す。

### 複数source

同じ業務値を複数sourceから得る場合、優先順位、fallback、重複解消、代表値の選択規則を
owner featureの仕様として文書化し、contract testで固定する。偶然のID順や現在のrow順に
依存してはならない。

## 12. Infrastructure安全規則

- SQLへユーザー入力を文字列展開してはならない。bind variableを使う
- LIKE検索で`%`、`_`、escape文字をliteral扱いするかwildcard扱いするかを仕様化する
- transaction境界はowner infrastructureまたはapplication serviceが所有する
- debug用の二重queryやproduction console logを残さない
- nullable DB columnを公開DTOの不正なsentinel値へ変換しない
- schema、wire、route、sync protocolの変更は構造リファクタと分離する

## 13. Presentationとrouting

- feature presentationは他featureのinternal widgetやproviderをimportしない
- source featureはdestination routeをimportせず、pure callbackでnavigation intentを渡す
- app routerがcallback payloadをdestination route contractへ変換する
- route identityはownerのstable identity valueを使う
- ephemeral display hintをidentityや取得成功条件に混ぜない

Flutter entryを公開する場合は`port/presentation_entry.dart`へ限定し、入力、callback、依存を
明示する。internal providerやview modelをbarrel exportしてはならない。

## 14. テスト戦略

### Port contract test

- Query/Command validation
- Resultとtyped error
- not found、optional、empty、partial missing
- value objectの範囲とserialization
- paging境界

### Internal contract test

- in-memory DBによるReaderPort contract
- mapperと複数sourceの優先順位
- bind parameterと特殊文字
- infrastructure errorの正規化
- transactionとordering

### Integration adapter test

frameworkなしでpure adapterをテストする。

- provider DTOからconsumer DTOへの変換
- provider errorからconsumer errorへの変換
- stable identityの保持
- partial failureとpaging情報の保持

### Smoke／acceptance test

- 実asset、emulator、real schemaを使う少数のsmoke test
- public portからpresentationまでを通すacceptance test
- import boundary checkerのfixture test

same-feature white-box testだけが同じfeatureのinternalをimportしてよい。cross-feature testは
各featureのpublic facadeとintegration adapterだけを使う。

## 15. 段階的リファクタ手順

構造変更はビルド可能な縦スライスで進める。

1. ownership matrixと変えてはいけない挙動を決める
2. characterization testで現在の正しい挙動を固定する
3. 新しいprovided／required portとDTOを追加する
4. owner internal adapterを実装する
5. `lib/integration` adapterを実装する
6. consumerを一つずつ新contractへ切り替える
7. compositionとpresentation wiringを切り替える
8. 全参照が0になった旧port、shim、consumer固有internal実装を削除する
9. facade、checker、ADR、public surface manifestを更新する
10. focused test、analyze、boundary check、full testを順に実行する

legacy APIは移行中だけ併存してよい。最終状態にre-export shim、typedef alias、重複modelを
残さない。削除は`rg`等でproductionとtestの参照が0であることを確認してから行う。

## 16. 自動検査

最低限、次をCIで検査する。

- feature外から`internal/**`へのimportが0
- feature外から個別`port/**`へのdeep importが0
- feature直下が許可された構造だけである
- `lib/integration/**`からfeature internal、DAO、SDK infrastructureへのimportが0
- coreからfeatureへのimportが0
- featureからappへのimportが0
- business portからFlutter、Riverpod、Drift、Firebase、GoRouterへのimportが0
  - 明示されたtechnical seamだけを限定例外にする
- app routingからfeature internalへのimportが0

baselineは新しい違反を正当化する仕組みとして使わない。既存debtを記録する場合はowner、
導入日、追跡先、削除条件を持たせ、新規違反を追加しない。

## 17. Review checklist

### Ownership

- [ ] 新しい型とoperationのownerを説明できる
- [ ] table配置や既存importだけでownerを決めていない
- [ ] consumer固有policyがproviderへ逆流していない

### Public contract

- [ ] 外部importは`port/<feature>.dart`に限定されている
- [ ] 公開型がfacadeへ明示的に追加されている
- [ ] internal entity、HTML、wire key、SDK型が漏れていない
- [ ] Query validation、absence、failureが仕様化されている

### Integration

- [ ] consumerがrequired portを所有している
- [ ] adapterは`lib/integration`にある
- [ ] adapter本体とframework wiringが分離されている
- [ ] adapterにpaging、warning、filtering等のpolicyがない

### Implementation

- [ ] DB／SDK実装はowner internal infrastructureにある
- [ ] SQL入力はbindされている
- [ ] 複数sourceの優先順位が明示されている
- [ ] errorがowner境界で正規化されている

### Migration

- [ ] characterization testが先にある
- [ ] consumerを縦スライスで切り替えている
- [ ] 最終状態にlegacy shimが残っていない
- [ ] checker、manifest、ADRが実装と一致している

## 18. Catalogへの適用例

Catalogはこの規則の基準実装である。

- sole facade: `features/catalog/port/catalog.dart`
- provided ports: focused read-only Query Services
- shared identity: `CatalogWordRef`
- consumer required ports: `SearchCatalogGateway`、`QuizCatalogGateway`
- adapters: `lib/integration/catalog_search`、`lib/integration/catalog_quiz`
- provider infrastructure: `features/catalog/internal/infrastructure/drift`
- Catalog-owned facts: 語義、活用、frequency、ranking metadata
- consumer-owned policy: Search/Quizのpaging表示、warning、候補選定

Catalog固有の詳細は[ADR 0002](./decisions/0002-catalog-read-ownership.md)と
[Catalog public surface](../refactor-v0.3/public-surface.md)を参照する。
